
Namespace mx2

#If __TARGET__="windows"
Const HostOS:="windows"
#Else If __TARGET__="macos"
Const HostOS:="macos"
#Else If __TARGET__="linux"
Const HostOS:="linux"
#Else If __TARGET__="raspbian"
Const HostOS:="raspbian"
#Else If __TARGET__="emscripten"
Const HostOS:="emscripten"
#Else If __TARGET__="android"
Const HostOS:="android"
#Else If __TARGET__="ios"
Const HostOS:="ios"
#Endif

Const CHAR_EOL:=10
Const CHAR_TAB:=9
Const CHAR_RETURN:=13
Const CHAR_HASH:=35
Const CHAR_QUOTE:=34
Const CHAR_PLUS:=43
Const CHAR_MINUS:=45
Const CHAR_DOT:=46
Const CHAR_UNDERSCORE:=95
Const CHAR_APOSTROPHE:=39
Const CHAR_DOLLAR:=36
Const CHAR_TILDE:=126
Const CHAR_BACKSLASH:=92

Global STRING_BACKSLASH:=String.FromChar( CHAR_BACKSLASH )
Global STRING_TILDE:=String.FromChar( CHAR_TILDE )
Global STRING_QUOTE:=String.FromChar( CHAR_QUOTE )
Global STRING_EOL:=String.FromChar( CHAR_EOL )
Global STRING_RETURN:=String.FromChar( CHAR_RETURN )
Global STRING_TAB:=String.FromChar( CHAR_TAB )

Global STRING_CPPBACKSLASH:=STRING_BACKSLASH+STRING_BACKSLASH
Global STRING_CPPQUOTE:=STRING_BACKSLASH+STRING_QUOTE
Global STRING_CPPEOL:=STRING_BACKSLASH+"n"
Global STRING_CPPRETURN:=STRING_BACKSLASH+"r"
Global STRING_CPPTAB:=STRING_BACKSLASH+"t"

Global STRING_MX2TILDE:=STRING_TILDE+STRING_TILDE
Global STRING_MX2QUOTE:=STRING_TILDE+"q"
Global STRING_MX2EOL:=STRING_TILDE+"n"
Global STRING_MX2RETURN:=STRING_TILDE+"r"
Global STRING_MX2TAB:=STRING_TILDE+"t"

Global APP_DIR:String

Function MakeIncludePath:String( path:String,baseDir:String )
	
	For Local moddir:=Eachin Module.Dirs
		If path.StartsWith( moddir ) Return path.Slice( moddir.Length )
	Next
	
	If APP_DIR And path.StartsWith( APP_DIR ) Return path.Slice( APP_DIR.Length )
	
	Return path
End

Function HashPath:String( path:String )
	
'	Print "Hash path:"+path
	
	Local cs:UInt=0
	
	For Local i:=0 Until path.Length
		cs=cs*31+path[i]
	Next
	
	Local name:=StripDir( StripExt( path ) )

	Local i:=name.FindLast( "_" )
	If i<>-1
		If i+1<name.Length And IsDigit( name[i+1] ) i+=1
		name=name.Slice( i+1 )
	Endif
	Local hash:=name+Hex( cs ).ToLower()+ExtractExt( path )
	
'	Print "hash="+hash+" ("+path+")"
	
	Return hash
End

Function MungPath:String( path:String )
	Local id:=path
	id=id.Replace( "_","_0" )
	id=id.Replace( "../","_1" )
	id=id.Replace( "/","_2" )
	id=id.Replace( ":","_3" )
	id=id.Replace( " ","_4" )
	id=id.Replace( "-","_5" )
	Return id
End

Function Identize:String( str:String )
	
	str=MungPath( str )

	For Local i:=0 Until str.Length
		
		If IsIdent( str[i] ) Continue
		
		Local rep:="_"+String( str[i]+6 )
		
		str=str.Slice( 0,i )+rep+str.Slice( i+1 )
		
		i+=rep.Length-1
	
	Next
	
	Return str
End

Function CSaveString( str:String,path:String )
	Local t:=stringio.LoadString( path )
	If t<>str stringio.SaveString( str,path )
End

'Should probably just use absolute path if path is outside monkey2 home dir?
'
Function MakeRelativePath:String( path:String,baseDir:String )

	If Not baseDir.EndsWith( "/" )
		Print "Invalid baseDir:"+baseDir
		baseDir+="/"
	End
	
	If path.StartsWith( baseDir ) Return path.Slice( baseDir.Length )
	
	Local relpath:=""

	While Not path.StartsWith( baseDir )
		Local tdir:=baseDir
		baseDir=ExtractDir( baseDir )
		If baseDir=tdir
