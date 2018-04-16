Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-loaders>"

#Import "assets/castle/@/castle"
#Import "../../mojo3d/tests/assets/heightmap_256.BMP"
#Import "../../mojo3d/tests/assets/mossy-ground1.pbr@/mossy-ground1.pbr"

'#Import "../../mojo3d/tests/assets/miramar-skybox.jpg"

#Import "util"

Using std..
Using mojo..
Using mojo3d..

Struct QResult
	Field position:Vec3f
	Field hitground:Bool
	Field hitwall:Bool
End

Function QCollide:QResult( collider:ConvexCollider,src:Vec3f,dst:Vec3f,moving:Bool )
	
	Local margin:=collider.Margin
	
	Local world:=collider.Entity.Scene.World
	
	Local start:=src
	
	Local plane0:Planef,plane1:Planef,state:=0,casts:=0
	
	Local qresult:QResult
	
	Local debug:=""
	
	Repeat
		
		If src.Distance( dst )<.00001
			dst=src
			Exit
		Endif

		casts+=1
		
		Local cresult:=world.ConvexSweep( collider,src,dst,1 )
		If Not cresult Exit
	
'		debug+=", "
		
		If cresult.normal.y>.7071
'			Print "hitground "+cresult.normal
			qresult.hitground=True
		Endif
		
		If cresult.normal.y<.1
			qresult.hitwall=True
		Endif
			
		Local plane:=New Planef( cresult.point,cresult.normal )
		plane.d-=margin
		
		Local d0:=plane.Distance( src ),d1:=plane.Distance( dst )
		
		Local tline:=New Linef( src,dst-src )
		
		Local t:=plane.TIntersect( tline )
		
		If t>0 src=tline * t
		
		If Not moving Or t>=1
			dst=src
			Exit
		Endif
			
		Select state
		Case 0
			dst=plane.Nearest( dst )
'			debug+="A "+P( plane )
			plane0=plane
			state=1
		Case 1
			Local v:=plane0.n.Cross( plane.n )
			If v.Length>.001
				Local groove:=New Linef( src,v )
'				Local d0:=plane0.Distance( dst )
				dst=groove.Nearest( dst )
'				debug+="B "+P( plane )+" d0="+F(d0)+" sd0="+F(plane0.Distance(src))+" dd0="+F(plane0.Distance(dst))
				plane1=plane
				state=2
			Else
				Print "QCollide OOPS2"
'				debug+="C "+P( plane )
				dst=plane.Nearest( dst )
				plane0=plane
				state=1
			Endif
		Case 2
'			Local d0:=plane0.Distance( dst )
'			Local d1:=plane1.Distance( dst )
'			debug+="D "+P( plane )+" d0="+F(d0)+" d1="+F(d1)
			dst=src
			Exit
		End
		
	Forever
	
	If casts>3 Print debug.Slice( 2 )+"QCOLLIDE OOPS3 casts="+casts

	qresult.position=dst
	
	Return qresult
End


Class CharacterController Extends Behaviour
	
	Method New( entity:Entity )
		
		Super.New( entity )
	End
	
	Property OnGround:Bool()
		
		Return _onground
	End
	
	Property StepDown:Float()
		
		Return _stepDown
		
	 Setter( stepDown:Float )
		 
		 _stepDown=stepDown
	End
	
	Protected
	
	Field _jumping:Bool
	
	Field _stepDown:Float=.5	'50 cms
	
	Field _onground:Bool
	
	Field _vel:Vec3f
	
	Method OnUpdate( elapsed:Float ) Override
		
		If Keyboard.KeyDown( Key.Left )
			Entity.RotateY( 2.5 )
		Else If Keyboard.KeyDown( Key.Right )
			Entity.RotateY( -2.5 )
		Endif

		Local src:=Entity.Position
		
		Local moving:=False
		
		If Keyboard.KeyDown( Key.A )
			Entity.MoveZ( .15 )
			moving=True
		Else If Keyboard.KeyDown( Key.Z )
			Entity.MoveZ( -.15 )
			moving=True
		Endif
		
		If _onground _vel.y=-Entity.Collider.Margin
			
		_vel+=Entity.Scene.World.Gravity/60.0/60.0
		
		If Keyboard.KeyHit( Key.Space )
			_jumping=True
			_vel.y=.125
		Endif
		
		Entity.Move( _vel )
		
		Local dst:=Entity.Position
		
		Local qres:=QCollide( Cast<ConvexCollider>( Entity.Collider ),src,dst,moving Or Not _onground )
		dst=qres.position
		
		If Not _jumping And Not qres.hitground And _onground
			src=dst
			dst.y-=_stepDown
			qres=QCollide( Cast<ConvexCollider>( Entity.Collider ),src,dst,False )
			dst=qres.position
		Endif
		
		_onground=qres.hitground

		If _onground _jumping=False
		
		_vel.y=dst.y-src.y
		
		Entity.Position=dst
	End
	
