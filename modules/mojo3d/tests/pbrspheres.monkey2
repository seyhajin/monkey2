
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

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
	
	Field _spheres:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 60 )	'aim directional light 'downish'.
		
		'create ground
		'
		Local mesh:=Mesh.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1 )
		
		Local material:=New PbrMaterial( Color.Green,0,.5 )
		
		_ground=New Model( mesh,material )
		
		'create spheres
		
		_spheres=Model.Load( "asset::spheres.gltf/MetalRoughSpheres.gltf" )
		
		_spheres.Move( 0,10,0 )
		
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		util.Fly( _camera,Self )
		
		_scene.Render( canvas,_camera )
		
		canvas.DrawText( "FPS="+App.FPS,Width/2,0,.5,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
