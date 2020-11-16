
Namespace mx2cc

#Import "<std>"

#Import "mx2"
#Import "findmsvc"

#Import "newdocs/docsnode"
#Import "newdocs/docsbuffer"
#Import "newdocs/docsmaker"
#Import "newdocs/markdown"

Using mx2.newdocs

#Import "geninfo/geninfo"

Using libc..
Using std..
Using mx2..

Global opts_time:Bool

Global StartDir:String

Global profileName:String

Const TestArgs:="mx2cc makemods"

'Const TestArgs:="mx2cc makeapp src/mx2cc/test.monkey2"

Function Main()
	
	'Set aside 64M for GC!
	GCSetTrigger( 64*1024*1024 )
	
	Print ""
	Print "Mx2cc version "+MX2CC_VERSION+MX2CC_VERSION_EXT
	
	StartDir=CurrentDir()
	
	ChangeDir( AppDir() )
	
	Local env:="bin/env_"+HostOS+".txt"
	
	While Not IsRootDir( CurrentDir() ) And GetFileType( env )<>FILETYPE_FILE
	
		ChangeDir( ExtractDir( CurrentDir() ) )
	Wend
	
	If GetFileType( env )<>FILETYPE_FILE Fail( "Unable to locate mx2cc 'bin' directory" )

	CreateDir( "tmp" )
	
	Local args:String[]

#If __CONFIG__="debug"
'	Local tenv:="bin/env_"+HostOS+"_dev.txt"
'	If GetFileType( tenv )=FileType.File env=tenv
	args=TestArgs.Split( " " )
#else
	args=AppArgs()
