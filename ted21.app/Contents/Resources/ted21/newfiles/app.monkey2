
Namespace myApp

#Import "<std>"
#Import "<mojo>"
Using std..
Using mojo..

'import oberon, & ini stuff lives here
#import "../oberon/oberon"



const Name:string = "App"
Const Ver:string = "V1.01"
'widescreen
Const Size := New Vec2i( 1024, 640 )
'4:3
'Const Size := New Vec2i( 856, 640 )



Function Main()
	'3drun
	Local cfg := New StringMap<String>
	
	cfg["GL_depth_buffer_enabled"] = 1
	cfg["GL_stencil_buffer_enabled"] = 1
	
	New AppInstance( cfg )

'	gSplashImage = Image.Load( "asset::title.png" )

	New MyWindow
	App.Run()

'	New AppInstance
'	New MyWindow
'	App.Run()
	
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

		InitPages()

		'set an ini file
		LoadIni()

		'set a timer that ticks 60FPS
		_timer60 = New Timer( 60, OnUpdate60 )
	End


	method InitPages()
		Page = New UXPageView( "Page 1" )
'		Page.SetGridX( 11 )
		Page.SetGrid( 24, 16 )
'		Page.Visible = false
		Page.ShowGrid = true
'		Page.PageColor = Color.PicoBlack

		local text2 := New UXLabel( "Color Controls", ALIGN_CENTERED )
		text2.Bold = True
		text2.BGColor = Color.Blood * 0.8
'		text2.BGColor = Color.ExPurple
		text2.SetGridLayout( 1, 8.5, 9, 0.5 )
		Page.AddControl( text2 )


		Local panelx:UXPanel = New UXPanel()
		panelx.SetGridLayout( 1, 9, 9, 7 )
		panelx.Border = 0
		panelx.FGColor = Color.PicoBlack * 0.8
		panelx.DrawTop = true
		Page.AddControl( panelx )


		faderMono = New UXVertical( )
		local zoomLabel1 := New UXLabel( "Mono", ALIGN_CENTERED )
		local zoomText1 := New UXLabel( "1.0", ALIGN_CENTERED )
		faderRed = New UXVertical( )
		local zoomLabel2 := New UXLabel( "Red", ALIGN_CENTERED )
		local zoomText2 := New UXLabel( "1.0", ALIGN_CENTERED )
		faderGreen = New UXVertical( )
		local zoomLabel3 := New UXLabel( "Green", ALIGN_CENTERED )
		local zoomText3 := New UXLabel( "1.0", ALIGN_CENTERED )
		faderBlue = New UXVertical( )
		local zoomLabel4 := New UXLabel( "Blue", ALIGN_CENTERED )
		local zoomText4 := New UXLabel( "1.0", ALIGN_CENTERED )
		faderGamma = New UXVertical( )
		local gammaLabel1 := New UXLabel( "Gamma", ALIGN_CENTERED )
		local gammaText1 := New UXLabel( "1.0", ALIGN_CENTERED )

		faderMono.SetGridLayout( 2, 10, 1, 5 )
		faderMono.HelpText = "Modify the current Mono amount, MouseWheeel also works here"
		faderMono.Value = 0.0
		faderMono.Clicked = Lambda()
			zoomText1.Text = GetFloatText( faderMono.Value )
		End
		Page.AddControl( faderMono )
		zoomText1.SetGridLayout( 2, 9, 1, 1 )
		Page.AddControl( zoomText1 )
		zoomLabel1.SetGridLayout( 2, 15, 1, 1 )
		Page.AddControl( zoomLabel1 )

		faderRed.SetGridLayout( 4, 10, 1, 5 )
		faderRed.HelpText = "Modify the current Red amount, MouseWheeel also works here"
		faderRed.Value = 1.0
		faderRed.Clicked = Lambda()
			zoomText2.Text = GetFloatText( faderRed.Value )
		End
		Page.AddControl( faderRed )
		zoomText2.SetGridLayout( 4, 9, 1, 1 )
		Page.AddControl( zoomText2 )
		zoomLabel2.SetGridLayout( 4, 15, 1, 1 )
		Page.AddControl( zoomLabel2 )

		faderGreen.SetGridLayout( 5, 10, 1, 5 )
		faderGreen.HelpText = "Modify the current Green amount, MouseWheeel also works here"
		faderGreen.Value = 1.0
		faderGreen.Clicked = Lambda()
			zoomText3.Text = GetFloatText( faderGreen.Value )
		End
		Page.AddControl( faderGreen )
		zoomText3.SetGridLayout( 5, 9, 1, 1 )
		Page.AddControl( zoomText3 )
		zoomLabel3.SetGridLayout( 5, 15, 1, 1 )
		Page.AddControl( zoomLabel3 )

		faderBlue.SetGridLayout( 6, 10, 1, 5 )
		faderBlue.HelpText = "Modify the current Blue amount, MouseWheeel also works here"
		faderBlue.Value = 1.0
		faderBlue.Clicked = Lambda()
			zoomText4.Text = GetFloatText( faderBlue.Value )
		End
		Page.AddControl( faderBlue )
		zoomText4.SetGridLayout( 6, 9, 1, 1 )
		Page.AddControl( zoomText4 )
		zoomLabel4.SetGridLayout( 6, 15, 1, 1 )
		Page.AddControl( zoomLabel4 )

		faderGamma.SetGridLayout( 8, 10, 1, 5 )
		faderGamma.HelpText = "Modify the current Gamma, MouseWheeel also works here"
		faderGamma.Value = 0.5
		faderGamma.Clicked = Lambda()
			gammaText1.Text = GetFloatText( faderGamma.Value*2 )
			FinalGamma = (faderGamma.Value*2)
		End
		Page.AddControl( faderGamma )
		gammaText1.SetGridLayout( 8, 9, 1, 1 )
		Page.AddControl( gammaText1 )
		gammaLabel1.SetGridLayout( 7.5, 15, 2, 1 )
		Page.AddControl( gammaLabel1 )

