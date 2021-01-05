
'test..
Namespace mx2

Class Translator_CPP Extends Translator

	Field _module:Module
	Field _lambdaId:Int
	Field _gctmps:=0
	Field _dbline:=-1
	
	Method Reset() Override
		Super.Reset()
		_lambdaId=0
		_gctmps=0
		_dbline=-1
	End
	
	Method TranslateModule:Bool( module:Module )
		
		_module=module
		
		For Local fdecl:=Eachin _module.fileDecls
			
			If Builder.opts.verbose>=2 Print fdecl.path
		
			Try
			
				TranslateFile( fdecl )
				
			Catch ex:TransEx

				Return False
			End

		Next
		
		Return True
	End
	
	Method TranslateTypeInfo( module:Module )
		
		_module=module
	
		Reset()
	
		EmitBr()
		Emit( "#include <bbmonkey.h>" )
		Emit( "#include <bbtypeinfo_r.h>" )
		Emit( "#include <bbdeclinfo_r.h>" )
		
		EmitBr()
		Emit( "#include ~q_r.h~q" )
		
		Local nmspaces:=New StringMap<Stack<FileDecl>>
		
		EmitBr()
		For Local fdecl:=Eachin _module.fileDecls
			Local nmspace:=fdecl.nmspace
			Local fdecls:=nmspaces[fdecl.nmspace]
			If Not fdecls
				fdecls=New Stack<FileDecl>
				nmspaces[fdecl.nmspace]=fdecls
			Endif
			fdecls.Add( fdecl )
			EmitExternIncludes( fdecl )
		Next
		
		BeginDeps()
		
		For Local it:=eachin nmspaces
			
			Local fdecls:=it.Value
			
			Local nmpath:=it.Key,rcc:=""
			
			Repeat
				Local mpath:="BB_R_"+nmpath.Replace( "_","_0" ).Replace( ".","_" )
				If rcc
					rcc+=" || "+mpath+"__"
				Else
					rcc=mpath+" || "+mpath+"__"
				Endif
				Local i:=nmpath.FindLast( "." )
				If i=-1 Exit
				nmpath=nmpath.Slice( 0,i )
			Forever
			
			EmitBr()
			Emit( "#if "+rcc )
			
			For Local fdecl:=Eachin fdecls
		
				EmitTypeInfo( fdecl )
		
				For Local etype:=Eachin fdecl.enums
					If GenTypeInfo( etype )
						EmitTypeInfo( etype )
					Else
						EmitNullTypeInfo( etype )
					Endif
				Next
				
				For Local ctype:=Eachin fdecl.extclasses
					If GenTypeInfo( ctype ) EmitTypeInfo( ctype )
				Next
				
				For Local ctype:=Eachin fdecl.classes
					If GenTypeInfo( ctype )
						EmitTypeInfo( ctype )
					Else
						EmitNullTypeInfo( ctype )
					Endif
				Next
				
			Next
			
			Emit( "#else" )
			
			For Local fdecl:=Eachin fdecls
		
				EmitNullTypeInfo( fdecl )
		
				For Local etype:=Eachin fdecl.enums
					EmitNullTypeInfo( etype )
				Next
				
				For Local ctype:=Eachin fdecl.classes
					EmitNullTypeInfo( ctype )
				Next
			Next

			Emit( "#endif" )
		Next
		
		EndDeps( ExtractDir( _module.rfile ) )
		
		Local src:=_buf.Join( "~n" )
		
		CSaveString( src,_module.rfile )
	End
	
	Method EmitNullTypeInfo( fdecl:FileDecl )
	End

	Method EmitNullTypeInfo( etype:EnumType )
		
		UsesType( etype )
		
		Local ename:=EnumName( etype ),rename:="r"+ename
		
		Emit( "static bbUnknownTypeInfo "+rename+"(~q"+etype.Name+"~q);" )

		Emit( "bbTypeInfo *bbGetType("+ename+" const&){" )
		Emit( "return &"+rename+";" )
		Emit( "}" )
	End
	
	Method EmitNullTypeInfo( ctype:ClassType )
		
		UsesType( ctype )

		Local cname:=ClassName( ctype ),rcname:="r"+cname
		Local ptype:=ctype.IsStruct ? " " Else "*"

		Emit( "static bbUnknownTypeInfo "+rcname+"(~q"+ctype.Name+"~q);" )

		Emit( "bbTypeInfo *bbGetType("+cname+ptype+"const&){" )
		Emit( "return &"+rcname+";" )
		Emit( "}" )
		
		Emit( "bbTypeInfo *"+cname+"::typeof()const{" )
		Emit( "return &"+rcname+";" )
		Emit( "}" )
	End
	
	Method EmitExternIncludes( fdecl:FileDecl )
		
		For Local ipath:=Eachin fdecl.imports
		
			If ipath.Contains( "*." ) Continue
		
			Local imp:=ipath.ToLower()
			
			If imp.EndsWith( ".h" ) Or imp.EndsWith( ".hh" ) Or imp.EndsWith( ".hpp" )
				Local path:=ExtractDir( fdecl.path )+ipath
				Emit( "#include ~q"+MakeIncludePath( path,ExtractDir( fdecl.hfile ) )+"~q" )
				Continue
			Endif
			
			If imp.EndsWith( ".h>" ) Or imp.EndsWith( ".hh>" ) Or imp.EndsWith( ".hpp>" )
				Emit( "#include "+ipath )
				Continue
			Endif
			
		Next
	End
	
	Method TranslateFile( fdecl:FileDecl )
	
		Reset()
		
		'***** Emit header file *****
		
		EmitBr()
		Emit( "#ifndef MX2_"+fdecl.ident.ToUpper()+"_H" )
		Emit( "#define MX2_"+fdecl.ident.ToUpper()+"_H" )
		
		EmitBr()
		Emit( "#include <bbmonkey.h>" )
		If fdecl.exhfile Emit( "#include ~q"+MakeIncludePath( fdecl.exhfile,ExtractDir( fdecl.hfile ) )+"~q" )
			
		EmitExternIncludes( fdecl )
		
		BeginDeps()
		
		_deps.included[fdecl]=True
		
		'sort classes by dependancy
		
		Local done:=New Map<SNode,Bool>
		Local order:=New Stack<ClassType>
		
		For Local ctype:=Eachin fdecl.classes
			
			SortClassTypes( ctype,done,order,fdecl )
		Next
		
		fdecl.classes=order

		EmitBr()
		For Local etype:=Eachin fdecl.enums
			
			Local ename:=EnumName( etype )
			
			Emit( "BB_ENUM("+ename+")" )
			
			AddRef( etype )
		Next
		
		EmitBr()
		For Local ctype:=Eachin fdecl.classes
			
			Local cname:=ClassName( ctype )
			
			If ctype.IsStruct
				Emit( "BB_STRUCT("+cname+")" )
			Else
				Emit( "BB_CLASS("+cname+")" )
			Endif
			
			AddRef( ctype )
		Next
		
		EmitBr()
		For Local vvar:=Eachin fdecl.globals
			
			RefsType( vvar.type )
			
			Emit( "extern "+VarProto( vvar )+";" )
		Next
		
		EmitBr()
		For Local func:=Eachin fdecl.functions
			
			'Refs( func.ftype )
			RefsType( func.ftype )
			
			If func.IsExtension 
				'Refs( func.selfType )
				RefsType( func.selfType )
			Endif
			
			Emit( FuncProto( func,True )+";" )
		Next

'		EndDeps( ExtractDir( fdecl.hfile ) )
		
		'emit classes
		For Local ctype:=Eachin fdecl.classes
			'may have to begin/end deps around this again...
			EmitClassProto( ctype )
		Next

		EndDeps( ExtractDir( fdecl.hfile ) )
		
		EmitBr()		
		Emit( "#endif" )
		EmitBr()
		
		CSaveString( _buf.Join( "~n" ),fdecl.hfile )
		
		'***** Emit cpp source file *****
		
		_buf.Clear()
		
		EmitBr()
		Emit( "#include ~q"+MakeIncludePath( fdecl.hfile,ExtractDir( fdecl.cfile ) )+"~q" )
		EmitBr()

		BeginDeps()
		
		'enum debug code...
		EmitBr()
		For Local etype:=Eachin fdecl.enums
			
			Local ename:=EnumName( etype )
			
			Emit( "bbString bbDBType("+ename+"*p){" )
			Emit( "~treturn ~q"+etype.Name+"~q;" )
			Emit( "}" )
			
			Emit( "bbString bbDBValue("+ename+"*p){" )
			Emit( "~treturn bbString( *(int*)p );" )
			Emit( "}" )
		Next
		
		For Local vvar:=Eachin fdecl.globals
			DeclsVar( vvar.type )
			Emit( VarProto( vvar )+";" )
		Next
		
		For Local func:=Eachin fdecl.functions
			EmitFunc( func )
		Next
		
		For Local ctype:=Eachin fdecl.classes
			EmitClassMembers( ctype )
		Next

		If fdecl=_module.fileDecls[0] And Not _module.main
			EmitBr()
			Emit( "void mx2_"+_module.ident+"_main(){" )
			EmitMain()
			Emit( "}" )
		Endif
		
		EmitGlobalInits( fdecl )
		
		EndDeps( ExtractDir( fdecl.cfile ) )
		
		EmitBr()
		
		CSaveString( _buf.Join( "~n" ),fdecl.cfile )
	End
	
	'***** Decls *****
	
	Method HeapVarType:String( type:Type )
	
		If IsGCPtrType( type ) Return "bbGCVar<"+ClassName( TCast<ClassType>( type ) )+">"
		
		Return TransType( type )
	End
	
	Method VarType:String( vvar:VarValue )
	
		Local type:=vvar.type
		
		Select vvar.vdecl.kind
		Case "const","global","field"
			Return HeapVarType( type )
		End
		
		Return TransType( type )
	End

	Method VarProto:String( vvar:VarValue ) Override
	
		Return VarType( vvar )+" "+VarName( vvar )
	End
	
	Method FuncProto:String( func:FuncValue ) Override

		Return FuncProto( func,True )
	End
	
	Method FuncProto:String( func:FuncValue,header:Bool )

		Local fdecl:=func.fdecl
		Local ftype:=func.ftype
		Local ctype:=func.scope.FindClass()
	
		Local retType:=""
		If Not func.IsCtor retType=TransType( ftype.retType )+" "

		Local params:=""
		If func.IsExtension

			'new self
			Local tself:=func.selfType.IsStruct ? "*l_self" Else "l_self"
			params=TransType( func.selfType )+" "+tself
			
