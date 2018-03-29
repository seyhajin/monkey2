
Namespace mojo3d

#rem monkeydoc The Scene class.
#end
Class Scene

	#rem monkeydoc Creates a new scene.
	
	If there is no current scene when a new scene is created, the new scene becomes the current scene.
		
	#end
	Method New()
		
		If Not _current _current=Self
		
		_clearColor=Color.Sky

		_ambientDiffuse=Color.DarkGrey
		
		_envColor=Color.White
		
		_world=New World( Self )
		
		Local type:=TypeInfo.GetType( "mojo3d.Scene" )
		If type And type.Kind="Class"
			_jsonifier=New Jsonifier
			_jsonifier.AddInstance( Self,New Variant[0] )
		Endif
		
		_editing=False
	End
	
	#rem monkeydoc The sky texture.
	
	The sky texture is used to clear the scene. 
	
	If there is no sky texture, the clear color is used instead.
	
	This must currently be a valid cubemap texture.
	
	#end
'	[jsonify=1]
	Property SkyTexture:Texture()
		
		Return _skyTexture
	
	Setter( texture:Texture )
		
		_skyTexture=texture
	End
	
	#rem monkeydoc The environment texture.
	
	The environment textures is used to render specular reflections within the scene.
	
	If there is no environment texture, the sky texture is used instead.
		
	If there is no environment texture and no sky texture, a default internal environment texture is used.
	
	This must currently be a valid cubemap texture.
	
	#end
