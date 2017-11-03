
Namespace mojo.input

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
	
	Global JoystickAdded:Void( index:Int )
	
	Global JoystickRemoved:Void( index:Int )
	
	#rem monkeydoc True if joystick is currently attached.
	#end
	Property Attached:Bool()
		
		Return _attached
	End

	#rem monkeydoc Joystick device name.
	#end	
	Property Name:String()
		Return _name
	End
	
	#rem monkeydoc Joystick globally unique identifier.
	#end	
	Property GUID:String()
		Return _guid
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
		Return (Float(SDL_JoystickGetAxis( _joystick,axis ))+32768)/32767.5-1
	End
	
	#rem monkeydoc Gets joystick ball value.
	#end	
	Method GetBall:Vec2i( ball:Int )
		Local x:Int,y:Int
		SDL_JoystickGetBall( _joystick,ball,Varptr x,Varptr y )
		Return New Vec2i( x,y )
	End

	#rem monkeydoc Gets joystick hat value.
	#end	
	Method GetHat:JoystickHat( hat:Int )
		Return Cast<JoystickHat>( SDL_JoystickGetHat( _joystick,hat ) )
	End

	#rem monkeydoc Check up/down state of a button.
	#end
	Method ButtonDown:Bool( button:Int )
		Return SDL_JoystickGetButton( _joystick,button )
	End
	
	#rem monkeydoc Checks is a button has been pressed.
	#end
	Method ButtonPressed:Bool( button:Int )
		If ButtonDown( button )
			If _hits[button] Return False
			_hits[button]=True
			Return True
		Endif
		_hits[button]=False
		Return False
	End
	
	#rem monkeydoc Gets the number of joysticks attached.
	#end
	Function NumJoysticks:Int()
		Return Min( SDL_NumJoysticks(),8 )
	End

	#rem  monkeydoc @hidden
	#end	
	Function UpdateJoysticks()
		SDL_JoystickUpdate()
	End
	
	#rem monkeydoc Opens a joystick device.
	
	@param index Joystick index.

	#end
	Function Open:JoystickDevice( index:Int )
		
		Assert( index>=0 And index<8 )
		
		Local joystick:=_joysticks[index]
		
		If Not joystick
			
			Local sdlJoystick:=SDL_JoystickOpen( index )
			If Not sdlJoystick Return Null
			
			joystick=New JoystickDevice( sdlJoystick )
			_joysticks[index]=joystick
			
		Endif
		
		Return joystick
	End
	
	Internal
	
	Function SendEvent( event:SDL_Event Ptr )
	
		Select event->type
		Case SDL_JOYDEVICEADDED
			
			Local jevent:=Cast<SDL_JoyDeviceEvent Ptr>( event )
			
			Local index:=jevent->which
			
			For Local j:=7 Until index Step -1
				_joysticks[j]=_joysticks[j-1]
			Next
			_joysticks[index]=Null
			
			JoystickAdded( index )
			
		Case SDL_JOYDEVICEREMOVED
			
			Local jevent:=Cast<SDL_JoyDeviceEvent Ptr>( event )
			
			For Local index:=0 Until 8
				
				Local joystick:=_joysticks[index]
				
				If Not joystick Or SDL_JoystickInstanceID( joystick._joystick )<>jevent->which Continue
				
				SDL_JoystickClose( joystick._joystick )
				
				joystick._attached=False
				
				For Local j:=index Until 7
					_joysticks[j]=_joysticks[j+1]
				Next
				_joysticks[7]=Null

				JoystickRemoved( index )
				
				Exit
			Next
				
		End
	
	End
	
	Private
	
	Global _joysticks:=New JoystickDevice[8]
	
	Field _joystick:SDL_Joystick Ptr
	Field _name:String
	Field _guid:String
	Field _numAxes:Int
	Field _numBalls:Int
	Field _numButtons:Int
	Field _numHats:Int
	Field _attached:Bool
	Field _hits:=New Bool[32]
	
	Method New( joystick:SDL_Joystick Ptr )
		_joystick=joystick
		_name=String.FromCString( SDL_JoystickName( _joystick ) )
		_numAxes=SDL_JoystickNumAxes( _joystick )
		_numBalls=SDL_JoystickNumBalls( _joystick )
		_numButtons=SDL_JoystickNumButtons( _joystick )
		_numHats=SDL_JoystickNumHats( _joystick )
		_attached=True
		
		Local buf:=New Byte[64]
		Local guid:=SDL_JoystickGetGUID( _joystick )
		SDL_JoystickGetGUIDString( guid,Cast<libc.char_t Ptr>( buf.Data ),buf.Length )
		buf[buf.Length-1]=0
		_guid=String.FromCString( buf.Data )
	End
	
End
