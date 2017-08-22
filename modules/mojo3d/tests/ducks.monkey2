
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
	
	Field _ducks:=New Stack<Model>
	
	Field _fog:FogEffect
	
	Field _monochrome:MonochromeEffect
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		Print gles20.glGetString( gles20.GL_EXTENSIONS ).Replace( " ","~n" )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()

		'fog effect
		'		
		_fog=New FogEffect
		_fog.Color=Color.Sky
		_fog.Near=0
		_fog.Far=100
		
		'monochrome effect - hit space to toggle
		'
		_monochrome=New MonochromeEffect
		_monochrome.Enabled=False
		
		'_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,15,-20 )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 90 )	'aim directional light downwards
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green,0,1 ) )
		
		'create ducks
		'		
		Local duck:=Model.Load( "asset::duck.gltf/Duck.gltf" )
		duck.Mesh.FitVertices( New Boxf( -1,1 ) )
		'duck.CastsShadow=false
		
		Local root:=duck.Copy()
		root.Move( 0,10,0 )
		root.Scale=New Vec3f( 3 )
		
		_ducks.Push( root )
		
		For Local m:=0.0 To 1.0 Step .125
		
			For Local i:=0.0 Until 360.0 Step 24
			
				Local copy:=duck.Copy( root )
				
				copy.RotateY( i )
				
				copy.Move( 0,0,6+m*16 )
				
				copy.Scale=New Vec3f( 1 )
				
				For Local j:=0 Until copy.Materials.Length
				
					Local material:=Cast<PbrMaterial>( copy.Materials[j].Copy() )
					
					material.MetalnessFactor=m
					material.RoughnessFactor=i/360.0
					
					copy.Materials[j]=material
				Next
				
				_ducks.Push( copy )
			
			Next
		Next
		
		duck.Destroy()

	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
		'Space to toggle monochrome mode!
		If Keyboard.KeyHit( Key.Space ) _monochrome.Enabled=Not _monochrome.Enabled
			
		'_monochrome.Level=Sin( Now()*3 ) * .5 + .5
		
		For Local duck:=Eachin _ducks
			
			duck.RotateY( 1 )
		Next
		
		util.Fly( _camera,Self )
		
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
