Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"

#Import "assets/"

#Import "../../mojo3d/tests/assets/miramar-skybox.jpg"

#Import "util"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _ground:Model
	
	Field _model:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,30,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		_light.CastsShadow=True
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),8,1,8,New PbrMaterial( Color.Green*.1,0,1 ) )
		_ground.CastsShadow=False
		
		'create model
		'		
		_model=Model.Load( "asset::castle/CASTLE1.X" )
		
		Const cheight:=30.0
		
		_model.Mesh.FitVertices( New Boxf( -10000,0,-10000,10000,cheight,10000 ),True )
	End
		
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_scene.Update()
		
		_camera.Render( canvas )

		canvas.DrawText( "FPS="+App.FPS,1,0,Width,0 )
	End
	
End

Function Main()
	
	Print RealPath( "desktop::hello.png" )

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
