
Namespace my2dApp

#Import "<std>"
#Import "<mojo>"
Using std..
Using mojo..

'import oberon ini stuff lives here
#import "../oberon/oberon"

#import "arcadesprite"

#Import "assets/screen.png"
#Import "assets/lucon16x16_font.png"
#Import "assets/8x8_font.png"
#Import "assets/12x12_font.png"
#Import "assets/walls16x16_font.png"
#Import "assets/anim16x16_font.png"
#Import "assets/map1.mx2map"
#Import "assets/game.mx2palette"


const Name:string = "base2d"
Const Ver:string = "V1.01"
'widescreen
Const Size := New Vec2i( 1024, 640 )
'4:3
'Const Size := New Vec2i( 856, 640 )

'amstrad  320, 200 / 640, 200
'spectrum 256, 192
'atari ST 320, 200 / 640, 400
'amiga ST 320, 256 / 640, 400 / 640, 512
'atari 2600 160, 192 / 320, 192
'atari 7200 160×240 / 320×240
'bbc micro 160, 256 / 320, 256
'C64 160, 200 / 320, 200
'NES 256, 240
'Const Resolution:Vec2i = New Vec2i( 448, 320 )
Const Resolution:Vec2i = New Vec2i( 512, 320 )
const MidX:int = Resolution.X * 0.5
const MidY:int = Resolution.Y * 0.5

#jump page defines
	const PAGE_GAME:int = 1
	const PAGE_INTRO1:int = 2
	const PAGE_INTRO2:int = 3
	const PAGE_HEADER:int = 4
	const PAGE_MENU:int = 5
	const PAGE_OPTIONS:int = 6
	const PAGE_SOUND:int = 7
	const PAGE_ENDLEVEL:int = 8
	const PAGE_HISCOREENTER:int = 9
	const PAGE_SCORES:int = 10
	const PAGE_WARNING:int = 11
	const PAGE_LEVELPICK:int = 12
	const PAGE_ENTERNAME:int = 13
	const PAGE_CONTROLS:int = 14
	const PAGE_BONUS:int = 15
	const PAGE_AUTOPLAY:int = 16
	const PAGE_GAMEOVER:int = 17
	const PAGE_GAMETITLE:int = 18
	const PAGE_GAMETITLE2:int = 19
	const PAGE_GAMETITLE3:int = 20
	const PAGE_SUBGAME1:int = 21
	const PAGE_SUBGAME2:int = 22
	const PAGE_SUBGAME3:int = 23
	const PAGE_SUBGAME4:int = 24
	const PAGE_BADGAME:int = 25


Function Main()
	'3drun
	Local cfg := New StringMap<String>
	
	cfg["GL_depth_buffer_enabled"] = 1
	cfg["GL_stencil_buffer_enabled"] = 1
	
	New AppInstance( cfg )

'	gSplashImage = Image.Load( "asset::title.png" )

	New MyWindow
	App.Run()
	
	'to enable profiling
	'#P<code><num><data>
	'print "#PN0Hello"
	'print "#PV012" 'values go from 0 to 100
	'print "#PM0<num>" 'place a mark
End



Class MyWindow Extends GLWindow

	Method New()
		Super.New( Name+" "+Ver, Size.X, Size.Y, WindowFlags.Resizable )
		SetMinSize( Size.X, Size.Y )
	
		'if you want a constant canvas size use this
