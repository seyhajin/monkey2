
Namespace mx2

Global Builder:BuilderInstance

Class BuildOpts

	Field mainSource:String
	
	Field productType:String	'"app" or "module"
	
	Field toolchain:String		'"msvc" or "gcc"
	
	Field target:String
	
	Field config:String
	
	Field threads:Bool
	
	Field clean:Bool
	
	Field product:String

	Field appType:String
	
	Field arch:String
	
	Field verbose:Int
	
	Field fast:Bool

	Field passes:Int	'1=parse, 2=semant, 3=translate, 4=build, 5=run
	
	Field geninfo:Bool
	
	Field wholeArchive:Bool
	
	Field makedocs:bool
	
End

Class BuilderInstance

	Field errors:=New Stack<ErrorEx>

	Field opts:BuildOpts
	
	Field product:BuildProduct
	
	Field profileName:String
	
	Field ppsyms:=New StringMap<String>

	Field mainModule:Module
	
	Field parsingModule:Module
	
	Field modules:=New Stack<Module>
	
	Field modulesMap:=New StringMap<Module>
	
	Field rootNamespace:NamespaceScope
	
	Field monkeyNamespace:NamespaceScope
	
	Field semantingModule:Module
	
	Field semantStmts:=New Stack<FuncValue>
	
	Field semantMembers:=New List<ClassType>
	
	Field imported:=New StringMap<Bool>
	
	Field currentDir:String
	
	Field MX2_SRCS:=New StringStack

	Field MX2_LIBS:=New StringStack
	
	Method New( opts:BuildOpts )
	
		Self.opts=opts
		
		Builder=self
		
		ppsyms["__HOST__"]="~q"+HostOS+"~q"
		ppsyms["__HOSTOS__"]="~q"+HostOS+"~q"
		ppsyms["__TARGET__"]="~q"+opts.target+"~q"
		ppsyms["__CONFIG__"]="~q"+opts.config+"~q"
		ppsyms["__ARCH__"]="~q"+opts.arch+"~q"
		ppsyms["__COMPILER__"]="~q"+opts.toolchain+"~q" '//new! maybe '__TOOL_CHAIN__' ? = 'msvc' or 'gcc'
		
		Select opts.target
		Case "windows","macos","linux","raspbian"
			
			ppsyms["__DESKTOP_TARGET__"]="true"
			ppsyms["__MOBILE_TARGET__"]="false"
			ppsyms["__WEB_TARGET__"]="false"
			
		Case "android","ios"
			ppsyms["__DESKTOP_TARGET__"]="false"
			ppsyms["__MOBILE_TARGET__"]="true"
			ppsyms["__WEB_TARGET__"]="false"
			
		Case "emscripten"
			ppsyms["__DESKTOP_TARGET__"]="false"
			ppsyms["__MOBILE_TARGET__"]="false"
			ppsyms["__WEB_TARGET__"]="true"
		End
		
		Select opts.config
		Case "debug"
			ppsyms["__DEBUG__"]="true"
			ppsyms["__RELEASE__"]="false"
		Case "release"
			ppsyms["__DEBUG__"]="false"
			ppsyms["__RELEASE__"]="true"
		End
		
		ppsyms["__MAKEDOCS__"]=opts.makedocs ? "true" Else "false"

		ppsyms["__THREADS__"]=opts.threads ? "true" Else "false"

		profileName=opts.target+"_"+opts.config
		
		If opts.target="windows"
			
			If opts.toolchain="msvc" profileName+="_msvc"
				
			If opts.arch="x64" profileName+="_x64"
				
		Elseif opts.target="ios"
			
			If opts.arch="x64" profileName+="_x64"
				
		Endif
		
		If opts.threads profileName+="_mx"
		
		If opts.productType="app" APP_DIR=ExtractDir( opts.mainSource )
		
		ClearPrimTypes()
		
		rootNamespace=New NamespaceScope( Null,Null )
		
		monkeyNamespace=GetNamespace( "monkey" )
	End
	
	Method Parse()
	
		If opts.verbose>=0 Print "[#    ] Parsing..."
		
		Local name:=StripDir( StripExt( opts.mainSource ) )

		Local module:=New Module( name,opts.mainSource,MX2CC_VERSION,profileName )
		modulesMap[name]=module
		modules.Push( module )
		
		Select opts.target
		Case "android"
			product=New AndroidBuildProduct( module,opts )
		Case "ios"
			product=New IosBuildProduct( module,opts )
		Default
			product=New GccBuildProduct( module,opts )
		End
		
		mainModule=module
		
		If name="monkey" And opts.productType="module" modulesMap["monkey"]=module
		
		If opts.clean
			DeleteDir( module.outputDir,True )
			DeleteDir( module.cacheDir,True )
		Endif
		
		parsingModule=module
		MX2_SRCS.Push( module.srcPath )
		
		Repeat
		
			If MX2_SRCS.Empty
			
				parsingModule=Null
			
				If MX2_LIBS.Empty
					If modulesMap["monkey"] Exit
					MX2_LIBS.Push( "monkey" )
				Endif
				
				Local name:=MX2_LIBS.Pop()
				Local srcPath:=""
				For Local moddir:=Eachin module.Dirs
					srcPath=moddir+name+"/"+name+".monkey2"
					If GetFileType( srcPath )=FileType.File Exit
					srcPath=""
				Next
				If Not srcPath
					New BuildEx( "Can't find module '"+name+"'" )
					Continue
				Endif
				
				module=New Module( name,srcPath,MX2CC_VERSION,profileName )
				modulesMap[name]=module
				modules.Push( module )
				parsingModule=module
				MX2_SRCS.Push( module.srcPath )
			Endif
			
			Local path:=MX2_SRCS.Pop()
			
			If opts.verbose>=2 Print path
				
			Local ipath:=MakeRelativePath( StripExt( path ),module.baseDir )

			Local ident:=module.ident+"_"+Identize( ipath )
			
			Local parser:=New Parser
			
			Local fdecl:=parser.ParseFile( ident,path,ppsyms )
			
			fdecl.module=module
			fdecl.hfile=module.hfileDir+ident+".h"
			fdecl.cfile=module.cfileDir+ident+".cpp"
