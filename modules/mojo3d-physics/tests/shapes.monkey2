
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
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=Scene.GetCurrent()
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.1
		_camera.Far=60
		_camera.Move( 0,10,-10 )
		New FlyBehaviour( _camera )
		
		Local camCollider:=New SphereCollider( _camera )
		camCollider.Radius=1
		Local camBody:=New RigidBody( _camera )
		camBody.Kinematic=True
		camBody.Mass=0
		
		'create light
		'
		_light=New Light
		_light.RotateX( 75,15 )
		
		'create ground
		'
		Local groundBox:=New Boxf( -60,-1,-60,60,0,60 )
		
		_ground=Model.CreateBox( groundBox,16,16,16,New PbrMaterial( Color.Green ) )
		
		Local groundCollider:=New BoxCollider( _ground )
		groundCollider.Box=groundBox
		
		Local groundBody:=New RigidBody( _ground )
		groundBody.Mass=0
		
		Local material:=New PbrMaterial( Color.White )

		Local box0:=New Boxf( -1,-5,-1,1,5,1 )		
		Local model0:=Model.CreateBox( box0,1,1,1,material )
		Local collider0:=New BoxCollider( model0 )
		collider0.Box=box0
		Local body0:=New RigidBody( model0 )
		
		Local model1:=Model.CreateSphere( 1,32,16,material )
		Local collider1:=New SphereCollider( model1 )
		Local body1:=New RigidBody( model1 )

		Local model2:=Model.CreateCylinder( 1,8,Axis.Y,32,material )
		Local collider2:=New CylinderCollider( model2 )
		collider2.Radius=1
		collider2.Length=8
		Local body2:=New RigidBody( model2 )

		Local model3:=Model.CreateCapsule( 1,10,Axis.Y,32,material )
		Local collider3:=New CapsuleCollider( model3 )
		collider3.Radius=1
		collider3.Length=10
		Local body3:=New RigidBody( model3 )

		Local model4:=Model.CreateCone( 2.5,5,Axis.Y,32,material )
		Local collider4:=New ConeCollider( model4 )
		collider4.Radius=2.5
		collider4.Length=5
		Local body4:=New RigidBody( model4 )
		
		Local models:=New Model[]( model0,model1,model2,model3,model4 )
		
		#rem
		For Local x:=-40 To 40 Step 8
			
			For Local z:=-40 To 40 Step 8
				
				Local i:=Int( Rnd(5) )
				
				Local model:=models[i].Copy()
				
				model.Materials=New Material[]( New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) ) )
				
				model.Move( x,10,z )
			Next
		
		Next
		#end
		
		Local x:=0.0
		
		For Local model:=Eachin models
			
			model.Move( x,10,0 )
			
			x+=5.0
			
			'model.Destroy()
		Next
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
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
