Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/walker/"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _model:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-5 )
		
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 90 )
		
		'create donut - metallic silver...
		
		Local material:=New PbrMaterial( Color.Silver,1,0.5 )
		
		_model=Model.LoadBoned( "asset::walk.gltf" )
		
		_model.Animator.Animate( 0 )
		
		_model.Move( 0,10,0 )
		
'		_model.Mesh.FitVertices( New Boxf( -1,1 ),False )
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		_camera.Viewport=Rect
		
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