'			fdecl.rfile=module.cfileDir+"r_"+ident+".cpp"

			module.fileDecls.Push( fdecl )
			
			product.reflects.AddAll( fdecl.reflects )
			
			'process imports...
			'
			If opts.passes=1 Continue
			'
			Local cd:=currentDir
			currentDir=ExtractDir( fdecl.path )
			BuildEx.srcpath=fdecl.path
			BuildEx.srcpos=-1
			
			For Local imp:=0 Until fdecl.imports.Length
				
				Local path:=fdecl.imports[imp]
				
				Local i:=path.FindLast( "[" )
				If i<>-1 And path.EndsWith( "]" )
					BuildEx.srcpos=Int( path.Slice( i+1,-1 ) )
					path=path.Slice( 0,i )
					fdecl.imports[imp]=path
				Else
					BuildEx.srcpos=-1
				Endif
				
				ImportFile( path )
			Next
			
			BuildEx.srcpath=""
			currentDir=cd
			
		Forever
	
	End
	
	Method SortModules( module:Module,done:StringMap<Bool>,deps:Stack<Module> )
	
		If done.Contains( module.name ) Return
		
		For Local dep:=Eachin module.moduleDeps.Keys
		
			Local module2:=modulesMap[dep]
		
			SortModules( module2,done,deps )
		
		Next
		
		If done.Contains( module.name ) Return
		
		done[module.name]=True
		
		deps.Push( module )
		
	End
	
	Method SortModules()

		'sort modules into dependency order
		Local sorted:=New Stack<Module>
		Local done:=New StringMap<Bool>
		
		sorted.Push( modulesMap["monkey"] )
		done["monkey"]=True
		
		For Local i:=0 Until modules.Length
			SortModules( modules[i],done,sorted )
		Next
		
		modules=sorted
		
		For Local i:=0 Until modules.Length
		
			Local module:=modules[modules.Length-i-1]
			
			If module<>mainModule
				product.imports.Push( module )
			Endif
		Next
		
	End

	Method Semant()
	
		If opts.verbose>=0 Print "[##   ] Semanting..."
		
		SortModules()
		
		For Local i:=0 Until modules.Length
		
			Local module:=modules[i]
			
			For Local fdecl:=Eachin module.fileDecls

				Local fscope:=New FileScope( fdecl )
				
				module.fileScopes.Push( fscope )
			Next
			
			If i=0 CreatePrimTypes()
			
			semantingModule=module
			
			For Local fscope:=Eachin module.fileScopes
			
				PNode.semanting.Push( fscope.fdecl )
				
				Try
					fscope.SemantUsings()
				catch ex:SemantEx
				End
				
				PNode.semanting.Pop()
				
			Next
			
			For Local fscope:=Eachin module.fileScopes
			
				If opts.verbose>=2 Print fscope.fdecl.path
			
				fscope.Semant()
			Next
			
			Repeat
			
				If Not semantMembers.Empty
					
					Local ctype:=semantMembers.RemoveFirst()
					
					PNode.semanting.Push( ctype.cdecl )
					Scope.semanting.Push( Null )
					
					Try
					
						ctype.SemantMembers()
						
					Catch ex:SemantEx
					End
					
					PNode.semanting.Pop()
					Scope.semanting.Pop()

				Else If Not semantStmts.Empty
					
					Local func:=semantStmts.Pop()
					
					PNode.semanting.Push( func.fdecl )
					Scope.semanting.Push( Null )
					
					Try
						If Not opts.makedocs func.SemantStmts()
			
					Catch ex:SemantEx
					End
					
					PNode.semanting.Pop()
					Scope.semanting.Pop()
				
				Else
					Exit
				Endif

			Forever
			
			semantingModule=Null

			'Check Main
			'			
			Local main:=module.main
			
			If opts.productType="app" And module=mainModule
				If main
					main.fdecl.symbol="bbMain"
				Else
					New BuildEx( "Can't find Main:Void()" )
				Endif
			Else If opts.productType="module"
				If main
					main.fdecl.symbol="mx2_"+module.ident+"_main"
				Endif
			Endif
			
			'Ugly stuff for generic instances - but hey, it works!
			'
			Local transFiles:=New StringMap<FileDecl>
			
			For Local inst:=Eachin module.genInstances
			
				Local transFile:FileDecl
				
				Local vvar:=Cast<VarValue>( inst )
				Local func:=Cast<FuncValue>( inst )
				Local ctype:=TCast<ClassType>( inst )
				Local etype:=TCast<EnumType>( inst )
				
				If vvar
					transFile=vvar.transFile
				Else If func
					transFile=func.transFile
				Else If ctype
					transFile=ctype.transFile
				Else If etype
					transFile=etype.transFile
				Endif
				
				If Not transFile Or transFile.module=module Continue
				
				Local transFile2:=transFile

				transFile=transFiles[transFile2.ident]
				
				If Not transFile
				
