Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _donut:Model
	
	Field _bloom:BloomEffect
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.ClearColor=Color.Black
		
		_bloom=New BloomEffect
		
		_scene.AddPostEffect( _bloom )
		
		'create camera
		'
		_camera=New Camera( self )
		_camera.Move( 0,10,-10 )
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 90 )
		
		Local material:=New PbrMaterial( Color.Black )
		material.EmissiveFactor=New Color( 0,2,0 )
		
		_donut=Model.CreateTorus( 2,.5,48,24,material )
		
		_donut.Move( 0,10,0 )
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_donut.Rotate( .1,.2,.3 )
		
		_scene.Render( canvas )
		
		canvas.DrawText( "FPS="+App.FPS,Width,0,1,0 )
		
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