'		Layout = "letterbox"
		'or If you want the canvas to always fill the window use this
		Layout = "fill"

		ClearColor = Color.PicoBlack

		'setup the custom canvas
		myCanvas = New Canvas( canvasImage )


		_screenImage = Image.Load( "asset::screen.png" )
		local fontImage:Image = Image.Load( "asset::walls16x16_font.png" )
		_font = New ArcadeFont( fontImage )
		fontImage = Image.Load( "asset::8x8_font.png" )
		_fontTiny = New ArcadeFont( fontImage )
		fontImage = Image.Load( "asset::12x12_font.png" )
		_fontSmall = New ArcadeFont( fontImage )
		fontImage = Image.Load( "asset::lucon16x16_font.png" )
		_fontText = New ArcadeFont( fontImage )
		fontImage = Image.Load( "asset::anim16x16_font.png" )
		_fontAnim = New ArcadeFont( fontImage )

		_palette = New ColorPalette( "asset::game.mx2palette" )
		_fontMap =  New FontMap( _font, _palette )

		_fontMap.Load( "asset::map1.mx2map" )
		_fontMap.SetDivRes( 16, 16, Resolution.X, Resolution.Y )
		
		
'		SetPage( PAGE_SUBGAME3 )
		SetPage( PAGE_GAME )
		

		'set an ini file
		LoadIni()

		'set a timer that ticks 60FPS
		_timer60 = New Timer( 60, OnUpdate60 )
	End


	method SetPage( page:int )
'		Print "setpage "+page
		_gameFrame = 0
		_pageTime = _gameTime
		
		Select page
			Case PAGE_SUBGAME3

			Case PAGE_SUBGAME2
				
			Case PAGE_GAME
		End Select
		
		_page = page
	End method


protected

	'the AppView hold each page and handles all the UI interaction stuff
	field AppView:UXAppView
	'the Pages are added to the app view
	field Page:UXPageView
	field PageOptions:UXPageView

	method OnUpdate60()
		_oldTime = _gameTime
		_gameTime = Millisecs() - _startTime
				
		_gameFrame += 1

		Select _page
			Case PAGE_SUBGAME3
				RequestRender()

			Case PAGE_GAME
				RequestRender()
		End Select
		
	End method
	



	
	Method OnRender( canvas:Canvas ) Override
		'enable perfect pixels
		canvas.TextureFilteringEnabled = False
		myCanvas.TextureFilteringEnabled = false

		'setup the initial window redraw
		If Width <> _width or Height <> _height Then
			If _height <> Height Then
				_fontScale = float(Height) / 640
			End If
			
'			If _width <> Width then
				'deal with any true fonts
'				_fontScale = float(Width) / 720
'				_font = Font.Load( "asset::Amalgamation V1.1.ttf", 18 * _fontScale )
'				_fontBig = Font.Load( "asset::Amalgamation V1.1.ttf", 33 * _fontScale )
'				_fontBiggest = Font.Load( "asset::Amalgamation V1.1.ttf", 40 * _fontScale )
'				_fontNBig = Font.Load( "asset::Neuropol.ttf", 34 * _fontScale )
'				_fontN = Font.Load( "asset::Neuropol.ttf", 17 * _fontScale )
'				_fontNSmall = Font.Load( "asset::Neuropol.ttf", 11 * _fontScale )

'				_midX = Width * 0.5
'				_midY = Height * 0.5
			
'				_scale = _midY * 0.15
'				_mScale = _scale / 3
	
'				paths.SetScale( _mScale )
'				paths.Smooth( 200 )
'			End if
			_width = Width
			_height = Height
			_midX = Width * 0.5
			_midY = Height * 0.5
			_redraw = True
			OnWindowSize( Self )
		End If
		
		'we need at lest one draw command!
		canvas.DrawText( " ", -10, -10 )
		

'		canvas.DrawText( "y= "+_lookatY, 30, 150 )
'		canvas.DrawText( "dist= "+_dist, 30, 165 )
'		canvas.DrawText( "roty= "+_rotY+"  rotx= "+_rotX, 30, 180 )

		'fill the custom canvas with a color
		myCanvas.Clear(Color.None)
		myCanvas.Color = Color.Red
		myCanvas.Alpha = 0.5
		myCanvas.DrawRect( 0, 0, Resolution.X, Resolution.Y )
		myCanvas.DrawRect( 0, 0, 100, 100 )
		myCanvas.Alpha = 1
		myCanvas.Color = Color.White
		myCanvas.DrawLine( 10, 10, 100, 100 )

		'finally draw the custom canvas to the normal canvas
		myCanvas.Flush()
		
		canvas.Color = Color.White
		canvas.DrawRect( 0, 0, Width, Height,  canvasImage )

	End


	method OnKeyDown( KeyDown:Key )
		Select KeyDown
			Case Key.P
				If DEBUG Then
				End If
				
			Case _keyUp
			Case _keyDown
			Case _keyLeft
			Case _keyRight
			Case _keyFire1
		End Select
	End method

	
	method OnKeyUp( KeyUp:Key )