'					Print "transFile2="+transFile2.path+", module="+transFile2.module.ident+", exhfile="+transFile2.exhfile+", hfile="+transFile2.hfile
				
					transFile=New FileDecl
					
					transFile.ident=module.ident+"_"+transFile2.ident
					
					transFile.path=transFile2.path
					transFile.nmspace=transFile2.nmspace
					transFile.usings=transFile2.usings
					transFile.imports=transFile2.imports
										
					transFile.module=module
					transFile.exhfile=transFile2.hfile
					transFile.hfile=module.hfileDir+transFile.ident+".h"
					transFile.cfile=module.cfileDir+transFile.ident+".cpp"
					
					transFiles[transFile2.ident]=transFile
					
					module.fileDecls.Push( transFile )
				Endif
				
				If vvar
					vvar.transFile=transFile
					transFile.globals.Push( vvar )
				Else If func
					func.transFile=transFile
					transFile.functions.Push( func )
				Else If ctype
					ctype.transFile=transFile
					transFile.classes.Push( ctype )
				Else If etype
					etype.transFile=transFile
					transFile.enums.Push( etype )
				Endif
				
			Next
	
		Next
		
	End
	
	Method Translate()
	
		If opts.verbose>=0 Print "[###  ] Translating..."
		
		Local module:=mainModule
		
		CreateDir( module.outputDir )

		If Not CreateDir( module.hfileDir ) Throw New BuildEx( "Failed to create dir:"+module.hfileDir )
		If Not CreateDir( module.cfileDir ) Throw New BuildEx( "Failed to create dir:"+module.cfileDir )
		
		Local translator:=New Translator_CPP
		
		translator.TranslateModule( module )

		translator.TranslateTypeInfo( module )
	End
	
	Method GetNamespace:NamespaceScope( path:String,mustExist:Bool=False )
	
		Local nmspace:=rootNamespace,i0:=0
		
		While i0<path.Length
			Local i1:=path.Find( ".",i0 )
			If i1=-1 i1=path.Length
			
			Local id:=path.Slice( i0,i1 )
			i0=i1+1
			
			Local ntype:=TCast<NamespaceType>( nmspace.GetType( id ) )
			If Not ntype
				If mustExist New SemantEx( "Namespace '"+path+"' not found" )
				ntype=New NamespaceType( id,nmspace )
				nmspace.Insert( id,ntype )
			Endif
			
			nmspace=ntype.scope
		Wend
		
		Return nmspace
	End
	
	Method ClearPrimTypes()
	
