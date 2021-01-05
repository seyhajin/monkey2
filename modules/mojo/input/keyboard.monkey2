
Namespace mojo.input

#Import "native/keyinfo.h"
#Import "native/keyinfo.cpp"

Extern Private

Struct bbKeyInfo
	Field name:Void Ptr
	Field scanCode:Int
	Field keyCode:Int
End

Global bbKeyInfos:bbKeyInfo Ptr

Public

#rem monkeydoc Global instance of the KeyboardDevice class.

#end
Const Keyboard:=New KeyboardDevice

#rem monkeydoc The KeyboardDevice class.

To access the keyboard device, use the global [[Keyboard]] constant.

The keyboard device should only used after a new [[AppInstance]] is created.

All methods that take a `key` parameter can also be combined with 'raw' keys.

A raw key represents the physical location of a key on US keyboards. For example, `Key.Q|Key.Raw` indicates the key at the top left of the
QWERTY keys, as this is where the 'Q' key is on US keyboards.

#end
Class KeyboardDevice

	#rem monkeydoc The current state of the modifier keys.
	#end
	Property Modifiers:Modifier()
		Return _modifiers
	End

	#rem monkeydoc Gets the name of a key.
	
	If `key` is a raw key, returns the name 'printed' on the key, eg: KeyName( Key.W|Key.Raw ) will always return the name of key at the top left of the QWERTY keys.
	
	if `key` is a virtual key, returns the name of the key, eg: KeyName( Key.W ) will always return "W".
	
	#end	
	Method KeyName:String( key:Key )
		If key & Key.Raw
			key=TranslateKey( key&~Key.Raw ) & ~Key.Raw
		Endif
		If key<=Key.None Or key>=Key.Max Return "?????"
		Return _names[key]
	End
	
	#rem monkeydoc Gets the key by a given name.
	#end
	Method KeyFromName:Key( name:String )
		
		For Local i:=0 Until _names.Length
			If _names[i]=name
				Return Cast<Key>( i )
			Endif
		Next
		Return Key.None
	End
	
	#rem monkeydoc Translates a key to/from a raw key.
	
	If `key` is a raw key, returns the corresponding virtual key.
	
	If `key` is a virtual key, returns the corresponding raw key.
	
	#end
	Method TranslateKey:Key( key:Key )
		If key & Key.Raw
			key&=~Key.Raw
			If key<=Key.None Or key>=Key.Max Return Null
#If __TARGET__="emscripten"
			Return key
#Else
			Local keyCode:=SDL_GetKeyFromScancode( Cast<SDL_Scancode>( _raw2scan[key] ) )
			Return KeyCodeToKey( keyCode )
#Endif
		Else
			If key<=Key.None Or key>=Key.Max Return Null
			Local scanCode:=_key2scan[key]
			Return _scan2raw[scanCode]
		Endif
		Return Null
	End
	
	#rem monkeydoc Checks the current up/down state of a key.
	
	Returns true if `key` is currently held down.
	
	If `key` is a raw key, the state of the key as it is physically positioned on US keyboards is returned.
	
	@param key Key to check.
	
	#end
	Method KeyDown:Bool( key:Key )

		Local scode:=ScanCode( key )

		Return _keys[scode].down
	End
	
	#rem monkeydoc Checks if a key was pressed.
	
	Returns true if `key` was pressed since the last call to KeyPressed with the same key.

	If `key` is a raw key, the state of the key as it is physically positioned on US keyboards is returned.
	
	if `repeating` is true, then key repeats are included.
	
	@param key Key to check.
	
	#end
	Method KeyPressed:Bool( key:Key,repeating:Bool=False )
		
		Local scode:=ScanCode( key )
		
		If repeating 
			Local pressed:=_keys[scode].rpressed=_frame
			
			_keys[scode].rpressed=0
			
			Return pressed
		Endif

		Local pressed:=_keys[scode].pressed=_frame
		
		_keys[scode].pressed=0
		
		Return pressed
	End

	#rem monkeydoc Checks if a key was released.
	
	Returns true if `key` was released since the last call to KeyReleased with the same key.
	
	If `key` is a raw key, the state of the key as it is physically positioned on US keyboards is returned.
	
	@param key Key to check.
	
	#end
	Method KeyReleased:Bool( key:Key )
	
		Local scode:=ScanCode( key )
		
		Local released:=_keys[scode].released=_frame
		
		_keys[scode].released=0
		
		Return released
	End
	
	#rem monkeydoc @hidden
	#end
	Method KeyHit:Bool( key:Key,repeating:Bool=False )
		Return KeyPressed( key,repeating )
	End
	
	#rem monkeydoc Peeks at the next character in the character queue.
	#end
	Method PeekChar:Int()
		If _charPut=_charGet Return 0
		Return _charQueue[_charGet & CHAR_QUEUE_MASK]
	End
	
	#rem monkeydoc Gets the next character from the character queue.
	#end
	Method GetChar:Int()
		If _charPut=_charGet Return 0
		Local char:=_charQueue[_charGet & CHAR_QUEUE_MASK]
		_charGet+=1
		Return char
	End
	
	#rem monkeydoc Flushes the character queue.
	
	Removes all queued characters in the character queue.
	
	Note that [[AppInstance.ResetPolledInput|App.ResetPolledInput]] also flushes the character queue.
	
	#end
	Method FlushChars()
		_charPut=0
		_charGet=0
	End
	
	#rem monkeydoc Flushes all keyboard input.
	#end
	Method FlushKeys()
		FlushChars()
		_frame+=1
	End
	