'		Select KeyUp
'			Case Key.Enter
'				Print "ENTER UP"
'		End Select
	End method
	
	
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


	method OnMouseDown() Override
		Select _page
			Case PAGE_GAME
		End Select
	End method
	
	method OnMouseMove() override
		Select _page
			Case PAGE_GAME
		End select
	End method
	
	

	method LoadIni()
		Local user:string
'#If __TARGET__="windows"
			Local USERNAME:libc.char_t Ptr = libc.getenv("USER")
			user = String.FromCString(USERNAME)
'#Else If __TARGET__="macos"
'			Local USERNAME:libc.char_t Ptr = libc.getenv("USER")
'			user = String.FromCString(USERNAME)
'#Else
'			Local USERNAME:libc.char_t Ptr = libc.getenv("USERNAME")
'			user = String.FromCString(USERNAME)
'#endif

		Ini = New UXIni( DataDir()+Name )
		Ini.Load()

		Local k:int
		Local str:string

		If Ini.GetInt( "Window", "X", -99 ) <> -99 Then
			_windowX = Ini.GetInt( "DesktopWindow", "X", 50 )
			_windowY = Ini.GetInt( "DesktopWindow", "Y", 50 )
			_windowWidth = Ini.GetInt( "DesktopWindow", "Width", Size.X )
			_windowHeight = Ini.GetInt( "DesktopWindow", "Height", Size.Y )
			_fullscreen = Ini.GetBool( "DesktopWindow", "Fullscreen", False )
			If _fullscreen Then
				Print "dx= "+_windowX+" dy= "+_windowY+"  _ww= "+_windowWidth+" _wh= "+_windowHeight+"  fc= yes"
			Else
				Print "dx= "+_windowX+" dy= "+_windowY+"  _ww= "+_windowWidth+" _wh= "+_windowHeight+"  fc= no"
			End if

			
			If _fullscreen Then
#If __TARGET__="macos"
				Print "mac fullscreen windowresize"
				WindowResize( _windowX, _windowY, _windowWidth, _windowHeight )
#Else
				Print "win fullscreen windowresize"
				BeginFullscreen()
				WindowResize( 0, 0, DesktopWidth, DesktopHeight )
#Endif
			Else
				Print "not fullscreen"
				Local x:int = Ini.GetInt( "Window", "X", 50 )
				Local y:int = Ini.GetInt( "Window", "Y", 50 )
				Local w:int = Ini.GetInt( "Window", "Width", Size.X )
				Local h:int = Ini.GetInt( "Window", "Height", Size.Y )
				
				If w = DesktopWidth And h = DesktopHeight Then
					w = Size.X
					h = Size.Y
				End If
				If x = 0 And y = 0 Then
					x = 50
					y = 50
				End if
				
				WindowResize( x, y, w, h )
			End If
'			WindowResize( Ini.GetInt( "Window", "X", 0 ), Ini.GetInt( "Window", "Y", 0 ), Ini.GetInt( "Window", "Width", Size.X ), Ini.GetInt( "Window", "Height", Size.Y ) )
		End If

		
		_keyLeft = Cast<Key>( Ini.GetInt( "Keys", "Left", Key.Left ) )
		_keyRight = Cast<Key>( Ini.GetInt( "Keys", "Right", Key.Right ) )
		_keyUp = Cast<Key>( Ini.GetInt( "Keys", "Up", Key.Up ) )
		_keyDown = Cast<Key>( Ini.GetInt( "Keys", "Down", Key.Down ) )
		_keyFire1 = Cast<Key>( Ini.GetInt( "Keys", "Fire1", Key.Space ) )
		_keyBack = Cast<Key>( Ini.GetInt( "Keys", "Back", Key.Escape ) )

		
