
#Import "<std>"
#Import "<mojo>"
#Import "<mojo3d>"
#Import "<bullet>"
 
Using std..
Using mojo..
Using mojo3d..
 
Const WALL_WIDTH:Int	= 20
Const WALL_HEIGHT:Int	= 20
 
Class PhysBox
 
	Class PhysParams
		Field mass:Float
		Field group:Short
		Field mask:Short
	End
	
	Field box:Boxf
	Field model:Model
	Field collider:BoxCollider
	Field body:RigidBody
 
	Field init:PhysParams
	 
	Method New (width:Float = 1, height:Float = 1, depth:Float = 1, mass:Float = 1, material:Material = Null, group:Int = 1, mask:Int = 1)
 
		' Store setup params for PhysBox.Start ()
		
'		SetConfig( "MOJO3D_RENDERER","forward" )
		
		init = New PhysParams
		
		init.mass	= mass
		init.group	= group
		init.mask	= mask
		
		If Not material
			material = New PbrMaterial (Color.Red)
		Endif
		
		box					= New Boxf (-width * 0.5, -height * 0.5, -depth * 0.5, width * 0.5, height * 0.5, depth * 0.5)
		model				= Model.CreateBox (box, 1, 1, 1, material)
 
	End
 
	Method Start ()
 
		collider			= New BoxCollider (model)
		body				= New RigidBody (model)
 
		collider.Box		= box
	
		body.Mass			= init.mass
		body.CollisionGroup	= init.group
		body.CollisionMask	= init.mask
		
		box					= Null
		init				= Null
		
	End
	 
	Method Move (x:Float, y:Float, z:Float)
		model.Move (x, y, z)
	End
 
	Method Rotate (pitch:Float, roll:Float, yaw:Float, localspace:Bool = False)
		model.Rotate (pitch, roll, yaw, localspace)
	End
	
End
 
Class Game Extends Window
 
	Const CAMERA_MOVE:Float = 0.05
	Const CAMERA_BOOST:Float = 4.0
	
	Field cam_boost:Float = 1.0
	 
	Field scene:Scene
	Field cam:Camera
	Field light:Light
	
	Field ground:PhysBox
 
	Field boxes:List <PhysBox>
	Field bullets:List <PhysBox>
	
	Method New (title:String, width:Int, height:Int, flags:WindowFlags)
 
		Super.New (title, width, height, flags)
 
		SwapInterval = 1
		
		CreateArena (50)
		
	End
	
	Method CreateArena:Void (ground_size:Float = 100)
 
		SeedRnd (Millisecs ())
		
		scene					= Scene.GetCurrent ()
		ground					= New PhysBox (ground_size, 1, ground_size, 0, New PbrMaterial (Color.Green * 0.25))
		cam						= New Camera( Self )
		light					= New Light
 
		scene.AmbientLight	= Color.White * 0.75
		scene.ClearColor	= Color.Sky * 0.75
		scene.ShadowAlpha	= .5
 
		cam.FOV = 100
		cam.Move (0, 10, -10)
		
		ground.Start ()
		
		cam.Near				= 0.01
		cam.Far					= 1000
	
		light.CastsShadow		= True
		light.Range				= 1000
 
		light.Move (0, 20, 10)
		
