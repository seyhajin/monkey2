
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/"

Using std..
Using mojo..
Using mojo3d..

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _donut:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		SetConfig( "MOJO3D_RENDERER","forward" )
		
		_scene=New Scene
		
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Move( 0,10,-10 )
		
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 75,15,0 )
		
		'create donut - metallic silver...
		
		Local material:=New PbrMaterial( Color.Silver,1,0.5 )
		
		_donut=Model.CreateTorus( 2,.5,48,24,material )
		
		_donut.Move( 0,10,0 )
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		_donut.Rotate( .1,.2,.3 )
		
		_scene.Update()
		
		_camera.Render( canvas )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

