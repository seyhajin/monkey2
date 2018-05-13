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
	
	Field _mono:MonochromeEffect
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		_scene.ClearColor=Color.Black
		
		_bloom=New BloomEffect
		_bloom.Enabled=True
		_scene.AddPostEffect( _bloom )
		
		_mono=New MonochromeEffect
		_mono.Enabled=False
		_scene.AddPostEffect( _mono )
		
		'create camera
		'
		_camera=New Camera( self )
		_camera.Move( 0,10,-10 )
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.RotateX( 90 )
		
		Local material:=New PbrMaterial( New Color( 2,.5,0,1 ),0,1 )
		
		_donut=Model.CreateTorus( 2,.5,48,24,material )
		_donut.AddComponent<RotateBehaviour>().Speed=New Vec3f( .1,.2,.3 )
		
		_donut.Move( 0,10,0 )
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		If Keyboard.KeyHit( Key.Key1 ) _bloom.Enabled=Not _bloom.Enabled

		If Keyboard.KeyHit( Key.Key2 ) _mono.Enabled=Not _mono.Enabled
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "Bloom="+_bloom.Enabled+" (1) monochrome="+_mono.Enabled+" (2)",0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
