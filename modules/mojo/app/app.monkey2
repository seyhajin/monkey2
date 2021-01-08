
#Import "native/app.cpp"
#Import "native/app.h"

'jl added
#Import "../assets/fonts/Roboto-Regular.ttf"
#Import "../assets/fonts/RobotoMono-Regular.ttf"

Namespace mojo.app

Extern Private

Function AppInit()="bbApp::init"

Public

#rem monkeydoc The global AppInstance instance.
#end
Global App:AppInstance

#rem monkeydoc Display mode structure.

Contains information describing a display mode.

See [[AppInstance.DesktopMode]] for more information.

#end
Struct DisplayMode
	
	Field width:Int
	Field height:Int
	Field depth:Int
	Field hertz:Int
	
	Operator To:String()
	
		Return "DisplayMode("+width+","+height+","+depth+","+hertz+")"
	End
	
End

#rem monkeydoc The AppInstance class.

The AppInstance class is mainly reponsible for running the app 'event loop', but also provides several utility functions for managing the application.

A global instance of the AppInstance class is stored in the [[App]] global variable, so you can use any member of the AppInstance simply by prefixing it with 'App.', eg: App.MilliSecs

There are a number of config settings that can be used to control app behaviour. See [[std:std.filesystem.SetConfig|SetConfig]] for more information about config settings.

| Config setting		  			| Possible values					| Default value
|:----------------------------------|:----------------------------------|:-------------
| "MOJO\_OPENGL\_PROFILE"			| "es", "compatibility" or "core" 	| "compatibility" on macos and linux, "es" on all other targets. Uses 'Angle' for es support on windows.
| "MOJO\_OPENGL\_VERSION\_MAJOR"	| Open gl major version				| 2
| "MOJO\_OPENGL\_VERSION\_MINOR"	| Open gl minor version				| 0
| "MOJO\_COLOR\_BUFFER\_BITS"		| Minimum color bit depth			| 8
| "MOJO\_DEPTH\_BUFFER\_BITS"		| Minimum depth buffer bit depth	| 0
| "MOJO\_STENCIL\_BUFFER\_BITS"		| Minimum stencil buffer bit depth	| 0

#end
Class AppInstance
	
	#rem monkeydoc Invoked when the app becomes idle.
	#end
	Field Idle:Void()
	
	#rem monkeydoc Invoked when app is activated.
	#end
	Field Activated:Void()
	
	#rem monkeydoc Invoked when app is deactivated.
	#end
	Field Deactivated:Void()
	
	#rem monkeydoc @hidden
	#end
	Field ThemeChanged:Void()
	
	#rem monkeydoc Invoked when a file is dropped on an app window.
	#end
	Field FileDropped:Void( path:String )
	
	#rem monkeydoc Key event filter.
	
	To prevent the event from being sent to a view, a filter can eat the event using [[Event.Eat]].
	
	Filter functions should check if the event has already been 'eaten' by checking the event's [[Event.Eaten]] property before processing the event.
	
	#end
	Field KeyEventFilter:Void( event:KeyEvent )

	#rem monkeydoc MouseEvent filter.
	
	To prevent the event from being sent to a view, a filter can eat the event using [[Event.Eat]].

	Filter functions should check if the event has already been 'eaten' by checking the event's [[Event.Eaten]] property before processing the event.
	
	#end	
	Field MouseEventFilter:Void( event:MouseEvent )
	
	#rem monkeydoc Raw SDL_Event filter.
	
	The filter is called for all SDL events before mojo processes them.
	
	#end
	Field SdlEventFilter:Void( event:SDL_Event Ptr )

	#rem monkeydoc Creates a new app instance.
	
	Creates a new AppInstance objects and initializes the global [[App]] variable with it.
	
	A runtime error will occur if more than 1 AppInstance is created.
	
	#end
	Method New()
	
		App=Self
		
		SDL_Init( SDL_INIT_VIDEO|SDL_INIT_JOYSTICK|SDL_INIT_GAMECONTROLLER )

		libc.atexit( SDL_Quit )
		
		SDL_SetHint( "SDL_MOUSE_FOCUS_CLICKTHROUGH","1" )

		SDL_FlushEvents( SDL_JOYDEVICEADDED,SDL_JOYDEVICEADDED )
		SDL_FlushEvents( SDL_CONTROLLERDEVICEADDED,SDL_CONTROLLERDEVICEADDED )
		
		AppInit()
		
		Keyboard.Init()
		
		Mouse.Init()
		
		Touch.Init()
		
		Audio.Init()
		
		'Set GL attributes
		'
		Local gl_profile:Int,gl_major:Int=2,gl_minor:Int=0

		Select GetConfig( "MOJO_OPENGL_PROFILE" )
		Case "core"
			gl_profile=SDL_GL_CONTEXT_PROFILE_CORE
		Case "compatibility"
			gl_profile=SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
		Case "es"
			gl_profile=SDL_GL_CONTEXT_PROFILE_ES
		Default