'			Local tself:=func.selfType.IsStruct ? "&l_self" Else "l_self"
'			params=TransType( func.selfType )+" "+tself
		Endif

		For Local p:=Eachin func.params
			If params params+=","
			params+=TransType( p.type )+" "+VarName( p )
		Next

		If func.IsCtor And ctype.IsStruct 
			If Not ftype.argTypes.Length Or ftype.argTypes[0].Equals( ctype )
				If params params+=","
				params+="bbNullCtor_t"
			Endif
		Endif
		
		Local ident:=FuncName( func )
		If Not header And func.IsMember ident=ClassName( ctype )+"::"+ident
		
		Local proto:=retType+ident+"("+params+")"
		
		If header And func.IsMethod	'Member
			If fdecl.IsAbstract Or fdecl.IsVirtual Or ctype.IsVirtual
				proto="virtual "+proto
				If fdecl.IsAbstract proto+="=0"
			Endif
		Endif
		
		Return proto
	End
	
	Method EmitGlobalInits( fdecl:FileDecl )
	
		EmitBr()
		Emit( "void mx2_"+fdecl.ident+"_init_f(){" )
		
		BeginGCFrame()
		
		'initalize globals
		'
		Local gc:=False
		For Local vvar:=Eachin fdecl.globals
			If vvar.init Emit( TransRef( vvar )+"="+Trans( vvar.init )+";" )
			If IsGCType( vvar.type ) gc=True
		Next
		
		EndGCFrame()
		Emit( "}" )
		
		If gc
			EmitBr()
			Emit( "struct mx2_"+fdecl.ident+"_roots_t : bbGCRoot{" )
			Emit( "void gcMark(){" )
			For Local vvar:=Eachin fdecl.globals
				If Not IsGCType( vvar.type ) Continue
				
				Emit( "bbGCMark("+Trans(vvar)+");" )
				
				MarksType( vvar.type )
			Next
			Emit( "}" )
			Emit( "}mx2_"+fdecl.ident+"_roots;" )
		Endif
		
	End
	
	Method SortClassTypes( ctype:ClassType,done:Map<SNode,Bool>,order:Stack<ClassType>,fdecl:FileDecl )
		
		If done[ctype] Return
		
		done[ctype]=True
		
		If ctype.cdecl.IsExtern Return
		
		'have to emit super type first...
		If ctype.superType SortClassTypes( ctype.superType,done,order,fdecl )
			
		'have to emit interface types first...
		For Local itype:=Eachin ctype.ifaceTypes
			
			SortClassTypes( itype,done,order,fdecl )
		End
		
		'have to emit struct fields first...
		For Local vvar:=Eachin ctype.fields
			
			Local ctype:=TCast<ClassType>( vvar.type )
			
			If ctype And ctype.IsStruct SortClassTypes( ctype,done,order,fdecl )
		Next
		
		If ctype.transFile=fdecl order.Add( ctype )
	End
	
	Method EmitClassProto( ctype:ClassType )
	
		Local cdecl:=ctype.cdecl
		Local cname:=ClassName( ctype )
		
		Local xtends:=""
		Local superName:String
	
		Select cdecl.kind
		
		Case "class"
		
			If ctype.superType
				
				'Uses( ctype.superType )
				UsesType( ctype.superType )
				
				superName=ClassName( ctype.superType )
				xtends="public "+superName
			Else
				xtends="public bbObject"
			Endif
			
		Case "struct"

			If ctype.superType
				
				'Uses( ctype.superType )
				UsesType( ctype.superType )
				
				superName=ClassName( ctype.superType )
				xtends="public "+superName
			Endif
		
		Case "interface"
		
			If Not ctype.ifaceTypes xtends="public virtual bbInterface"
			
		End
		
		For Local iface:=Eachin ctype.ifaceTypes
			
			'Uses( iface )
			UsesType( iface )
			
			If xtends xtends+=","
			xtends+="public virtual "+ClassName( iface )
		Next
		
		If xtends xtends=" : "+xtends
		
		EmitBr()
		Emit( "struct "+cname+xtends+"{" )
		
		If ctype.IsClass
			Emit( "typedef "+cname+" *bb_object_type;" )
		Else If ctype.IsInterface
			Emit( "typedef "+cname+" *bb_object_type;" )
		Else If ctype.IsStruct
			Emit( "typedef "+cname+" bb_struct_type;" )
		Endif
		
		If ctype.superType
		
			Local done:=New StringMap<Bool>
		
			EmitBr()
			For Local it:=Eachin ctype.scope.nodes
			
				Local flist:=Cast<FuncList>( it.Value )
				If Not flist Or it.Key="new" Continue
				
				For Local func:=Eachin flist.funcs
				
					If func.IsGeneric Continue
					
					If Not func.IsMethod Continue
					
					If func.cscope.ctype=ctype Continue
					
					Local superName:=ClassName( func.cscope.ctype )
					
					Local sym:=superName+"::"+FuncName( func )
					If done[sym] Continue
					done[sym]=True
					
					Emit( "using "+sym+";" )
				Next
			Next
		Endif

'		If GenTypeInfo( ctype )
			Emit( "bbTypeInfo *typeof()const;" )
