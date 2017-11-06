
Namespace mojo.input

Private

Const DEBUG:=True

Const PARANOID:=True

Public

#rem monkeydoc Joystick hat directions.

| JoystickHat value	| 
|:------------------|
| Centered
| Up
| Right
| Down
| Left
| RightUp
| RightDown
| LeftUp
| LeftDown

#end
Enum JoystickHat	'SDL values...
	Centered=0
	Up=1
	Right=2
	Down=4
	Left=8
	RightUp=Right|Up
	RightDown=Right|Down
	LeftUp=Left|Up
	LeftDown=Left|Down
End

#rem monkeydoc The JoystickDevice class.
#end
Class JoystickDevice
	
	#rem monkeydoc True if joystick is currently attached.
	#end
	Property Attached:Bool()
		
		Return _joystick<>Null
	End

	#rem monkeydoc Joystick device name.
	#end	
	Property Name:String()
		
		Return _name
	End
	
	#rem monkeydoc Joystick globally unique identifier.
	#end	
	Property GUID:String()

		Local buf:=New Byte[64]
		SDL_JoystickGetGUIDString( _guid,Cast<libc.char_t Ptr>( buf.Data ),buf.Length )
		buf[buf.Length-1]=0
		Return String.FromCString( buf.Data )
	End

	#rem monkeydoc The number of axes supported by the joystick.
	#end	
	Property NumAxes:Int()
		
		Return _numAxes
	End
	
	#rem monkeydoc The number of balls upported by the joystick.
	#end	
	Property NumBalls:Int()
		
		Return _numBalls
	End
	
	#rem monkeydoc The number of buttons supported by the joystick.
	#end	
	Property NumButtons:Int()
		
		Return _numButtons
	End
	
	#rem monkeydoc The number of hats supported by the joystick.
	#end	
	Property NumHats:Int()
		
		Return _numHats
	End
	
	#rem monkeydoc Gets joystick axis value in the range -1 to 1.
	#end	
	Method GetAxis:Float( axis:Int )
		
		If Not _joystick Return 0
		
		Return (Float(SDL_JoystickGetAxis( _joystick,axis ))+32768)/32767.5-1
	End
	
	#rem monkeydoc Gets joystick ball value.
	#end	
	Method GetBall:Vec2i( ball:Int )

		If Not _joystick Return Null
		
		Local x:Int,y:Int
		SDL_JoystickGetBall( _joystick,ball,Varptr x,Varptr y )
		Return New Vec2i( x,y )
	End

	#rem monkeydoc Gets joystick hat value.
	#end	
	Method GetHat:JoystickHat( hat:Int )

		If Not _joystick Return JoystickHat.Centered
		
		Return Cast<JoystickHat>( SDL_JoystickGetHat( _joystick,hat ) )
	End

	#rem monkeydoc Check up/down state of a button.
	#end
	Method ButtonDown:Bool( button:Int )
		
		If Not _joystick Return False
		
		Return SDL_JoystickGetButton( _joystick,button )
	End
	
	#rem monkeydoc Checks is a button has been pressed.
	#end
	Method ButtonPressed:Bool( button:Int )

		If Not _joystick Return False
		
		If ButtonDown( button )
			If _hits[button] Return False
			_hits[button]=True
			Return True
		Endif
		_hits[button]=False
		Return False
	End
	
	#rem monkeydoc Closes the joystick.
	#end
	Method Close()
		
		If _index=-1 Return
		
		_refs-=1
		If _refs Return

		For Local devid:=0 Until MaxJoysticks
			If _opened[devid]<>Self Continue
			_opened[devid]=Null
			Exit
		Next
		
		Discard()
	End
	
	#rem monkeydoc Gets the number of attached joysticks.
	#end
	Function NumJoysticks:Int()
		
		Return Min( SDL_NumJoysticks(),MaxJoysticks )
	End

	#rem monkeydoc Opens a joystick if possible.
	
	@param index Joystick index.

	#end
	Function Open:JoystickDevice( index:Int )
		
		If index<0 Or index>=MaxJoysticks Return Null
		
		Local joystick:=_joysticks[index]
		If joystick 
			joystick._refs+=1
			Return joystick
		End
		
		For Local devid:=0 Until NumJoysticks()
			
			If _opened[devid]
				If PARANOID
					Local guid:=SDL_JoystickGetDeviceGUID( devid )
					Local error:=True
					For Local joystick:=Eachin _joysticks
						If joystick And joystick._guid=guid
							error=False
							Exit
						Endif
					Next
					If error Print "***** JoystickDevice.Open() Error: device GUID not used by any open joystick! *****"
				Endif
				Continue
			Endif
			
			If PARANOID
				Local guid:=SDL_JoystickGetDeviceGUID( devid )
				For Local joystick:=Eachin _joysticks
					If joystick And joystick._guid=guid
						Print "***** JoystickDevice.Open() Error: device GUID already in use by open joystick! *****"
						Continue
					Endif
				Next
			Endif
			
			Local sdljoystick:=SDL_JoystickOpen( devid )
			If Not sdljoystick Continue

			Local joystick:=New JoystickDevice( index,sdljoystick )
			
			_opened[devid]=joystick
			
			return joystick
		Next
		
		Return Null
	End

	Internal
	
	Function UpdateJoysticks()
		
		SDL_JoystickUpdate()
	End
	
	Function SendEvent( event:SDL_Event Ptr )
		
		If Not _joysticks Return
	
		Select event->type
		Case SDL_JOYDEVICEADDED
			
			Local jevent:=Cast<SDL_JoyDeviceEvent Ptr>( event )
			
			If DEBUG Print "SDL_JOYDEVICEADDED, device id="+jevent->which
			
			For Local i:=MaxJoysticks-1 Until jevent->which Step -1
				_opened[i]=_opened[i-1]
			Next
			_opened[jevent->which]=Null
			
		Case SDL_JOYDEVICEREMOVED
			
			Local jevent:=Cast<SDL_JoyDeviceEvent Ptr>( event )
			
			If DEBUG Print "SDL_JOYDEVICEREMOVED, instanceID="+jevent->which
				
			Local sdljoystick:=SDL_JoystickFromInstanceID( jevent->which )
				
			For Local devid:=0 Until MaxJoysticks
				
				Local joystick:=_joysticks[devid]
				
				If Not joystick Or joystick._joystick<>sdljoystick Continue
			
				For Local i:=devid Until MaxJoysticks-1
					_opened[i]=_opened[i+1]
				Next
				_opened[MaxJoysticks-1]=Null
				
				joystick.Discard()
				
				Return
			Next

			If PARANOID Print "***** SDL_JOYDEVICEREMOVED Error: Can't find joystick for instanceID *****"
				
		End
	
	End
	
	Private
	
	Const MaxJoysticks:=8
	
	'curently open joysticks by user id.
	Global _joysticks:=New JoystickDevice[MaxJoysticks]
	
	'currently opened devices by instance id.
	Global _opened:=New JoystickDevice[MaxJoysticks]
	
	Function GetGUID:String( joystick:SDL_Joystick Ptr )
		
		Local buf:=New Byte[64]
		Local guid:=SDL_JoystickGetGUID( joystick )
		SDL_JoystickGetGUIDString( guid,Cast<libc.char_t Ptr>( buf.Data ),buf.Length )
		buf[buf.Length-1]=0
		Return String.FromCString( buf.Data )
	End
	
	Field _refs:=1
	Field _index:Int
	Field _joystick:SDL_Joystick Ptr
	Field _guid:SDL_JoystickGUID
	Field _name:String
	Field _numAxes:Int
	Field _numBalls:Int
	Field _numButtons:Int
	Field _numHats:Int
	Field _hits:=New Bool[32]
	
	Method New( index:Int,joystick:SDL_Joystick Ptr )
		
		Assert( Not _joysticks[index] )
		
		_index=index
		_joystick=joystick
		_guid=SDL_JoystickGetGUID( joystick )
		_name=String.FromCString( SDL_JoystickName( _joystick ) )
		_numAxes=SDL_JoystickNumAxes( _joystick )
		_numBalls=SDL_JoystickNumBalls( _joystick )
		_numButtons=SDL_JoystickNumButtons( _joystick )
		_numHats=SDL_JoystickNumHats( _joystick )
		
		_joysticks[_index]=Self
		
		If DEBUG Print "Joystick Created, user id="+_index
	End
	
	Method Discard()

		If _index=-1 Return

		libc.memset( _hits.Data,0,_hits.Length )
		
		SDL_JoystickClose( _joystick )
		_joystick=Null
		
		_joysticks[_index]=Null
				
		If DEBUG Print "Joystick Discarded, user id="+_index
		
		_index=-1
	End

End
