
Namespace myapp

#Import "<std>"
#Import "<mojo>"

Using std..
Using mojo..

#If __TARGET__="windows"

#Import "<windows.h>"

Extern

Function SetProcessDPIAware:Int()

Public

#Endif

Class MyWindow Extends Window
	
	Field _ticks:=0
	
	Field _time:Double

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=Null )

		Super.New( title,width,height,flags|WindowFlags.Resizable|WindowFlags.HighDPI )
		
		Print "Desktop="+App.DesktopSize
		
		SwapAsync=True
		
		Local timer:=New Timer( 250,Lambda()
		
			Local time:=Now()
			
			Print "Elapsed="+Int( (time-_time)*1000+.5 )
			
			_time=time
			
			_ticks+=1
		End )
		
	End

	Method OnRender( canvas:Canvas ) Override
		
		If Keyboard.KeyDown( Key.LeftShift )
			
			If Keyboard.KeyHit( Key.Enter )
				If Fullscreen EndFullscreen() Else BeginFullscreen()
			Else If Keyboard.KeyDown( Key.Left )
				ResizeWindow( Frame.X-1,Frame.Y,Frame.Width+1,Frame.Height )
			Else If Keyboard.KeyDown( Key.Right )
				ResizeWindow( Frame.X+0,Frame.Y,Frame.Width+1,Frame.Height )
			Endif
'			Print String( Frame.Origin )+","+Frame.Size
		Else
			If Keyboard.KeyDown( Key.Left )
				ResizeWindow( Frame.X-1,Frame.Y,Frame.Width,Frame.Height )
			Else If Keyboard.KeyDown( Key.Right )
				ResizeWindow( Frame.X+1,Frame.Y,Frame.Width,Frame.Height )
			Endif
'			Print String( Frame.Origin )+","+Frame.Size
		Endif
		
		'Print "Render"
		
		App.RequestRender()
	
		canvas.DrawText( "Hello World! Ticks="+_ticks+" FPS="+App.FPS,Width/2,Height/2,.5,.5 )
	End
	
End

Function Main()

#If __TARGET__="windows"
	SetProcessDPIAware()
#Endif
	
	New AppInstance
	
	New MyWindow
	
	Local x:Float,y:Float,d:Float
	sdl2.SDL_GetDisplayDPI( 0,Varptr x,Varptr y,Varptr d )
	
	Print "x="+x+", y="+y+", d="+d
	
	App.Run()
End