'		Endif
		
		Emit( "const char *typeName()const{return ~q"+cname+"~q;}" )
		
		'Emit fields...
		'
		Local needsInit:=False
		Local needsMark:=False

		EmitBr()		
		For Local vvar:=Eachin ctype.fields
			
			DeclsVar( vvar.type )
		
			If IsGCType( vvar.type ) needsMark=True
			
			Local proto:=VarProto( vvar )
			
			If vvar.init
				If vvar.init.HasSideEffects
					Emit( proto+"{};" )
					needsInit=True
				Else
					Local lit:=Cast<LiteralValue>( vvar.init )
					If Not lit Or lit.value
							
						Emit( proto+"{"+Trans( vvar.init )+"};" )
						
						If IsGCType( vvar.type ) MarksType( vvar.type )
					Else
						Emit( proto+"{};" )
					Endif
				Endif
			Else
				Emit( proto+"{};" )
			Endif
			
		Next

		If needsInit
			EmitBr()
			Emit( "void init();" )
		Endif
		
		If cdecl.kind="class"
		
			If needsMark
				EmitBr()
				Emit( "void gcMark();" )
			Endif
		
		Endif
		
		If _debug
		
			If cdecl.kind="class"
				Emit( "void dbEmit();" )
			Else If cdecl.kind="struct"
				Emit( "static void dbEmit("+cname+"*);" )
			Endif

		Endif

		'Emit ctor methods
		'
		Local hasCtor:=False
		Local hasDefaultCtor:=False
		
		EmitBr()
		For Local func:=Eachin ctype.ctors
			
			hasCtor=True
	
			If Not func.ftype.argTypes hasDefaultCtor=True
			
			'Refs( func.ftype )
			RefsType( func.ftype )

			Emit( FuncProto( func,true )+";" )
		Next
		
		'Emit dtor
		'		
		Emit( "~~"+cname+"();" )
		
		'Emit non-ctor methods
		'
		Local hasCmp:=False
		
		EmitBr()
		For Local func:=Eachin ctype.methods
			
			If func.fdecl.ident="<=>" hasCmp=True
			
			'Refs( func.ftype )
			RefsType( func.ftype )
			
			If func.simpleGetter And Not _debug
				EmitFunc( func,False,True )
			Else
				Emit( FuncProto( func,True )+";" )
			Endif
		Next
		
		If cdecl.kind="struct"
			If hasCtor Or Not hasDefaultCtor
				EmitBr()
				Emit( cname+"(){" )
				Emit( "}" )
			Endif
			If Not hasDefaultCtor
				EmitBr()
				Emit( cname+"(bbNullCtor_t){" )
				If needsInit Emit( "init();" )
				Emit( "}" )
			Endif
		Else If cdecl.kind="class"
			If Not hasDefaultCtor
				EmitBr()
				Emit( cname+"(){" )
				If needsInit Emit( "init();" )
				Emit( "}" )
			Endif
		Endif

		Emit( "};" )
		
		#rem
		Emit( "bbTypeInfo *bbGetType("+cname+(ctype.IsStruct ? " " Else "*")+"const&);" )
		
		If _debug
			Local tname:=cname
			If Not ctype.IsStruct tname+="*"
			Emit( "bbString bbDBType("+tname+"*);" )
			Emit( "bbString bbDBValue("+tname+"*);" )
		Endif
		#end
		
		If ctype.IsStruct
			EmitBr()
			If hasCmp
				Emit( "inline int bbCompare(const "+cname+"&x,const "+cname+"&y){return x.m__cmp(y);}" )
			Else
				Emit( "int bbCompare(const "+cname+"&x,const "+cname+"&y);" )
			Endif
		
			If needsMark
				EmitBr()
				Emit( "void bbGCMark(const "+ClassName( ctype )+"&);" )
			Endif
			
		Endif
		
	End
	
	Method EmitClassMembers( ctype:ClassType )
	
		Local cdecl:=ctype.cdecl
		If cdecl.kind="protocol" Return
		
		Local cname:=ClassName( ctype )
		
		'Emit fields...
		'
		Local needsInit:=False
		Local needsMark:=False

		EmitBr()
		For Local vvar:=Eachin ctype.fields
			
			If IsGCType( vvar.type ) 
				needsMark=True
			Endif
			
			If vvar.init And vvar.init.HasSideEffects needsInit=True
		Next
		
		'Emit init() method
		'
		If needsInit

			EmitBr()
			Emit( "void "+cname+"::init(){" )
			
			BeginGCFrame()
			
			For Local vvar:=Eachin ctype.fields
			
				If Not vvar.init Or Not vvar.init.HasSideEffects Continue

				Emit( TransRef( vvar )+"="+Trans( vvar.init )+";" )
				
				If IsGCType( vvar.type ) MarksType( vvar.type )
			Next
			
			EndGCFrame()

			Emit( "}" )
		
		Endif
		
		If cdecl.kind="class"
		
			If needsMark
			
				EmitBr()
				Emit( "void "+cname+"::gcMark(){" )
				
				If ctype.superType And Not ctype.superType.ExtendsVoid And ctype.superType<>Type.ObjectClass
					
					Emit( ClassName( ctype.superType )+"::gcMark();" )
				End
			
				For Local vvar:=Eachin ctype.fields
					If Not IsGCType( vvar.type ) Continue
					
					Emit( "bbGCMark("+VarName( vvar )+");" )
					
					MarksType( vvar.type )
				Next
				
				Emit( "}" )
			
			Endif
			
		Endif
		
		If _debug And cdecl.kind="class"
			EmitBr()
			
			Emit( "void "+cname+"::dbEmit(){" )

			If ctype.superType And Not ctype.superType.cdecl.IsExtern	'And ctype.superType<>Type.ObjectClass
				Emit( ClassName( ctype.superType )+"::dbEmit();" )
			End
			
			Emit( "puts( ~q["+ctype.Name+"]~q);" )
			
			For Local vvar:=Eachin ctype.fields
				Emit( "bbDBEmit(~q"+vvar.vdecl.ident+"~q,&"+VarName( vvar )+");" )
			Next
			
			Emit( "}" )
		Endif
		
		If _debug And cdecl.kind="struct"
			EmitBr()
			
			Emit( "void "+cname+"::dbEmit("+cname+"*p){" )
			
			For Local vvar:=Eachin ctype.fields
				Emit( "bbDBEmit(~q"+vvar.vdecl.ident+"~q,&p->"+VarName( vvar )+");" )
			Next
			
			Emit( "}" )
		Endif
	
		'Emit ctor methods
		'
		For Local func:=Eachin ctype.ctors
			
			EmitBr()
			EmitFunc( func,needsInit )
		Next
		
		'Emit dtor
		'
		Emit( cname+"::~~"+cname+"(){" )
		Emit( "}" )
		
		'Emit non-ctor methods
		'
		Local hasCmp:=False
		
		For Local func:=Eachin ctype.methods
			
			If func.fdecl.ident="<=>" hasCmp=True
				
			If func.simpleGetter And Not _debug Continue

			EmitBr()
			EmitFunc( func )
		Next
		
		If _debug
			Local tname:=cname
			If Not ctype.IsStruct tname+="*"
			
			Emit( "bbString bbDBType("+tname+"*){" )
			Emit( "return ~q"+ctype.Name+"~q;" )
			Emit( "}" )
			
			Emit( "bbString bbDBValue("+tname+"*p){" )
			
			If ctype.ExtendsVoid
				Emit( "return bbDBValue(*p);" )
			Else
				Select cdecl.kind
				Case "class"

					Emit( "return bbDBObjectValue(*p);" )
					
				Case "interface"
				
					Emit( "return bbDBInterfaceValue(*p);" )
					
				Case "struct"
				
					Emit( "return bbDBStructValue(p);" )
				End
			Endif
				
			Emit( "}" )
				
		Endif

		'Emit static struct methods
		'
		If ctype.IsStruct
			If Not hasCmp
				EmitBr()
				Emit( "int bbCompare(const "+cname+"&x,const "+cname+"&y){" )
				For Local vvar:=Eachin ctype.fields
					Local vname:=VarName( vvar )
					Emit( "if(int t=bbCompare(x."+vname+",y."+vname+")) return t;" )
				Next
				Emit( "return 0;" )
				Emit( "}" )
			Endif
		
			If needsMark
		
				EmitBr()
				Emit( "void bbGCMark(const "+cname+"&t){" )
				
				If ctype.superType And ctype.superType<>Type.ObjectClass
					Emit( "bbGCMark(("+ClassName( ctype.superType )+"&)t);" )
				Endif
	
				For Local vvar:=Eachin ctype.fields
					If Not IsGCType( vvar.type ) Continue
					
					Emit( "bbGCMark(t."+VarName( vvar )+");" )
					
					MarksType( vvar.type )
				Next
				
				Emit( "}" )
				
			Endif
			
		Endif

	End
	
	Method EmitTypeInfo( fdecl:FileDecl )
	
		Local decls:=New Stack<String>
	
		For Local vvar:=Eachin fdecl.globals
			If Not GenTypeInfo( vvar ) Continue
			Local fscope:=vvar.scope.FindFile()
			If fscope.fdecl<>fdecl Continue
			If vvar.scope<>fscope Continue
			
			Local id:=vvar.vdecl.ident
			Local vname:=VarName( vvar )
			Local meta:=vvar.vdecl.meta ? ","+EnquoteCppString( vvar.vdecl.meta ) Else ""
			
			If IsGCType( vvar.type ) MarksType( vvar.type )
			DeclsVar( vvar.type )
			RefsVar( vvar )
			
			decls.Push( "bb"+vvar.vdecl.kind.Capitalize()+"Decl(~q"+id+"~q,&"+vname+meta+")" )
		Next
		
		For Local func:=Eachin fdecl.functions
			If Not GenTypeInfo( func ) Continue
			Local fscope:=func.scope.FindFile()
			If fscope.fdecl<>fdecl Continue
			If func.scope<>fscope Continue

			Local id:=func.fdecl.ident
			Local fname:=FuncName( func )
			Local meta:=func.fdecl.meta ? ","+EnquoteCppString( func.fdecl.meta ) Else ""
			Local args:=TransType( func.ftype.retType )
			For Local arg:=Eachin func.ftype.argTypes
				args+=","+TransType( arg )
			Next
			
			UsesFunc( func.ftype )
'			DeclsFunc( func.ftype )
			RefsFunc( func )
						
			decls.Push( "bbFunctionDecl<"+args+">(~q"+id+"~q,&"+fname+meta+")" )
		Next
		
		If decls.Empty Return

		Local tname:="mx2_"+fdecl.ident+"_typeinfo"
	
		Emit( "static struct "+tname+" : public bbClassDecls{" )
		
		Emit( tname+"():bbClassDecls(bbClassTypeInfo::getNamespace(~q"+fdecl.nmspace+"~q)){" )
		Emit( "}" )
		
		Emit( "bbDeclInfo **initDecls(){" )
		Emit( "return bbMembers("+decls.Join( "," )+");" )
		Emit( "}" )
		
		Emit( "}_"+tname+";" )
	End
	
	Method EmitTypeInfo( etype:EnumType )
		
		UsesType( etype )
		
		Local edecl:=etype.edecl
		Local ename:=EnumName( etype )
		Local rname:="e"+ename
		
		EmitBr()

		Emit( "struct "+rname+" : public bbEnumTypeInfo{" )
		
		Emit( "static "+rname+" instance;" )
		
		'struct decls_t
		Emit( "static struct decls_t : public bbClassDecls{" )
		
		Emit( "decls_t():bbClassDecls(&instance){}" )
		
		'initDecls()
		Emit( "bbDeclInfo **initDecls(){" )
		
		Local decls:=New StringStack
		
		For Local it:=Eachin etype.scope.nodes
			decls.Add( "bbLiteralDecl<"+ename+">(~q"+it.Key+"~q,("+ename+")"+Cast<LiteralValue>( it.Value ).value+")" )
'			decls.Add( "bbLiteralDecl<int>(~q"+it.Key+"~q,"+Cast<LiteralValue>( it.Value ).value+")" )
		Next

		Emit( "return bbMembers("+decls.Join( "," )+");" )
		Emit( "}" )
		Emit( "}decls;" )
		
		'Ctor
		Emit( rname+"():bbEnumTypeInfo(~q"+etype.Name+"~q){" )
		Emit( "}" )
		
		'MakeEnum
		Emit( "bbVariant makeEnum( int i ){" )
		Emit( "return bbVariant( ("+ename+")i );" )
		Emit( "}" )
		
		Emit( "int getEnum( bbVariant v ){" )
		Emit( "return (int)v.get<"+ename+">();" )
		Emit( "}" )
		
		Emit( "};" )
		
		Emit( rname+" "+rname+"::instance;" )
		Emit( rname+"::decls_t "+rname+"::decls;" )
		
		EmitBr()
		
		Emit( "bbTypeInfo *bbGetType("+ename+" const&){" )
		Emit( "return &"+rname+"::instance;" )
		Emit( "}" )
	End

	Method EmitTypeInfo( ctype:ClassType )
	
		UsesType( ctype )
		
		Local fdecl:=ctype.scope.FindFile().fdecl

		Local cdecl:=ctype.cdecl
		Local cname:=ClassName( ctype )
		Local rcname:="r"+cname

		EmitBr()
		Emit( "struct "+rcname+" : public bbClassTypeInfo{" )
		
		Emit( "static "+rcname+" instance;" )
		
		'struct decls_t
		Emit( "static struct decls_t : public bbClassDecls{" )
		
		Emit( "decls_t():bbClassDecls(&instance){}" )
		
		'initDecls()
		Emit( "bbDeclInfo **initDecls(){" )
		
		Local decls:=New StringStack
		
