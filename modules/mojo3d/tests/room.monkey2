Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/fish.glb"

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
	
	Field _room:Model
	
	Field _fish:Entity
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		CreateScene()
	End
	
	Method CreateRoom()

		Local box:=New Boxf( -10,10 )
		
		Local material:=New PbrMaterial( Color.Orange )
		
		Local model:=Model.CreateBox( box,1,1,1,material )
		model.Mesh.FlipTriangles()
		model.Mesh.UpdateNormals()
		model.Mesh.UpdateTangents()
		model.CastsShadow=False
	
	End
	
	Method CreateFishes()
		
		Local model:=Model.Load( "asset::fish.glb" )
		model.Mesh.FitVertices( New Boxf( -1,1 ) )
		
		Local root:=New Entity
		root.AddComponent<RotateBehaviour>().Speed=New Vec3f( 0,.1,0 )
		root.Visible=True
		
		For Local an:=0 Until 360 Step 9
			
			Local copy:=model.Copy( root )
			
			copy.Rotate( 0,an,0 )
			copy.Move( 0,Sin( an )*3,Rnd( 2.5,9.5 ) )
			copy.Rotate( 0,-90,0 )
			
		Next
		
		model.Destroy()
	End
	
	Method CreateScene()
		
		'Create scene
		_scene=New Scene
		_scene.ClearColor=Color.Black
		_scene.AmbientLight=Color.Black
		_scene.EnvColor=Color.Black
		_scene.ShadowAlpha=.7
		
		'Create camera
		Local camera:=New Camera( Self )
		camera.Move( 0,0,-5 )
		camera.AddComponent<FlyBehaviour>()
		
		'Create light
		Local light:=New Light
		light.Type=LightType.Point
		light.CastsShadow=True
		light.Range=15
		
		CreateRoom()
		
		CreateFishes()
	End
		
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "FPS "+App.FPS,Width,0,1,0 )
	End
	
End

