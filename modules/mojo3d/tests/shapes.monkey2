
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
	
	Field _marker:Model
	
'	Method OnMeasure:Vec2i() Override
		
'		Return New Vec2i( 640,480 )
'	End
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
'		Layout="letterbox"
		
		_scene=Scene.GetCurrent()
		
		'create camera
		'
		_camera=New Camera
		_camera.Name="Camera"
		_camera.Near=.1
		_camera.Far=60
		_camera.Move( 0,10,-10 )
		New FlyBehaviour( _camera )
		
		Local camCollider:=New SphereCollider( _camera )
		camCollider.Radius=1
		Local camBody:=New RigidBody( _camera )
		camBody.Kinematic=True
		camBody.Mass=0
		camBody.CollisionGroup=32
		camBody.CollisionMask=127
		
		'create light
		'
		_light=New Light
		_light.RotateX( 75,15 )
		_light.CastsShadow=true
		
		'create ground
		'
		Local groundBox:=New Boxf( -60,-1,-60,60,0,60 )
		
		_ground=Model.CreateBox( groundBox,16,16,16,New PbrMaterial( Color.Green ) )
		_ground.Name="Ground"
		
		_ground.Collided+=Lambda( body:RigidBody )
		
'			Print "Ground hit: "+body.Entity.Name
		End
		
'		Local groundCollider:=New BoxCollider( _ground )
'		groundCollider.Box=groundBox

		Local groundCollider:=New MeshCollider( _ground )
		groundCollider.Mesh=_ground.Mesh
		
		Local groundBody:=New RigidBody( _ground )
		groundBody.Mass=0
		groundBody.CollisionGroup=64
		groundBody.CollisionMask=127
		
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
				
				Local i:=Int( Rnd(5) )
				
				Local model:=models[i].Copy()
				
				model.Materials=New Material[]( New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
				
				model.Move( x,10,z )
			Next
		
		Next
		
		For Local model:=Eachin models
			
			model.Destroy()
		Next
		
		_marker=Model.CreateCone( 1,2,Axis.Y,12,New PbrMaterial( Color.Red ),Null )
		
		_marker.Mesh.FitVertices( New Boxf( -.125,0,-.125,.125,1,.125 ),False )
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_camera.Viewport=Rect
		
		_scene.Update()
		
		Local raycast:=_camera.MousePick( 127 )
		
		Local picked:=""
		
		If raycast
			
			Local j:=raycast.normal,i:Vec3f,k:Vec3f
			
			If Abs( j.x )>.5
				k=New Vec3f( 0,0,1 )
				i=j.Cross( k ).Normalize()
				k=i.Cross( j ).Normalize()
			Else
				i=New Vec3f( 1,0,0 )
				k=i.Cross( j ).Normalize()
				i=j.Cross( k ).Normalize()
			Endif
			
			_marker.Position=raycast.point
			_marker.Basis=New Mat3f( i,j,k )
			_marker.Visible=True
			picked=raycast.body.Entity.Name+" "+_marker.Basis.j
			
		Else
			
			_marker.Visible=False
			
		Endif
		
		_scene.Render( canvas )
		
		canvas.DrawText( "Camera pos="+_camera.Position+", Picked="+picked+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