#If __TARGET__="macos" Or __TARGET__="linux"
			gl_profile=SDL_GL_CONTEXT_PROFILE_COMPATIBILITY	'no gles20 on macos...
#Else
			gl_profile=SDL_GL_CONTEXT_PROFILE_ES
#Endif
		End

		SDL_GL_SetAttribute( SDL_GL_CONTEXT_PROFILE_MASK,gl_profile )
		SDL_GL_SetAttribute( SDL_GL_CONTEXT_MAJOR_VERSION,Int( GetConfig( "MOJO_OPENGL_VERSION_MAJOR",gl_major ) ) ) 
		SDL_GL_SetAttribute( SDL_GL_CONTEXT_MINOR_VERSION,Int( GetConfig( "MOJO_OPENGL_VERSION_MINOR",gl_minor ) ) )
		
		SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER,1 )
		
		Local n:=Int( GetConfig( "MOJO_COLOR_BUFFER_BITS",8 ) )

		SDL_GL_SetAttribute( SDL_GL_RED_SIZE,n )
		SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE,n )
		SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE,n )
'jl modified
'		SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE,Int( GetConfig( "MOJO_DEPTH_BUFFER_BITS" ) ) )
		SDL_GL_SetAttribute( SDL_GL_DEPTH_SIZE, 32 )

		SDL_GL_SetAttribute( SDL_GL_STENCIL_SIZE,Int( GetConfig( "MOJO_STENCIL_BUFFER_BITS" ) ) )
		
		Local msaa_samples:=Int( GetConfig( "MOJO_MSAA_SAMPLES",0 ) )
		If msaa_samples
			SDL_GL_SetAttribute( SDL_GL_MULTISAMPLEBUFFERS,1 )
			SDL_GL_SetAttribute( SDL_GL_MULTISAMPLESAMPLES,msaa_samples )
		Endif
		
#If __DESKTOP_TARGET__

		'WIP multiple windows...
		
		SDL_GL_SetAttribute( SDL_GL_SHARE_WITH_CURRENT_CONTEXT,1 )
		
		'create dummy window/context
		Local _sdlWindow:=SDL_CreateWindow( "<dummy>",0,0,0,0,SDL_WINDOW_HIDDEN|SDL_WINDOW_OPENGL )
		Assert( _sdlWindow,"FATAL ERROR: SDL_CreateWindow failed~n> SDL_ERROR: "+String.FromCString(SDL_GetError()) )

		Local _sdlGLContext:=SDL_GL_CreateContext( _sdlWindow )
		Assert( _sdlGLContext,"FATAL ERROR: SDL_GL_CreateContext failed~n> SDL_ERROR: "+String.FromCString(SDL_GetError()) )
		
		SDL_GL_MakeCurrent( _sdlWindow,_sdlGLContext )
#Endif	
		
#If __TARGET__="windows" Or __TARGET__="macos" Or __TARGET__="emscripten"
		_captureMouse=True	'breaks on linux...
#Endif

#if __MOBILE_TARGET__
		_touchMouse=True
#Endif

		_defaultFont=_res.OpenFont( "DejaVuSans",16 )
'jl added
		_defaultMonoFont = Font.Load( DefaultMonoFontName,16 )
		
		_theme=New Theme
		
		Local themePath:=GetConfig( "MOJO_INITIAL_THEME","default" )
		
		Local themeScale:=Float( GetConfig( "MOJO_INITIAL_THEME_SCALE",1 ) )
		
		_theme.Load( themePath,New Vec2f( themeScale ) )
		
		_theme.ThemeChanged+=Lambda()

			ThemeChanged()
			
			RequestRender()
			
			UpdateWindows()
		End