'		If ctype.scope.outer.IsInstanceOf	'semi-generic?
		If ctype.scope.IsInstanceOf			'generic?
			
		Else
			
			If ctype.IsClass And Not ctype.IsAbstract And Not cdecl.IsExtension
				If ctype.ctors.Length
					For Local ctor:=Eachin ctype.ctors
						If Not GenTypeInfo( ctor ) Continue
					
						Local meta:=ctor.fdecl.meta ? EnquoteCppString( ctor.fdecl.meta ) Else ""
						
						Local args:=cname
						For Local arg:=Eachin ctor.ftype.argTypes
							If args args+=","
							args+=TransType( arg )
						Next
						
						UsesFunc( ctor.ftype )
'						DeclsFunc( ctor.ftype )
						
						decls.Push( "bbCtorDecl<"+args+">("+meta+")" )
					Next
				Else
					'default ctor!
					decls.Push( "bbCtorDecl<"+cname+">()" )
				Endif
			Endif
			
			For Local vvar:=Eachin ctype.fields
				If Not GenTypeInfo( vvar ) Continue
				
				Local id:=vvar.vdecl.ident
				Local vname:=VarName( vvar )
				Local meta:=vvar.vdecl.meta ? ","+EnquoteCppString( vvar.vdecl.meta ) Else ""
				
				If IsGCType( vvar.type ) MarksType( vvar.type )
				DeclsVar( vvar.type )
				
				decls.Push( "bbFieldDecl(~q"+id+"~q,&"+cname+"::"+vname+meta+")" )
			Next
	
			For Local func:=Eachin ctype.methods
				If func.fdecl.flags & (DECL_GETTER|DECL_SETTER) Or Not GenTypeInfo( func ) Continue
				
				If func.IsExtension 
					Print "Extension:"+func.fdecl.ident
					Continue
				Endif
				
				Local id:=func.fdecl.ident
				Local fname:=FuncName( func )
				Local meta:=func.fdecl.meta ? ","+EnquoteCppString( func.fdecl.meta ) Else ""
				
				Local args:=cname+","+TransType( func.ftype.retType )
				For Local arg:=Eachin func.ftype.argTypes
					args+=","+TransType( arg )
				Next
				
				UsesFunc( func.ftype )
				'DeclsFunc( func.ftype )
				
				decls.Push( "bbMethodDecl<"+args+">(~q"+id+"~q,&"+cname+"::"+fname+meta+")" )
			Next
			
			For Local node:=Eachin ctype.scope.nodes.Values
				Local plist:=Cast<PropertyList>( node )
				If Not plist Continue
				If plist.getFunc And Not GenTypeInfo( plist.getFunc ) Continue
				If plist.setFunc And Not GenTypeInfo( plist.setFunc ) Continue
				
				Local id:=plist.pdecl.ident
				Local meta:=plist.pdecl.meta ? ","+EnquoteCppString( plist.pdecl.meta ) Else ""
	
				DeclsVar( plist.type )
				
				If cdecl.IsExtension
					
					Local cname:=ClassName( ctype.superType )
					Local args:=cname+","+TransType( plist.type )
					
					Local get:=plist.getFunc ? "&"+FuncName( plist.getFunc ) Else "0"
					Local set:=plist.setFunc ? "&"+FuncName( plist.setFunc ) Else "0"
					decls.Push( "bbExtPropertyDecl<"+args+">(~q"+id+"~q,"+get+","+set+meta+")" )
					
				Else
	
					Local args:=cname+","+TransType( plist.type )
					
					Local get:=plist.getFunc ? "&"+cname+"::"+FuncName( plist.getFunc ) Else "0"
					Local set:=plist.setFunc ? "&"+cname+"::"+FuncName( plist.setFunc ) Else "0"
					decls.Push( "bbPropertyDecl<"+args+">(~q"+id+"~q,"+get+","+set+meta+")" )
					
				Endif
			Next
			
			For Local vvar:=Eachin fdecl.globals
				If vvar.scope<>ctype.scope Or Not GenTypeInfo( vvar ) Continue
				
				Local id:=vvar.vdecl.ident
				Local vname:=VarName( vvar )
				Local meta:=vvar.vdecl.meta ? ","+EnquoteCppString( vvar.vdecl.meta ) Else ""
	
				If IsGCType( vvar.type ) MarksType( vvar.type )
				DeclsVar( vvar.type )
				
				decls.Push( "bb"+vvar.vdecl.kind.Capitalize()+"Decl(~q"+id+"~q,&"+vname+meta+")" )
			Next
			
			For Local func:=Eachin fdecl.functions
				
				If func.scope<>ctype.scope Or Not GenTypeInfo( func ) Continue
				
				If func.fdecl.flags & (DECL_GETTER|DECL_SETTER) Continue
				
				Local id:=func.fdecl.ident
				Local fname:=FuncName( func )
				Local meta:=func.fdecl.meta ? ","+EnquoteCppString( func.fdecl.meta ) Else ""
					
				UsesFunc( func.ftype )
				'DeclsFunc( func.ftype )
					
				If func.IsExtension
	
					Local cname:=ClassName( func.selfType )
							
					Local args:=cname+","+TransType( func.ftype.retType )
					For Local arg:=Eachin func.ftype.argTypes
						args+=","+TransType( arg )
					Next
							
					decls.Push( "bbExtMethodDecl<"+args+">(~q"+id+"~q,&"+fname+meta+")" )
				
				Else
				
					Local args:=TransType( func.ftype.retType )
					For Local arg:=Eachin func.ftype.argTypes
						args+=","+TransType( arg )
					Next
		
					decls.Push( "bbFunctionDecl<"+args+">(~q"+id+"~q,&"+fname+meta+")" )
					
				Endif
			Next
		
		Endif
		
		Emit( "return bbMembers("+decls.Join( "," )+");" )
		
		Emit( "}" )
		
		Emit( "}decls;" )

		'Ctor
		Local name:=ctype.Name
		Local kind:=cdecl.kind.Capitalize()
		If cdecl.IsExtension 
			name+=" Extension"
			kind+=" Extension"
		Endif
		Emit( rcname+"():bbClassTypeInfo(~q"+name+"~q,~q"+kind+"~q){" )
		Emit( "}" )

		'superType
		If ctype.superType
			
			Local sname:=ClassName( ctype.superType )
			If Not ctype.IsStruct sname+="*"
			
			RefsType( ctype.superType )
			
			Emit( "bbTypeInfo *superType(){" )
			Emit( "return bbGetType<"+sname+">();" )
			Emit( "}" )
		Endif
		
		'interfaceTypes
		If ctype.ifaceTypes
			Emit( "bbArray<bbTypeInfo*> interfaceTypes(){" )
			Local args:=""
			For Local iface:=Eachin ctype.ifaceTypes
				If args args+=","
					
				RefsType( iface )
				
				args+="bbGetType<"+ClassName( iface )+"*>()"
			Next
			Emit( "return bbArray<bbTypeInfo*>({"+args+"},"+ctype.ifaceTypes.Length+");" )
			Emit( "}" )
		Endif
		
		Local ccname:=cdecl.IsExtension ? ClassName( ctype.superType ) Else cname
		
		'nullvalue
		Emit( "bbVariant nullValue(){" )
		If ctype.IsStruct
			Emit( "return bbVariant("+ccname+"{});")
		Else
			Emit( "return bbVariant(("+ccname+"*)0);")
		Endif
		Emit( "}" )
		
		'newArray
		Emit( "bbVariant newArray( int length ){" )
		If ctype.IsStruct
			Emit( "return bbVariant(bbArray<"+ccname+">(length));" )
		Else
			Emit( "return bbVariant(bbArray<bbGCVar<"+ccname+">>(length));" )
		Endif
		Emit( "}" )
		
		Emit( "};" )		
		
		Emit( rcname+" "+rcname+"::instance;" )
		
		Emit( rcname+"::decls_t "+rcname+"::decls;" )
		
		EmitBr()
		
		If Not cdecl.IsExtension
			Emit( "bbTypeInfo *bbGetType("+cname+(ctype.IsStruct ? " " Else "*")+"const&){" )
			Emit( "return &"+rcname+"::instance;" )
			Emit( "}" )
	
			Emit( "bbTypeInfo *"+cname+"::typeof()const{" )
			Emit( "return &"+rcname+"::instance;" )
			Emit( "}" )
		endif
		
	End

	'For later...
	Method DiscardGCFields( ctype:ClassType,prefix:String )
		
		For Local vvar:=Eachin ctype.fields
			
			If Not IsGCType( vvar.type ) Continue
			
			Local ctype:=TCast<ClassType>( vvar.type )
			If ctype And ctype.cdecl.kind="struct"
				DiscardGCFields( ctype,prefix+VarName( vvar )+"." )
			Else
				Emit( prefix+VarName( vvar )+".discard();" )
			Endif
			
		Next		
	End
	
	Method EmitFunc( func:FuncValue,init:Bool=False,header:Bool=False )
		
		If func.fdecl.IsAbstract Return
	
		DeclsFunc( func.ftype )
	
		Local proto:=FuncProto( func,header )
		
		If func.invokeNew
		
			proto+=":"+ClassName( func.invokeNew.ctype )+"("+TransArgs( func.invokeNew.args )+")"
			
			'Don't call init if we start with self.new!
			Local cscope:=Cast<ClassScope>( func.scope )
			If func.invokeNew.ctype=cscope.ctype init=False
		End
		
		EmitBr()
		
		Emit( proto+"{" )
		
		If _gctmps
			Emit( "bbGC::popTmps("+_gctmps+");" )
			_gctmps=0
		Endif
		
		If init Emit( "init();" )
			
		'is it 'main'?
		'Local module:=func.scope.FindFile().fdecl.module
		'If func=module.main
			
		If func=_module.main
			EmitMain()
		Endif
		
		If _debug And func.IsMethod And func.cscope.ctype.IsClass And Not func.IsVirtual And Not func.IsExtension

			Emit( "bbDBAssertSelf(this);" )
		Endif
		
		EmitBlock( func )
		
		Emit( "}" )
	End
	
	Method EmitMain()
		
		Emit( "static bool done;" )
		Emit( "if(done) return;" )
		Emit( "done=true;" )
		
		If _module.ident<>"monkey" Emit( "void mx2_monkey_main();mx2_monkey_main();" )

		'init dependent modules...
		For Local dep:=Eachin _module.moduleDeps.Keys
			Local mod2:=Builder.modulesMap[dep]
			Local id:="mx2_"+mod2.ident+"_main();"
			Emit( "void "+id+id )
		Next
		
		'init module files...
		For Local fdecl:=Eachin _module.fileDecls.Backwards()
			Local id:="mx2_"+fdecl.ident+"_init_f();"
			Emit( "void "+id+id )
		Next
		
	End
	
	Method EmitLambda:String( func:FuncValue )
	
		Local ident:String="lambda"+_lambdaId
		_lambdaId+=1
		
		Local bbtype:="bbFunction<"+CFuncType( func.ftype )+">"
		
		Emit( "struct "+ident+" : public "+bbtype+"::Rep{" )
		
		Local ctorArgs:="",ctorInits:="",ctorVals:=""
		
		For Local vvar:=Eachin func.captures
			Local varty:=TransType( vvar.type )
			Local varid:=VarName( vvar )
			
			'Decls( vvar )
			RefsType( vvar.type )
			Emit( varty+" "+varid+";" )
			
			ctorArgs+=","+varty+" "+varid
			ctorInits+=","+varid+"("+varid+")"
			ctorVals+=","+Trans( vvar.init )
		Next
		
		If ctorArgs
			ctorVals="("+ctorVals.Slice( 1 )+")"
			Emit( ident+"("+ctorArgs.Slice( 1 )+"):"+ctorInits.Slice( 1 )+"{" )
			Emit( "}" )
		Endif
		
		Local retType:=TransType( func.ftype.retType )

		Local params:=""
		For Local p:=Eachin func.params
			If params params+=","
			params+=TransType( p.type )+" "+VarName( p )
		Next
		
		Emit( retType+" invoke("+params+"){" )
		
		EmitBlock( func )
		
		Emit( "}" )

		Emit( "void gcMark(){" )
		For Local vvar:=Eachin func.captures
			If Not IsGCType( vvar.type ) Continue
			
			Emit( "bbGCMark("+VarName( vvar )+");" )
			
			MarksType( vvar.type )
		Next
		Emit( "}" )
		
		Emit( "};" )
		
		Return bbtype+"(new "+ident+ctorVals+")"
	End
	
	'***** Block *****
	
	Method DebugInfo:String( stmt:Stmt )
		
		If _debug And stmt.pnode Return "bbDBStmt("+stmt.pnode.srcpos+")"
		
		Return ""
	End
	
	Method EmitDebugInfo( stmt:Stmt )
		
		Local db:=DebugInfo( stmt )
		If Not db Return
		
		If stmt.pnode.srcpos Shr 12=_dbline Return 

		_dbline=stmt.pnode.srcpos Shr 12
		
		Emit( db+";" )
	End
	
	Method BeginBlock()

		BeginGCFrame()
		
		If _debug Emit( "bbDBBlock db_blk;" )

	End
	
	Method EmitStmts( block:Block )
		
		For Local stmt:=Eachin block.stmts
			
			EmitStmt( stmt )
			
			FreeGCTmps()
		Next

	End
	
	Method EndBlock()
	
		EndGCFrame()
	End
	
	Method EmitBlock( block:Block )
	
		BeginBlock()
		
		EmitStmts( block )
		
		EndBlock()
	End
	
	Method EmitBlock( func:FuncValue )
	
		BeginGCFrame( func )
		
		If _debug 
		
			Emit( "bbDBFrame db_f{~q"+func.Name+":"+func.ftype.retType.Name+"("+func.ParamNames+")~q,~q"+func.pnode.srcfile.path+"~q};" )
			
			If func.IsCtor Or func.IsMethod
				
				Select func.cscope.ctype.cdecl.kind
				Case "struct"
					Emit( ClassName( func.selfType )+"*self=&"+Trans( func.selfValue )+";" )
					Emit( "bbDBLocal(~qSelf~q,self);" )
				Case "class"
					Emit( ClassName( func.selfType )+"*self="+Trans( func.selfValue )+";" )
					Emit( "bbDBLocal(~qSelf~q,&self);" )
				End
				
			Endif
			
			For Local vvar:=Eachin func.params
				Emit( "bbDBLocal(~q"+vvar.vdecl.ident+"~q,&"+Trans( vvar )+");" )
			Next
			
		Endif
		
		EmitStmts( func.block )
	
		EndGCFrame()
	End
	
	'***** Stmt *****
	
	Method EmitStmt( stmt:Stmt )
	
		If Not stmt Return
		
		EmitDebugInfo( stmt )
		
		Local exitStmt:=Cast<ExitStmt>( stmt )
		If exitStmt EmitStmt( exitStmt ) ; Return
		
		Local continueStmt:=Cast<ContinueStmt>( stmt )
		If continueStmt EmitStmt( continueStmt ) ; Return
		
		Local returnStmt:=Cast<ReturnStmt>( stmt )
		If returnStmt EmitStmt( returnStmt ) ; Return
		
		Local varDeclStmt:=Cast<VarDeclStmt>( stmt )
		If varDeclStmt EmitStmt( varDeclStmt ) ; Return
		
		Local assignStmt:=Cast<AssignStmt>( stmt )
		If assignStmt EmitStmt( assignStmt ) ; Return
		
		Local evalStmt:=Cast<EvalStmt>( stmt )
		If evalStmt EmitStmt( evalStmt ) ; Return
		
		Local ifStmt:=Cast<IfStmt>( stmt )
		If ifStmt EmitStmt( ifStmt ) ; Return
		
		Local forStmt:=Cast<ForStmt>( stmt )
		If forStmt EmitStmt( forStmt ) ; Return
		
		Local whileStmt:=Cast<WhileStmt>( stmt )
		If whileStmt EmitStmt( whileStmt ) ; Return
		
		Local repeatStmt:=Cast<RepeatStmt>( stmt )
		If repeatStmt EmitStmt( repeatStmt ) ; Return
		
		Local selectStmt:=Cast<SelectStmt>( stmt )
		If selectStmt EmitStmt( selectStmt ) ; Return
		
		Local tryStmt:=Cast<TryStmt>( stmt )
		If tryStmt EmitStmt( tryStmt ) ; Return
		
		Local throwStmt:=Cast<ThrowStmt>( stmt )
		If throwStmt EmitStmt( throwStmt ) ; Return
		
		Local printStmt:=Cast<PrintStmt>( stmt )
		If printStmt EmitStmt( printStmt ) ; Return
		
		TransError( "Translator.EmitSmt" )
	End
	
	Method EmitStmt( stmt:PrintStmt )

		Emit( "bb_print("+Trans( stmt.value )+");" )
	End
	
	Method EmitStmt( stmt:ExitStmt )
	
		Emit( "break;" )
	End
	
	Method EmitStmt( stmt:ContinueStmt )
	
		Emit( "continue;" )
	End
	
	Method EmitStmt( stmt:ReturnStmt )
	
		If Not stmt.value Emit( "return;" ) ; Return
		
		Emit( "return "+Trans( stmt.value )+";" )
	End
	
	Method EmitStmt( stmt:VarDeclStmt )
		
		Local vvar:=stmt.varValue
		Local vdecl:=vvar.vdecl
		
		DeclsVar( vvar.type )
		
		Local tvar:=""
		
		If vdecl.kind="local" And IsGCType( vvar.type )
			
			tvar=InsertGCTmp( vvar )

			If vvar.init Emit( tvar+"="+Trans( vvar.init )+";" )
				
		Else
		
			tvar=VarName( vvar )
			
			Local type:=VarType( vvar )
			
			If vdecl.kind="global" Or vdecl.kind="const" type="static "+type
			
			Local init:="{}"
			If vvar.init init="="+Trans( vvar.init )
			
			Emit( type+" "+tvar+init+";" )
			
			If (vdecl.kind="global" Or vdecl.kind="const") And IsGCType( vvar.type )
				
				Emit( "static struct _"+tvar+"_t:bbGCRoot{" )
				Emit( "void gcMark(){ bbGCMark("+tvar+");}" )
				Emit( "}_"+tvar+";" )
				
				MarksType( vvar.type )
			Endif
			
		Endif
		
		If _debug And vdecl.kind="local" Emit( "bbDBLocal(~q"+vvar.vdecl.ident+"~q,&"+tvar+");" )

	End
	
	Method AssignsTo( type:Type )
		
		MarksType( type )

		Local ctype:=TCast<ClassType>( type )
		If ctype And ctype.IsStruct
			For Local vvar:=Eachin ctype.fields
				AssignsTo( vvar.type )
			Next
		Endif
		
	End
	
	Method EmitStmt( stmt:AssignStmt )
	
		Local op:=stmt.op
		Select op
		Case "~=" op="^="
		Case "mod=" op="%="
		Case "shl=" op="<<="
		Case "shr=" op=">>="