'		_joystick.CurrentName = Ini.GetString( "Joy", "Name" )
'		Print _joystick.CurrentName
'		_joystick.Left = Ini.GetInt( "Joy", "Left", 0 )
'		_joystick.Right = Ini.GetInt( "Joy", "Right", 1 )
'		_joystick.Up = Ini.GetInt( "Joy", "Up", 2 )
'		_joystick.Down = Ini.GetInt( "Joy", "Down", 3 )
'		_joystick.Fire1 = Ini.GetInt( "Joy", "Fire1", 4 )
'		_joystick.Back = Ini.GetInt( "Joy", "Back", 5 )

'		Local score:int
'		Local level:int
'		Local name:string
'		For k = 0 To 5
'			score = Ini.GetInt( "Score"+k, "Score" )
'			level = Ini.GetInt( "Score"+k, "Level" )
'			name = Ini.GetString( "Score"+k, "Name" )
'			_scoreTable.Add( score, level, name )
'		Next

'		For k = 1 To 6
'			_zoneActive[k] = Ini.GetBool( "zone", k, false )
'			_zoneActive[k] = true
'		Next

'		OpenPage.middleIconButton.Selected = Ini.GetBool( "UI", "OpenMiddle", true )
'		OpenPage.ModifyFileMiddle()

'		OpenPage.ListButton.Selected = Ini.GetBool( "UI", "OpenList", true )
'		OpenPage.IconButton.Selected = Not OpenPage.ListButton.Selected
'		OpenPage.files.UseIcons = Not OpenPage.ListButton.Selected

'		str = Ini.GetString( "OpenFiles", "Last", DesktopDir() )
'		places.Path = str
'		folders.Path = str
'		files.Path = str
'		PathTrail.Path = str

		
'		Local count:int = Ini.GetInt( "favorite", "count", -1 )
'		If count > -1 Then
'			Print "favorites = "+count
'			For k = 0 To count
'	 			str = Ini.GetString( "favorite", k, "" )
'	 			If str <> "" Then
''	 				Print str
'	 				OpenPage.places.AddFavorite( str )
'	 			End If
'	 		next
'		End If
	End method

	
	method SaveIni( x:int, y:int, width:int, height:int )
		If Not Ini Then Return
		
		Ini.SetInt( "DesktopWindow", "X", _windowX )
		Ini.SetInt( "DesktopWindow", "Y", _windowY )
		Ini.SetInt( "DesktopWindow", "Width", _windowWidth )
		Ini.SetInt( "DesktopWindow", "Height", _windowHeight )
		Ini.SetBool( "DesktopWindow", "Fullscreen", _fullscreen )

		Ini.SetInt( "Window", "X", x )
		Ini.SetInt( "Window", "Y", y )
		Ini.SetInt( "Window", "Width", width )
		Ini.SetInt( "Window", "Height", height )
		
		Ini.SetInt( "Keys", "Left", _keyLeft )
		Ini.SetInt( "Keys", "Right", _keyRight )
		Ini.SetInt( "Keys", "Up", _keyUp )
		Ini.SetInt( "Keys", "Down", _keyDown )
		Ini.SetInt( "Keys", "Fire1", _keyFire1 )
		Ini.SetInt( "Keys", "Back", _keyBack )

'		Ini.SetString( "Joy", "Name", _joystick.CurrentName )
'		Ini.SetInt( "Joy", "Left", _joystick.Left )
'		Ini.SetInt( "Joy", "Right", _joystick.Right )
'		Ini.SetInt( "Joy", "Up", _joystick.Up )
'		Ini.SetInt( "Joy", "Down", _joystick.Down )
'		Ini.SetInt( "Joy", "Fire1", _joystick.Fire1 )
'		Ini.SetInt( "Joy", "Back", _joystick.Back )