#if __DESKTOP_TARGET__ 
		SDL_AddEventWatch( _EventFilter,Null )
#Endif
		RequestRender()
	End

'jl added
'------------------------------------------------------------
	#rem monkeydoc @hidden
	#end
	Property DefaultFontName:String()
		Return "asset::Roboto-Regular.ttf"
	End
	
	#rem monkeydoc @hidden
	#end
	Property DefaultMonoFontName:String()
		Return "asset::RobotoMono-Regular.ttf"
	End
	
	#rem monkeydoc @hidden
	#end
	Property DefaultMonoFont:Font()
		Return _defaultMonoFont
	End
'------------------------------------------------------------	
	
	#rem monkeydoc Fallback font.
	#end
	Property DefaultFont:Font()
	
		Return _defaultFont
	End
	
	#rem monkeydoc The current theme.
	#end
	Property Theme:Theme()
	
		Return _theme
	End
	
	#rem monkeydoc True if clipboard text is empty.
	
	This is faster than checking whether [[ClipboardText]] returns an empty string.
	
	#end
	Property ClipboardTextEmpty:Bool()
	
		Return SDL_HasClipboardText()=SDL_FALSE
	End
	
	#rem monkeydoc Clipboard text.
	#end
	Property ClipboardText:String()
	
		If SDL_HasClipboardText()=SDL_FALSE Return ""
	
		Local p:=SDL_GetClipboardText()
		
		Local str:=String.FromCString( p )

		'fix windows eols		
		str=str.Replace( "~r~n","~n" )
		str=str.Replace( "~r","~n" )		
		
		SDL_free( p )
		
		Return str
		
	Setter( text:String )
	
		SDL_SetClipboardText( text )
	End
	
	#rem monkeydoc The current key view.
	
	The key view is the view key events are sent to.

	#end
	Property KeyView:View()
	
		If Not _active Return Null
	
		If IsActive( _keyView ) Return _keyView
		
		If _modalView Return _modalView
		
		Return _activeWindow
		
	Setter( keyView:View )
	
		_keyView=keyView
	End
	
	#rem monkeydoc The current mouse view.
	
	The mouse view is the view that the mouse is currently 'dragging'.
	
	#end
	Property MouseView:View()
	
		Return _mouseView
	End
	
	#rem monkeydoc The current hover view.
	
	The hover view is the view that the mouse is currently 'hovering' over.
	
	#end
	Property HoverView:View()
	
		Return _hoverView
	End
	
	#rem monkeydoc The desktop size.
	#end	
	Property DesktopSize:Vec2i()
		
		Local mode:=DesktopMode
		Return New Vec2i( mode.width,mode.height )
	End

	#rem monkeydoc The desktop display mode.
	#end
	Property DesktopMode:DisplayMode()

		Local sdlMode:SDL_DisplayMode
		SDL_GetDesktopDisplayMode( 0,Varptr sdlMode )
		
		Return CreateDisplayMode( Varptr sdlMode )
	End
	
	#rem monkeydoc True if app is active.
	
	An app is active if any of its windows has system input focus.
	
	#end
	Property Active:Bool()
	
		Return _active
	End

	#rem monkeydoc The currently active window.
	
	The active window is the window that has system input focus.
	
	#end
	Property ActiveWindow:Window()
	
		If Not _activeWindow
			Local windows:=Window.VisibleWindows()
			If windows _activeWindow=windows[0]
		Endif
	
		Return _activeWindow
	End
	
	#rem monkeydoc Mouse location relative to the active window.
	#end	
	Property MouseLocation:Vec2i()

		Return _mouseLocation
	End
	
	#rem monkeydoc @hidden
	#end
	Property ModalView:View()
	
		Return _modalView
	End
	
	#rem monkeydoc Approximate frames per second rendering rate.
	#end
	Property FPS:Float()

		Return _fps
	End
	
	#rem monkeydoc Number of milliseconds app has been running.
	
	Deprecated! Just use std.time.Millisecs()
	
	#end
	Property Millisecs:Int()
	
		Return std.time.Millisecs()
	End
	
	#rem monkeydoc Puts the app to sleep.
	
	Note: Use of this method is not recommended, as the app will be unresponsive while sleeping!
	
	#end
	Method Sleep( seconds:Double )
	
		Local timeout:=Now()+seconds
		
		Repeat
			Local sleep:=timeout-Now()
			If sleep>10
				time.Sleep( sleep )
				UpdateWindows()
			Else If sleep>0
				time.Sleep( sleep )
			Else
				Return
			Endif
		Forever
	
	End
	
