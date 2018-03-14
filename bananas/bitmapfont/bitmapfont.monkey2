#rem

gnsh-bitmap font from opengameart.org:

https://opengameart.org/content/bitmap-font-0

#end

Namespace myapp

#Import "<std>"
#Import "<mojo>"

#Import "gnsh-bitmapfont-colour1.png"
#Import "testfont.fnt"
#Import "testfont_0.png"

Using std..
Using mojo..

Class MyWindow Extends Window
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		
		Local image:=Image.Load( "asset::testfont_0.png" )
		Assert( image )
		
		Style.Font=ImageFont.Load( "asset::gnsh-bitmapfont-colour1.png",5,12 )
'		Style.Font=AngelFont.Load( "asset::testfont.fnt" )
		
		ClearColor=Color.Blue	'so we can see nice drop shadow.
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
		
		canvas.Scale( New Vec2f( 2.5,2.5 ) )
	
		canvas.DrawText( "The Quick Brown Fox Jumps Over The Lazy Dog",0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
