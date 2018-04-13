Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

'Need this to be able to create an 'editable' scene
#Reflect mojo3d

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	Field _camera:Camera
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		Local scene:=New Scene( True )	'True to create an 'editable' scene.
		
		'create camera
		'
		Local camera:=New Camera( Self )
		camera.Name="Camera"	'so we can find camera later after loading
		camera.Near=.1
		camera.Far=60
		camera.Move( 0,10,-10 )
		New FlyBehaviour( camera )
		
		Local camCollider:=New SphereCollider( camera )
		camCollider.Radius=1
		Local camBody:=New RigidBody( camera )
		camBody.Kinematic=True
		camBody.Mass=0
		camBody.CollisionGroup=32
		camBody.CollisionMask=127
		
		'create light
		'
		Local light:=New Light
		light.RotateX( 75,15 )
		light.CastsShadow=true
		
		'create ground
		'
		Local groundBox:=New Boxf( -60,-1,-60,60,0,60 )
		
		Local ground:=Model.CreateBox( groundBox,16,16,16,New PbrMaterial( Color.Green ) )
		
		ground.Collided+=Lambda( body:RigidBody )
		
'			Print "Ground hit: "+body.Entity.Name
		End

		'3 ways to create a ground collider!
		Local groundCollider:=New BoxCollider( ground )
		groundCollider.Box=groundBox
		
'		Local groundCollider:=New ConvexHullCollider( _ground )
'		groundCollider.Mesh=_ground.Mesh

'		Local groundCollider:=New MeshCollider( _ground )
'		groundCollider.Mesh=_ground.Mesh
		
		Local groundBody:=New RigidBody( ground )
		groundBody.CollisionGroup=64
		groundBody.CollisionMask=127
		groundBody.Mass=0	'static body
		
		Local material:=New PbrMaterial( Color.White )

		Local box0:=New Boxf( -1,-5,-1,1,5,1 )		
		Local model0:=Model.CreateBox( box0,1,1,1,material )
		model0.Name="Box"
		Local collider0:=New BoxCollider( model0 )
		collider0.Box=box0
		Local body0:=New RigidBody( model0 )
		body0.CollisionGroup=1
		body0.CollisionMask=127
		
		Local model1:=Model.CreateSphere( 1,32,16,material )
		model1.Name="Sphere"
		Local collider1:=New SphereCollider( model1 )
		Local body1:=New RigidBody( model1 )
		body1.CollisionGroup=2
		body1.CollisionMask=127

		Local model2:=Model.CreateCylinder( 1,8,Axis.Y,32,material )
		model2.Name="Cylinder"
		Local collider2:=New CylinderCollider( model2 )
		collider2.Radius=1
		collider2.Length=8
		Local body2:=New RigidBody( model2 )
		body2.CollisionGroup=4
		body2.CollisionMask=127

		Local model3:=Model.CreateCapsule( 1,10,Axis.Y,32,material )
		model3.Name="Capsule"
		Local collider3:=New CapsuleCollider( model3 )
		collider3.Radius=1
		collider3.Length=10
		Local body3:=New RigidBody( model3 )
		body3.CollisionGroup=8
		body3.CollisionMask=127
		
		Local model4:=Model.CreateCone( 2.5,5,Axis.Y,32,material )
		model4.Name="Cone"
		Local collider4:=New ConeCollider( model4 )
		collider4.Radius=2.5
		collider4.Length=5
		Local body4:=New RigidBody( model4 )
		body4.CollisionGroup=16
		body4.CollisionMask=127
		
		Local models:=New Model[]( model0,model1,model2,model3,model4 )
		
		For Local x:=-40 To 40 Step 8
			
			For Local z:=-40 To 40 Step 8
				
				Local i:=Int( Rnd( models.Length ) )
				
				Local materials:=New Material[]( New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )

				Local model:=models[i].Copy()
				
				model.Materials=materials
				
				model.Move( x,50,z )
			Next
		
		Next
		
		local x:=0
		For Local model:=Eachin models
			
			x+=5
			
			model.Materials=New Material[]( New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
			
			model.Move( x,50,0 )
			
'			model.Destroy()
		Next
		
		Print "Saving scene..."
		
		scene.Save( "shapes-scene.mojo3d" )
		
		Print "Loading scene..."
		
		_scene=Scene.Load( "shapes-scene.mojo3d" )
		_camera=Cast<Camera>( _scene.FindEntity( "Camera" ) )
		_camera.View=Self
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_scene.Update()
		
		_scene.Render( canvas )
		
		canvas.DrawText( "FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