'			Print "MakeRelativePath Error! baseDir="+baseDir
			Return path
		Endif
		relpath="../"+relpath
	Wend
	
	relpath+=path.Slice( baseDir.Length )
	
'	Print "Result="+relpath
	
	Return relpath
End

Function ToStrings<T>:String[]( bits:T[] )
	Local strs:=New String[bits.Length]
	For Local i:=0 Until strs.Length
		If bits[i] strs[i]=bits[i].ToString()
	Next
	Return strs
End

Function Join<T>:String( bits:T[],sep:String="," )
	Return sep.Join( ToStrings( bits ) )
End

Function SemantRValues:Value[]( exprs:Expr[],scope:Scope )

	Local args:=New Value[exprs.Length]
	For Local i:=0 Until args.Length
		If exprs[i] args[i]=exprs[i].SemantRValue( scope )
	Next
	
	Return args
End

Function SemantArgs:Value[]( exprs:Expr[],scope:Scope )

	Local args:=New Value[exprs.Length]
	For Local i:=0 Until args.Length
		If exprs[i] args[i]=exprs[i].Semant( scope )
	Next
	Return args
End

Function UpCast:Value[]( args:Value[],type:Type )

	args=args.Slice( 0 )
	For Local i:=0 Until args.Length
		If args[i] args[i]=args[i].UpCast( type )
	Next
	Return args
End

Function Types:Type[]( args:Value[] )

	Local types:=New Type[args.Length]
	For Local i:=0 Until types.Length
		If args[i] types[i]=args[i].type
	Next
	Return types
End

Function TypesEqual:Bool( lhs:Type[],rhs:Type[] )

	If lhs.Length<>rhs.Length Return False
	
	For Local i:=0 Until lhs.Length
		If Not lhs[i].Equals( rhs[i] ) Return False
	Next
	
	Return True
End

Function AnyTypeGeneric:Bool( types:Type[] )

	For Local type:=Eachin types
		If type.IsGeneric Return True
	Next
	
	Return False
End

Function AllTypesGeneric:Bool( types:Type[] )

	For Local type:=Eachin types
		If Not type.IsGeneric Return False
	Next
	
	Return True
End

Function DequoteMx2String:String( str:String )

	If str.Length<2 Or str[0]<>CHAR_QUOTE Or str[str.Length-1]<>CHAR_QUOTE
		Print "MX2 string error:"+str
		Return str
	Endif
	
	str=str.Slice( 1,-1 )
	str=str.Replace("~q~q","~q") ' replace all "" with "
	
	Local out:="",i0:=0

	Repeat
		Local i:=str.Find( STRING_TILDE,i0 )
		If i=-1 Or i>=str.Length-1
			If i0 Return out+str.Slice( i0 )
			Return str
		Endif
		Local rep:=""
		Select str[i+1]
		Case CHAR_TILDE	'~
			rep=STRING_TILDE
		'Case CHAR_QUOTE	'"
		'	rep=STRING_QUOTE
		Case 113		'q
			rep=STRING_QUOTE
		Case 110		'n
			rep=STRING_EOL
		Case 114		'r
			rep=STRING_RETURN
		Case 116		't
			rep=STRING_TAB
		Default
			out+=str.Slice( i0,i+2 )
			i0=i+2
			Continue
		End
'		Print "str="+str+" i="+i+" rep="+rep
		out+=str.Slice( i0,i )+rep
		i0=i+2
	Forever
	
	Return ""
#rem	
	str=str.Replace( STRING_MX2TILDE,STRING_TILDE )
	str=str.Replace( STRING_MX2QUOTE,STRING_QUOTE )
	str=str.Replace( STRING_MX2EOL,STRING_EOL )
	str=str.Replace( STRING_MX2RETURN,STRING_RETURN )
	str=str.Replace( STRING_MX2TAB,STRING_TAB )
	
	Return str
#end
End

Function EnquoteCppString:String( str:String )

	str=str.Replace( STRING_BACKSLASH,STRING_CPPBACKSLASH )
	str=str.Replace( STRING_QUOTE,STRING_CPPQUOTE )
	str=str.Replace( STRING_EOL,STRING_CPPEOL )
	str=str.Replace( STRING_RETURN,STRING_CPPRETURN )
	str=str.Replace( STRING_TAB,STRING_CPPTAB )
	
	Return "L"+STRING_QUOTE+str+STRING_QUOTE
End
