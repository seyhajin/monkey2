
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/miramar-skybox.jpg"
#Import "assets/spheres.gltf"

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
		
		_scene=New Scene
		
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap|TextureFlags.Envmap )
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Near=.01
		_camera.Move( 0,10,-10 )
		
		New FlyBehaviour( _camera )
		
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
		
		_spheres=Model.Load( "asset::MetalRoughSpheres.gltf" )
		
		_spheres.Move( 0,10,0 )
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "FPS="+App.FPS,Width,0,1,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
