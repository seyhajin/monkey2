
Namespace mojo3d

Class FlyBehaviour Extends Behaviour
	
	Method New( entity:Entity )
		
		Super.New( entity )
	End
	
	Property Speed:Float()
		
		Return _speed
	
	Setter( speed:Float )
		
		_speed=speed
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		Local rspeed:=_speed*(elapsed/(1.0/60.0))
		
		Local entity:=Entity
		
		Local view:=App.ActiveWindow
	
		If Keyboard.KeyDown( Key.Up )
			entity.RotateX( rspeed )
		Else If Keyboard.KeyDown( Key.Down )
			entity.RotateX( -rspeed )
		Endif
		
		If Keyboard.KeyDown( Key.Left )
			entity.RotateY( rspeed,True )
		Else If Keyboard.KeyDown( Key.Right )
			entity.RotateY( -rspeed,True )
		Endif
	
		If Keyboard.KeyDown( Key.A )
			entity.MoveZ( .1 )
		Else If Keyboard.KeyDown( Key.Z )
			entity.MoveZ( -.1 )
		Endif
		
		If Mouse.ButtonDown( MouseButton.Left )
			If Mouse.X<view.Width/3
				entity.RotateY( rspeed,True )
			Else If Mouse.X>view.Width/3*2
				entity.RotateY( -rspeed,True )
			Else
				entity.Move( New Vec3f( 0,0,.1 ) )
			Endif
		Endif
		
	End
	
	Private
	
	Field _speed:Float=3.0
	
End
