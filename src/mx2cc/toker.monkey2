
Namespace mx2

Const TOKE_EOF:=0
Const TOKE_EOL:=1
Const TOKE_IDENT:=2
Const TOKE_KEYWORD:=3
Const TOKE_INTLIT:=4
Const TOKE_FLOATLIT:=5
Const TOKE_STRINGLIT:=6
Const TOKE_SYMBOL:=7
Const TOKE_BADSTRINGLIT:=8
Const TOKE_PREPROC:=9

Global KeyWords:StringMap<String>

Global trigraphs:String[]
Global digraphs:String[]

Global tokerInited:Bool

Function InitToker:Void()
	If tokerInited Return
	tokerInited=True
	
	Local keyWords:="Namespace;Using;Import;Extern;"
	keyWords+="Public;Private;Protected;Internal;Friend;"
	keyWords+="Void;Bool;Byte;UByte;Short;UShort;Int;UInt;Long;ULong;Float;Double;String;Array;Object;Continue;Exit;"
	keyWords+="New;Self;Super;Eachin;True;False;Null;Where;"
	keyWords+="Alias;Const;Local;Global;Field;Method;Function;Property;Getter;Setter;Operator;Lambda;"
	keyWords+="Enum;Class;Interface;Struct;Extends;Implements;Virtual;Override;Abstract;Final;Inline;"
	keyWords+="Var;Varptr;Ptr;"
	keyWords+="Not;Mod;And;Or;Shl;Shr;End;"
	keyWords+="If;Then;Else;Elseif;Endif;"
	keyWords+="While;Wend;"
	keyWords+="Repeat;Until;Forever;"
	keyWords+="For;To;Step;Next;"
	keyWords+="Select;Case;Default;"
	keyWords+="Try;Catch;Throw;Throwable;Variant;CString;WString;TypeInfo;Typeof;"
	keyWords+="Return;Print;Static;Cast;"
	keyWords+="Extension;Protocol;Finalize;Delete"

	KeyWords=New StringMap<String>
	
	For Local kw:=Eachin keyWords.Split( ";" )
		KeyWords.Set( kw.ToLower(),kw )
	Next
	
	trigraphs="<=>".Split( "," )

	digraphs="->,:=,*=,/=,+=,-=,&=,|=,~~=,<=,>=,<>,?.".Split( "," )

End