'jl removed	
'	Internal
	
	Method ScanCode:Int( key:Key )
		If key & Key.Raw 
			key&=~Key.Raw
			If key<=0 Or key>=Key.Max Return 0
			Return _raw2scan[ key & ~Key.Raw ]
		Endif
		If key<=0 Or key>=Key.Max Return 0
		Return _key2scan[ key ]
	End
	
	Method KeyCodeToKey:Key( keyCode:Int )
		If (keyCode & $40000000) keyCode=(keyCode & ~$40000000)+$80
		If keyCode<=0 Or keyCode>=Int( Key.Max ) Return Null
		Return Cast<Key>( keyCode )
	End
	
	Method ScanCodeToRawKey:Key( scanCode:Int )
		If scanCode<=0 Or scanCode>=512 Return null
		Return _scan2raw[ scanCode ]
	End
	
	Method Init()
		Local p:=bbKeyInfos
		
		While p->name
		
			Local name:=String.FromCString( p->name )
			Local scanCode:=p->scanCode
			Local keyCode:=p->keyCode
			
			Local key:=KeyCodeToKey( keyCode )
			
			_names[key]=name
			_raw2scan[key]=scanCode
			_scan2raw[scanCode]=key | Key.Raw
			
#If __TARGET__="emscripten"
			_key2scan[key]=scanCode
#Else
			_key2scan[key]=SDL_GetScancodeFromKey( Cast<SDL_Keycode>( keyCode ) )
#Endif
			_scan2key[_key2scan[key]]=key
			
			p=p+1
		Wend

	End
	
	Method Update()
	End
	
	Method SendEvent( event:SDL_Event Ptr )
	
		Select event->type
			
		Case SDL_KEYDOWN
		
			Local kevent:=Cast<SDL_KeyboardEvent Ptr>( event )

			'Update key matrix
			'
			Local scode:=kevent->keysym.scancode
			
			_keys[scode].down=True
			If kevent->repeat_
				_keys[scode].rpressed=_frame
			Else
				_keys[scode].pressed=_frame
				_keys[scode].rpressed=_frame
			Endif
			
			'Update modifiers
			'
			Local key:=KeyCodeToKey( Int( kevent->keysym.sym ) )

			_modifiers=Cast<Modifier>( kevent->keysym.mod_ )
			
			Select key
			Case Key.CapsLock,Key.KeypadNumLock
				_modifiers~=KeyToModifier( key )
			Default
				_modifiers|=KeyToModifier( key )
			End
			
			'Update charqueue
			'			
			Local char:=KeyToChar( _scan2key[scode] )
			If char PushChar( char )

		Case SDL_KEYUP
		
			Local kevent:=Cast<SDL_KeyboardEvent Ptr>( event )
			
			'Update key matrix
			'
			Local scode:=kevent->keysym.scancode
			
			_keys[scode].down=False
			_keys[scode].released=_frame
			
			'Update modifiers
			'
			Local key:=KeyCodeToKey( Int( kevent->keysym.sym ) )
			
			Select key
			Case Key.CapsLock,Key.KeypadNumLock
			Default
				_modifiers&=~KeyToModifier( key )
			End

		Case SDL_TEXTINPUT
		
			Local tevent:=Cast<SDL_TextInputEvent Ptr>( event )
			
			Local text:=String.FromCString( tevent->text )
			
			If text PushChar( text[0] )
		End

	End
	
	Method Reset()
		_charPut=0
		_charGet=0
		For Local i:=0 Until 512
			_keys[i].pressed=0
			_keys[i].rpressed=0
			_keys[i].released=0
		Next
	End

	Private
	
	Struct KeyState
		Field down:Bool
		Field pressed:Int	'frame of last keydown received
		Field rpressed:Int	'frame of last keydown+repeat received
		Field released:Int
	End

	Const CHAR_QUEUE_SIZE:=32
	Const CHAR_QUEUE_MASK:=31

	Field _frame:Int=1
	Field _keys:=New KeyState[512]
	Field _charQueue:=New Int[CHAR_QUEUE_SIZE]
	Field _charPut:Int
	Field _charGet:Int
	Field _modifiers:Modifier

	Field _names:=New String[512]
	Field _raw2scan:=New Int[512]	'no translate
	Field _scan2raw:=New Key[512]	'no translate
	Field _key2scan:=New Int[512]	'translate
	Field _scan2key:=New Int[512]	'translate

	Method New()
	End
	
	Function KeyToModifier:Modifier( key:Int )
		Select key
		Case Key.LeftShift Return Modifier.LeftShift
		Case Key.RightShift Return Modifier.RightShift
		Case Key.LeftControl Return Modifier.LeftControl
		Case Key.RightControl Return Modifier.RightControl
		Case Key.LeftAlt Return Modifier.LeftAlt
		Case Key.RightAlt Return Modifier.RightAlt
		Case Key.LeftGui Return Modifier.LeftGui
		Case Key.RightGui Return Modifier.RightGui
		Case Key.CapsLock Return Modifier.CapsLock
		Case Key.KeypadNumLock Return Modifier.NumLock
		End
		Return Null
	End
	
	Function KeyToChar:Int( key:Int )
		Select key
		Case Key.Backspace,Key.Tab,Key.Enter,Key.Escape,Key.KeyDelete
			Return key
		Case Key.PageUp,Key.PageDown,Key.KeyEnd,Key.Home,Key.Left,Key.Up,Key.Right,Key.Down,Key.Insert
			Return key | $10000
		End
		Return 0
	End
	
	Method PushChar( char:Int )
		If _charPut-_charGet=CHAR_QUEUE_SIZE Return
		_charQueue[ _charPut & CHAR_QUEUE_MASK ]=char
		_charPut+=1
	End
	
End
