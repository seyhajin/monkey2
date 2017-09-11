
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
	
	Field _water:Model
	
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
		_light.RotateX( 90 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create water material
		'
		Local waterMaterial:=New WaterMaterial
		
		waterMaterial.ScaleTextureMatrix( 10,10 )
		waterMaterial.ColorFactor=Color.SeaGreen
		waterMaterial.Roughness=0
		
		waterMaterial.NormalTextures=New Texture[]( 
			Texture.Load( "asset::water_normal0.png",TextureFlags.WrapST|TextureFlags.FilterMipmap ),
			Texture.Load( "asset::water_normal1.png",TextureFlags.WrapST|TextureFlags.FilterMipmap ) )
		
		waterMaterial.Velocities=New Vec2f[]( 
			New Vec2f( .01,.03 ),
			New Vec2f( .02,.05 ) )
		
		'create water
		'
		_water=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,waterMaterial )
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		util.Fly( _camera,Self )
		
		_scene.Render( canvas,_camera )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	Local config:=New StringMap<String>

	config["mojo3d_renderer"]="deferred"

	New AppInstance( config )
	
	New MyWindow
	
	App.Run()
End