'	[jsonify=1]
	Property EnvTexture:Texture()
		
		Return _envTexture
	
	Setter( texture:Texture )
		
		_envTexture=texture
	End
	
	#rem monkey The environment color.
	
	#end
	[jsonify=1]
	Property EnvColor:Color()
		
		Return _envColor
	
	Setter( color:Color )
		
		_envColor=color
	End
	
	#rem monkeydoc The clear color.
	
	The clear color is used to clear the scene.
	
	The clear color is only used if there is no sky texture.
	
	#end
	[jsonify=1]
	Property ClearColor:Color()
		
		Return _clearColor
		
	Setter( color:Color )
		
		_clearColor=color
	End
	
	[jsonify=1]
	Property FogColor:Color()
		
		Return _fogColor
	
	Setter( color:Color )
		
		_fogColor=color
	End
	
	[jsonify=1]
	Property FogNear:Float()
		
		Return _fogNear
	
	Setter( near:Float )
		
		_fogNear=near
	End
	
	[jsonify=1]
	Property FogFar:Float()
		
		Return _fogFar
	
	Setter( far:Float )
		
		_fogFar=far
	End
	
	[jsonify=1]
	Property ShadowAlpha:Float()
		
		Return _shadowAlpha
	
	Setter( alpha:Float )
		
		_shadowAlpha=alpha
	End
	
	#rem monkeydoc Scene update rate.
	#end
	[jsonify=1]
	Property UpdateRate:Float()
		
		Return _updateRate
	
	Setter( updateRate:Float )
		
		_updateRate=updateRate
	End
	
	#rem monkeydoc Ambient diffuse lighting.
	#end
	[jsonify=1]
	Property AmbientLight:Color()
		
		Return _ambientDiffuse
		
	Setter( color:Color )
		
		_ambientDiffuse=color
	End
	
	#rem monkeydoc Array containing the cascaded shadow map frustum splits for directional light shadows.
	
	Defaults to Float[]( 8.0,16.0,64.0,256.0 )
	
	Must have length 4.
		
	#end
	[jsonify=1]
	Property CSMSplits:Float[]()
		
		Return _csmSplits
		
	Setter( splits:Float[] )
		Assert( splits.Length=4,"CSMSplits array must have 4 elements" )
		
		_csmSplits=splits.Slice( 0 )
	End
	
	Property Editing:Bool()
		
		Return _editing
	
	Setter( editing:Bool )
		
		If editing And Not _jsonifier RuntimeError( "Scene is not editable" )
		
		_editing=editing
	End
	
	Property Jsonifier:Jsonifier()
		
		Return _jsonifier
	End
	
	Method PauseEditing()
		
		_editingPaused+=1
	End
	
	Method ResumeEditing:Bool()
		
		_editingPaused-=1
		
		Return Editing
	End
	
	Method LoadTexture:Texture( path:String,flags:TextureFlags,flipNormalY:Bool=False )
		
		Local texture:=Texture.Load( path,flags,flipNormalY )
		If Not texture Return Null
		
		If Editing Jsonifier.AddInstance( texture,"mojo3d.Scene.LoadTexture",Self,New Variant[]( path,flags,flipNormalY ) )
			
		Return texture
	End

	#rem monkeydoc Finds an entity in the scene.
	
	Finds an entity in the scene with the given name.
	
	#end
	Method FindEntity:Entity( name:String )
		
		For Local entity:=Eachin _rootEntities
			
			Local found:=entity.Find( name )
			If found Return found
		Next
		
		Return Null
	End
	
	#rem monkeydoc Adds a post effect to the scene.
	#end
	Method AddPostEffect( postEffect:PostEffect )
		
		_postEffects.Add( postEffect )
	End
	
	#rem monkeydoc Removes a post effect from the scene
	#end
	Method RemovePostEffect( postEffect:PostEffect )
		
		_postEffects.Remove( postEffect )
	End
	
	#rem monkeydocs Get all post effect that have been added to the scene
	#end
	Method GetPostEffects:PostEffect[]()
		
		Return _postEffects.ToArray()
	End
	
	#rem monkeydoc Destroys all entities in the scene.
	#end
	Method DestroyAllEntities()
		
		While Not _rootEntities.Empty

			_rootEntities.Top.Destroy()
		Wend
	End
	
	#rem monkeydoc Updates the scene.
	#end
	Method Update()
		
		Global time:=0.0
		
		Local elapsed:=0.0
		
		If time
			elapsed=Now()-time
			time+=elapsed
		Else
			time=Now()
		Endif
		
		Update( elapsed )
	End
	
	#rem monkeydoc Renders the scene to	a canvas.
	#end
	Method Render( canvas:Canvas )
		
		For Local camera:=Eachin _cameras
			
			camera.Render( canvas )
		Next
	End
	
	Method RayCast:RayCastResult( rayFrom:Vec3f,rayTo:Vec3f,collisionMask:Int )
		
		Return _world.RayCast( rayFrom,rayTo,collisionMask )
	End

	#rem monkeydoc Enumerates all entities in the scene with null parents.
	#end
	Method GetRootEntities:Entity[]()
		
		Return _rootEntities.ToArray()
	End
	
	#rem monkeydoc Saves the scene to a mojo3d scene file
	#end
	Method Save( path:String )
		
		Assert( _jsonifier,"Scene is not editable" )
		
		Local jobj:=_jsonifier.JsonifyInstances()
		
		Local json:=jobj.ToJson()
		
		SaveString( json,path )
	End
	
	#rem monkeydoc Sets the current scene.
	
	All newly created entities (including entites created using Entity.Copy]]) are automatically added to the current scene.
	
	#end
	Function SetCurrent( scene:Scene )
		
		_current=scene
	End
	
	#rem monkeydoc Gets the current scene.
	
	If there is no current scene, a new scene is automatically created and made current.
		
	#end
	Function GetCurrent:Scene()

		If Not _current New Scene
			
		Return _current
	End
	
	#rem monkeydoc Loads a mojo3d scene file and makes it current
	#end
	Function Load:Scene( path:String )

		Local json:=LoadString( path )
		If Not json Return Null
		
		Local jobj:=JsonObject.Parse( json )
		If Not jobj Return Null
		
		Local scene:=New Scene
		
		SetCurrent( scene )
		
		scene.Jsonifier.DejsonifyInstances( jobj )
		
		Return scene
	End
	
	Internal

	Property PostEffects:Stack<PostEffect>()
		
		Return _postEffects
	End
	
	Property RootEntities:Stack<Entity>()
		
		Return _rootEntities
	End
	
	Property Cameras:Stack<Camera>()
		
		Return _cameras
	End
	
	Property Lights:Stack<Light>()
		
		Return _lights
	End
	
	Property Renderables:Stack<Renderable>()
	
		Return _renderables
	End
	
	Property World:World()
		
		Return _world
	End
	
	Private
	
	Global _current:Scene
	Global _defaultEnv:Texture
	
	Field _skyTexture:Texture
	Field _envTexture:Texture
	Field _envColor:Color
	
	Field _clearColor:Color
	Field _ambientDiffuse:Color
	
	Field _fogColor:Color
	Field _fogNear:Float
	Field _fogFar:Float
	
	Field _shadowAlpha:Float=1

	Field _updateRate:Float=60
	
	Field _csmSplits:=New Float[]( 8.0,16.0,64.0,256.0 )
	
	Field _rootEntities:=New Stack<Entity>
	Field _cameras:=New Stack<Camera>
	Field _lights:=New Stack<Light>
	Field _renderables:=New Stack<Renderable>()
	Field _postEffects:=New Stack<PostEffect>
	
	Field _world:World
	
	Field _jsonifier:Jsonifier
	
	Field _editing:Bool
	
	Field _editingPaused:=0
	
	Method Update( elapsed:Float )
		
		For Local e:=Eachin _rootEntities
			e.BeginUpdate()
		Next
		
		_world.Update( elapsed )
		
		For Local e:=Eachin _rootEntities
			e.Update( elapsed )
		Next
	End
			
End
