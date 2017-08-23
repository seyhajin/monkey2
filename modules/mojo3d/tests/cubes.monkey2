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
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		
		'create light
		'
		_light=New Light

		_light.RotateX( 90 )
		
		'Create donut - metallic silver...
		'
		Local cube:=Model.CreateBox( New Boxf( -1,1 ),1,1,1,New PbrMaterial( Color.White ) )
		
		cube.CastsShadow=False
		
		For Local x:=-50.0 To 50.0 Step 2.5
			For Local z:=-50.0 To 50.0 Step 2.5
				Local copy:=cube.Copy()
				copy.Move( x,0,z )
			Next
		Next
		
		cube.Destroy()
		
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		util.Fly( _camera,Self )
		
		_scene.Render( canvas,_camera )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
