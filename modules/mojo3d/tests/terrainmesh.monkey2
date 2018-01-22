
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/miramar-skybox.jpg"

#Import "assets/terrain_256.png"
#Import "assets/mossy-ground1.pbr@/mossy-ground1.pbr"


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
		_scene=New Scene
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		_scene.FogColor=Color.White *.7
		_scene.FogNear=75
		_scene.FogFar=100
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,15,-20 )
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 45 )

		'create terrain
		'
		'box
		Local terrainBox:=New Boxf( -256,0,-256,256,32,256 )
		
		'heightmap
		Local terrainHMap:=Pixmap.Load( "asset::terrain_256.png" )

		'material		
		Local terrainMaterial:=PbrMaterial.Load( "asset::mossy-ground1.pbr" )
		terrainMaterial.ScaleTextureMatrix( 64,64 )
		
		'model+mesh
		_terrain=Model.CreateTerrain( terrainHMap,terrainBox,terrainMaterial )

		_terrain.CastsShadow=False
		
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
		_camera.Viewport=Rect
		
		_scene.Update()
		
		_scene.Render( canvas )

		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "FPS="+App.FPS,Width,0,1,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
