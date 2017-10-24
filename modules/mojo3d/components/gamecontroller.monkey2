
Namespace mojo3d

Enum Button
	Up
	Down
	Left
	Right
	Fire
	Forward
	Backward
End

Class GameController Extends Component
	
	Const Type:=New ComponentType( "GameController",-1,ComponentTypeFlags.Singleton )
	
	Method New( entity:Entity )
		
		Super.New( entity,Type )
	End
	
	Method ButtonDown:Bool( button:Button ) Virtual
	
		Return False
	End
	
	Method ButtonHit:Bool( button:Button ) Virtual
		
		Return False
	End
	
End
