#rem

gnsh-bitmap font from opengameart.org:

https://opengameart.org/content/bitmap-font-0

#end

Namespace myapp

#Import "<std>"
#Import "<mojo>"

#Import "gnsh-bitmapfont-colour1.png"

Using std..
Using mojo..

Class MyWindow Extends Window
	
	Field _font:Font

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		
		_font=Font.Load( "asset::gnsh-bitmapfont-colour1.png",5,12 )
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
		
		canvas.Font=_font
		
		canvas.Scale( New Vec2f( 5,5 ) )
	
		canvas.DrawText( "The Quick Brown Fox Jumps Over The Lazy Dog",.8,.8 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
