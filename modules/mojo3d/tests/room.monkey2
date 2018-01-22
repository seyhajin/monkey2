Namespace myapp

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/"

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
		
		SetConfig( "MOJO3D_RENDERER","forward" )
		
		'Create scene
		_scene=New Scene
		_scene.ClearColor=Color.Black
		_scene.AmbientLight=Color.Black'DarkGrey*.2
		_scene.EnvColor=Color.DarkGrey
		_scene.ShadowAlpha=.7
		
		'Create camera
		_camera=New Camera( Self )
		_camera.Move( 0,0,-5 )
		
		New FlyBehaviour( _camera )
		
		'Create light
		_light=New Light
		_light.Type=LightType.Point
		_light.CastsShadow=True
		_light.Range=15
		
		Local sphereMaterial:=New PbrMaterial( Color.Black,0,1 )
		sphereMaterial.EmissiveFactor=_light.Color
		
		'Local sphere:=Model.CreateSphere( .1,24,12,sphereMaterial,_light )
		'sphere.CastsShadow=False
		
		'_light.Visible=False
		
		'Create room
		Local roomBox:=New Boxf( -10,10 )
		Local roomMaterial:=New PbrMaterial( Color.Orange )
'		Local roomMaterial:=PbrMaterial.Load( "asset::blocksrough.pbr" )
		_room=Model.CreateBox( roomBox,1,1,1,roomMaterial )
		_room.Mesh.FlipTriangles()
		_room.Mesh.UpdateNormals()
		_room.Mesh.UpdateTangents()
		_room.CastsShadow=False
		
		Local fish:=Model.Load( "asset::fish.glb" )
'		Local fish:=Model.Load( "asset::barramundi.gltf/BarramundiFish.gltf" )
		fish.Mesh.FitVertices( New Boxf( -1,1 ) )
		
		_fish=New Entity
		_fish.Visible=True
		
		For Local an:=0 Until 360 Step 15
			
			local copy:=fish.Copy( _fish )
			
			copy.Rotate( 0,an,0 )
			copy.Move( 0,Sin( an )*3,Rnd( 2.5,7.5 ) )
			
			copy.Rotate( 0,-90,0 )
			
		Next
		
		fish.Destroy()
		
	End
	
	Method OnRender( canvas:Canvas ) Override
	
		RequestRender()
		
		_fish.Rotate( 0,.1,0 )
		
		_scene.Update()
		
		_camera.Render( canvas )
		
		canvas.DrawText(	"POS="+_camera.Position,0,0 )
		
		canvas.DrawText( "FPS "+App.FPS,Width,0,1,0 )
	End
	
End