End

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _player:Model
	
	Field _camera:Camera
	
	Method CreateTerrain:Model()
		
		Local box:=New Boxf( -256,-32,-256,256,0,256 )
		
		Local hmap:=Pixmap.Load( "asset::heightmap_256.BMP",PixelFormat.I8 )

		Local material:=PbrMaterial.Load( "asset::mossy-ground1.pbr" )
		material.ScaleTextureMatrix( 64,64 )
		
		'model+mesh
		Local model:=Model.CreateTerrain( hmap,box,material )
		model.CastsShadow=False
		
		Local collider:=model.AddComponent<TerrainCollider>()
		collider.Heightmap=hmap
		collider.Bounds=box
		
		Local body:=model.AddComponent<RigidBody>()
		body.Mass=0
		
		Return model
	End
	
	Method CreateCastle:Model()
		
		Local box:=New Boxf( -10000,0,-10000,10000,30,10000 )
		
		Local model:=Model.Load( "asset::castle/CASTLE1.X" )
		model.Mesh.FitVertices( box,True )
		
		Local collider:=model.AddComponent<MeshCollider>()
		collider.Mesh=model.Mesh
		
		Local body:=model.AddComponent<RigidBody>()
		body.Mass=0
		
		Return model
	End
	
	Method CreatePlayer:Model()
		
		Local radius:=.25,length:=1.25,segs:=12
		Local material:=New PbrMaterial( Color.Green )
		
		Local model:=Model.CreateCapsule( radius,length,Axis.Y,segs,material )
		model.Move( 0,10,0 )
		
		Local collider:=model.AddComponent<CapsuleCollider>()
		collider.Radius=radius
		collider.Length=length
		collider.Axis=Axis.Y
		
'		Local body:=_player.AddComponent<RigidBody>()
'		body.Kinematic=True
		
		Local controller:=model.AddComponent<CharacterController>()
		
		Return model
	End
	
	Method CreateScene:Scene()
		
		Local scene:=New Scene
		
		Local light:=New Light
		light.Rotate( 60,30,0 )	'aim directional light 'down' - Pi/2=90 degrees.
		light.CastsShadow=True
		
		Local terrain:=CreateTerrain()
		
		Local castle:=CreateCastle()
		
		_player=CreatePlayer()
		
		Local camera:=New Camera( _player )
		camera.View=Self
		camera.LocalPosition=New Vec3f( 0,.5,0 )
		camera.RotateX( 45 )
		camera.Move( 0,0,-2 )
		
		_camera=camera
		
		Return scene
	End
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=CreateScene()
	End
		
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		_scene.Update()
		
		If Keyboard.KeyDown( Key.Up )
			_camera.RotateX( 1,True )
		Else If Keyboard.KeyDown( Key.Down )
			_camera.RotateX( -1,True )
		Endif
		
		_scene.Render( canvas )
		
		Local controller:=_player.GetComponent<CharacterController>()

'		canvas.DrawText( "y="+_player.Position.y+" onground="+controller.OnGround+" FPS="+App.FPS,0,0 )
		canvas.DrawText( " onground="+controller.OnGround+" FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	Print RealPath( "desktop::hello.png" )

	New AppInstance
	
	New MyWindow
	
	App.Run()
End
