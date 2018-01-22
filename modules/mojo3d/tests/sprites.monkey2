
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
	
	Field _ground:Model
	
	Field _sprites:=New Stack<Sprite>
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
'		SetConfig( "MOJO3D_RENDERER","forward" )
		
		_scene=New Scene
		
		_scene.SkyTexture=Texture.Load( "asset::miramar-skybox.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		_scene.FogColor=Color.Sky
		_scene.FogNear=10
		_scene.FogFar=30
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Near=.1
		_camera.Far=100
		_camera.Move( 0,10,-10 )
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.Rotate( 60,45,0 )
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green ) )
		
		'create sprites
		'
		Local material:=SpriteMaterial.Load( "asset::Acadia-Tree-Sprite.png" )
		
		material.AlphaDiscard=1.0/255.0
		
		For Local i:=0 Until 1000
			
			Local sprite:=New Sprite( material )
			
			sprite.Move( Rnd(-50,50),0,Rnd(-50,50) )
			
			sprite.Scale=New Vec3f( Rnd(4,5),Rnd(5,6),1 )
			
			sprite.Handle=New Vec2f( .5,0 )
			
			sprite.Mode=SpriteMode.Upright

			_sprites.Push( sprite )
		Next
		
		For Local i:=0 Until 1'00
			
			Local box:=Model.CreateBox( New Boxf( -5,0,-5,5,Rnd(2,10),5 ),1,1,1,New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
			
			box.Move( Rnd(-50,50),0,Rnd(-50,50) )

		next			
		
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

