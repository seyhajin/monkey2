
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
		
		New KinematicBody( New SphereCollider( 1 ),_camera )
		
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
		
		Local collider:Collider=New BoxCollider( groundBox )
		
		Local body:=New StaticBody( collider,_ground )

		'create some meshes/colliders
		
		Local meshes:=New Mesh[5]
		Local colliders:=New Collider[5]
		
		meshes[0]=Mesh.CreateBox( New Boxf( -1,-5,-1,1,5,1 ),1,1,1 )
		colliders[0]=New BoxCollider(  New Boxf( -1,-5,-1,1,5,1 ) )
		
		meshes[1]=Mesh.CreateSphere( 1,32,16 )
		colliders[1]=New SphereCollider( 1 )

		meshes[2]=Mesh.CreateCylinder( 1,8,Axis.Y,32 )
		colliders[2]=New CylinderCollider( 1,8,Axis.Y )

		meshes[3]=Mesh.CreateCapsule( 1,10,Axis.Y,32 )
		colliders[3]=New CapsuleCollider( 1,10,Axis.Y )

		meshes[4]=Mesh.CreateCone( 2.5,5,Axis.Y,32 )
		colliders[4]=New ConeCollider( 2.5,5,Axis.Y )
		
		For Local x:=-40 To 40 Step 8
			
			For Local z:=-40 To 40 Step 8
				
				Local i:=Int( Rnd(5) )
				
				Local mesh:=meshes[i]
				Local material:=New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) )
				
				Local model:=New Model( mesh,material )
				model.Move( x,10,z )
				
				Local body:=New DynamicBody( colliders[i],model )
				
			Next
		
		Next
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		util.Fly( _camera,Self )
			
		_scene.World.Update()
		
		_scene.Render( canvas,_camera )
		
		canvas.DrawText( "Camera pos="+_camera.Position+", Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
