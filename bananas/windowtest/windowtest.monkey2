
Namespace myapp

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

Class MyWindow Extends Window

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,WindowFlags.Center|WindowFlags.Maximized|WindowFlags.Resizable )

	End
	
	Method OnKeyEvent( event:KeyEvent ) Override
	
		If event.Type=EventType.KeyDown
			Select event.Key
			Case Key.Up
				If Maximized
					Fullscreen=True
				Else If Minimized
					Restore()
				Else
					Maximize()
				Endif
			Case Key.Down
				If Fullscreen
					Fullscreen=False
				Else If Maximized
					Restore()
				Else
					Minimize()
				Endif
			End
		Endif
	End
	
	Method OnWindowEvent( event:WindowEvent ) Override
	
		Select event.Type
		Case EventType.WindowMaximized
			Print "Maximized!"
		Case EventType.WindowMinimized
			Print "Minimized!"
		Case EventType.WindowRestored
			Print "Restored!"
		Case EventType.WindowResized
			Print "Resized!"
		End
		
		Print Int( Maximized )+","+Int( Minimized )
		
		Super.OnWindowEvent( event )
	End

	Method OnRender( canvas:Canvas ) Override
	
		Print "OnRender: Width="+Width+", Height="+Height
	
		canvas.DrawText( "Hello World!",Width/2,Height/2,.5,.5 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
