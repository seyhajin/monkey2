
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#import "assets/terrain_256.png"

#Import "util"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _terrain:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,15,-20 )
		Local fly:=New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 60 )

		'create terrain
		'
		'heightmap
		Local terrain_hmap:=Pixmap.Load( "asset::terrain_256.png" )

		'material		
		Local terrain_material:=New PbrMaterial( Color.Green )
		
		'model+mesh
		_terrain=Model.CreateTerrain( terrain_hmap,New Boxf( -256,0,-256,256,32,256 ),terrain_material )
		_terrain.CastsShadow=False
		
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
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