#If __DESKTOP_TARGET__
	
	#rem monkeydoc @hidden
	#end
	Method WaitIdle()
		Local future:=New Future<Bool>
		
		Idle+=Lambda()
			future.Set( True )
		End
		
		future.Get()
	End
	
#Endif
	
	#rem monkeydoc Puts app into modal mode.
	#end
	Method BeginModal( view:View )
	
		_modalStack.Push( _modalView )
		
		_modalView=view
		
		RequestRender()
	End
	
	#rem monkeydoc Exits app from modal mode.
	#end
	Method EndModal()
		
		_modalView=_modalStack.Pop()
		
		RequestRender()
	End
	
	#rem monkeydoc Terminate the app.
	#end
	Method Terminate()
	
		libc.exit_( 0 )
	End
	
	#rem monkeydoc Request that the app render itself.
	#end
	Method RequestRender()
	
		_requestRender=True
	End
	
	#rem monkeydoc @hidden
	#end
	Property Renderable:Bool()
		
		Return _activeWindow And Not _activeWindow.Minimized And _activeWindow.CanRender And Not _renderingSuspended
	End

	#rem monkeydoc @hidden
	#end
	Method MainLoop()
		
		If Not _requestRender Or Not Renderable

			SDL_WaitEvent( Null )
		Endif
		
		UpdateEvents()
		
		UpdateWindows()
	End
	
	#rem monkeydoc @hidden
	#end
	Method IsActive:Bool( view:View )
	
		Return view And view.Active And (Not _modalView Or view.IsChildOf( _modalView ))
	End
	
	#rem monkeydoc @hidden
	#end
	Method ActiveViewAtMouseLocation:View()
	
		If Not _window Return Null
		
		Local view:=_window.FindViewAtWindowPoint( _mouseLocation )
		
		If IsActive( view ) Return view
		
		Return Null
	End
	
	#rem monkeydoc @hidden
	#end	
	Method UpdateWindows()
		
		if Not Renderable Return
		
		Local render:=_requestRender
		_requestRender=False

		If render UpdateFPS()
		
		For Local window:=Eachin Window.VisibleWindows()
			window.UpdateWindow( render )
		Next
		
		If _mouseView And Not IsActive( _mouseView )
			SendMouseEvent( EventType.MouseUp,_mouseView )
			_mouseView=Null
		Endif
		
		If _hoverView And Not IsActive( _hoverView )
			SendMouseEvent( EventType.MouseLeave,_hoverView )
			_hoverView=Null
		Endif
		
		If Not _hoverView And Not _touchMouse
			_hoverView=ActiveViewAtMouseLocation()
			If _mouseView And _hoverView<>_mouseView _hoverView=Null
			If _hoverView SendMouseEvent( EventType.MouseEnter,_hoverView )
		Endif
		
	End
	
	#rem monkeydoc Resets polled mouse and keyboard devices.
	
	Clears the keyboard character queue and clears the pressed and released states for all keys and mouse buttons.
	
	#end
	Method ResetPolledInput()
		
		Keyboard.Reset()
		
		Mouse.Reset()
	End
	
	#rem monkeydoc @hidden
	#end
	Function EmscriptenMainLoop()

		App.RequestRender()
		
		App.MainLoop()
	End
	
	#rem monkeydoc Run the app.
	#end
	Method Run()
		'jl added
		if not _notesHaveBeenSet Then CreateNotes()
		
#If __TARGET__="emscripten"

		emscripten_set_main_loop( EmscriptenMainLoop,0,1 )
#Else
		Repeat

			MainLoop()
			
		Forever
