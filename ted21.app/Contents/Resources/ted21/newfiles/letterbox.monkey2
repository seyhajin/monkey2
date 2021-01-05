
Namespace myLetterboxApp

#Import "<std>"
#Import "<mojo>"
Using std..
Using mojo..


Const Size := New Vec2i( 640,360 )



Function Main()
	New AppInstance
	New MyWindow
	App.Run()
End


Class MyWindow Extends GLWindow

	Method New()
		Super.New( "My Window", Size.X, Size.Y, WindowFlags.Resizable )
		SetMinSize( Size.X, Size.Y )

		'if you want a constant canvas size use this
		Layout = "letterbox"
		'or If you want the canvas to always fill the window use this
'		Layout = "fill"

		ClearColor = Color.Black
	End

protected
	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		canvas.Color = Color.Red
		canvas.DrawLine( 10, 0, 10, Height )
		canvas.DrawLine( 0, 10, Width, 10 )
		
		canvas.Color = Color.White
		canvas.DrawText( "Hello World", 10, 10 )
	End

	
	method OnKeyDown( key:Key )
		Select key
			Case key.Enter
		End Select
	End method
	
	method OnKeyUp( key:Key )
		Select key
			Case key.Enter
		End Select
	End method

	'respond to any key presses
	Method OnKeyEvent( event:KeyEvent ) Override
		_shiftDown = event.Modifiers & Modifier.Shift
		_altDown = event.Modifiers & Modifier.Alt
		_controlDown = event.Modifiers & Modifier.Command
		_commandDown = event.Modifiers & Modifier.Gui
		
		Select event.Type
			case EventType.KeyDown
				OnKeyDown( event.Key )

			Case EventType.KeyUp
				OnKeyUp( event.Key )

		End Select
	End

	Method OnMeasure:Vec2i() Override
		Return Size
	End

private	
	field _shiftDown:bool
	field _altDown:bool
	field _controlDown:bool
	field _commandDown:bool
End
