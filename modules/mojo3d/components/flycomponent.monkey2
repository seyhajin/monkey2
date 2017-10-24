
Namespace mojo3d

Class FlyComponent Extends Component
	
	Const Type:=New ComponentType( "FlyController",0,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
	End
	
	Property Speed:Float()
		
		Return _speed
	
	Setter( speed:Float )
		
		_speed=speed
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		Local c:=Entity.GetComponent<GameController>()
		Assert( c,"Entity has no game controller" )
		
		Local rspeed:=_speed*(elapsed/(1.0/60.0))
		
		Local entity:=Entity
		
		Local view:=App.ActiveWindow
	
		If c.ButtonDown( Button.Up )
			entity.RotateX( rspeed )
		Else If c.ButtonDown( Button.Down )
			entity.RotateX( -rspeed )
		Endif
		
		If c.ButtonDown( Button.Left )
			entity.RotateY( rspeed,True )
		Else If c.ButtonDown( Button.Right )
			entity.RotateY( -rspeed,True )
		Endif
	
		If c.ButtonDown( Button.Forward )
			entity.MoveZ( .1 )
		Else If c.ButtonDown( Button.Backward )
			entity.MoveZ( -.1 )
		Endif
		
'		If Mouse.ButtonDown( MouseButton.Left )
'			If Mouse.X<view.Width/3
'				entity.RotateY( rspeed,True )
'			Else If Mouse.X>view.Width/3*2
'				entity.RotateY( -rspeed,True )
'			Else
'				entity.Move( New Vec3f( 0,0,.1 ) )
'			Endif
'		Endif
		
	End
	
	Private
	
	Field _speed:Float=3.0
	
End