#-
		'create the app view and add any created pages
		AppView = New UXAppView()
		
		AppView.AddPage( Page )
'		AppView.AddPage( PageOptions )
'		AppView.AddPage( SamplePage )
'		AppView.AddPage( OpenPage )
'		AppView.AddPage( NewPage )

		'activate the app view
		ContentView = AppView
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


		RequestRender()
	End method
	



	
	Method OnRender( canvas:Canvas ) Override
		'enable perfect pixels
'		canvas.TextureFilteringEnabled = False

		'setup the initial window redraw
		If Width <> _width or Height <> _height Then
			If _height <> Height Then
'				_fontScale = float(Height) / 640
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
		

	End


	method OnKeyDown( KeyDown:Key )
		Select KeyDown
			Case Key.P
				If DEBUG Then
'					Page.Visible = Not Page.Visible
'					_showOverlay = Not _showOverlay
				End If
				
		End Select
	End method

	
	method OnKeyUp( KeyUp:Key )
'		Select KeyUp
'			Case Key.Enter
'				Print "ENTER UP"
'		End Select
	End method
	
	


	method OnMouseDown() Override
	End method
	
	method OnMouseMove() override
	End method
	
	
private
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

		
'		_keyLeft = Cast<Key>( Ini.GetInt( "Keys", "Left", Key.Left ) )
'		_keyRight = Cast<Key>( Ini.GetInt( "Keys", "Right", Key.Right ) )
'		_keyUp = Cast<Key>( Ini.GetInt( "Keys", "Up", Key.Up ) )
'		_keyDown = Cast<Key>( Ini.GetInt( "Keys", "Down", Key.Down ) )
'		_keyFire1 = Cast<Key>( Ini.GetInt( "Keys", "Fire1", Key.Space ) )
'		_keyBack = Cast<Key>( Ini.GetInt( "Keys", "Back", Key.Escape ) )

		
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
		
'		Ini.SetInt( "Keys", "Left", _keyLeft )
'		Ini.SetInt( "Keys", "Right", _keyRight )
'		Ini.SetInt( "Keys", "Up", _keyUp )
'		Ini.SetInt( "Keys", "Down", _keyDown )
'		Ini.SetInt( "Keys", "Fire1", _keyFire1 )
'		Ini.SetInt( "Keys", "Back", _keyBack )

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
	
	
	'respond to any key presses
	Method OnKeyEvent( event:KeyEvent ) Override
		_shiftDown = event.Modifiers & Modifier.Shift
		_altDown = event.Modifiers & Modifier.Alt
		_controlDown = event.Modifiers & Modifier.Command
		_commandDown = event.Modifiers & Modifier.Gui
		
		Select event.Type
			case EventType.KeyDown
				_keyPressed = true
				OnKeyDown( event.Key )
				
			Case EventType.KeyUp
				_keyPressed = true
				OnKeyUp( event.Key )
				
		End Select
		
	End

	'this is needed to allow the Size to be correct. this is called automatically
	Method OnMeasure:Vec2i() Override
		Return Size
	End

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

	'2d overlay
	field faderMono:UXVertical
	field faderRed:UXVertical
	field faderGreen:UXVertical
	field faderBlue:UXVertical
	field faderGamma:UXVertical
	field FinalColor:Color = Color.White
	field FinalGamma:float = 0.5

	'keys
	field _keyPressed:bool
	field _shiftDown:bool
	field _altDown:bool
	field _controlDown:bool
	field _commandDown:bool

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

End

