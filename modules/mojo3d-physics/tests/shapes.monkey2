
Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-physics>"

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
	
	Field _collider:SphereCollider
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		_scene.ClearColor=Color.Sky
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=60
		_camera.Move( 0,10,-10 )
		
		Local camBody:=New RigidBody( _camera )
		camBody.Kinematic=True
		camBody.Mass=1
		
		Local camCollider:=New SphereCollider( _camera )
		
		'create fog
		'		
		Local fog:=New FogEffect
		fog.Color=Color.Sky
		fog.Near=50
		fog.Far=60
		
		'create light
		'
		_light=New Light
		_light.RotateX( 90 )	'aim directional light 'down'.
		
		'create ground
		'
		Local groundBox:=New Boxf( -60,-1,-60,60,0,60 )
		
		_ground=Model.CreateBox( groundBox,16,16,16,New PbrMaterial( Color.Green ) )
		
		Local collider:=New BoxCollider( _ground )
		collider.Box=groundBox
		
		Local body:=New RigidBody( _ground )
		body.Mass=0
		
		'create some meshes/colliders
		
		Local material:=New PbrMaterial( Color.White )
		
		Local model0:=Model.CreateBox( New Boxf( -1,-5,-1,1,5,1 ),1,1,1,material )
		model0.AddComponent<RigidBody>()
		Local collider0:=model0.AddComponent<BoxCollider>()
		collider0.Box=New Boxf( -1,-5,-1,1,5,1 )

		Local model1:=Model.CreateSphere( 1,32,16,material )
		model1.AddComponent<RigidBody>()
		Local collider1:=model1.AddComponent<SphereCollider>()

		Local model2:=Model.CreateCylinder( 1,8,Axis.Y,32,material )
		model2.AddComponent<RigidBody>()
		Local collider2:=model2.AddComponent<CylinderCollider>()
		collider2.Radius=1
		collider2.Length=8

		Local model3:=Model.CreateCapsule( 1,10,Axis.Y,32,material )
		model3.AddComponent<RigidBody>()
		Local collider3:=model3.AddComponent<CapsuleCollider>()
		collider3.Radius=1
		collider3.Length=10

		Local model4:=Model.CreateCone( 2.5,5,Axis.Y,32,material )
		model4.AddComponent<RigidBody>()
		Local collider4:=model4.AddComponent<ConeCollider>()
		collider4.Radius=2.5
		collider4.Length=5
		
		Local models:=New Model[]( model0,model1,model2,model3,model4 )
		
		For Local x:=-40 To 40 Step 8
			
			For Local z:=-40 To 40 Step 8
				
				Local i:=Int( Rnd(5) )
				
				Local model:=models[i].Copy()
				
				model.Materials=New Material[]( New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
				
				model.Move( x,10,z )
			Next
		
		Next
		
		For Local model:=Eachin models
			model.Destroy()
		Next
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		util.Fly( _camera,Self )
			
		_scene.Update()
		
		_scene.Render( canvas,_camera )
		
		canvas.DrawText( "Camera pos="+_camera.Position+", Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
