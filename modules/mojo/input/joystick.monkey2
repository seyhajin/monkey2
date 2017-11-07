
Namespace mojo.input

Private

Const DEBUG:=False

Public

#rem monkeydoc Type alias for compatibility.

The name JoystickDevice has been deprecated in favor of plain Joystick.

#end
Alias JoystickDevice:Joystick

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

#rem monkeydoc The Joystick class.
#end
Class Joystick
	
	#rem monkeydoc True if joystick is currently attached.
	#end
	Property Attached:Bool()
		
		If _discarded Return False
		
		If SDL_JoystickGetAttached( _sdljoystick ) Return True
		
		Discard()
		
		Return False
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
		
		If _discarded Return 0
		
		Return (Float(SDL_JoystickGetAxis( _sdljoystick,axis ))+32768)/32767.5-1
	End
	
	#rem monkeydoc Gets joystick ball value.
	#end	
	Method GetBall:Vec2i( ball:Int )

		If _discarded Return Null
		
		Local x:Int,y:Int
		SDL_JoystickGetBall( _sdljoystick,ball,Varptr x,Varptr y )
		Return New Vec2i( x,y )
	End

	#rem monkeydoc Gets joystick hat value.
	#end	
	Method GetHat:JoystickHat( hat:Int )

		If _discarded Return JoystickHat.Centered
		
		Return Cast<JoystickHat>( SDL_JoystickGetHat( _sdljoystick,hat ) )
	End

	#rem monkeydoc Check up/down state of a button.
	#end
	Method ButtonDown:Bool( button:Int )
		
		If _discarded Return False
		
		Return SDL_JoystickGetButton( _sdljoystick,button )
	End
	
	#rem monkeydoc Checks is a button has been pressed.
	#end
	Method ButtonPressed:Bool( button:Int )

		If _discarded Return False
		
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
		
		If _discarded Return
		
		_refs-=1
		If Not _refs Discard()
	End
	
	#rem monkeydoc Gets the number of attached joysticks.
	#end
	Function NumJoysticks:Int()
		
		Return Min( SDL_NumJoysticks(),MaxJoysticks )
	End

	#rem monkeydoc Opens a joystick if possible.
	
	@param index Joystick index.

	#end
	Function Open:Joystick( index:Int )
		
		If index<0 Or index>=MaxJoysticks Return Null
		
		Local joystick:=_joysticks[index]
		If joystick 
			joystick._refs+=1
			Return joystick
		End
		
		For Local devid:=0 Until NumJoysticks()

			Local sdljoystick:=SDL_JoystickOpen( devid )
			If Not sdljoystick Continue
			
			Local instid:=SDL_JoystickInstanceID( sdljoystick )
			If _opened[instid]
				SDL_JoystickClose( sdljoystick )
				Continue
			Endif
			
			Local joystick:=New Joystick( index,sdljoystick )
			
			Return joystick
		Next
		
		Return Null
	End

	Internal
	
	Function UpdateJoysticks()
		
		SDL_JoystickUpdate()
	End
	
	Function SendEvent( event:SDL_Event Ptr )
		
		Select event->type
		Case SDL_JOYDEVICEADDED
			
			Local jevent:=Cast<SDL_JoyDeviceEvent Ptr>( event )
			
			If DEBUG Print "SDL_JOYDEVICEADDED, device id="+jevent->which
			
		Case SDL_JOYDEVICEREMOVED
			
			Local jevent:=Cast<SDL_JoyDeviceEvent Ptr>( event )
			
			If DEBUG Print "SDL_JOYDEVICEREMOVED, inst id="+jevent->which
		End
	
	End
	
	Private
	
	Const MaxJoysticks:=8
	
	'currently opened joysticks by instance id.
	Global _opened:=New IntMap<Joystick>
	
	'curently opened joysticks by user id.
	Global _joysticks:=New Joystick[MaxJoysticks]
	
	Function GetGUID:String( joystick:SDL_Joystick Ptr )
		
		Local buf:=New Byte[64]
		Local guid:=SDL_JoystickGetGUID( joystick )
		SDL_JoystickGetGUIDString( guid,Cast<libc.char_t Ptr>( buf.Data ),buf.Length )
		buf[buf.Length-1]=0
		Return String.FromCString( buf.Data )
	End
	
	Field _refs:=1
	Field _index:Int
	Field _sdljoystick:SDL_Joystick Ptr 
	Field _discarded:Bool
	
	Field _inst:Int
	Field _name:String
	Field _guid:String
	
	Field _numAxes:Int
	Field _numBalls:Int
	Field _numButtons:Int
	Field _numHats:Int
	
	Field _hits:=New Bool[32]
	
	Method New( index:Int,sdljoystick:SDL_Joystick Ptr )
		
		_index=index
		_sdljoystick=sdljoystick
	
		_inst=SDL_JoystickInstanceID( _sdljoystick )
		_name=String.FromCString( SDL_JoystickName( _sdljoystick ) )
		_guid=GetGUID( _sdljoystick )
		
		_numAxes=SDL_JoystickNumAxes( _sdljoystick )
		_numBalls=SDL_JoystickNumBalls( _sdljoystick )
		_numButtons=SDL_JoystickNumButtons( _sdljoystick )
		_numHats=SDL_JoystickNumHats( _sdljoystick )
		
		_joysticks[_index]=Self
		
		_opened[_inst]=Self
		
		If DEBUG Print "Joystick Created, user id="+_index+", instance id="+_inst
	End
	
	Method Discard()

		If _discarded Return
		
		If DEBUG Print "Discarding Joystick, user id="+_index+", instance id="+_inst
		
		SDL_JoystickClose( _sdljoystick )
		_sdljoystick=Null
		
		_joysticks[_index]=Null
		_index=-1
		
		_opened.Remove( _inst )
		_inst=-1
		
		_discarded=True
	End

End
