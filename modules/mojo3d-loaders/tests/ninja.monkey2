Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"

#Import "assets/psionic/ninja.b3d"
#Import "assets/psionic/nskinbl.jpg"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _ground:Model
	
	Field _ninja:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.AddComponent<FlyBehaviour>()
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-20 )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 75,15,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		_light.CastsShadow=True
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-5,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green ) )
		_ground.CastsShadow=False
		
		'create turtle
		'		
		_ninja=Model.LoadBoned( "asset::ninja.b3d" )
'		_ninja.Scale=New Vec3f( .125 )

		Local anim1:=_ninja.Animator.Animations[0].Slice( 1,14 )
		Local anim2:=_ninja.Animator.Animations[0].Slice( 206,250 )
		_ninja.Animator.Animations.Add( anim1 )
		_ninja.Animator.Animations.Add( anim2 )
		
	End
		
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		If Keyboard.KeyDown( Key.Enter )
			_ninja.Animator.Animate( 1,.4,.2 )
		Else
			_ninja.Animator.Animate( 2,.4,.2 )
		Endif

		_scene.Update()
		
		_scene.Render( canvas,_camera )
		
		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", anim time="+_ninja.Animator.Time+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
