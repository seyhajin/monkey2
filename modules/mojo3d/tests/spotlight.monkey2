Namespace myapp3d

#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"

#Import "assets/monkey2-logo.png"

Using std..
Using mojo..
Using mojo3d..

Class MyWindow Extends Window
	
	Field _scene:Scene
	
	Field _camera:Camera
	
	Field _light:Light
	
	Field _ground:Model

	Field _donut:Model
	
	Method New( title:String="Simple mojo3d app",width:Int=640,height:Int=480,flags:WindowFlags=WindowFlags.Resizable )
		
		Super.New( title,width,height,flags )
	End
	
	Method OnCreateWindow() Override
		
		'create (current) scene
		_scene=New Scene
		
		'create camera
		_camera=New Camera( Self )
		_camera.AddComponent<FlyBehaviour>()
		_camera.Move( 0,2.5,-10 )
		
		'create light
		_light=New Light
		_light.Type=LightType.Spot
		_light.Texture=Texture.Load( "asset::monkey2-logo.png" )'ColorTexture( Color.Red )
		_light.Range=25
		_light.InnerAngle=15
		_light.OuterAngle=45
		_light.CastsShadow=True
		_light.Position=New Vec3f( 0,10,0 )
		_light.Rotate( 90,0,0 )
		
		'create ground
		Local groundBox:=New Boxf( -100,-1,-100,100,0,100 )
		Local groundMaterial:=New PbrMaterial( Color.Brown,0,1 )
		_ground=Model.CreateBox( groundBox,1,1,1,groundMaterial )
		_ground.CastsShadow=False
		
		'create donut
		Local donutMaterial:=New PbrMaterial( Color.White,0,1 )
		_donut=Model.CreateTorus( 2,.5,48,24,donutMaterial )
		_donut.Move( 0,2.5,0 )
		_donut.AddComponent<RotateBehaviour>().Speed=New Vec3f( .2,.4,.6 )
		
	End
	
	Method OnRender( canvas:Canvas ) Override
		
		RequestRender()
		
		If Keyboard.KeyHit( Key.Space )
			Select _light.Type
			Case LightType.Directional
				_light.Type=LightType.Point
			Case LightType.Point
				_light.Type=LightType.Spot
			Case LightType.Spot
				_light.Type=LightType.Directional
			End
		Endif
		
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
