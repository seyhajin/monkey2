Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"
#Import "<mojo3d-physics>"

#Import "assets/"

#Import "../../mojo3d/tests/assets/miramar-skybox.jpg"

#Import "../../mojo3d-loaders/tests/assets/castle/@/castle"

#Import "util"

#Import "qcollide"

Using std..
Using mojo..
Using mojo3d..

Const GRAVITY:=30	'coz reality sux!

Class Player

	Field _scene:Scene
	
	Field _model:Model
	
	Field _collider:ConvexCollider
	
	Field _paused:Bool
	
	Field _onground:Bool
	
	Field _yvel:Float
	
	Method New( radius:Float=.5,height:Float=1 )
		
		_model=Model.CreateCapsule( radius,height,Axis.Y,12,New PbrMaterial( Color.Sky ) )

'		_model.Move( 0,0,0 )
		
		_collider=New CapsuleCollider( radius,height,Axis.Y )
		
		_collider.Margin=.01
	End
	
	Method Update()
		
		Local src:=_model.Position
		
		Move()
		
		If _paused Return
		
		Local qresult:=qcollide.QCollide( _collider,src,_model.Position )

		_model.Position=qresult.position
		
		src=_model.Position
		
		If _onground _yvel=-_collider.Margin
			
		_yvel-=GRAVITY/60.0/60.0

		_model.MoveY( _yvel )

		qresult=qcollide.QCollide( _collider,src,_model.Position )

		_model.Position=qresult.position
		
		_yvel=_model.Position.y-src.y
		
		_onground=qresult.onground
	End
	
	Method Move()
		
		If Keyboard.KeyDown( Key.Left )
			
			_model.RotateY( 2.5 )
			
		Else If Keyboard.KeyDown( Key.Right )
			
			_model.RotateY( -2.5 )
		Endif

		If _paused
			
			If Keyboard.KeyDown( Key.Up )
				
				_model.MoveY( .25 )
				
			Else If Keyboard.KeyDown( Key.Down )
				
				_model.MoveY( -.25 )
				
			Endif
		Endif
		
		If Keyboard.KeyDown( Key.A )
			
			_model.MoveZ( .15 )
			
		Else If Keyboard.KeyDown( Key.Z )
			
			_model.MoveZ( -.15 )
		Endif
		
		If Keyboard.KeyHit( Key.Space )
			
			_onground=False
			
			_yvel=.25
		Endif
		
	End
	
End

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _castle:Model
	
	Field _player:Player
	
	Field _sphere:SphereCollider
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		Print New Vec3f( 0,1,0 ).Cross( New Vec3f( 0,1,0 ) )
		
		_scene=Scene.GetCurrent()
		
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,60,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		'_light.ShadowsEnabled=False
		
		'Load castle
		'
		Local sz:=50
		
'		_castle=Model.Load( "asset::E1M1_clean.obj" )	'On the off chance you've got this...have no idea of license issues though.
		_castle=Model.Load( "asset::castle/CASTLE1.X" )

		_castle.Mesh.FitVertices( New Boxf( -sz,sz ),True )
		
		Local collider:=New MeshCollider( _castle.Mesh )
		
		Local body:=New StaticBody( collider,_castle,1,1 )
		
	
		'create player
		'
		_player=New Player( .75,.5 )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=200
		
		_sphere=New SphereCollider( .2 )

	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		If Keyboard.KeyHit( Key.Enter ) _player._paused=Not _player._paused
		
		_player.Update()

		_scene.World.Update()
		
		Local src:=_player._model.Matrix * New Vec3f( 0,1,0 )
		
		Local dst:=_player._model.Matrix * New Vec3f( 0,1.5,-2.5 )
		
		_camera.Position=dst
		
		_camera.PointAt( _player._model.Position+New Vec3f( 0,1.5,0 ) )
		
		_scene.Render( canvas,_camera )
		
'		canvas.DrawText( "position="+_player._model.Position+", Rx="+_player._model.Rx+", Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