'		Case "="
'			Local vvar:=Cast<VarValue>( stmt.lhs )
'			If vvar And vvar.vdecl.kind="param" FindGCTmp( vvar )
		End
		
		AssignsTo( stmt.lhs.type )
		
		Local lhs:=TransRef( stmt.lhs )
		Local rhs:=Trans( stmt.rhs )
		
		Emit( lhs+op+rhs+";" )
	End

	Method EmitStmt( stmt:EvalStmt )
	
		Emit( Trans( stmt.value )+";" )
	End
	
	Method EmitStmt( stmt:IfStmt )
	
		Emit( "if("+Trans( stmt.cond )+"){" )
		
		EmitBlock( stmt.block )
		
		While stmt.succ
		
			stmt=stmt.succ
			
			If stmt.cond
				Local db:=DebugInfo( stmt )
				If db db+=","
				Emit( "}else if("+db+Trans( stmt.cond )+"){" )
			Else
				Emit( "}else{" )
				EmitDebugInfo( stmt )
			Endif
			
			EmitBlock( stmt.block )
		Wend

		Emit( "}" )
	End
	
	Method EmitStmt( stmt:SelectStmt )
	
		'Local tvalue:=Trans( stmt.value ),head:=True
		Local head:=True
		
		For Local cstmt:=Eachin stmt.cases
		
			If cstmt.values
				Local cmps:=""
				For Local value:=Eachin cstmt.values
					If cmps cmps+="||"
					cmps+=Trans( value )
				Next
				cmps="if("+cmps+"){"
				If Not head cmps="}else "+cmps
				Emit( cmps )
			Else
				Emit( "}else{" )
			Endif
			head=False
			
			EmitBlock( cstmt.block )
		Next
		
		Emit( "}" )
	End
	
	Method EmitStmt( stmt:WhileStmt )
	
		If _debug
			Emit( "{" )
			Emit( "bbDBLoop db_loop;" )
		Endif
	
		Emit( "while("+Trans( stmt.cond )+"){" )
		
		EmitBlock( stmt.block )
		
		Emit( "}" )
		
		If _debug Emit( "}" )
	End
	
	Method EmitStmt( stmt:RepeatStmt )
	
		If _debug
			Emit( "{" )
			Emit( "bbDBLoop db_loop;" )
		Endif
	
	
		If stmt.cond Emit( "do{" ) Else Emit( "for(;;){" )
		
		EmitBlock( stmt.block )
		
		If stmt.cond Emit( "}while(!("+Trans( stmt.cond )+"));" ) Else Emit( "}" )
		
		If _debug Emit( "}" )
	End
	
	Method EmitStmt( stmt:ForStmt )
	
		Emit( "{" )
		BeginGCFrame()
		If _debug Emit( "bbDBLoop db_loop;" )
	
		EmitStmts( stmt.iblock )
		
		Local cond:=Trans( stmt.cond )
		
		If stmt.incr

			EmitStmt( stmt.incr )
			Local incr:=_buf.Pop().Trim().Slice( 0,-1 )

			Emit( "for(;"+cond+";"+incr+"){" )
		Else
			Emit( "while("+cond+"){" )
		Endif
		
		EmitBlock( stmt.block )
		
		Emit( "}" )
		
		EndGCFrame()
		Emit( "}" )
	End
	
	Method EmitStmt( stmt:TryStmt )
	
		Emit( "try{" )

		EmitBlock( stmt.block )
		
		For Local cstmt:=Eachin stmt.catches
		
			Local vvar:=cstmt.vvar
		
			'Uses( vvar.type )
			UsesType( vvar.type )
