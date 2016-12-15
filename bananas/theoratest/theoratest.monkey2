Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<theoraplayer>"

#Import "konqi.ogv"

Using std..
Using mojo..
Using theoraplayer..

Class MyWindow Extends Window

	Field audiofactory:AudioInterfaceFactory
	
	Field vidman:VideoManager
	
	Field vidclip:VideoClip
	
	Field image:Image
	
	Field time:Double

	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		vidman=VideoManager.getInstance()
		
		audiofactory=New OpenAL_AudioInterfaceFactory
		
		vidman.setAudioInterfaceFactory( audiofactory )
		
		vidclip=vidman.createVideoClip( AssetsDir()+"konqi.ogv" )
		
		image=New Image( vidclip.getWidth(),vidclip.getHeight(),PixelFormat.RGB24,TextureFlags.Dynamic )
		
		vidclip.play()
		
		time=Now()
		
	End

	Method OnRender( canvas:Canvas ) Override
	
		App.RequestRender()
		
		Local now:=Now()
		
		Local elapsed:=now-time
		
		time=now
		
		vidman.update( elapsed )
	
'		vidclip.updateTimerToNextFrame()
		
		Local frame:=vidclip.fetchNextFrame()
		
		If frame
		
			Local pixmap:=New Pixmap( vidclip.getWidth(),vidclip.getHeight(),PixelFormat.RGB24,frame.getBuffer(),vidclip.getWidth()*3 )
			
			image.Texture.PastePixmap( pixmap,0,0 )
			
			vidclip.popFrame()
		
		Endif
		
		canvas.BlendMode=BlendMode.Opaque
		
		canvas.DrawRect( 0,0,Width,Height,image )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
