
Namespace test

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

'***** Simple Joystick allocater *****

'should something like this go in modules?

Global alloced:=New StringMap<Bool>

Function AllocJoystick:JoystickDevice()
	
	For Local i:=0 Until JoystickDevice.NumJoysticks()
		
		Local joystick:=JoystickDevice.Open( i )
		If alloced.Contains( joystick.GUID ) Continue
		
		alloced[joystick.GUID]=True
		
		Return joystick
	Next
	
	Return Null
End

Function FreeJoystick( joystick:JoystickDevice )
	
	If joystick alloced.Remove( joystick.GUID )
End

'***** Simple player class *****

Class Player

	Field id:Int
	Field joystick:JoystickDevice
	
	Global used:=New StringMap<Bool>
	
	Method New( id:Int )
		Self.id=id
		Self.joystick=AllocJoystick()
	End
	
	Method Update( canvas:Canvas )
		
		canvas.DrawText( "Player "+id,0,0 )
		
		'update joystick state
		If joystick And Not joystick.Attached
			FreeJoystick( joystick )
			joystick=Null
		Endif
		
		If Not joystick
			joystick=AllocJoystick()
			If Not joystick
				canvas.DrawText( "No Joystick available",0,16 )
				Return
			Endif
		Endif

		'draw joystick info.		
		canvas.DrawText( "Name="+joystick.Name,0,16 )
		
		For Local axis:=0 Until 6
			canvas.DrawText( "Axis "+axis+"="+joystick.GetAxis( axis ),0,axis*16+32 )
		Next
	
	End
	
End

'***** MainWindow *****

Class MainWindow Extends Window
	
	Field players:=New Player[4]

	Method New()
		Super.New( "Joystick test",640,480 )
		
		For Local i:=0 Until 4
			players[i]=New Player( i )
		Next
		
	End

	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
	
		canvas.DrawText( "NumJoysticks="+JoystickDevice.NumJoysticks(),0,0 )
		
		canvas.PushMatrix()
		
		canvas.Translate( 0,16 )
		
		For Local i:=0 Until 4
			
			players[i].Update( canvas )
			
			canvas.Translate( 0,144 )
		Next
		
		canvas.PopMatrix()
		
	End
	
End

Function Main()

	New AppInstance
	
	New MainWindow
	
	App.Run()
	
End