
Namespace ultralight

#Import "<std>"
#Import "<mojo>"
#Import "<ultralight>"

Using std..
Using mojo..
Using ultralight..

Class AppWindow Extends Window
	
	'Ultralight fields
	Field _config:ULConfig
	Field _renderer:ULRenderer
	Field _view:ULView
	
	Field _onChangeCursor:ULChangeCursorCallback
	
	'Draw ulView in monkey2
	Field _image:Image

	Method New( title:String, width:Int=800, height:Int=600, flags:WindowFlags=Null )
		Super.New( title, width, height, flags )
		
		'Create configuration
		_config = ulCreateConfig()
		ulConfigSetDeviceScaleHint(_config, App.Theme.Scale.X)
		
		'Create renderer
		_renderer = ulCreateRenderer(_config)
		
		'Create view and load URL
		_view = ulCreateView(_renderer, Self.Width, Self.Height, False)
		ulViewLoadURL(_view, ulCreateString("http://www.codedan.net/Monkey2/docs/"))
		
		'Create mojo image to render
		_image = New Image(Self.Width, Self.Height, TextureFlags.Dynamic)
	End
	
	Method OnMouseEvent( event:MouseEvent ) Override
		Select event.Type
			Case EventType.MouseClick, EventType.MouseDown, EventType.MouseDoubleClick, EventType.MouseRightClick
				Local evt:=ulCreateMouseEvent(kMouseEventType_MouseDown, 
					event.Location.X, event.Location.Y, Cast<ULMouseButton>(Int(event.Button)))
				ulViewFireMouseEvent(_view, evt)
				ulDestroyMouseEvent(evt)
			
			Case EventType.MouseUp
				Local evt:=ulCreateMouseEvent(kMouseEventType_MouseUp, 
					event.Location.X, event.Location.Y, Cast<ULMouseButton>(Int(event.Button)))
				ulViewFireMouseEvent(_view, evt)
				ulDestroyMouseEvent(evt)
			
			Case EventType.MouseMove
				Local evt:=ulCreateMouseEvent(kMouseEventType_MouseMoved, 
					event.Location.X, event.Location.Y, Cast<ULMouseButton>(Int(event.Button)))
				ulViewFireMouseEvent(_view, evt)
				ulDestroyMouseEvent(evt)
			
			Case EventType.MouseWheel
				Local evt:=ulCreateScrollEvent(kScrollEventType_ScrollByPage, 
					event.Wheel.X, event.Wheel.Y)
				ulViewFireScrollEvent(_view, evt)
				ulDestroyScrollEvent(evt)
		End
	End
	
	Method OnWindowEvent( event:WindowEvent ) Override
		Select event.Type
			Case EventType.WindowClose
				Quit()
				
			Case EventType.WindowResized, EventType.WindowMaximized, 
				EventType.WindowMinimized,EventType.WindowRestored
				
				ulViewResize(_view, Self.Width, Self.Height)
				ulViewSetNeedsPaint(_view, True)

				If _image _image.Discard()
					
				'Resize image
				_image = New Image(Self.Width, Self.Height, TextureFlags.Dynamic)
		End
	End

	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		'//-------------------------------------
		'// Update
		'//-------------------------------------
		If Keyboard.KeyHit( Key.Escape ) Then 
			'App.Terminate()
			Quit()
		End
		
		If Keyboard.KeyHit( Key.Space) Then
			ulViewLoadURL(_view, ulCreateString("http://www.clubic.com"))
		End
		
		'//-------------------------------------
		'// Render
		'//-------------------------------------
		canvas.Clear( Color.DarkGrey )
		
		'// Update timers and dispatch internal callbacks
		ulUpdate(_renderer)
		
		'// Render all active views to display lists and dispatch calls to GPUDriver
		ulRender(_renderer)
		
		'// Copy ULView bitmap into Pixmap and paste it to _image
		If ulViewIsBitmapDirty(_view)
			Local bmp:=ulViewGetBitmap(_view)
			Local bmpWidth:=ulBitmapGetWidth(bmp)
			Local bmpHeight:=ulBitmapGetHeight(bmp)
			Local bmpPitch:=ulBitmapGetRowBytes(bmp)
			Local bmpDataPtr:=Cast<UByte Ptr>(ulBitmapRawPixels(bmp))
			
			Local pixmap:= New Pixmap(bmpWidth, bmpHeight, PixelFormat.RGBA8, bmpDataPtr, bmpPitch)
			
			_image.Texture.PastePixmap(pixmap,0,0)
			
			Local title:=ulViewGetTitle(_view)
			Self.Title = "Monkey2 WebView | " + String.FromWString(ulStringGetData(title), ulStringGetLength(title))
		End

		'// Draw web page
		canvas.DrawImage(_image, 0, 0)

		'// Debug infos
		canvas.Color = Color.White
		canvas.DrawText( "FPS: " + App.FPS, 0, 0, 0, 0 )
	End
	
	Method Quit()
		'// Save ulView to png
		'Local png:ULBitmap=ulViewGetBitmap(_view)
		'Local save:= ulBitmapWritePNG(png, AppDir()+"capture.png")
		'Print "Save ulView to PNG state: '" + save + (save ? "' to " + AppDir()+"capture.png" Else "")
		
		ulDestroyView(_view)
		ulDestroyRenderer(_renderer)
		ulDestroyConfig(_config)
		
		App.Terminate()
	End
End

Function Main()
	New AppInstance
	New AppWindow("Monkey2 WebView", 1024, 768, WindowFlags.Center|WindowFlags.Resizable)
	App.Run()
End
