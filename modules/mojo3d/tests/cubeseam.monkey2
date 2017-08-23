
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
	
	Field _donut:Model
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		'little mini cubemap
		Local pixmap:=New Pixmap( 4,3 )
		pixmap.Clear( Color.Black )
		pixmap.SetPixelARGB( 1,0,$ffff0000 )
		pixmap.SetPixelARGB( 1,1,$ff00ff00 )
		pixmap.SetPixelARGB( 1,2,$ff0000ff )
		pixmap.SetPixelARGB( 0,1,$ffffff00 )
		pixmap.SetPixelARGB( 2,1,$ffff00ff )
		pixmap.SetPixelARGB( 3,1,$ff00ffff )
		Local cubemap:=New Texture( pixmap,TextureFlags.Cubemap|TextureFlags.FilterMipmap )		'seamless
'		Local cubemap:=New Texture( pixmap,TextureFlags.Cubemap )								'seamed
		
		_scene=Scene.GetCurrent()
		
		_scene.EnvTexture=cubemap
'		_scene.SkyTexture=cubemap
		
		_scene.AmbientLight=Color.Black
		
		_scene.ClearColor=Color.Black
		
		Local bloom:=New BloomEffect
		bloom.Passes=4
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		
		'create light
		'
		'_light=New Light
		'_light.RotateX( 90 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create donut - metallic silver...
		'		
'		Local material:=New PbrMaterial( Color.White,1,0 )	'shiny metallic white
		Local material:=New PbrMaterial( Color.White,0,1 )	'rough non-metallic white
		
		_donut=Model.CreateTorus( 2,.5,48,24,material )
		
		_donut.Move( 0,10,0 )
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		If Keyboard.KeyHit( Key.Space ) _donut.Visible=Not _donut.Visible
		
		_donut.Rotate( .1,.2,.3 )
		
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