'			DeclsVar( vvar.type )
			
			If IsGCType( vvar.type )
			
				Emit( "}catch("+TransType( vvar.type )+" ex){" )
				
				BeginBlock()
				
				Local tmp:=InsertGCTmp( vvar )
				
				Emit( tmp+"=ex;" )
				
				EmitStmts( cstmt.block )
				
				EndBlock()
			Else
			
				Emit( "}catch("+VarProto( vvar )+"){" )
				
				EmitBlock( cstmt.block )

			Endif
			
		Next
		
		Emit( "}" )
	End
	
	Method EmitStmt( stmt:ThrowStmt )
		If stmt.value Emit( "throw "+Trans( stmt.value )+";" ) Else Emit( "throw;" )
	End
	
	'***** Value *****
	
	Method Trans:String( value:Value ) Override
	
		Local upCastValue:=Cast<UpCastValue>( value )
		If upCastValue Return Trans( upCastValue )
		
		Local explicitCastValue:=Cast<ExplicitCastValue>( value )
		If explicitCastValue Return Trans( explicitCastValue )
	
		Local literalValue:=Cast<LiteralValue>( value )
		If literalValue Return Trans( literalValue )
		
		Local selfValue:=Cast<SelfValue>( value )
		If selfValue Return Trans( selfValue )
		
		Local superValue:=Cast<SuperValue>( value )
		If superValue Return Trans( superValue )
		
		Local invokeValue:=Cast<InvokeValue>( value )
		If invokeValue Return Trans( invokeValue )
		
		Local memberVarValue:=Cast<MemberVarValue>( value )
		If memberVarValue Return Trans( memberVarValue )
		
		Local memberFuncValue:=Cast<MemberFuncValue>( value )
		If memberFuncValue Return Trans( memberFuncValue )
		
		Local newObjectValue:=Cast<NewObjectValue>( value )
		If newObjectValue Return Trans( newObjectValue )
		
		Local newArrayValue:=Cast<NewArrayValue>( value )
		If newArrayValue Return Trans( newArrayValue )
		
		Local arrayIndexValue:=Cast<ArrayIndexValue>( value )
		If arrayIndexValue Return Trans( arrayIndexValue )
		
		Local pointerIndexValue:=Cast<PointerIndexValue>( value )
		If pointerIndexValue Return Trans( pointerIndexValue )
		
		Local stringIndexValue:=Cast<StringIndexValue>( value )
		If stringIndexValue Return Trans( stringIndexValue )
		
		Local unaryopValue:=Cast<UnaryopValue>( value )
		If unaryopValue Return Trans( unaryopValue )

		Local binaryopValue:=Cast<BinaryopValue>( value )
		If binaryopValue Return Trans( binaryopValue )
		
		Local ifThenElseValue:=Cast<IfThenElseValue>( value )
		If ifThenElseValue Return Trans( ifThenElseValue )
		
		Local pointerValue:=Cast<PointerValue>( value )
		If pointerValue Return Trans( pointerValue )
		
		Local funcValue:=Cast<FuncValue>( value )
		If funcValue Return Trans( funcValue )
		
		Local varValue:=Cast<VarValue>( value )
		If varValue Return Trans( varValue )
		
		Local typeofValue:=Cast<TypeofValue>( value )
		If typeofValue Return Trans( typeofValue )

		Local typeofTypeValue:=Cast<TypeofTypeValue>( value )
		If typeofTypeValue Return Trans( typeofTypeValue )
		
		TransError( "Translator.Trans()" )
		
		Return ""
	End
	
	Method Trans:String( value:UpCastValue )
	
		Local src:="("+Trans( value.value )+")"
	
		'Uses( value.type )			'uses dst type
		UsesType( value.type )
			
		If value.type.Equals( value.value.type ) Return src

		'Uses( value.value.type )	'...and src type
		UsesType( value.value.type )	'...and src type
		
		If IsCValueType( value.type ) Return TransType( value.type )+src

		Return "(("+TransType( value.type )+")"+src+")"
	End
	
	Method Trans:String( value:ExplicitCastValue )
	
		Local src:="("+Trans( value.value )+")"

		If value.type.Equals( value.value.type ) Return src
	
		UsesType( value.type )
		
		If value.value.type=Type.VariantType
			Return src+".get<"+TransType( value.type )+">()"
		Endif
		
		If IsCValueType( value.type ) Return TransType( value.type )+src

		'obj->obj		
		Local ctype:=TCast<ClassType>( value.type )
		If ctype And TCast<ClassType>( value.value.type ) Return "bb_object_cast<"+ClassName( ctype )+"*>"+src
		
		Return "(("+TransType( value.type )+")"+src+")"
	End
	
	Method TransNull:String( type:Type )
	
		Local ptype:=TCast<PrimType>( type )
		If ptype
			If ptype.IsIntegral Return "0"
			If ptype=Type.FloatType Return ".0f"
			If ptype=Type.DoubleType Return "0.0f"
			If ptype=Type.BoolType Return "false"
		Endif
		
		'Refs( type )
		RefsType( type )

		Local etype:=TCast<EnumType>( type )
		If etype Return EnumName( etype )+"(0)"
		
		If IsCValueType( type )
			
			'Uses( type )
			UsesType( type )
			
			Return TransType( type )+"{}"
		Endif

'		Uses( type )		
		Return "(("+TransType( type )+")0)"
	End

	Method Trans:String( value:LiteralValue )
	
		If Not value.value Return TransNull( value.type )
		
		Local ptype:=TCast<PrimType>( value.type )
		If ptype
			
			If ptype.IsIntegral

				Return TransType( value.type )+"("+value.value+")"