#endif

	LoadEnv( env )
	
	Local moddirs:=New StringStack
	moddirs.Add( CurrentDir()+"modules/" )
	For Local moddir:=Eachin GetEnv( "MX2_MODULE_DIRS" ).Split( ";" )
		moddir=moddir.Replace( "\","/" )
		If GetFileType( moddir )<>FileType.Directory Continue
		moddir=RealPath( moddir )
		If Not moddir.EndsWith( "/" ) moddir+="/"
		If Not moddirs.Contains( moddir ) moddirs.Add( moddir )
	Next
	Module.Dirs=moddirs.ToArray()
	
	If args.Length<2

		Print ""
		Print "Mx2cc usage: MX2CC [action] [options] [source|modules]"
		Print ""
		Print "Actions:"
		print "  makeapp      - make an application."
		print "  makemods     - make modules."
		print "  makedocs     - make docs."
		Print ""
		Print "Options:"
		Print "  -quiet       - emit less info when building."
		Print "  -verbose     - emit more info when building."
		Print "  -clean       - force clean rebuild."
		Print "  -time        - output build time information."
		Print "  -parse       - parse only."
		Print "  -semant      - parse and semant."
		Print "  -translate   - parse, semant and translate."
		Print "  -build       - parse, semant, translate and build."
		Print "  -run         - the works! The default."
		Print "  -apptype=    - app type to make, one of : gui, console. (Defaults: gui)."
		print "  -target=     - build target, one of: windows, macos, linux, emscripten, wasm, android, ios, desktop. Desktop is an alias for current host. (Defaults: desktop)."
		Print "  -config=     - build config, one of: debug, release. (Defaults: debug)."
		Print ""
		Print "Sources:"
		Print "  for makeapp  - single monkey2 source file."
		Print "  for makemods - space separated list of modules, or nothing to make all modules."
		Print "  for makedocs - space separated list of modules, or nothing to make all docs."

#If __DESKTOP_TARGET__
		If Int( GetEnv( "MX2_USE_MSVC" ) ) and HostOS="windows"
			system( "cl > tmp\_v.txt" )		'doesn't work?
			Print ""
			Print "Mx2cc using cl version:"
			Print ""
			Print LoadString( "tmp/_v.txt" )
		Else
			system( "g++ --version > tmp/_v.txt" )
			Print ""
			Print "Mx2cc using g++ version:"
			Print ""
			Print LoadString( "tmp/_v.txt" )
		Endif
#Endif
		exit_( 0 )
	Endif

	Local ok:=False

	Try
	
		Local cmd:=args[1]
		args=args.Slice( 2 )
		
		Local start:=std.time.Now()
		
		Select cmd
		Case "geninfo"
			ok=GenInfo( args )
		Case "makeapp"
			ok=MakeApp( args )
		Case "makemods"
			ok=MakeMods( args )
		Case "makedocs"
			ok=MakeDocs( args )
		Default
			Fail( "Unrecognized mx2cc command: '"+cmd+"'" )
		End
		
		Local elapsed:=std.time.Now()-start
		
		If opts_time Print "Elapsed time="+elapsed
		
	Catch ex:BuildEx
	
		Fail( "Internal mx2cc build error" )
	End
	
	If Not ok libc.exit_( 1 )
End

Function GenInfo:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="module"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=2
	opts.geninfo=True
	
	args=ParseOpts( opts,args )
	If args.Length<>1 Fail( "Invalid app source file" )
		
	Local cd:=CurrentDir()
	ChangeDir( StartDir )
	opts.mainSource=RealPath( args[0].Replace( "\","/" ) )
	ChangeDir( cd )
	
	Print ""
	Print "***** Generating info for "+opts.mainSource+"' "+profileName+" *****"
	Print ""

	New BuilderInstance( opts )

	Local gen:=New GeninfoGenerator
	
	Builder.Parse()
	
	If opts.passes=1
		gen.GenSemantInfo()
'		gen.GenParseInfo()
	Else
		If Not Builder.errors.Length Builder.Semant()
		gen.GenSemantInfo()
	Endif
	
	Return Builder.errors.Length=0
End

Function MakeApp:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="app"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=5
	
	args=ParseOpts( opts,args )
	
	If args.Length<>1 Fail( "Invalid app source file" )
	
	Local cd:=CurrentDir()
	ChangeDir( StartDir )
	
	'DebugStop()
	
	Local srcPath:=RealPath( args[0].Replace( "\","/" ) )
	
	ChangeDir( cd )
	
	opts.mainSource=srcPath
	
	Print ""
	Print "***** Making app '"+opts.mainSource+"' "+profileName+" *****"
	Print ""

	New BuilderInstance( opts )

	'pass1 	
	Builder.Parse()
	If opts.passes=1 Return Builder.errors.Length=0
	If Builder.errors.Length Return False
	
	Builder.Semant()
	If opts.passes=2 Return Builder.errors.Length=0
	If Builder.errors.Length Return False
	
	Builder.Translate()
	If opts.passes=3 Return Builder.errors.Length=0
	If Builder.errors.Length Return False
	
	Builder.product.Build()
	If Builder.errors.Length Return False
	If opts.passes=4
		Print "Application built:"+Builder.product.outputFile
		Return True
	Endif
	
	Builder.product.Run()
	Return True
End

Function MakeMods:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="module"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=4
	
	args=ParseOpts( opts,args )

	If Not args args=EnumModules()
	
	Local errs:=0
	
	Local target:=opts.target
	
	For Local modid:=Eachin args
		
		Local path:=""
		For Local moddir:=Eachin Module.Dirs
			path=moddir+modid+"/"+modid+".monkey2"
			If GetFileType( path )=FileType.File Exit
			path=""
		Next
		If Not path Fail( "Module '"+modid+"' not found" )
	
		Print ""
		Print "***** Making module '"+modid+"' "+profileName+" *****"
		Print ""
		
		opts.mainSource=RealPath( path )
		opts.target=target
		
		New BuilderInstance( opts )
		
		Builder.Parse()
		If Builder.errors.Length errs+=1;Continue
		If opts.passes=1 Continue

		Builder.Semant()
		If Builder.errors.Length errs+=1;Continue
		If opts.passes=2 Continue
		
		Builder.Translate()
		If Builder.errors.Length errs+=1;Continue
		If opts.passes=3 Continue
		
		Builder.product.Build()
		If Builder.errors.Length errs+=1;Continue
	Next
	
	Return errs=0
End

Function MakeDocs:Bool( args:String[] )

	Local opts:=New BuildOpts
	opts.productType="module"
	opts.target="desktop"
	opts.config="debug"
	opts.clean=False
	opts.fast=True
	opts.verbose=0
	opts.passes=2
	opts.makedocs=true
	
	args=ParseOpts( opts,args )
	
	opts.clean=False
	
	If Not args
		args=EnumModules()
		DeleteDir( "docs/modules",True )
	Endif

	Local docsDir:=RealPath( "docs" )+"/"
	
	Local pageTemplate:=LoadString( "docs/new_docs_page_template.html" )
	
	Local docsMaker:=New DocsMaker( docsDir,pageTemplate )

	Local errs:=0
	
	For Local modid:=Eachin args
		
		Local path:=""
		For Local moddir:=Eachin Module.Dirs
			path=moddir+modid+"/"+modid+".monkey2"
			If GetFileType( path )=FileType.File Exit
			path=""
		Next
		If Not path Fail( "Module '"+modid+"' not found" )
	
		Print ""
		Print "***** Doccing module '"+modid+"' *****"
		Print ""
		
		opts.mainSource=RealPath( path )
		
		New BuilderInstance( opts )

		Builder.Parse()
		If Builder.errors.Length errs+=1;Continue
		
		Builder.Semant()
		If Builder.errors.Length errs+=1;Continue

		Local module:=Builder.modules.Top
		
		docsMaker.CreateModuleDocs( module )
		
	Next
	
	Local buf:=New StringStack
	Local modsbuf:=New StringStack
	
	For Local modid:=Eachin EnumModules()

		Local index:=LoadString( "docs/modules/"+modid+"/manual/index.js" )
		If index and Not index.Trim() Print "module OOPS modid="+modid
		If index buf.Push( index )
		
		index=LoadString( "docs/modules/"+modid+"/module/index.js" )
		If index and Not index.Trim() Print "manual OOPS modid="+modid
		If index modsbuf.Push( index )
	Next
	
	buf.Add( "{text:'Modules reference',children:[~n"+modsbuf.Join( "," )+"]}~n" )
	
	Local tree:=buf.Join( "," )
	
	Local page:=LoadString( "docs/new_docs_template.html" )
	page=page.Replace( "${DOCS_TREE}",tree )
	SaveString( page,"docs/newdocs.html" )
	
	Print "~n[#####] Makedocs complete."
	
	Return True
End

Function ParseOpts:String[]( opts:BuildOpts,args:String[] )

	Global done:=False
	Assert( Not done )
	done=True
	
	opts.verbose=Int( GetEnv( "MX2_VERBOSE" ) )
	
	Local i:=0
	
	For i=0 Until args.Length
	
		Local arg:=args[i]
		
		' Options without parameters
		Select arg
		Case "-run"
			opts.passes=5
		Case "-build"
			opts.passes=4
		Case "-translate"
			opts.passes=3
		Case "-semant"
			opts.passes=2
		Case "-parse"
			opts.passes=1
		Case "-clean"
			opts.clean=True
		Case "-quiet"
			opts.verbose=-1
		Case "-verbose"
			opts.verbose=1
		Case "-time"
			opts_time=True
		Default
			If arg.StartsWith( "-" )
				' Options with parameters
				Local j:=arg.Find( "=" )
				
				If j=-1 Fail( "Expected value for option '"+arg+"'" )
					
				Local opt:=arg.Slice( 0,j ),val:=arg.Slice( j+1 )
				
				Local path:=val.Replace( "\","/" )
				If path.StartsWith( "~q" ) And path.EndsWith( "~q" ) path=path.Slice( 1,-1 )
				
				val=val.ToLower()
				
				Select opt
				Case "-product"
					opts.product=path
				Case "-apptype"
					opts.appType=val
				Case "-target"
					Select val
					Case "desktop","windows","macos","linux","raspbian","emscripten","android","ios"
						opts.target=val
					Default
						Fail( "Invalid value for 'target' option: '"+val+"' - must be 'desktop', 'raspbian', 'emscripten', 'android' or 'ios'" )
					End
				Case "-config"
					Select val
					Case "debug","release"
						opts.config=val
					Default
						Fail( "Invalid value for 'config' option: '"+val+"' - must be 'debug' or 'release'" )
					End
				Case "-verbose"
					Select val
					Case "0","1","2","3","-1"
						opts.verbose=Int( val )
					Default
						Fail( "Invalid value for 'verbose' option: '"+val+"' - must be '0', '1', '2', '3' or '-1'" )
					End
				Default
					Fail( "Unrecognized option '"+arg+"'" )
				End
			Else
				' Path to monkey2 file
				Exit
			Endif
		End
	Next
	args=args.Slice( i )
	
	If Not opts.target Or opts.target="desktop" opts.target=HostOS
		
	opts.wholeArchive=Int( GetEnv( "MX2_WHOLE_ARCHIVE" ) )
		
	opts.threads=Int( GetEnv( "MX2_THREADS" ) )
		
	opts.toolchain="gcc"
	
	Select opts.target
	Case "windows"
		
		If Not opts.appType opts.appType="gui"
		
		opts.arch=GetEnv( "MX2_ARCH_"+opts.target.ToUpper(),"x86" )
		
		If opts.arch<>"x64" And opts.arch<>"x86"
			Fail( "Unrecognized architecture '"+opts.arch+"'" )
		Endif
		
'		Print "MX2_USE_MSVC='"+GetEnv( "MX2_USE_MSVC" )+"'"
		
		Local msvc:=GetEnv( "MX2_USE_MSVC" )
		
		If msvc=""
			msvc=FindMSVC() ? "1" Else "0"
		Endif
		
		If Int( msvc )
			
			opts.toolchain="msvc"
			
			Local arch:=opts.arch.ToUpper()
			
			SetEnv( "PATH",GetEnv( "MX2_MSVC_PATH_"+arch )+";"+GetEnv( "PATH" ) )
			SetEnv( "INCLUDE",GetEnv( "MX2_MSVC_INCLUDE_"+arch ) )
			SetEnv( "LIB",GetEnv( "MX2_MSVC_LIB_"+arch ) )
			
		Endif
	
		If opts.arch="x64" And opts.toolchain<>"msvc"
			'Fail( "x64 builds for windows currently only supported for msvc" )
		Endif
		
	Case "macos","linux"
		
		If Not opts.appType opts.appType="gui"
		
		opts.arch="x64"
		
	Case "raspbian"

		If Not opts.appType opts.appType="gui"
			
		opts.arch="arm32"
			
		SetEnv( "PATH",GetEnv( "MX2_RASPBIAN_TOOLS" )+";"+GetEnv( "PATH" ) )
		
	Case "emscripten"
		
		If Not opts.appType opts.appType="wasm"
			
		opts.arch="llvm"
		
		opts.threads=False
		
	Case "android"
		
		opts.arch=GetEnv( "MX2_ANDROID_APP_ABI","armeabi-v7a" )
		
	Case "ios"
		
		opts.arch="armv7 arm64"
		
		If Int( GetEnv( "MX2_IOS_USE_SIMULATOR" ) ) 
			opts.arch="x64"
			opts.threads=0 'Don't support threads
		End
		
	Default
		
		Fail( "Unrecognized target '"+opts.target+"'" )
	
	End
	
	Select opts.appType
	Case "console","gui"
		
		Select opts.target
		Case "windows","macos","linux","raspbian"
		Default
			Fail( "apptype '"+opts.appType+"' is only valid for desktop targets" )
		End
		
	case "wasm","asmjs","wasm+asmjs"
		
		If opts.target<>"emscripten" Fail( "apptype '"+opts.appType+"' is only valid for emscripten target" )
			
	case ""
	Default
		Fail( "Unrecognized apptype '"+opts.appType+"'" )
	End
	
	profileName="("+opts.target+" "+opts.config+" "+opts.arch+" "+opts.toolchain+(opts.threads ? " mx" Else "")+")"
		
	Return args
End

Function EnumModules( out:StringStack,cur:String,src:String,deps:StringMap<StringStack> )
	
	If Not deps.Contains( cur )
		Print "Can't find module dependancy '"+cur+"' - check module.json file for '"+src+"'"
		Return
	End
	
	If out.Contains( cur ) Return
	
	For Local dep:=Eachin deps[cur]
		EnumModules( out,dep,cur,deps )
	Next
	
	out.Push( cur )
End

Function EnumModules:String[]()

	Local mods:=New StringMap<StringStack>
	
	For Local moddir:=Eachin Module.Dirs
		
		For Local f:=Eachin LoadDir( moddir )
		
			Local dir:=moddir+f+"/"
			If GetFileType( dir )<>FileType.Directory Continue
			
			Local str:=LoadString( dir+"module.json" )
			If Not str Continue
			
			Local obj:=JsonObject.Parse( str )
			If Not obj
				Print "Error parsing json:"+dir+"module.json"
				Continue
			Endif
			
			Local name:=obj["module"].ToString()
			If name<>f Continue
			
			Local deps:=New StringStack
			If name<>"monkey" deps.Push( "monkey" )
			
			Local jdeps:=obj["depends"]
			If jdeps
				For Local dep:=Eachin jdeps.ToArray()
					deps.Push( dep.ToString() )
				Next
			Endif
			
			mods[name]=deps
		Next
	
	Next
	
	Local out:=New StringStack
	For Local cur:=Eachin mods.Keys
		EnumModules( out,cur,"",mods )
	Next
	
	Return out.ToArray()
End

Function LoadEnv:Bool( path:String )

	SetEnv( "MX2_HOME",CurrentDir() )
	SetEnv( "MX2_MODULES",CurrentDir()+"modules" )

	Local lineid:=0
	
	For Local line:=Eachin stringio.LoadString( path ).Split( "~n" )
		lineid+=1
		
		line=line.Trim()
		If Not line Or line.StartsWith( "'" ) Or line.StartsWith( "#" ) Continue
	
		Local i:=line.Find( "=" )
		If i=-1 Fail( "Env config file error at line "+lineid )
		
		Local name:=line.Slice( 0,i ).Trim()
		Local value:=line.Slice( i+1 ).Trim()
		
		value=ReplaceEnv( value,lineid )
		
		SetEnv( name,value )

	Next
	
	Return True
End

Function ReplaceEnv:String( str:String,lineid:Int )
	Local i0:=0
	Repeat
		Local i1:=str.Find( "${",i0 )
		If i1=-1 Return str
		
		Local i2:=str.Find( "}",i1+2 )
		If i2=-1 Fail( "Env config file error at line "+lineid )
		
		Local name:=str.Slice( i1+2,i2 ).Trim()
		
		Local value:=GetEnv( name )
		
		If Not value
			
			Select name
			Case "MX2_IOS_SDK"
				
				Local sdk:="iphoneos"
				
				If Int( GetEnv( "MX2_IOS_USE_SIMULATOR" ) ) sdk="iphonesimulator"
		
				system( "xcrun --sdk "+sdk+" --show-sdk-path >tmp/_p.txt" )
				
				value=LoadString( "tmp/_p.txt" ).Trim()
				
				SetEnv( "MX2_IOS_SDK",value )
				
			Case "MX2_IOS_ARCHS"
				
				value="-arch armv7 -arch arm64"
				
				If Int( GetEnv( "MX2_IOS_USE_SIMULATOR" ) ) value="-arch x86_64"
			End
			
			If value SetEnv( name,value )
			
		Endif
		
		str=str.Slice( 0,i1 )+value+str.Slice( i2+1 )
		i0=i1+value.Length
		
	Forever
	Return ""
End

Function Fail( msg:String )

	Print ""
	Print "***** Fatal mx2cc error *****"
	Print ""
	Print msg
		
	exit_( 1 )
End
