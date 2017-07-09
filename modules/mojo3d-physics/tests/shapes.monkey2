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

Function Randomize( model:Model )
	
	Local vertices:=model.Mesh.GetVertices()
	
	Local indices:=model.Mesh.GetAllIndices()
	
	Local mesh:=New Mesh
	
	mesh.AddVertices( vertices )
	
	mesh.AddMaterials( 9 )
	
	Local materials:=New Material[10]
	
	For Local i:=0 Until 10

		materials[i]=New PbrMaterial( New Color( Rnd(),Rnd(),Rnd() ) )
	
	Next
	
	For Local i:=0 Until indices.Length Step 3
		
		mesh.AddTriangles( New UInt[]( indices[i],indices[i+1],indices[i+2] ),Rnd(10) )
	
	Next
	
	model.Mesh=mesh
	
	model.Materials=materials
End

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _ground:Model
	
	Field _sphere:Model
	
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
		
		New RigidBody( 0,New SphereCollider( 1 ),_camera,True )

		'create fog
		'		
		Local fog:=New FogEffect
		fog.Color=Color.Sky
		fog.Near=50
		fog.Far=60
		
		'create light
		'
		_light=New Light
		_light.RotateX( Pi/2 )	'aim directional light 'down' - Pi/2=90 degrees.
		
		'create ground
		'
		Local groundBox:=New Boxf( -60,-1,-60,60,0,60 )
		
		_ground=Model.CreateBox( groundBox,16,16,16,New PbrMaterial( Color.Green ) )
		
'		Randomize( _ground )
		
'		Local collider:Collider=New MeshCollider( _ground.Mesh )	'UGH - FIXME!
		Local collider:Collider=New BoxCollider( groundBox )
		
		Local body:=New RigidBody( 0,collider,_ground )
		
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
'				model.RotateZ( Rnd(-.1,.1) )
				
				Local body:=New RigidBody( 1,colliders[i],model )
				
			Next
		
		Next
		
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		util.Fly( _camera,Self )
		
		World.GetDefault().Update()
		
		_scene.Render( canvas,_camera )
		
		canvas.DrawText( "Width="+Width+", Height="+Height+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