'		Local k:int
'		For k = 0 To 5
'			Ini.SetInt( "Score"+k, "Score", _scoreTable.score[k] )
'			Ini.SetInt( "Score"+k, "Level", _scoreTable.level[k] )
'			Ini.SetString( "Score"+k, "Name", _scoreTable.name[k] )
'		Next
		
'		For k = 1 To 6
'			Ini.SetBool( "zone", k, _zoneActive[k] )
'		Next
		
		'	field score:int[] = New int[10]
'	field level:int[] = New int[10]
'	field name:string[] = New string[10]

		
'		Ini.SetBool( "UI", "OpenMiddle", OpenPage.middleIconButton.Selected )
'		Ini.SetBool( "UI", "OpenList", OpenPage.ListButton.Selected )
		
'		Ini.SetString( "OpenFiles", "Last", OpenPage.files.Path )
		
'		Local count:int
'		Print "favorites = "+places.FavoriteCount
' 		If OpenPage.places.FavoriteCount > -1 Then
' 			Ini.SetInt( "favorite", "count", OpenPage.places.FavoriteCount )
' 			Local k:int
' 			For k = 0 To OpenPage.places.FavoriteCount
'' 				Print k+" "+places.GetFavorite( k )
'	 			Ini.SetString( "favorite", k, OpenPage.places.GetFavorite( k ) )
' 			Next
' 		else
' 			Ini.SetInt( "favorite", "count", -1 )
' 		End If
		
		Ini.Save()
	End method
	
	
	Method OnWindowEvent( event:WindowEvent ) Override
		Select event.Type
			Case EventType.WindowClose
				OnClose( Self )
				App.Terminate()
			Case EventType.WindowResized
				OnWindowSize( Self )
				RequestRender()
		End select
	End
	
	method OnWindowSize( window:Window )
		If IsFullscreen Then
			_fullscreen = true
		Else
			_windowX = WindowX
			_windowY = WindowY
			_windowWidth = WindowWidth
			_windowHeight = WindowHeight
			_fullscreen = false
		End If
		_redraw = True
	End method

	Method OnClose( window:Window )
		local windowRect:Recti = window.Frame

		SaveIni( windowRect.X, windowRect.Y, windowRect.Width, windowRect.Height )
	End


private
	field Ini:UXIni

	field _timer60:Timer

	field _startTime:long = Millisecs()
	field _gameFrame:int = 0
	field _gameTime:long
	field _oldTime:long

	field _page:int
	field _pageTime:long

	Field canvasImage:Image = New Image( Resolution.X, Resolution.Y )
	field myCanvas:Canvas

	field _fontText:ArcadeFont
	field _fontTiny:ArcadeFont
	field _fontSmall:ArcadeFont
	field _font:ArcadeFont
	field _fontAnim:ArcadeFont
	field _fontMap:FontMap
	field _palette:ColorPalette
	field _screenImage:Image
	
	field _fontScale:float = 1
	
	field _sprites:SpriteManager = New SpriteManager()

	'window stuff
	field _windowX:int
	field _windowY:int
	field _windowWidth:int
	field _windowHeight:int
	field _fullscreen:bool = false
	field _width:int
	field _height:int
	field _midX:int
	field _midY:int
	field _redraw:bool = False

	'input systems
	field _keyPressed:bool
	field _shiftDown:bool
	field _altDown:bool
	field _controlDown:bool
	field _commandDown:bool
	field _keyLeft:Key = Key.Left
	field _keyRight:Key = Key.Right
	field _keyUp:Key = Key.Up
	field _keyDown:Key = Key.Down
	field _keyFire1:Key = Key.Z
	field _keyFire2:Key = Key.X
	field _keyFire3:Key = Key.C
	field _keyBack:Key = Key.Escape
	
End