#rem
				If value.value="0" Return TransType( value.type )+"(0)"
				
				Select value.type
				Case Type.IntType
					Local ivalue:=Int( value.value )
					If String( ivalue )=value.value Return value.value
				Case Type.UIntType
					Local ivalue:=UInt( value.value )
					If String( ivalue )=value.value Return "bbUInt("+value.value+")"
				Case Type.LongType
					Local ivalue:=Long( value.value )
					If String( ivalue )=value.value Return "bbLong("+value.value+")"
				Case Type.ULongType
					Local ivalue:=ULong( value.value )
					If String( ivalue )=value.value Return "bbULong("+value.value+")"
				End
				
				Return TransType( value.type )+"("+value.value+")"
#end				
				
			Else If ptype.IsReal

				Local t:=value.value
				If t.Find( "." )=-1 And t.Find( "e" )=-1 And t.Find( "E" )=-1 t+=".0"
				
				If ptype=Type.FloatType Return t+"f"
				Return t

			Else If ptype=Type.StringType

				Local str:=value.value
				If str.Length Return "bbString("+EnquoteCppString( str )+","+str.Length+")"
				Return "bbString()"
				
			Endif
		
		Endif
		
		'Refs( value.type )
		RefsType( value.type )
		
		Local etype:=TCast<EnumType>( value.type )
		If etype Return EnumValueName( etype,value.value )
		
		Return value.value
	End
	
	Method Trans:String( value:SelfValue )
	
		If value.func.IsExtension
			If value.ctype.IsStruct Return "(*l_self)"
			Return "l_self"
		Endif
		
		If value.ctype.IsStruct Return "(*this)"
		Return "this"
	End
	
	Method Trans:String( value:SuperValue )
	
		'Uses( value.ctype )
		UsesType( value.ctype )
		
		Local cname:=ClassName( value.ctype )
		
		If value.ctype.IsStruct Return "(*static_cast<"+cname+"*>(this))"
		
		Return "static_cast<"+cname+"*>(this)"
	End
	
	Method TransMember:String( instance:Value,member:Value,invoking:Bool )
	
		UsesType( instance.type )
		
		Local supr:=Cast<SuperValue>( instance )
		
		If supr
			If supr.func And supr.func.IsLambda
				' Call to a base class method inside of a lambda that is inside of a method
				Return "l_self->"+ClassName( supr.ctype )+"::"+Trans( member )
			Endif
			Return ClassName( supr.ctype )+"::"+Trans( member )
		Endif

		Local tinst:=Trans( instance )
		Local tmember:=Trans( member )
		
		If invoking And IsVolatile( instance )
			Local func:=Cast<FuncValue>( member )
			If Not func Or Not func.simpleGetter
				If _gcframe
					tinst="("+AllocGCTmp( instance.type )+"="+tinst+")"
				Else
					tinst="bbGC::tmp("+tinst+")"
					UsesType( instance.type )
					_gctmps+=1
				Endif
			Endif
		Endif

		If IsCValueType( instance.type ) Return tinst+"."+tmember
		
		Return tinst+"->"+tmember
	End
	
	Method TransInvokeMember:String( instance:Value,member:FuncValue,args:Value[] )

		UsesType( instance.type )
			
		If member.IsExtension
			
			Local tinst:=Trans( instance )
			
			If member.selfType.IsStruct
				If Not instance.IsLValue 
					If _gcframe
						tinst="("+AllocGCTmp( instance.type )+"="+tinst+")"
					Else
						Throw New TransEx( "Mark TODO 2" )
					Endif
				Endif
				tinst="&"+tinst
			Else
				If IsVolatile( instance )
					If _gcframe
						tinst="("+AllocGCTmp( instance.type )+"="+tinst+")"
					Else
						Throw New TransEx( "Mark TODO 3" )
					Endif
				Endif
						
			Endif
			
			If args tinst+=","
				
			Return Trans( member )+"("+tinst+TransArgs( args )+")"
		Endif
			
		Return TransMember( instance,member,True )+"("+TransArgs( args )+")"
	End
	
	Method Trans:String( value:InvokeValue )
	
		'Decls( value.type )
		DeclsVar( value.type )
		
		Local mfunc:=Cast<MemberFuncValue>( value.value )
		
		If mfunc Return TransInvokeMember( mfunc.instance,mfunc.member,value.args )
		
		Return Trans( value.value )+"("+TransArgs( value.args )+")"
	End

	Method Trans:String( value:MemberVarValue )
	
		Return TransMember( value.instance,value.member,False )
	End

	Method Trans:String( value:MemberFuncValue )

		Local ctype:=value.member.cscope.ctype
		
		Local func:=value.member
		
		If func.fdecl.IsExtension
			
			ctype=ctype.superType

			UsesType( ctype )
			
			Local cname:=ClassName( ctype )

			Local args:="<"+cname+","+TransType( func.ftype.retType )
			For Local ty:=Eachin func.ftype.argTypes
				args+=","+TransType( ty )
			Next
			args+=">"
		
'			Print "args="+args
		
			Return "bbExtMethod"+args+"(("+cname+"*)("+Trans( value.instance )+"),&"+Trans( value.member )+")"
			
		Endif

		UsesType( ctype )
		
		Local cname:=ClassName( ctype )
		
		Local args:="<"+cname+","+TransType( func.ftype.retType )
		For Local ty:=Eachin func.ftype.argTypes
			args+=","+TransType( ty )
		Next
		args+=">"
		