'		cam.PointAt (ground.model)
		light.PointAt (ground.model)
 
		boxes	= New List <PhysBox>
		bullets	= New List <PhysBox>
 
		BuildWall (WALL_WIDTH, WALL_HEIGHT)
		
	End
 
	Method BuildWall (width:Int, height:Int)
	
		For Local y:Int = 0 Until height
			For Local x:Int = 0 Until width
				
				Local color:Color = New Color (Rnd (0.4, 1.0), Rnd (0.4, 1.0), Rnd (0.4, 1.0))
				
				' Create new PhysBox...
				
				Local pb:PhysBox = New PhysBox (1, 1, 1, 1, New PbrMaterial (color))
				
				' Position PhysBox...
				
	 			pb.Move (x - (width / 2.0), (y + 1), 0)
	
				boxes.Add (pb)
				
				' Start its physics...
				
				pb.Start ()
				
			Next
		Next
 
	End
 
	Method DropBox ()
 
		Local pb:PhysBox = New PhysBox (1, 1, 1, 1, New PbrMaterial (Color.Red))
		
		pb.Move (0, 50, 0)
 
		boxes.Add (pb)
		
		pb.Start ()
 
	End
	
	Method BumpWall ()
 
		Local vec:Vec3f = New Vec3f (0.0, 0.5, 0.0)
	
		'Local count:Int
		
		For Local pb:PhysBox = Eachin boxes
			'If Not pb.collider Then Print "No collider"
			'If Not pb.body Then Print "No body"
			pb.body.ApplyImpulse (vec)
			'pb.body.LinearVelocity=vec
			'Print "Body count: " + count
			'count = count + 1
		Next
		
		'Print Millisecs ()
		
	End
	
	Method UpdateBoxes ()
 
		For Local pb:PhysBox = Eachin boxes
 
			If pb.model.Y < -20
 
				pb.model.Scale = pb.model.Scale * 0.75
 
				If pb.model.Scale.x < 0.01
					pb.model.Destroy ()
					boxes.Remove (pb)
				Endif
 
			Endif
 
		Next
 
	End
 
	Method UpdateGame ()
		
		UpdateBoxes ()
		
		If Keyboard.KeyDown (Key.D)
			DropBox ()
		Endif
 	
		If Keyboard.KeyDown (Key.B)
			BumpWall ()
		Endif
 	
		If Keyboard.KeyHit (Key.Escape)
			App.Terminate ()
		Endif
 	
 		If Keyboard.KeyHit (Key.S)
			light.CastsShadow = Not light.CastsShadow
		Endif
	 
 		If Keyboard.KeyHit (Key.Space)
 			
 			For Local pb:PhysBox = Eachin boxes
				pb.model.Destroy ()
				boxes.Remove (pb)
			Next
			
			BuildWall (WALL_WIDTH, WALL_HEIGHT)
			
		Endif
	 
		If Keyboard.KeyDown (Key.LeftShift)
			cam_boost = CAMERA_BOOST
		Else
			cam_boost = 1.0
		Endif
		
		If Keyboard.KeyDown (Key.A)
			cam.Move (0.0, 0.0, CAMERA_MOVE * cam_boost)
		Endif
 
		If Keyboard.KeyDown (Key.Z)
			cam.Move (0.0, 0.0, -CAMERA_MOVE * cam_boost)
		Endif
 
		If Keyboard.KeyDown (Key.Left)
			cam.Rotate (0.0, 1.0, 0.0)
		Endif
 
		If Keyboard.KeyDown (Key.Right)
			cam.Rotate (0.0, -1.0, 0.0)
		Endif
 
		If Keyboard.KeyDown (Key.Up)
			cam.Rotate (1.0, 0.0, 0.0, True)
		Endif
 
		If Keyboard.KeyDown (Key.Down)
			cam.Rotate (-1.0, 0.0, 0.0, True)
		Endif
		
	End
 
	Method ShadowText:Void (canvas:Canvas, s:String, x:Float, y:Float)
		canvas.Color = Color.Black
		canvas.DrawText	(s, x + 1, y + 1)
		canvas.Color = Color.White
		canvas.DrawText	(s, x, y)
	End
 
	Method RenderText (canvas:Canvas)
		
		ShadowText (canvas, "FPS: " + App.FPS, 20.0, 20.0)
		ShadowText (canvas, "A/Z + Cursors to move camera", 20.0, 40.0)
		ShadowText (canvas, "SHIFT to boost", 20.0, 60.0)
		ShadowText (canvas, "SPACE to rebuild wall", 20.0, 80.0)
		ShadowText (canvas, "S to toggle shadows", 20.0, 100.0)
		ShadowText (canvas, "B to boost boxes", 20.0, 120.0)
 		ShadowText (canvas, "Boxes: " + boxes.Count (), 20.0, 160.0)
		
	End
	
	Method OnRender (canvas:Canvas) Override
 
		RequestRender ()
		
		UpdateGame ()
		
		scene.Update ()
		
		scene.Render (canvas)
 
		RenderText (canvas)
		
	End
	
End
 
Function Run3D (title:String, width:Int, height:Int, flags:WindowFlags = WindowFlags.Center)
 
	New AppInstance
	New Game (title, width, height, flags)
 
	App.Run ()
 
End
 
Function Main ()
	Run3D ("3D Scene", 960, 540, WindowFlags.Center)		' 1/4 HD!
'	Run3D ("3D Scene", 1920, 1080, WindowFlags.Fullscreen) 
End
