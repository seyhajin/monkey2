Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"
#Import "<mojo3d-physics>"

#Import "assets/"

#Import "../../mojo3d/tests/assets/miramar-skybox.jpg"

#Import "../../mojo3d-loaders/tests/assets/castle/@/castle"

Using std..
Using mojo..
Using mojo3d..

Class FPSPlayer Extends FPSCollider
	
	Method New( entity:Entity )
		Super.New( entity )
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		If Keyboard.KeyDown( Key.Left )
			
			Entity.RotateY( 2.5 )
			
		Else If Keyboard.KeyDown( Key.Right )
			
			Entity.RotateY( -2.5 )
		Endif

		If Keyboard.KeyDown( Key.Up )
			
			Entity.MoveY( .25 )
			
		Else If Keyboard.KeyDown( Key.Down )
			
			Entity.MoveY( -.25 )
			
		Endif
		
		If Keyboard.KeyDown( Key.A )
			
			Entity.MoveZ( .15 )
			
		Else If Keyboard.KeyDown( Key.Z )
			
			Entity.MoveZ( -.15 )
		Endif
		
		If Keyboard.KeyDown( Key.Space )
			
			YVelocity=.25
			
		Endif

		'Update actual collider.
		'
		'Extending FPSCollider is probably not a great idea, this lot should really be in its own
		'component, but haven't thought much about how to access YVelocity etc yet so this'll do for now.
		'
		Super.OnUpdate( elapsed )
		
	End
	
	
End

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _castle:Model
	
	Field _player:FPSPlayer
	
	Field _sphere:SphereCollider
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		Print New Vec3f( 0,1,0 ).Cross( New Vec3f( 0,1,0 ) )
		
		_scene=Scene.GetCurrent()
		
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=200
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,60,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		_light.CastsShadow=True
		
		'Load castle
		'
		Local sz:=50
		
'		_castle=Model.Load( "asset::E1M1_clean.obj" )	'On the off chance you've got this...have no idea of license issues though.
		_castle=Model.Load( "asset::castle/CASTLE1.X" )
		_castle.Mesh.FitVertices( New Boxf( -sz,sz ),True )
		
		Local collider:=New MeshCollider( _castle )
		collider.Mesh=_castle.Mesh
		
		Local body:=New RigidBody( _castle )
		body.Mass=0
		
		Local model:=Model.CreateCapsule( .5,.75,Axis.Y,24,New PbrMaterial( Color.Sky ) )
		
		_player=model.AddComponent<FPSPlayer>()
		_player.Margin=.01
		_player.Radius=.5
		_player.Length=.75
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_scene.Update()
		
		Local src:=_player.Entity.Matrix * New Vec3f( 0,1,0 )
		
		Local dst:=_player.Entity.Matrix * New Vec3f( 0,1.5,-2.5 )
		
		_camera.Position=dst
		
		_camera.PointAt( _player.Entity.Position+New Vec3f( 0,1.5,0 ) )
		
		_scene.Render( canvas,_camera )
		
'		canvas.DrawText( "position="+_player._model.Position+", Rx="+_player._model.Rx+", Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
