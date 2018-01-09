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
		
		_channel=Audio.PlayMusic( "asset::ACDC_-_Back_In_Black-sample.ogg",Lambda()
		
			Print "Music Finished!"
			
		End )
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		canvas.DrawText( 
		"Music Test: Hit [Enter] to "+
		(_channel ? "stop" Else "start")+
		(_channel ? ", [Space] to "+(_channel.Paused ? "resume" Else "pause") Else "")+
		(_channel ? ",  Sample="+_channel.PlayheadSample+", Time="+_channel.PlayheadTime Else ""),
		0,0 )
		
		'Stop/Start?
		If Keyboard.KeyHit( Key.Enter ) Or Mouse.ButtonHit( MouseButton.Left )
			If _channel 
				_channel.Stop()
				_channel=Null
			Else
				StartMusic()
			Endif
		Endif
		
		'Pause/Resume?
		If Keyboard.KeyHit( Key.Space ) Or Mouse.ButtonHit( MouseButton.Right )
			If _channel
				_channel.Paused=Not _channel.Paused
			Endif
		Endif
		
	End
 	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
