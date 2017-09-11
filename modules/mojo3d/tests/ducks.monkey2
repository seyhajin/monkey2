
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
	
	Field _fog:FogEffect

	Field _camera:Camera
	
	Field _light:Light
	
	Field _light2:Light
	
	Field _ground:Model
	
	Field _ducks:=New Stack<Model>
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		SwapInterval=0
		
		Print gles20.glGetString( gles20.GL_EXTENSIONS ).Replace( " ","~n" )
		
		'create scene
		'		
		_scene=Scene.GetCurrent()
		_scene.ClearColor=Color.Sky

		'add fog effect to scene
		'		
'		_fog=New FogEffect
'		_fog.Color=Color.Sky
'		_fog.Near=0
'		_fog.Far=50
'		_scene.AddPostEffect( _fog )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=50
		_camera.FOV=90
		_camera.Move( 0,15,-20 )
		
		'create light
		'
		_light=New Light
		_light.Type=LightType.Point
		_light.Move( 0,20,0 )
		_light.Range=40
		_light.CastsShadow=True

		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),10,10,10,New PbrMaterial( Color.Green,0,1 ) )
		_ground.CastsShadow=False
		
		'create ducks
		'		
		Local duck:=Model.Load( "asset::duck.gltf/Duck.gltf" )
		duck.Mesh.FitVertices( New Boxf( -1,1 ) )
		
		Local root:=duck.Copy()
		root.Move( 0,10,0 )
		root.Scale=New Vec3f( 3 )
		
		_ducks.Push( root )
		
		'#rem
		
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
		
		'#End
		
		duck.Destroy()
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
		_ducks[0].RotateY( 1 )

		util.Fly( _camera,Self )
		
		_scene.Render( canvas,_camera )

		canvas.Scale( Width/640.0,Height/480.0 )
		
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
