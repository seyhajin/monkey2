Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<mojo3d-vr>"

#Import "../../mojo3d/tests/assets/bluspark.png"
#Import "../../mojo3d/tests/assets/duck.gltf/@/duck.gltf"

#Import "assets/vivecontroller.gltf"

Using std..
Using mojo..
Using mojo3d..

Class DuckBehaviour Extends Behaviour
	
	Field _speed:Float
	Field _yawsp:Float
	Field _timer:Float
	
	Method New( entity:Entity )
		
		Super.New( entity )
		Reset()
	End
	
	Method Reset()
		_speed=Rnd( .001,.002 )
		_yawsp=Rnd( -1,1 )
		_timer=Rnd( 1,3 )
	End
	
	Method OnUpdate( elapsed:Float ) Override
		
		_timer-=elapsed
		
		If _timer<=0 Reset()
			
		Entity.RotateY( _yawsp )
		
		Entity.MoveZ( _speed )
	End
	
End

Class MyWindow Extends Window
	
	Field _renderer:VRRenderer
	
	Field _scene:Scene
	
	Field _camera:Camera

	Field _light:Light
	
	Field _ground:Model
	
	Field _particles:ParticleSystem
	
	Field _ctrlModel:Model
	
	Field _bases:=New Model[2]

	Field _ctrls:=New Model[2]
	
	Field _ducks:=New Stack<Model>
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		SwapInterval=0
		
		Print "GL_VERSION="+opengl.glGetString( opengl.GL_VERSION )
		
		'Enables VR: must happen before Scene.GetCurrent()!
		'
		_renderer=New VRRenderer
		
		'Use more detailed CSM shadow split distances to compensate for the much nearer near clip plane.
		'
		_renderer.CSMSplits=New Float[]( 2,4,16,256 )
		
		_renderer.TrackingSpace=VRTrackingSpace.Standing
		
		_scene=Scene.GetCurrent()

		'very dark!		
		'_scene.EnvColor=Color.Black
		'_scene.ClearColor=Color.Black
		'_scene.AmbientLight=Color.Black
		
		'create camera
		'
		_camera=New Camera
		_camera.Near=.01		'Note: near clip plane 1 centimeter from camera so we can look at things nice and close up.
		_camera.Far=100			'camera far/near ratio is probably a bit much
		
		'create light
		'
		_light=New Light
		_light.Rotate( 75,15,0 )
		_light.CastsShadow=True
		
		'ground material
		'
		Local groundMaterial:=New PbrMaterial( Color.Green,0,1 )
		
		'create ground
		'
		Local groundBox:=New Boxf( -50,-.1,-50,50,0,50 )
		_ground=Model.CreateBox( groundBox,1,1,1,groundMaterial )
		_ground.CastsShadow=False
		
		'create ducks
		'		
		Local duck:=Model.Load( "asset::duck.gltf/Duck.gltf" )
		duck.Mesh.FitVertices( New Boxf( -.05,.05 ) )
'		duck.Mesh.FitVertices( New Boxf( -.5,.5 ) )
		duck.Mesh.TransformVertices( AffineMat4f.Rotation( 0,Pi/2,0 ) )
		duck.Rotate( 0,-Pi/2,0 )
		
		For Local i:=0 Until 100
			
			Local copy:=duck.Copy()
			New DuckBehaviour( copy )
			
			copy.Position=Null
			copy.RotateY( Rnd( 360 ) )
			copy.Move( 0,Rnd( .5,1.5 ),Rnd( -1,1 ) )
			
			_ducks.Add( copy )
		Next
		
		New FlyBehaviour( duck ).Speed=.01
		duck.Move( 0,.7,.5 )
		
		Local baseBox:=New Boxf( -.042,-.042,-.042,.042,.042,.042 )
		Local baseMaterial:=New PbrMaterial( Color.Aluminum,1.0,1.0 )
		_bases[0]=Model.CreateBox( baseBox,1,1,1,baseMaterial )
		_bases[1]=_bases[0].Copy()'Model.CreateBox( baseBox,1,1,1,baseMaterial )
		
		Local ctrlModel:=Model.Load( "asset::vivecontroller.gltf" )
		ctrlModel.Mesh.TransformVertices( AffineMat4f.Rotation( -Pi/2,0,0 ) )
		
'		Local ctrlMaterial:=New PbrMaterial( Color.Black,0.0,1.0 )
'		_ctrlModel=Model.CreateCylinder( .03,.23,Axis.Z,24,ctrlMaterial )
		
		_ctrls[0]=ctrlModel
		_ctrls[1]=ctrlModel.Copy()
		
	End
	
	Method OnRender( canvas:Canvas ) Override

		RequestRender()
		
		'need to call this for VRRenderer before renderer or you'll get an error.
		'
		_renderer.Update()

		_camera.Matrix=_renderer.HeadMatrix
		
		_ctrls[0].Visible=_renderer.Active
		_ctrls[1].Visible=_renderer.Active
		
		_ctrls[0].Matrix=_renderer.ControllerMatrices[0]
		_ctrls[1].Matrix=_renderer.ControllerMatrices[1]
		
		_bases[0].Matrix=_renderer.BaseStationMatrices[0]
		_bases[1].Matrix=_renderer.BaseStationMatrices[1]
		
		If _renderer.Active _scene.Update()
		
		_scene.Render( canvas,_camera )

		'Done!
'		_renderer.LeftEyeImage.Scale=New Vec2f( -1,-1 )
		canvas.DrawRect( 0,Height,Width,-Height,_renderer.LeftEyeImage )

		canvas.Scale( Width/640.0,Height/480.0 )
		
		canvas.DrawText( "Camera.Position="+_camera.Position+", FPS="+App.FPS,0,0 )
	End
	
End

Function Main()
	
	New AppInstance
	
	New MyWindow
	
	App.Run()
End