'		Type.VoidType=Null
		Type.BoolType=Null
		Type.ByteType=Null
		Type.UByteType=Null
		Type.ShortType=Null
		Type.UShortType=Null
		Type.IntType=Null
		Type.UIntType=Null
		Type.LongType=Null
		Type.ULongType=Null
		Type.FloatType=Null
		Type.DoubleType=Null
		Type.StringType=Null
		Type.VariantType=Null
		Type.ArrayClass=Null
		Type.ObjectClass=Null
		Type.ThrowableClass=Null
	End
	
	Method CreatePrimTypes()
	
		Local types:=monkeyNamespace

		'Find new 'monkey.types' namespace...
		For Local scope:=Eachin monkeyNamespace.inner
			Local nmspace:=Cast<NamespaceScope>( scope )
			If Not nmspace Or nmspace.ntype.ident<>"types" Continue
			types=nmspace
			Exit
		Next

		Type.BoolType=New PrimType( TCast<ClassType>( types.nodes["@bool"] ) )
		Type.ByteType=New PrimType( TCast<ClassType>( types.nodes["@byte"] ) )
		Type.UByteType=New PrimType( TCast<ClassType>( types.nodes["@ubyte"] ) )
		Type.ShortType=New PrimType( TCast<ClassType>( types.nodes["@short"] ) )
		Type.UShortType=New PrimType( TCast<ClassType>( types.nodes["@ushort"] ) )
		Type.IntType=New PrimType( TCast<ClassType>( types.nodes["@int"] ) )
		Type.UIntType=New PrimType( TCast<ClassType>( types.nodes["@uint"] ) )
		Type.LongType=New PrimType( TCast<ClassType>( types.nodes["@long"] ) )
		Type.ULongType=New PrimType( TCast<ClassType>( types.nodes["@ulong"] ) )
		Type.FloatType=New PrimType( TCast<ClassType>( types.nodes["@float"] ) )
		Type.DoubleType=New PrimType( TCast<ClassType>( types.nodes["@double"] ) )
		Type.StringType=New PrimType( TCast<ClassType>( types.nodes["@string"] ) )
		Type.VariantType=New PrimType( TCast<ClassType>( types.nodes["@variant"] ) )
		
		Type.ArrayClass=TCast<ClassType>( types.nodes["@array"] )
		Type.ObjectClass=TCast<ClassType>( types.nodes["@object"] )
		Type.ThrowableClass=TCast<ClassType>( types.nodes["@throwable"] )

		Type.CStringClass=TCast<ClassType>( types.nodes["@cstring"] )
		Type.WStringClass=TCast<ClassType>( types.nodes["@wstring"] )
		Type.TypeInfoClass=TCast<ClassType>( types.nodes["@typeinfo"] )

		rootNamespace.Insert( "void",Type.VoidType )
		rootNamespace.Insert( "bool",Type.BoolType )
		rootNamespace.Insert( "byte",Type.ByteType )
		rootNamespace.Insert( "ubyte",Type.UByteType )
		rootNamespace.Insert( "short",Type.ShortType )
		rootNamespace.Insert( "ushort",Type.UShortType )
		rootNamespace.Insert( "int",Type.IntType )
		rootNamespace.Insert( "uint",Type.UIntType )
		rootNamespace.Insert( "long",Type.LongType )
		rootNamespace.Insert( "ulong",Type.ULongType )
		rootNamespace.Insert( "float",Type.FloatType )
		rootNamespace.Insert( "double",Type.DoubleType )
		rootNamespace.Insert( "string",Type.StringType )
		rootNamespace.Insert( "variant",Type.VariantType )
		
		rootNamespace.Insert( "object",Type.ObjectClass )
		rootNamespace.Insert( "throwable",Type.ThrowableClass )

		rootNamespace.Insert( "cstring",Type.CStringClass )
		rootNamespace.Insert( "wstring",Type.WStringClass )
		rootNamespace.Insert( "typeinfo",Type.TypeInfoClass )
		
		Type.BoolType.Semant()
		Type.ByteType.Semant()
		Type.UByteType.Semant()
		Type.ShortType.Semant()
		Type.UShortType.Semant()
		Type.IntType.Semant()
		Type.UIntType.Semant()
		Type.LongType.Semant()
		Type.ULongType.Semant()
		Type.FloatType.Semant()
		Type.DoubleType.Semant()
		Type.StringType.Semant()
		Type.VariantType.Semant()
		Type.ArrayClass.Semant()
		Type.ObjectClass.Semant()
		Type.ThrowableClass.Semant()
		Type.CStringClass.Semant()
		Type.WStringClass?.Semant()
		Type.TypeInfoClass.Semant()
	End
	
	Method ImportFile( path:String )
		
		If path.StartsWith( "<" ) And path.EndsWith( ">" )
			ImportSystemFile( path.Slice( 1,-1 ) )

		'// ***** Experimental *****
		Else If path.StartsWith( "MX2_LD_OPTS_") Or path.StartsWith( "MX2_CC_OPTS_") Or path.StartsWith( "MX2_CPP_OPTS_")
			Local name:=StripExt( path )
			local f:= name.Find("=")
			If f <> -1
				'// FIXME: Need some controls
				If name.StartsWith( "MX2_LD_OPTS_" + HostOS.ToUpper()) Then product.LD_OPTS += " " + name.Slice(f+1)
				If name.StartsWith( "MX2_CC_OPTS_" + HostOS.ToUpper()) Then product.CC_OPTS += " " + name.Slice(f+1)
				If name.StartsWith( "MX2_CPP_OPTS_" + HostOS.ToUpper()) Then product.CPP_OPTS += " " + name.Slice(f+1)
			Else
				'Failed to parse MX2 build options
				Throw New BuildEx( "Failed to parse additionnal MX2 build options : '"+path+"'" )
			End
		'// ***** Experimental *****
		Else
			If currentDir path=currentDir+path
			ImportLocalFile( RealPath( path ) )
		Endif
		
	End
	
	Method ImportSystemFile:Void( path:String )
	
		Local ext:=ExtractExt( path )

		Local name:=StripExt( path )
		
		If ext=".monkey2" parsingModule.moduleDeps[name]=True
		
		If imported.Contains( path ) Return
		
		imported[path]=True
		
		Select ext.ToLower()
		Case ".a"
			
			If name.StartsWith( "lib" )
				
				name=name.Slice( 3 )
				
				If opts.toolchain="msvc"
					product.LIB_FILES.Push( name+".lib" )
				Else
					product.LIB_FILES.Push( "-l"+name )
				Endif
			
			Else
				
				New BuildEx( "Import Error: "+path )
			Endif
			
		Case ".lib"
			
			If opts.toolchain="msvc"
				product.LIB_FILES.Push( StripDir( path ) )'name )
			Else
				product.LIB_FILES.Push( "-l"+name )
			Endif
			
		Case ".dylib"
			
			If opts.toolchain="gcc"
				product.LIB_FILES.Push( "-l"+name )
			Endif
			
		Case ".framework"
			
			If opts.toolchain="gcc"
				product.LIB_FILES.Push( "-framework "+name )
			Endif
			
		Case ".h",".hh",".hxx",".hpp"
		
