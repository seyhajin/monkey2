
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"

#Import "../mojo3d"

#Import "assets/"

#Import "util"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _ground:Model
	
	Field _turtle:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-20 )
		
		'create light
		'
		_light=New Light
		_light.Rotate( Pi/2,0,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create ground
		'
'		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green,0,.5 ) )
		
		'create turtle
		'		
		_turtle=Model.LoadBoned( "asset::turtle1.b3d" )
		
		Local animator:=_turtle.GetComponent<Animator>()
		
		animator.Paused=False
		
		
	End
		
	Method OnRender( canvas:Canvas ) Override
		
		Global time:=0.0
		
		RequestRender()
		
		util.Fly( _camera,Self )
		
		If Keyboard.KeyHit( Key.Space )

			Local animator:=_turtle.GetComponent<Animator>()
		
			animator.Paused=Not animator.Paused
		Endif
		
		_scene.Update()
		
		_scene.Render( canvas,_camera )
		
		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