#Endif
	
	End

	#rem monkeydoc @hidden
	#end
	Method SuspendRendering()
		
		_renderingSuspended+=1
	end
	
	#rem monkeydoc @hidden
	#end
	Method ResumeRendering()
		
		_renderingSuspended=Max( _renderingSuspended-1,0 )
	End

	#rem monkeydoc Enumerate the available display modes
	#end
	Method EnumDisplayModes:DisplayMode[]( displayIndex:Int=0 )
		
		Local n:=SDL_GetNumDisplayModes( displayIndex )
		If Not n Return Null
		
		Local modes:=New Stack<DisplayMode>
		
		For Local i:=0 Until n
			
			Local sdlMode:SDL_DisplayMode
			SDL_GetDisplayMode( displayIndex,i,Varptr sdlMode )
			
			Local mode:=CreateDisplayMode( Varptr sdlMode )
			
			Local found:=False
			For Local mode2:=Eachin modes
				If mode2.width<>mode.width Or mode2.height<>mode.height Or mode2.hertz<>mode.hertz Continue
				found=True
				Exit
			Next
			
			If Not found modes.Add( mode )
		Next
		
		Return modes.ToArray()
	End

'jl added
'------------------------------------------------------------	
	Method DispatchEvents()
		Local event:SDL_Event

		While SDL_PollEvent( Varptr event )
			Window.CreateNewWindows()
			
			DispatchEvent( Varptr event )
		Wend
	End
'------------------------------------------------------------	
	
	Internal
	
	Method UpdateEvents()
		
		'FIXME: Very hacky...
		Window.CreateNewWindows()
			
		Local event:SDL_Event

		While SDL_PollEvent( Varptr event )
			
			Keyboard.Update()
			
			Mouse.Update()
			
			Touch.Update()
		
			DispatchEvent( Varptr event )
			
		Wend
		
		Local idle:=Idle
		Idle=Null
		idle()

	End
	
	Private
	
	Field _touchMouse:Bool=False		'Whether mouse is really touch
	Field _captureMouse:Bool=False		'Whether to use SDL_CaptureMouse

'jl added
	Field _defaultMonoFont:Font
	
	Field _res:=New ResourceManager
	Field _defaultFont:Font
	Field _theme:Theme

	Field _active:Bool
	Field _activeWindow:Window
	
	Field _renderingSuspended:Int
	
	Field _keyView:View
	Field _hoverView:View
	Field _mouseView:View
	
	Field _requestRender:Bool
	Field _fps:Float
	Field _fpsFrames:Int
	Field _fpsMillis:Int

	Field _window:Window
	Field _keyDownView:View
	Field _key:Key
	Field _rawKey:Key
	Field _keyChar:String
	Field _modifiers:Modifier
	Field _mouseButton:MouseButton
	Field _mouseLocation:Vec2i
	Field _mouseWheel:Vec2i
	Field _mouseClicks:Int=0
	Field _finger:Int
	Field _fingerPressure:Float
	Field _fingerCoords:Vec2f
	
	Field _modalView:View
	Field _modalStack:=New Stack<View>
	
	Method UpdateFPS()
	
		_fpsFrames+=1
			
		Local elapsed:=App.Millisecs-_fpsMillis
		
		If elapsed>=250
			_fps=Round( _fpsFrames/(elapsed/1000.0) )
			_fpsMillis+=elapsed
			_fpsFrames=0
		Endif

	End
	
	Method SendKeyEvent( type:EventType )
	
		Local view:=KeyView
		
		Select type
		Case EventType.KeyDown
			_keyDownView=view
		Case EventType.KeyUp
			If view<>_keyDownView Return
		End
		
		Local event:=New KeyEvent( type,view,_key,_rawKey,_modifiers,_keyChar )
		
		KeyEventFilter( event )
		
		If event.Eaten Or Not view Return
		
		view.SendKeyEvent( event )
	End
	
	Method SendMouseEvent( type:EventType,view:View )
	
		Local location:=view.TransformWindowPointToView( _mouseLocation )
		
		Local event:=New MouseEvent( type,view,location,_mouseButton,_mouseWheel,_modifiers,_mouseClicks )
		
		MouseEventFilter( event )
		
		If event.Eaten Return
		
		view.SendMouseEvent( event )
		
		If event.Eaten Return
		
		Select type
		Case EventType.MouseDown
		
			Select _mouseButton
			Case MouseButton.Left
			
				SendMouseEvent( EventType.MouseClick,view )
				
				If _mouseClicks And Not (_mouseClicks & 1)
				
					SendMouseEvent( EventType.MouseDoubleClick,view )
					
				End
			
			Case MouseButton.Right

				SendMouseEvent( EventType.MouseRightClick,view )
			End
		End
		
	End
	
	Method SendTouchEvent( type:EventType )
	
		Local window:=_activeWindow
		If Not window Return

		Local p:=New Vec2i( _fingerCoords.x * window.Frame.Width,_fingerCoords.y * window.Frame.Height )

		Local location:=window.TransformWindowPointToView( p )
		
		window.SendTouchEvent( New TouchEvent( type,_activeWindow,location,_finger,_fingerPressure ) )
	End
	
	Method SendWindowEvent( type:EventType )
	
		Local event:=New WindowEvent( type,_window )
		
		_window.SendWindowEvent( event )
	End
	
	Method DispatchEvent( event:SDL_Event Ptr )
	
		SdlEventFilter( event )
		
		JoystickDevice.SendEvent( event )
	
		Keyboard.SendEvent( event )
		
		Mouse.SendEvent( event )
		
		Touch.SendEvent( event )
	
		Select event->type
		
