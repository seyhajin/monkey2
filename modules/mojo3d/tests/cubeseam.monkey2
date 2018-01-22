
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
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.AmbientLight=Color.Black
		
		_scene.ClearColor=Color.Black
		
		ToggleEnv()
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Move( 0,0,-5 )
		New FlyBehaviour( _camera )
		
		'create white donut
		'		
		Local material:=New PbrMaterial( Color.White,1,1 )
		
		_donut=Model.CreateTorus( 2,.5,48,24,material )
	End
	
	Method ToggleEnv()
		
		Global _filter:TextureFlags=Null
		
		_filter=_filter ? Null Else TextureFlags.FilterMipmap
			
		'little mini cubemap
		Local pixmap:=New Pixmap( 4,3 )
		pixmap.Clear( Color.Black )
		pixmap.SetPixelARGB( 1,0,$ffff0000 )
		pixmap.SetPixelARGB( 1,1,$ff00ff00 )
		pixmap.SetPixelARGB( 1,2,$ff0000ff )
		pixmap.SetPixelARGB( 0,1,$ffffff00 )
		pixmap.SetPixelARGB( 2,1,$ffff00ff )
		pixmap.SetPixelARGB( 3,1,$ff00ffff )
		Local cubemap:=New Texture( pixmap,TextureFlags.Cubemap|_filter )
		
		_scene.EnvTexture=cubemap
		
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		If Keyboard.KeyHit( Key.Space ) ToggleEnv()
		
		_donut.Rotate( .1,.2,.3 )
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "Hit <space> to toggle cubemap filtering (ie: seamless cubemaps)",0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
