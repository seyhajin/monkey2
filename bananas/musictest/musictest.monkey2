#rem

Simple music demo.

Note: PlayMusic path must be a file system path so ths wont work on android yet.

#end
Namespace myapp

#Import "<std>"
#Import "<mojo>"

#Import "ACDC_-_Back_In_Black-sample.ogg"

Using std..
Using mojo..

Class MyWindow Extends Window
	
	Field _channel:Channel

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags )
		
		StartMusic()
	End
	
	Method StartMusic()
		
		_channel=Audio.PlayMusic( "asset::ACDC_-_Back_In_Black-sample.ogg",StartMusic )
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		If Keyboard.KeyHit( Key.Space ) or Mouse.ButtonHit( MouseButton.Left ) _channel.Paused=Not _channel.Paused
		
		RequestRender()
	
		canvas.DrawText( "Hello World!",Width/2,Height/2,.5,.5 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