#If __TARGET__="macos"

		Case SDL_QUIT
		
			If _activeWindow _activeWindow.SendWindowEvent( New WindowEvent( EventType.WindowClose,_activeWindow ) )
#Endif		
		
		Case SDL_KEYDOWN
		
			Local kevent:=Cast<SDL_KeyboardEvent Ptr>( event )
			
			_window=Window.WindowForID( kevent->windowID )
			If Not _window Return

			_key=Keyboard.KeyCodeToKey( Int( kevent->keysym.sym ) )
			_rawKey=Keyboard.ScanCodeToRawKey( Int( kevent->keysym.scancode ) )
			_keyChar=Keyboard.KeyName( _key )
			_modifiers=Keyboard.Modifiers
			
			If kevent->repeat_
				SendKeyEvent( EventType.KeyRepeat )
			Else
				SendKeyEvent( EventType.KeyDown )
			Endif
			
		Case SDL_KEYUP

			Local kevent:=Cast<SDL_KeyboardEvent Ptr>( event )
			
			_window=Window.WindowForID( kevent->windowID )
			If Not _window Return
			
			_key=Keyboard.KeyCodeToKey( Int( kevent->keysym.sym ) )
			_rawKey=Keyboard.ScanCodeToRawKey( Int( kevent->keysym.scancode ) )
			_keyChar=Keyboard.KeyName( _key )
			_modifiers=Keyboard.Modifiers
			
			SendKeyEvent( EventType.KeyUp )
			
		Case SDL_TEXTINPUT
		
			Local tevent:=Cast<SDL_TextInputEvent Ptr>( event )

			_window=Window.WindowForID( tevent->windowID )
			If Not _window Return
			
			_keyChar=String.FromCString( tevent->text )
			
			SendKeyEvent( EventType.KeyChar )
			
		Case SDL_MOUSEBUTTONDOWN
			
			Local mevent:=Cast<SDL_MouseButtonEvent Ptr>( event )
			
			_window=Window.WindowForID( mevent->windowID )
			If Not _window Return
			
			_mouseLocation=_window.MouseScale * New Vec2i( mevent->x,mevent->y )
			_mouseButton=Cast<MouseButton>( mevent->button )
			
			If Not _mouseView
			
				Local mouseView:=ActiveViewAtMouseLocation()
				
				If mouseView

					If _touchMouse
					
						_hoverView=mouseView
						
						SendMouseEvent( EventType.MouseEnter,_hoverView )
					
					Endif
				
					If _captureMouse SDL_CaptureMouse( SDL_TRUE )
					
					_mouseView=mouseView
					
					_mouseClicks=mevent->clicks
					
					SendMouseEvent( EventType.MouseDown,_mouseView )
					
					_mouseClicks=0

				Endif
				
			Endif
		
		Case SDL_MOUSEBUTTONUP
			
			Local mevent:=Cast<SDL_MouseButtonEvent Ptr>( event )
			
			_window=Window.WindowForID( mevent->windowID )
			If Not _window Return
			
			_mouseLocation=_window.MouseScale * New Vec2i( mevent->x,mevent->y )
			_mouseButton=Cast<MouseButton>( mevent->button )
			
			If _mouseView

				If _captureMouse SDL_CaptureMouse( SDL_FALSE )

				SendMouseEvent( EventType.MouseUp,_mouseView )

				_mouseButton=Null
				
				_mouseView=Null
				
				If _touchMouse
					
					SendMouseEvent( EventType.MouseLeave,_hoverView )
				
					_hoverView=Null

				Endif

			Endif
			
		Case SDL_MOUSEMOTION
		
			Local mevent:=Cast<SDL_MouseMotionEvent Ptr>( event )
				
			_window=Window.WindowForID( mevent->windowID )
			If Not _window Return
				
			_mouseLocation=_window.MouseScale * New Vec2i( mevent->x,mevent->y )
			
			If Not _touchMouse
			
				Local hoverView:=ActiveViewAtMouseLocation()
				If _mouseView And hoverView<>_mouseView hoverView=Null
	
				If hoverView<>_hoverView
	
					If _hoverView SendMouseEvent( EventType.MouseLeave,_hoverView )
						
					_hoverView=hoverView
						
					If _hoverView SendMouseEvent( EventType.MouseEnter,_hoverView )
				
				Endif
				
			Endif
			
			If _mouseView
			
				SendMouseEvent( EventType.MouseMove,_mouseView )
			
			Else If _hoverView

				SendMouseEvent( EventType.MouseMove,_hoverView )
			
			Endif

		Case SDL_MOUSEWHEEL
		
			Local mevent:=Cast<SDL_MouseWheelEvent Ptr>( event )
			
			_window=Window.WindowForID( mevent->windowID )
			If Not _window Return
			
			_mouseWheel=New Vec2i( mevent->x,mevent->y )
			
			If _mouseView
			
				SendMouseEvent( EventType.MouseWheel,_mouseView )
				
			Else If _hoverView

				SendMouseEvent( EventType.MouseWheel,_hoverView )
			
			Endif
			
		Case SDL_FINGERDOWN
		
			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
			_finger=tevent->fingerId
			_fingerPressure=tevent->pressure
			_fingerCoords=New Vec2f( tevent->x,tevent->y )
			
			SendTouchEvent( EventType.TouchDown )
		
		Case SDL_FINGERUP
		
			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
			_finger=tevent->fingerId
			_fingerPressure=tevent->pressure
			_fingerCoords=New Vec2f( tevent->x,tevent->y )
			
			SendTouchEvent( EventType.TouchUp )
		
		Case SDL_FINGERMOTION
		
			Local tevent:=Cast<SDL_TouchFingerEvent Ptr>( event )
			
			_finger=tevent->fingerId
			_fingerPressure=tevent->pressure
			_fingerCoords=New Vec2f( tevent->x,tevent->y )
			
			SendTouchEvent( EventType.TouchMove )
		
		Case SDL_WINDOWEVENT
		
			Local wevent:=Cast<SDL_WindowEvent Ptr>( event )
			
			_window=Window.WindowForID( wevent->windowID )
			If Not _window Return
			
			Select wevent->event
					
			Case SDL_WINDOWEVENT_CLOSE
			
				SendWindowEvent( EventType.WindowClose )
			
			Case SDL_WINDOWEVENT_MAXIMIZED
				
				SendWindowEvent( EventType.WindowMaximized )
				
			Case SDL_WINDOWEVENT_MINIMIZED
			
				SendWindowEvent( EventType.WindowMinimized )
				
			Case SDL_WINDOWEVENT_RESTORED
			
				SendWindowEvent( EventType.WindowRestored )
				
			Case SDL_WINDOWEVENT_FOCUS_GAINED
			