'			STD_INCLUDES.Push( "<"+path+">" )
			
		Case ".monkey2"

			MX2_LIBS.Push( name )
		
		Default

			New BuildEx( "Unrecognized import file type: '"+path+"'" )
			
		End

	End
	
	Method ImportLocalFile:Void( path:String )
	
		If imported.Contains( path ) Return
		imported[path]=True
		
		Local i:=path.Find( "@/" )
		If i<>-1
			Local src:=path.Slice( 0,i )
			
			If GetFileType( src )=FileType.None
'				If Not opts.geninfo
				New BuildEx( "Asset '"+src+"' not found" )
				Return
			Endif
			
			product.ASSET_FILES.Push( path )
			Return
		Endif
		
		Local ext:=ExtractExt( path ).ToLower()
		
		Local name:=StripDir( StripExt( path ) )

		If name="*"
		
			Local dir:=ExtractDir( path )
			
			If GetFileType( dir )<>FILETYPE_DIR
'				If Not opts.geninfo
				New BuildEx( "Directory '"+dir+"' not found" )
				Return
			Endif
			
			Local qdir:="~q"+dir+"~q"
			
			Select ext
			Case ".h"
			
				product.CC_OPTS+=" -I"+qdir
				product.CPP_OPTS+=" -I"+qdir
				
			Case ".hh",".hpp",".hxx"
			
				product.CPP_OPTS+=" -I"+qdir
				
			Case ".a",".lib"
				
				If opts.toolchain="msvc"
					product.LD_OPTS+=" -LIBPATH:"+qdir
				Else
					product.LD_OPTS+=" -L"+qdir
				Endif
				
			Case ".dylib"
				
				If opts.toolchain="gcc"
					product.LD_OPTS+=" -L"+qdir
				Endif
				
			Case ".framework"
				
				If opts.toolchain="gcc"
					product.LD_OPTS+=" -F"+qdir
				Endif
				
			Default
			
				New BuildEx( "Unrecognized import file filter '*"+ext+"'" )
	
			End
			Return
		Endif
		
		Local qpath:="~q"+path+"~q"
		
		If ext=".framework"
			
			If opts.toolchain="gcc"
				If GetFileType( path )<>FileType.Directory
