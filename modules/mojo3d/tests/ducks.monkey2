
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
	
	Field _ground:Model
	
	Field _ducks:=New Stack<Model>
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		SetConfig( "MOJO3D_RENDERER","forward" )
		
		'create scene
		'		
		_scene=New Scene
		
		'for softer shadows
		'
		_scene.ShadowAlpha=.6
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Move( 0,15,-20 )
		
		New FlyBehaviour( _camera )
		
		'create light
		'
		_light=New Light
		_light.CastsShadow=True
		_light.Rotate( 75,15,0 )
		
		'create ground
		'
		_ground=Model.CreateBox( New Boxf( -50,-1,-50,50,0,50 ),1,1,1,New PbrMaterial( Color.Green,0,1 ) )
		_ground.CastsShadow=False
		
		'create ducks
		'		
		Local duck:=Model.Load( "asset::duck.gltf/Duck.gltf" )
		duck.Mesh.FitVertices( New Boxf( -1,1 ) )
		
		Local root:=duck.Copy()
		root.Move( 0,10,0 )
		root.Scale=New Vec3f( 3 )
		
		_ducks.Push( root )
		
		For Local m:=0.0 To 1.0 Step .125
		
			For Local i:=0.0 Until 360.0 Step 24
			
				Local copy:=duck.Copy( root )
				
				copy.RotateY( i )
				
				copy.Move( 0,0,6+m*16 )

				copy.Scale=New Vec3f( 1 )
				
'				copy.Alpha=1-m
				
				For Local j:=0 Until copy.Materials.Length
				
					Local material:=Cast<PbrMaterial>( copy.Materials[j].Copy() )
					
					material.MetalnessFactor=m
					material.RoughnessFactor=i/360.0
					
					copy.Materials[j]=material
					
				Next
				
				_ducks.Push( copy )
			
			Next
		Next
		
		duck.Destroy()
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
		_ducks[0].Rotate( 0,-.01,0 )
		
		_scene.Update()
		
		_camera.Render( canvas )

		canvas.DrawText( "FPS="+App.FPS,Width,0,1,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
