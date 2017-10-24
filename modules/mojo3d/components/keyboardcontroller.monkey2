
Namespace mojo3d

Class KeyboardController Extends GameController
	
	Method New( entity:Entity )
		
		Super.New( entity )
	End
	
	Method ButtonToKey:Key( button:Button )

		Select button
		Case Button.Up Return Key.Up
		Case Button.Down Return Key.Down
		Case Button.Left Return Key.Left
		Case Button.Right Return Key.Right
		Case Button.Fire Return Key.Space
		Case Button.Forward Return Key.A
		Case button.Backward Return Key.Z
		End
			
		Return Null
	End
	
	Method ButtonDown:Bool( button:Button ) Override
		
		Return Keyboard.KeyDown( ButtonToKey( button ) )
	End
	
	Method ButtonHit:Bool( button:Button ) Override
		
		Return Keyboard.KeyHit( ButtonToKey( button ) )
	End
	
End

	