'					If Not opts.geninfo 
					New BuildEx( "Framework not found "+qpath )
				Endif
				
				Return
			Endif
			
		Else If Not path.Contains( "$(TARGET_ARCH" )
			
			If GetFileType( path )=FileType.Directory
				
				product.ASSET_FILES.Push( path )
				
				Return
				
			Else If GetFileType( path )<>FileType.File
				
'				If Not opts.geninfo
 				New BuildEx( "File not found "+qpath )
					
				Return
			
			Endif
			
		Endif
		
		Select ext
		Case ".mx2",".monkey2"
			
			MX2_SRCS.Push( path )
			
		Case ".h",".hh",".hxx",".hpp"
		
'			STD_INCLUDES.Push( qpath )
			
		Case ".c",".cc",".cxx",".cpp",".m",".mm",".asm",".s"
		
			If parsingModule=mainModule
				product.SRC_FILES.Push( path )
			Endif
		
		Case ".java"
			
			If opts.target="android" 
				product.JAVA_FILES.Push( path )
			Endif
			
		Case ".o"
		
			product.OBJ_FILES.Push( path )
			
		Case ".lib"
			
			product.LIB_FILES.Push( qpath )
		
		Case ".a"
			
			If opts.toolchain="gcc"
				product.LIB_FILES.Push( qpath )
			Endif
			
		Case ".so",".dylib"
			
			If opts.toolchain="gcc"
				product.LIB_FILES.Push( qpath )
				product.DLL_FILES.Push( path )
			Endif
			
		Case ".dll",".exe"
			
			If opts.target="windows"
				product.DLL_FILES.Push( path )
			Endif
			
		Case ".framework"
			
			If opts.toolchain="gcc"
				'OK, this is ugly...
				ImportLocalFile( ExtractDir( path )+"*.framework" )
				ImportSystemFile( StripDir( path ) )
				product.DLL_FILES.Push( path )
			Endif
		
		Default
		
			product.ASSET_FILES.Push( path )
		End
	
	End
	
	Method AllocTmpFile:String( kind:String )
	
		CreateDir( "tmp" )

		For Local i:=1 Until 10
			Local file:="tmp/"+kind+i+".txt"
			DeleteFile( file )
			If GetFileType( file )=FileType.None Return file
		Next
		
		Throw New BuildEx( "Can't allocate tmp file" )
		Return ""
	End
	
	Method Exec:Bool( cmd:String )
	
		If opts.verbose>2 Print cmd
	
		Local errs:=AllocTmpFile( "stderr" )
			
		If Not system( cmd+" 2>"+errs ) Return True
		
		Local terrs:=LoadString( errs )
		
		Throw New BuildEx( "System command '"+cmd+"' failed.~n~n"+cmd+"~n~n"+terrs )
		
		Return False
	End
End
