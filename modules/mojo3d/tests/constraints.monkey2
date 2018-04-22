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
	
	Method New( title:String="Simple mojo app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )

		Super.New( title,width,height,flags )
		
		_scene=New Scene
		
		'create camera
		'
		_camera=New Camera( Self )
		_camera.Name="Camera"
		_camera.Near=.1
		_camera.Far=60
		_camera.Move( 0,10,-10 )
		New FlyBehaviour( _camera )
		
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
		Local groundCollider:=New BoxCollider( _ground )
		groundCollider.Box=groundBox
		Local groundBody:=New RigidBody( _ground )
		groundBody.Mass=0
		
		Local modelBox:=New Boxf( -.5,.5 )
		Local modelMaterial:=New PbrMaterial( Color.Orange )
		Local model:=Model.CreateBox( modelBox,1,1,1,modelMaterial )
		Local modelCollider:=model.AddComponent<BoxCollider>()
		modelCollider.Box=modelBox
		Local modelBody:=model.AddComponent<RigidBody>()

		Local prev:Model
		
		For Local i:=0 Until 100
			
			Local copy:=model.Copy()
			copy.Move( 0,1+i*1.2,0 )
			
			If prev
				Local constraint:=prev.AddComponent<PointToPointConstraint>()
				constraint.Pivot=New Vec3f( 0,.6,0 )
				constraint.ConnectedBody=copy.RigidBody
				constraint.ConnectedPivot=New Vec3f( 0,-.6,0 )
			Endif
			
			prev=copy
		Next
		
		prev.RigidBody.Mass=0
		
		model.Destroy()
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
