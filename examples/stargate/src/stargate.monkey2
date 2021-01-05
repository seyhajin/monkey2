
Namespace stargate

#Import "<std>"
#Import "<mojo>"
#Import "<mojox>"

Using std..
Using mojo..
Using mojox..

#Import "assets.monkey2"
#Import "planet.monkey2"
#Import "actor.monkey2"
#Import "player.monkey2"
#Import "lazer.monkey2"
#Import "humanoid.monkey2"
#Import "lander.monkey2"
#Import "mutant.monkey2"
#Import "bomber.monkey2"
#Import "pod.monkey2"
#Import "swarmer.monkey2"
#Import "bomb.monkey2"
#Import "baiter.monkey2"
#Import "bullet.monkey2"
#Import "bonus.monkey2"
#Import "game.monkey2"

#Import "titlepage.html"

Class GameView Extends View

	Method New()
		Layout="float"
		Gravity=New Vec2f( 0,1 )
	End

	Method OnMeasure:Vec2i() Override
		Return New Vec2i( ViewWidth,ViewHeight )
	End

	Method OnRender( canvas:Canvas ) Override
		RenderPlanet( canvas )
		RenderActors( canvas )
	End

End

Class StatsView Extends View

	Field player:Player

	Method New()
		Layout="float"
	End
	
	Method OnMeasure:Vec2i() Override
	
		Return New Vec2i( WindowWidth-ScannerWidth/2,ScannerHeight )
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		If Not player Return

		canvas.PushMatrix()
		
		canvas.Translate( 4,4 )
		
		canvas.DrawText( player.score,0,0 )
				
		canvas.Translate( 0,20 )
		canvas.Scale( .75,.75 )
		
		Local image:=playerAnim[0]
		For Local x:=0 Until player.lives
			canvas.DrawImage( image,x*(image.Width+4)-image.Bounds.Left,-image.Bounds.Top )
		Next
		
		canvas.PopMatrix()
	
	End

End

Class ScannerView Extends View

	Method New()
		Layout="float"
		Gravity=New Vec2f( .5,0 )
	End
	
	Method OnMeasure:Vec2i() Override
		Return New Vec2i( ScannerWidth,ScannerHeight )
	End
	
	Method OnRender( canvas:Canvas ) Override
		canvas.DrawImage( MiniMountains,-ScrollX*ScannerWidth/PlanetWidth,-1 )
		RenderBlips( canvas )
	End

End

'should be builtin!
Class PlayView Extends View

	Method AddView( view:View )
		AddChildView( view )
		_views.Push( view )
	End
	
	Method RemoveView( view:View )
		RemoveChildView( view )
		_views.Remove( view )
	End
	
	Method OnLayout() Override
		For Local view:=Eachin _views
			view.Frame=Rect
		Next
	End
	
	Field _views:=New Stack<View>
End

Class Stargate Extends Window

	Field playing:Bool
	Field gameover:Bool
	
	Field playView:PlayView
	Field titlePage:HtmlView
	
	Field gameView:GameView
	Field scannerView:ScannerView
	Field statsView1:StatsView
	Field statsView2:StatsView
	
	Field dialogStyle:Style
	Field dialogView:TextDialog
	Field dialogTimer:Float
	
	Method New()
		Super.New( "Stargate!",WindowWidth,WindowHeight,WindowFlags.Center )'|WindowFlags.Resizable )
		
		Layout="stretch"
		
		ClearColor=New Color( 0,0,0,1 )
		
		dialogStyle=New Style
		dialogStyle.BackgroundColor=New Color( 0,0,0,.5 )
'		dialogStyle.SetColor( "background",New Color( 0,0,0,.5 ) )
'		dialogStyle.SetFont( "text",Font.Open( App.DefaultMonoFontName,20 ) )
'		dialogStyle.SetColor( "text",Color.White )
		
		InitAssets()
		InitPlanet()
		InitActor()
		InitPlayer()
		InitLazer()
		InitHumanoid()
		InitBullet()
		InitBaiter()
		InitLander()
		InitMutant()
		InitBomber()
		InitPod()
		InitSwarmer()
		InitBomb()
		InitBonus()
		
		gameView=New GameView
		scannerView=New ScannerView
		statsView1=New StatsView
		statsView1.Gravity=New Vec2f( 0,0 )
		statsView2=New StatsView
		statsView2.Gravity=New Vec2f( 1,0 )
		
		playView=New PlayView
		playView.AddView( scannerView )
		playView.AddView( gameView )
		playView.AddView( statsView1 )
		playView.AddView( statsView2 )
		
		titlePage=New HtmlView
		titlePage.HtmlSource=LoadString( "asset::titlepage.html" )
		
		ContentView=titlePage
		
		SwapInterval=1
		
		New Timer( 60,OnUpdate )
	End
	
	Method ShowAttackWaveComplete()

		dialogView=New TextDialog
		dialogView.Title="Defender dialog"
		dialogView.Style=dialogStyle
		dialogView.Text="ATTACK WAVE "+AttackWave+" COMPLETE"
		dialogTimer=1
		
		dialogView.Open()
	End
	
	Method ShowGameOver()

		dialogView=New TextDialog
		dialogView.Title="Defender dialog"
		dialogView.Style=dialogStyle
		dialogView.Text="GAME OVER"
		dialogTimer=1
		
		dialogView.Open()
		
		gameover=True
	End
	
	Method OnUpdate()
	
		App.RequestRender()
		
		If Not playing
			If Keyboard.KeyDown( Key.Space )
				ContentView=playView
				playView.InvalidateStyle()
				StartNewGame()
				statsView1.player=PlayerUp
				playing=True
				gameover=False
			Else
				Return
			Endif
		Endif

		If dialogView
		
			dialogTimer-=.005
			If dialogTimer>=0
				dialogStyle.BackgroundColor=New Color( 0,0,0,1-dialogTimer )
				dialogView.InvalidateStyle()
				UpdateGame()
				Return
			Endif
			
			dialogView.Close()
			dialogView=Null
			dialogStyle.BackgroundColor=Color.None
			
			If gameover
			
				ContentView=titlePage
				playing=False
				Return
				
			Endif
			
			If PlayerKilled And Not PlayerUp.lives
				ShowGameOver()
				Return
			Endif
			
			RestartGame()
			
		Endif
		
		UpdateGame()
		
		If AttackWaveComplete
		
			ShowAttackWaveComplete()
			
		Else If PlayerKilled
		
			If Not PlayerUp.lives
				ShowGameOver()
			Else
				RestartGame()
			Endif
		Endif

	End
	
	Method OnMeasure:Vec2i() Override
	
		Return New Vec2i( WindowWidth,WindowHeight )
	End
		
End
