
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
	
	Field _sprites:=New Stack<Sprite>
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,45,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green ) )
		
		'create sprites
		'
		Local material:=SpriteMaterial.Load( "asset::Acadia-Tree-Sprite.png" )
		
		material.ColorTexture.Flags=TextureFlags.None
		
		For Local i:=0 Until 1000
			
			Local sprite:=New Sprite( material )
			
			sprite.Move( Rnd(-50,50),0,Rnd(-50,50) )
			
			sprite.Scale=New Vec3f( Rnd(2,3),Rnd(3,5),1 )
			
			sprite.Handle=New Vec2f( .5,0 )
			
			sprite.Mode=SpriteMode.Upright

			_sprites.Push( sprite )
		Next
		
		For Local i:=0 Until 10
			
			Local box:=Model.CreateBox( New Boxf( -5,0,-5,5,Rnd(2,10),5 ),1,1,1,New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
			
			box.Move( Rnd(-50,50),0,Rnd(-50,50) )

		next			
		
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
