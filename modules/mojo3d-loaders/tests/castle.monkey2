Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"

#Import "../mojo3d"

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
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-20 )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,80,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),8,1,8,New PbrMaterial( Color.Green*.1,0,1 ) )
		
		'create model
		'		
		_model=Model.Load( "asset::castle/CASTLE1.X" )
'		_model=Model.Load( "desktop::Temple.3DS" )
'		_model=Model.Load( "desktop::FairyHouse/FairyHouse.3DS" )
		
		For Local material:=Eachin _model.Materials
			material.CullMode=CullMode.None
		Next
		
		Const sz:=30
		
		_model.Mesh.FitVertices( New Boxf( -10000,0,-10000,10000,sz,10000 ),True )
		
		_model.Position=Null
		
		_camera.Position=New Vec3f( 0,10,-10 )
	End
		
	Method OnRender( canvas:Canvas ) Override
		
		Global time:=0.0
		
		RequestRender()
		
		util.Fly( _camera,Self )
		
		If Keyboard.KeyDown( Key.Space ) time+=12.0/60.0
			
		_scene.Render( canvas,_camera )

		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	Print RealPath( "desktop::hello.png" )

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
