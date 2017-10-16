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
	
	Field _particles:ParticleSystem
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,1,-1 )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,45,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Brown*.5 ) )
		
		_particles=New ParticleSystem( 15000 )
		_particles.RotateX( -90 )	'point upwards!
		
		Local pmaterial:=_particles.Material
		pmaterial.ColorTexture=Texture.Load( "asset::bluspark.png",TextureFlags.FilterMipmap )
		
		Local pbuffer:=_particles.ParticleBuffer
		pbuffer.Gravity=New Vec3f( 0,-9.81,0 )	'gravity in world space in m/s^2.
		pbuffer.Duration=2.5		'how long a single particle lasts in seconds.
		pbuffer.Fade=0.0			'how long before paticle starts fading out in seconds.
		pbuffer.Colors=New Color[]( Color.White,Color.Yellow,Color.Orange,Color.Red )
		pbuffer.ConeAngle=30		'angle of particle emission cone.
		pbuffer.MinVelocity=10.0	'min particle velocity.
		pbuffer.MaxVelocity=10.0	'max particle velocity.
		pbuffer.MinSize=24.0		'min particle size.
		pbuffer.MaxSize=32.0		'max particle size.
		
		
		For Local an:=0 Until 360 Step 45
			Local pivot:=New Entity
			pivot.RotateY( an )
			pivot.MoveZ( 20 )
			
			_particles.Copy( pivot )
		Next
		
		_particles.SetDynamicProperty( "blah",New IntStack )
		
		_particles.GetDynamicProperty<IntStack>( "blah" ).Push( 10 )
		
		
		'particles.AddParticles( 5000 )
		
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

'	config["mojo3d_renderer"]="deferred"		'defeault on non-mobile targets.

'	config["mojo3d_renderer"]="forward-direct"	'default on mobile targets. depth buffer must be enabled too.
'	config["GL_depth_buffer_enabled"]=1

'	config["mojo3d_renderer"]="forward"
		
	New AppInstance( config )
	
	New MyWindow
	
	App.Run()
End
