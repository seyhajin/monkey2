
Namespace myMojoApp

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

		ClearColor = Color.Black
	End method
	
protected	
	Method OnRender( canvas:Canvas ) Override
		canvas.DrawText( "Hello World",Width/2,Height/2,.5,.5 )
	End

	Method OnMeasure:Vec2i() Override
		Return Size
	End

End

