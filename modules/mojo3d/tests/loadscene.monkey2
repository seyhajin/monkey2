Namespace myapp3d

#Reflect mojo3d

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	Field _camera:Camera
	Field _light:Light
	Field _ground:Model
	Field _donut:Model
	
	Method New( title:String="Simple mojo3d app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )
		
		Super.New( title,width,height,flags )
	End
	
	Method CreateScene()
		
		_scene.AmbientLight = _scene.ClearColor * 0.25
		_scene.FogColor = _scene.ClearColor
		_scene.FogFar = 1.0
		_scene.FogFar = 200.0

		'create camera
		_camera=New Camera
		_camera.AddComponent<FlyBehaviour>()
		_camera.Move( 0,2.5,-5 )
		
		'create light
		_light=New Light
		_light.CastsShadow=True
		_light.Rotate( 45, 45, 0 )
		
		'create ground
		Local groundBox:=New Boxf( -100,-1,-100,100,0,100 )
		Local groundMaterial:=New PbrMaterial( Color.Lime )
		_ground=Model.CreateBox( groundBox,1,1,1,groundMaterial )
		_ground.CastsShadow=False
		
		'create donut
		Local donutMaterial:=New PbrMaterial( Color.Red, 0.05, 0.2 )
		_donut=Model.CreateTorus( 2,.5,48,24,donutMaterial )
		_donut.Move( 0,2.5,0 )
		Local rb:=_donut.AddComponent<RotateBehaviour>()
		rb.Speed=New Vec3f( .2,.4,.6 )
	End
	
	Method OnCreateWindow() Override
		
		Local path:=CurrentDir()+"test-scene.mojo3d"
		
		_scene=New Scene
		
		_scene.Editing=True
		
		Print "Creating scene"
		
		CreateScene()
		
		Print "Saving scene to "+path
			
		_scene.Save( path )
		
		Print "Loading scene from "+path
			
		_scene=Scene.Load( path )
			
		_camera=Cast<Camera>( _scene.FindEntity( "Camera" ) )
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_scene.Update()
		
		_camera.Render( canvas )
		
		canvas.DrawText( "FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
