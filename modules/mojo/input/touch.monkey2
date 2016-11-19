
Namespace mojo.input

#rem monkeydoc Global instance of the TouchDevice class.
#end
Const Touch:=New TouchDevice

#rem monkeydoc The TouchDevice class.

To access the touch device, use the global [[Touch]] constant.

The touch device should only used after a new [[app.AppInstance]] is created.

#end
Class TouchDevice Extends InputDevice

	Method FingerDown:Bool( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].down
	End
	
	Method FingerPressed:Bool( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].pressed
	End
	
	Method FingerReleased:Bool( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].released
	End
	
	Method FingerPressure:Float( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].pressure
	End

	Method FingerX:Int( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].location.x
	End
	
	Method FingerY:Int( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].location.y
	End
	
	Method FingerLocation:Vec2i( finger:Int )
		DebugAssert( finger>=0 And finger<10,"Finger index out of range" )
		Return _fingers[finger].location
	End
	
	'***** INTERNAL *****
	
	#rem monkeydoc @hidden
	#end
	Method Init()
	End
	
	#rem monkeydoc @hidden
	#end
	Method Update()
		For Local i:=0 Until 10
			_fingers[i].pressed=False
		Next
	End
	
	#rem monkeydoc @hidden
	#end
	Method EventLocation:Vec2i( tevent:SDL_TouchFingerEvent Ptr )
	
		Local window:=App.ActiveWindow
	
		Local p:=New Vec2i( tevent->x * window.Frame.Width,tevent->y * window.Frame.Height )

		Return window.TransformPointFromView( p,Null )
	End
	
	#rem monkeydoc @hidden
	#end
	Method SendEvent( event:SDL_Event Ptr )
	
		If Not App.ActiveWindow Return

		Select event->type
			
		Case SDL_FINGERDOWN
		
			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
			Local id:=tevent->fingerId
			If id>=0 And id<10
				_fingers[id].down=True
				_fingers[id].pressed=True
				_fingers[id].pressure=tevent->pressure
				_fingers[id].location=EventLocation( tevent )
			Endif
		
		Case SDL_FINGERUP
		
			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
			Local id:=tevent->fingerId
			If id>=0 And id<10
				_fingers[id].down=False
				_fingers[id].released=False
				_fingers[id].pressure=0
				_fingers[id].location=EventLocation( tevent )
			Endif
			
		Case SDL_FINGERMOTION
		
			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
			Local id:=tevent->fingerId
			If id>=0 And id<10
				_fingers[id].pressure=tevent->pressure
				_fingers[id].location=EventLocation( tevent )
			Endif
		
		End

	End
	
	Private
	
	Struct FingerState
		Field down:Bool
		Field pressed:Bool
		Field released:Bool
		Field pressure:FLoat
		Field location:Vec2i
	End
	
	Field _fingers:=New FingerState[10]
	
	Method New()
	End

End
