
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
	End
	
	#rem monkeydoc The sky texture.
	
	The sky texture is used to clear the scene. 
	
	If there is no sky texture, the clear color is used instead.
	
	This must currently be a valid cubemap texture.
	
	#end
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
	Property EnvTexture:Texture()
		
		Return _envTexture
	
	Setter( texture:Texture )
		
		_envTexture=texture
	End
	
	#rem monkey The environment color.
	
	#end
	Property EnvColor:Color()
		
		Return _envColor
	
	Setter( color:Color )
		
		_envColor=color
	End
	
	#rem monkeydoc The clear color.
	
	The clear color is used to clear the scene.
	
	The clear color is only used if there is no sky texture.
	
	#end
	Property ClearColor:Color()
		
		Return _clearColor
		
	Setter( color:Color )
		
		_clearColor=color
	End
	
	Property FogColor:Color()
		
		Return _fogColor
	
	Setter( color:Color )
		
		_fogColor=color
	End
	
	Property FogNear:Float()
		
		Return _fogNear
	
	Setter( near:Float )
		
		_fogNear=near
	End
	
	Property FogFar:Float()
		
		Return _fogFar
	
	Setter( far:Float )
		
		_fogFar=far
	End
	
	Property ShadowAlpha:Float()
		
		Return _shadowAlpha
	
	Setter( alpha:Float )
		
		_shadowAlpha=alpha
	End
	
	#rem monkeydoc Scene update rate.
	#end
	Property UpdateRate:Float()
		
		Return _updateRate
	
	Setter( updateRate:Float )
		
		_updateRate=updateRate
	End
	
	#rem monkeydoc Ambient diffuse lighting.
	#end
	Property AmbientLight:Color()
		
		Return _ambientDiffuse
		
	Setter( color:Color )
		
		_ambientDiffuse=color
	End
	
	#rem monkeydoc Array containing the cascaded shadow map frustum splits for directional light shadows.
	
	Defaults to Float[]( 8.0,16.0,64.0,256.0 )
	
	Must have length 4.
		
	#end
	Property CSMSplits:Float[]()
		
		Return _csmSplits
		
	Setter( splits:Float[] )
		Assert( splits.Length=4,"CSMSplits array must have 4 elements" )
		
		_csmSplits=splits.Slice( 0 )
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