Class Toker

	Method New()
		InitToker()
		Text=""
	End

	Method New( text:String )
		InitToker()
		Text=text
	End
	
	Method New( toker:Toker )
		InitToker()
		State=toker
	End
	
	Property Text:String()
	
		Return _text
	
	Setter( text:String )

		_text=text
		_len=_text.Length
		_pos=0
		_toke=""
		_tokePos=0
		_tokeType=TOKE_EOL
		_srcPos=0
		_endPos=0
		_linePos=0
		_line=1
		_flags=0
	End
	
	Property Toke:String()
	
		Return _toke
	End
	
	Property TokePos:Int()
	
		Return _tokePos
	End
	
	Property TokeType:Int()
	
		Return _tokeType
	End
	
	Property Line:Int()
	
		Return _line
	End
	
	Property LinePos:Int()

		Return _linePos
	End
	
	Property SrcPos:Int()
	
		Return _srcPos
	End
	
	Property EndPos:Int()
	
		Return _endPos
	
	End
	
	Property State:Toker()
	
		Return New Toker( Self )
	
	Setter( toker:Toker )
	
		_text=toker._text
		_len=toker._len
		_pos=toker._pos
		_toke=toker._toke
		_tokePos=toker._tokePos
		_tokeType=toker._tokeType
		_line=toker._line
		_srcPos=toker._srcPos
		_endPos=toker._endPos
		_linePos=toker._linePos
		_flags=toker._flags
	End
	
	Method Bump:String()
		
		'update endpos
		If _flags & 1 _endPos=(_line Shl 12) | (_pos-_linePos)
		
		'skip whitespace
		While _pos<_len And _text[_pos]<=32 And _text[_pos]<>CHAR_EOL
			_pos+=1
		Wend

		'update toke start pos
		_toke=""		
		_tokePos=_pos
		_srcPos=(_line Shl 12) | (_pos-_linePos)
		_flags|=1

		'check end of file
		If _pos=_len
			_tokeType=TOKE_EOF
			Return _toke
		Endif
		
		Local ch:=_text[_pos]
		_pos+=1
		
		If IsAlpha( ch ) Or ch=CHAR_UNDERSCORE
		
			While _pos<_len
				Local ch:=_text[_pos]
				If Not IsIdent( ch ) Exit
				_pos+=1
			Wend
			
			_toke=_text.Slice( _tokePos,_pos )
			
			Local kw:=_toke.ToLower()
			
			If KeyWords.Get( kw )
				_toke=kw
				_tokeType=TOKE_KEYWORD
			Else
				_tokeType=TOKE_IDENT
			Endif
			
		Else If IsDigit( ch ) Or (ch=CHAR_DOT And _pos<_len And IsDigit( _text[_pos] ))

			_tokeType=TOKE_INTLIT
			If ch=CHAR_DOT
				_tokeType=TOKE_FLOATLIT
				_pos+=1
			Endif
			
			While _pos<_len And IsDigit( _text[_pos] )
				_pos+=1
			Wend
			
			'.#
			If _pos+1<_len And _text[_pos]=CHAR_DOT And IsDigit( _text[_pos+1] ) And _tokeType=TOKE_INTLIT
				_tokeType=TOKE_FLOATLIT
				_pos+=2
				While _pos<_len And IsDigit( _text[_pos] )
					_pos+=1
				Wend
			Endif
			
			'e, E...
			If _pos+1<_len And (_text[_pos]=69 Or _text[_pos]=101)
				Local tpos:=_pos+1
				If _text[tpos]=43 Or _text[tpos]=45 tpos+=1
				If tpos<_len And IsDigit( _text[tpos] )
					_tokeType=TOKE_FLOATLIT
					_pos=tpos+1
					While _pos<_len And IsDigit( _text[_pos] )
						_pos+=1
					Wend
				Endif
			Endif
			
		Else If ch=CHAR_QUOTE
		
			While _pos<_len
				Local ch:=_text[_pos]
				If ch=CHAR_TILDE And _text[_pos+1]=CHAR_TILDE     ' ~~  - double-tilde = escape sequence
					_pos+=2
				'Elseif ch=CHAR_TILDE And _text[_pos+1]=CHAR_QUOTE ' ~"  - tilde + doublequote = escape sequence
				'	_pos+=2
				Elseif ch=CHAR_QUOTE
					If _text[_pos+1]=CHAR_QUOTE                   ' ""  - double-doublequote = escape sequence
						_pos+=2
					Else
						Exit                                      ' "   - single doublequote = end of string
					Endif
				Else
					_pos+=1
				Endif
				If ch=CHAR_EOL
					_linePos=_pos
					_line+=1
				Endif
			Wend
			If _pos<_len And _text[_pos]=CHAR_QUOTE
				_tokeType=TOKE_STRINGLIT
				_pos+=1
			Else
				_tokeType=TOKE_BADSTRINGLIT
			Endif
			
		Else If ch=CHAR_DOLLAR And _pos<_len And IsHexDigit( _text[_pos] )
		
			_pos+=1
			While _pos<_len And IsHexDigit( _text[_pos] )
				_pos+=1
			Wend
			
			_tokeType=TOKE_INTLIT
			
		Else If ch=CHAR_HASH And (_tokeType=TOKE_EOL Or _tokeType=TOKE_PREPROC)
		
			While _pos<_len And _text[_pos]<>CHAR_EOL
				_pos+=1
			Wend
			
			If _pos<_len
				_pos+=1
				_linePos=_pos
				_line+=1
			Endif
			
			If _tokeType=TOKE_PREPROC Or _tokeType=TOKE_EOL _flags&=~1
			
			_tokeType=TOKE_PREPROC
			
		Else If ch=CHAR_APOSTROPHE
		
			While _pos<_len And _text[_pos]<>CHAR_EOL
				_pos+=1
			Wend
			
			_tokePos=_pos

			If _pos<_len
				_pos+=1
				_linePos=_pos
				_line+=1
			Endif
			
			If _tokeType=TOKE_PREPROC Or _tokeType=TOKE_EOL _flags&=~1
			
			_tokeType=TOKE_EOL
			
		Else If ch=CHAR_EOL
			
			_linePos=_pos
			_line+=1
		
			If _tokeType=TOKE_PREPROC Or _tokeType=TOKE_EOL _flags&=~1
				
			_tokeType=TOKE_EOL
		Else
		
			Local found:=False

			If _pos<_len-1
				Local ch2:=_text[_pos]
				Local ch3:=_text[_pos+1]
				For Local t:=Eachin trigraphs
					If ch=t[0] And ch2=t[1] And ch3=t[2]
						_pos+=2
						found=True
						Exit
					Endif
				Next
			Endif
			
			If Not found And _pos<_len
				Local ch2:=_text[_pos]
				For Local t:=Eachin digraphs
					If ch=t[0] And ch2=t[1]
						_pos+=1
						Exit
					Endif
				Next
			Endif
			
			_tokeType=TOKE_SYMBOL
		Endif
		
		If Not _toke _toke=_text.Slice( _tokePos,_pos )

		Return _toke
	End
	
	Private

	Field _text:String
	Field _len:Int
	Field _pos:Int
	Field _toke:String
	Field _tokeType:Int
	Field _tokePos:Int
	Field _line:Int
	Field _srcPos:Int
	Field _endPos:Int
	Field _linePos:Int
	Field _flags:Int
End