'		Print "args="+args
		
		Return "bbMethod"+args+"(("+cname+"*)("+Trans( value.instance )+"),&"+cname+"::"+Trans( value.member )+")"
	End
	
	Method Trans:String( value:FuncValue )
	
		'Refs( value )
		RefsFunc( value )
	
		If value.fdecl.kind="lambda" 
			Return EmitLambda( value )
		Endif
		
		Return FuncName( value )
	End
	
	Method Trans:String( value:NewObjectValue )
	
		Local ctype:=value.ctype
		
		'Uses( ctype )
		UsesType( ctype )
	
		Local cname:=ClassName( ctype )
		
		If ctype.ExtendsVoid
			Return "new "+cname+"("+TransArgs( value.args )+")"
		Endif
		
		If ctype.IsStruct
			If Not value.args 
				If Not ctype.cdecl.IsExtern Return cname+"{bbNullCtor}"
				Return cname+"{}"
			Endif
			If value.args[0].type.Equals( ctype ) Return cname+"{"+TransArgs( value.args )+",bbNullCtor}"
			Return cname+"{"+TransArgs( value.args )+"}"
		Endif
		
		Return "bbGCNew<"+cname+">("+TransArgs( value.args )+")"
	End
	
	Method Trans:String( value:NewArrayValue )
	
		Local atype:=value.atype
		
		'Uses( atype.elemType )
		UsesType( atype.elemType )
		
		If value.inits 
			If value.sizes
				Return ArrayName( atype )+"({"+TransArgs( value.inits )+"},"+TransArgs( value.sizes )+")"
			Endif
			Return ArrayName( atype )+"({"+TransArgs( value.inits )+"},"+value.inits.Length+")"
		Endif
		
		Return ArrayName( atype )+"("+TransArgs( value.sizes )+")"
	End
	
	Method Trans:String( value:ArrayIndexValue )
	
		'Uses( value.type )
		UsesType( value.type )
		
		Local val:=Trans( value.value )

		If value.args.Length=1 
			val+="["+TransArgs( value.args )+"]"
		Else
			val+=".at("+TransArgs( value.args )+")"
		Endif
		
		If IsGCPtrType( value.type ) val+=".get()"
			
		Return val
	End
	
	Method Trans:String( value:PointerIndexValue )

		'Uses( value.type )
		UsesType( value.type )
		
		Return Trans( value.value )+"["+Trans( value.index )+"]"
	End

	Method Trans:String( value:StringIndexValue )
	
		Return Trans( value.value )+"["+Trans( value.index )+"]"
	End
	
	Method Trans:String( value:UnaryopValue )
	
		Local op:=value.op
		Select op
		Case "not" op="!"
		End
		
		Local etype:=TCast<EnumType>( value.type )

		Local t:=Trans( value.value )

		If etype t="int("+t+")"
		
		If (op="+" Or op="-") And t.StartsWith( op )	'deal with -- and ++
			t=op+"("+t+")"
		Else
			t=op+t
		Endif
		
		If etype t=EnumName( etype )+"("+t+")"
		
		Return t
	End
	
	Method Trans:String( value:BinaryopValue )
		Local op:=value.op
		Select op
		Case "<=>"
			
			'Uses( value.lhs.type )
			'Uses( value.rhs.type )
			UsesType( value.lhs.type )
			UsesType( value.rhs.type )
 
			Return "bbCompare("+Trans( value.lhs )+","+Trans( value.rhs )+")"
			
		Case "=","<>","<",">","<=",">="
		
			If op="=" op="==" Else If op="<>" op="!="
				
			Local ptype:=TCast<PrimType>( value.lhs.type )
			
			If ptype And ptype=Type.VariantType
				
				Return "(bbCompare("+Trans( value.lhs )+","+Trans( value.rhs )+")"+op+"0)"
			Endif
			
			Local ctype:=TCast<ClassType>( value.lhs.type )
			Local ftype:=TCast<FuncType>( value.lhs.type )
			
			If (ctype And ctype.IsStruct) Or (ftype And op<>"==" And op<>"!=" )
				
				'Uses( value.lhs.type )
				'Uses( value.rhs.type )
				UsesType( value.lhs.type )
				UsesType( value.rhs.type )
			
				Return "(bbCompare("+Trans( value.lhs )+","+Trans( value.rhs )+")"+op+"0)"
			Endif
			
		Case "mod"
		
			Local ptype:=TCast<PrimType>( value.type )
			If ptype=Type.FloatType Or ptype=Type.DoubleType Return "std::fmod("+Trans( value.lhs )+","+Trans( value.rhs )+")"
			
			op="%"
		Case "and" op="&&"
		Case "or" op="||"
		Case "~~" op="^"
		Case "shl" op="<<"
		Case "shr" op=">>"
		End

		Local lhs:=Trans( value.lhs )
		Local rhs:=Trans( value.rhs )
		
		Local etype:=TCast<EnumType>( value.type )
		If etype
			Return EnumName( etype )+"(int("+lhs+")"+op+"int("+rhs+"))"
		Endif
		
		Return "("+lhs+op+rhs+")"

	End
	
	Method Trans:String( value:IfThenElseValue )

		Return "("+Trans( value.value )+" ? "+Trans( value.thenValue )+" : "+Trans( value.elseValue )+")"
	End
	
	Method Trans:String( value:PointerValue )
		
		Return "(&"+TransRef( value.value )+")"
	End
	
	Method Trans:String( value:VarValue )
		
		RefsVar( value )
		
		Local vdecl:=value.vdecl
		
		If (vdecl.kind="local" Or vdecl.kind="param") And IsGCType( value.type )
			Return FindGCTmp( value )
		Endif
		
		If vdecl.kind<>"capture" And IsGCPtrType( value.type ) Return VarName( value )+".get()"
		
		Return VarName( value )
	End
	
	Method Trans:String( value:TypeofValue )
	
		Return "bbGetType("+Trans( value.value )+")"
	End
	
	Method Trans:String( value:TypeofTypeValue )
		
		'Refs( value.ttype )
		RefsType( value.ttype )
	
		Return "bbGetType<"+TransType( value.ttype )+">()"
	End
	
	'***** Refs, ie: LHS of assignment etc *****
	
	Method TransRef:String( value:Value )

		Local arrayIndexValue:=Cast<ArrayIndexValue>( value )
		If arrayIndexValue Return TransRef( arrayIndexValue )
		
		Local pointerIndexValue:=Cast<PointerIndexValue>( value )
		If pointerIndexValue Return TransRef( pointerIndexValue )
		
		Local varValue:=Cast<VarValue>( value )
		If varValue Return TransRef( varValue )
		
		Local memberVarValue:=Cast<MemberVarValue>( value )
		If memberVarValue Return TransRef( memberVarValue )
		
		Throw New TransEx( "Translator_CPP.TransRef() Unrecognized ref value type:"+value.ToString() )
	End
	
	Method TransRef:String( value:ArrayIndexValue )
		
		If value.args.Length=1 Return Trans( value.value )+"["+TransArgs( value.args )+"]"

		Return Trans( value.value )+".at("+TransArgs( value.args )+")"
	End
	
	Method TransRef:String( value:PointerIndexValue )
		
		Return Trans( value.value )+"["+Trans( value.index )+"]"
	End

	Method TransRef:String( value:VarValue )
		
		RefsVar( value )
	
		Local vdecl:=value.vdecl
		
		If (vdecl.kind="local" Or vdecl.kind="param") And IsGCType( value.type )
			Return FindGCTmp( value )
		Endif
		
		Return VarName( value )
	End
	
	Method TransRef:String( value:MemberVarValue )
		
		Local instance:=value.instance
		Local member:=value.member
		
		'Uses( instance.type )
		UsesType( instance.type )
		
		Local supr:=Cast<SuperValue>( instance )
		If supr Return ClassName( supr.ctype )+"::"+TransRef( member )
		
		Local tinst:=Trans( instance )
		Local tmember:=TransRef( member )
		
		If IsCValueType( instance.type ) Return tinst+"."+tmember
		
		Return tinst+"->"+tmember
	End

	'***** Args *****
	
	Method IsVolatileGCType:Bool( arg:Value )
	
		Local ucast:=Cast<UpCastValue>( arg )
		If ucast Return IsVolatileGCType( ucast.value )
		
		Local ecast:=Cast<ExplicitCastValue>( arg )
		If ecast Return IsVolatileGCType( ecast.value )
		
		Local vvar:=Cast<VarValue>( arg )
		If vvar Return vvar.vdecl.kind="global" Or vvar.vdecl.kind="field"
		
		Local mvar:=Cast<MemberVarValue>( arg )
		If mvar Return mvar.member.vdecl.kind="global" Or mvar.member.vdecl.kind="field"
		
		If Cast<LiteralValue>( arg ) Return False
		
		If Cast<SuperValue>( arg ) Return False
		
		If Cast<SelfValue>( arg ) Return False
		
		Return True
	End
	
	Method IsVolatile:Bool( arg:Value )

		If IsGCType( arg.type ) Return IsVolatileGCType( arg )
		
		Return False
	End
	
	Method TransArgs:String( args:Value[] )
	
		Local targs:=""
		
		For Local arg:=Eachin args

			DeclsVar( arg.type )
		
			Local t:=Trans( arg )
			
			If IsVolatile( arg )
				If _gcframe
					t=AllocGCTmp( arg.type )+"="+t
				Else
					t="bbGC::tmp("+t+")"
					UsesType( arg.type )
					_gctmps+=1
				Endif
			Endif
			
			If targs targs+=","
			targs+=t
		Next
		
		Return targs
	End
	
	'***** Type *****
	
	Method TransType:String( type:Type ) Override
	
		Local xtype:=Cast<AliasType>( type )
		If xtype 
			If xtype.adecl.symbol Return xtype.adecl.symbol
			If xtype.adecl.IsExtern Return xtype.adecl.ident
			Return TransType( xtype._alias )
		Endif

		If Cast<VoidType>( type ) Return "void"
		
		Local classType:=Cast<ClassType>( type )
		If classType Return TransType( classType )
		
		Local enumType:=Cast<EnumType>( type )
		If enumType Return TransType( enumType )
	
		Local primType:=Cast<PrimType>( type )
		If primType Return TransType( primType )
		
		Local funcType:=Cast<FuncType>( type )
		If funcType Return TransType( funcType )
		
		Local arrayType:=Cast<ArrayType>( type )
		If arrayType Return TransType( arrayType )
		
		Local pointerType:=Cast<PointerType>( type )
		If pointerType Return TransType( pointerType )
		
		Local genArgType:=Cast<GenArgType>( type )
		If genArgType Return TransType( genArgType )
#rem		
		If TCast<VoidType>( type ) Return "void"
		
		Local classType:=TCast<ClassType>( type )
		If classType Return TransType( classType )
		
		Local enumType:=TCast<EnumType>( type )
		If enumType Return TransType( enumType )
	
		Local primType:=TCast<PrimType>( type )
		If primType Return TransType( primType )
		
		Local funcType:=TCast<FuncType>( type )
		If funcType Return TransType( funcType )
		
		Local arrayType:=TCast<ArrayType>( type )
		If arrayType Return TransType( arrayType )
		
		Local pointerType:=TCast<PointerType>( type )
		If pointerType Return TransType( pointerType )
		
		Local genArgType:=TCast<GenArgType>( type )
		If genArgType Return TransType( genArgType )
#end
		
		'Throw New TransEx( "Translator_CPP.Trans() Type '"+String.FromCString( type.typeName() )+"' not recognized" )
		Throw New TransEx( "Translator_CPP.Trans() Type not recognized" )
	End
	
	Method TransType:String( type:ClassType )
		If type.IsStruct Return ClassName( type )
		Return ClassName( type )+"*"
	End
	
	Method TransType:String( type:EnumType )
		Return EnumName( type )
	End
	
	Method TransType:String( type:PrimType )
		Return type.ctype.cdecl.symbol
	End
	
	Method TransType:String( type:FuncType )
		Return "bbFunction<"+CFuncType( type )+">"
	End
	
	Method TransType:String( type:ArrayType )
		Return ArrayName( type )
	End
	
	Method TransType:String( type:PointerType )
		Return TransType( type.elemType )+"*"
	End
	
	Method TransType:String( type:GenArgType )
		Return type.ToString()
	End
	
	Method ArrayName:String( type:ArrayType )
		If type.rank=1 Return "bbArray<"+HeapVarType( type.elemType )+">"
		Return "bbArray<"+HeapVarType( type.elemType )+","+type.rank+">"
	End
	
	'***** MISC *****

	Method IsCValueType:Bool( type:Type )
	
		Local ctype:=TCast<ClassType>( type )
		If ctype And ctype.IsStruct Return True
	
		Return TCast<PrimType>( type ) Or TCast<FuncType>( type ) Or TCast<ArrayType>( type )
	End
	
	Method CFuncType:String( type:FuncType )
	
		Local retType:=TransType( type.retType )
		
		Local argTypes:=""
		For Local i:=0 Until type.argTypes.Length
			If argTypes argTypes+=","
			argTypes+=TransType( type.argTypes[i] )
		Next
		
		Return retType+"("+argTypes+")"
	End

End

Function GenTypeInfo:Bool( vvar:VarValue )

	'sanity check
	If vvar.vdecl.kind<>"field" And vvar.vdecl.kind="global" And vvar.vdecl.kind="const" Return False
	
	Return True
End

Function GenTypeInfo:Bool( func:FuncValue )
	
	'sanity check
	If func.fdecl.kind<>"method" And func.fdecl.kind<>"function" Return False

	'disable generic method instances
	If func.IsExtension Return func.fdecl.IsExtension
	
	Return True
End

Function GenTypeInfo:Bool( etype:EnumType )

	'disable native enums	
	If etype.edecl.IsExtern Return False
	
	'disable enums in generic scopes
	If etype.scope.IsInstanceOf Return False
	
	Return True
End

Function GenTypeInfo:Bool( ctype:ClassType )

	'disable native types
	If ctype.ExtendsVoid Return False
	
	'disable generic type instances
	If ctype.scope.IsInstanceOf Return False

	'disable structs
	'If ctype.IsStruct Return False

	'disable extensions
	'If ctype.cdecl.IsExtension Return False
	
	Return True
End