'				Print "SDL_WINDOWEVENT_FOCUS_GAINED"
			
				Local active:=_active
				_activeWindow=_window
				_active=True
				
				SendWindowEvent( EventType.WindowGainedFocus )
				
				If active<>_active Activated()
				
			Case SDL_WINDOWEVENT_FOCUS_LOST
			
'				Print "SDL_WINDOWEVENT_FOCUS_LOST"
			
				Local active:=_active
				_active=False
			
				If _mouseView And Not _captureMouse
					SendMouseEvent( EventType.MouseUp,_mouseView )
					_mouseView=Null
				Endif

				If _hoverView
					SendMouseEvent( EventType.MouseLeave,_hoverView )
					_hoverView=Null
				Endif
			
				SendWindowEvent( EventType.WindowLostFocus )
				
				If active<>_active Deactivated()
				
			Case SDL_WINDOWEVENT_LEAVE
			
				If _mouseView And Not _captureMouse
					SendMouseEvent( EventType.MouseUp,_mouseView )
					_mouseView=Null
				Endif
			
				If _hoverView
					SendMouseEvent( EventType.MouseLeave,_hoverView )
					_hoverView=Null
				Endif

			End
			
		Case SDL_USEREVENT
		
			Local uevent:=Cast<SDL_UserEvent Ptr>( event )
			
			Select uevent->code
			Case 0
				Local event:=Cast<AsyncEvent Ptr>( uevent->data1 )
				event->Dispatch()
			Case 1
				_window=Window.WindowForID( uevent->windowID )
				If Not _window Return
				
				SendWindowEvent( EventType.WindowSwapped )
			Case 2
				_window=ActiveWindow
				If Not _window Return
				
				SendWindowEvent( EventType.WindowVSync )
			End

		Case SDL_DROPFILE
		
			Local devent:=Cast<SDL_DropEvent Ptr>( event )
			
			Local path:=String.FromCString( devent->file ).Replace( "\","/" )
			
			SDL_free( devent->file )
			
			FileDropped( path )

		Case SDL_RENDER_TARGETS_RESET
		
			'Print "SDL_RENDER_TARGETS_RESET"
		
			RequestRender()
			
		Case SDL_RENDER_DEVICE_RESET
		
			'Print "SDL_RENDER_DEVICE_RESET"
		
			mojo.graphics.glutil.glGraphicsSeq+=1

#if __TARGET__="ios"

		Case SDL_APP_TERMINATING
			'Terminate the app.
			'Shut everything down before returning from this function.

		Case SDL_APP_LOWMEMORY
			'You will get this when your app is paused and iOS wants more memory.
			'Release as much memory as possible.		

		Case SDL_APP_WILLENTERBACKGROUND
			'Prepare your app to go into the background. Stop loops, etc.
			'This gets called when the user hits the home button, or gets a call.

			'Print "SDL_APP_WILLENTERBACKGROUND"
		
			SuspendRendering()

		Case SDL_APP_DIDENTERBACKGROUND
			'This will get called if the user accepted whatever sent your app to the background.
			'If the user got a phone call and canceled it, you'll instead get an SDL_APP_DIDENTERFOREGROUND event and restart your loops.
			'When you get this, you have 5 seconds to save all your state or the app will be terminated.
			'Your app is NOT active at this point.

		Case SDL_APP_WILLENTERFOREGROUND
			'This call happens when your app is coming back to the foreground.
			'Restore all your state here.

		Case SDL_APP_DIDENTERFOREGROUND
			'Restart your loops here.
			'Your app is interactive and getting CPU again.

			'Print "SDL_APP_DIDENTERFOREGROUND"

			ResumeRendering()

			RequestRender()
#Endif
     
		End
			
	End
	
	Function _EventFilter:Int( userData:Void Ptr,event:SDL_Event Ptr )
	
		Return App.EventFilter( userData,event )
	End
	
	Method EventFilter:Int( userData:Void Ptr,event:SDL_Event Ptr )
	
		Select event[0].type
		Case SDL_WINDOWEVENT

			Local wevent:=Cast<SDL_WindowEvent Ptr>( event )
			
			_window=Window.WindowForID( wevent->windowID )
			If Not _window Return 1
			
			Select wevent->event
			
			Case SDL_WINDOWEVENT_MOVED
			
'				Print "SDL_WINDOWEVENT_MOVED"
			
				SdlEventFilter( event )
	
				SendWindowEvent( EventType.WindowMoved )
			
				Return 0
					
			Case SDL_WINDOWEVENT_SIZE_CHANGED
				
'				Print "SDL_WINDOWEVENT_SIZE_CHANGED"

				Return 0
				
			Case SDL_WINDOWEVENT_RESIZED
				
'				Print "SDL_WINDOWEVENT_RESIZED"
			
				SdlEventFilter( event )
	
				SendWindowEvent( EventType.WindowResized )
				
				UpdateWindows()
			
				Return 0
			End

		End
		
		Return 1
	End
	
	Method CreateDisplayMode:DisplayMode( sdlMode:SDL_DisplayMode Ptr )
		
		Local mode:=New DisplayMode

#If __TARGET__="emscripten"
		mode.width=640
		mode.height=480
#else
		mode.width=sdlMode->w
		mode.height=sdlMode->h
		mode.depth=SDL_BYTESPERPIXEL( sdlMode->format )*8
		mode.hertz=sdlMode->refresh_rate
#endif
		Return mode
	End
		
End
