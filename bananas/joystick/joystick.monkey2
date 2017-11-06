
Namespace test

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Class Player

	Field id:Int
	Field joystick:JoystickDevice
	
	Global used:=New StringMap<Bool>
	
	Method New( id:Int )
		Self.id=id
		Self.joystick=JoystickDevice.Open( id )
	End
	
	Method Update( canvas:Canvas )
		
		canvas.DrawText( "Player "+id,0,0 )
		
		'update joystick state
		If joystick And Not joystick.Attached 
			joystick.Close()
			joystick=Null
		Endif
		
		If Not joystick
			joystick=JoystickDevice.Open( id )
			If Not joystick
				canvas.DrawText( "No Joystick available",0,16 )
				Return
			Endif
		Endif

		'draw joystick info.		
		canvas.DrawText( "Name="+joystick.Name,0,16 )
		canvas.DrawText( "GUID="+joystick.GUID,0,32 )
		
		For Local axis:=0 Until 6
			Local n:=Int( joystick.GetAxis( axis )*100)
			Local v:=(n/100)+"."+(n Mod 100)
'			canvas.DrawText( "Axis("+axis+")="+v,(axis Mod 3) * 96,(axis/3)*16+32 )'axis*16+32 )
			canvas.DrawText( "Axis("+axis+")="+v,axis * 104,48 )'axis*16+32 )
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