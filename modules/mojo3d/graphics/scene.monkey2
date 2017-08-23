
Namespace mojo3d.graphics

#rem monkeydoc The Scene class.
#end
Class Scene

	#rem monkeydoc Creates a new scene.
	#end
	Method New()
		
		_clearColor=Color.Sky

		_ambientDiffuse=Color.DarkGrey
	End
	
	#rem monkeydoc The sky texture.
	
	The sky texture is used to clear the scene. 
	
	If there is no sky texture, the clear color is used instead.
	
	This must currently be a valid cubemap texture.
	
	#end
	Property SkyTexture:Texture()
		
		Return _skytex
	
	Setter( skytex:Texture )
		
		_skytex=skytex
	End
	
	#rem monkeydoc The environment texture.
	
	The environment textures is used to render specular reflections within the scene.
	
	If there is no environment texture, the sky texture is used instead.
		
	If there is no environment texture and no sky texture, a default internal environment texture is used.
	
	This must currently be a valid cubemap texture.
	
	#end
	Property EnvTexture:Texture()
		
		Return _envtex
	
	Setter( envtex:Texture )
		
		_envtex=envtex
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
	
	#rem monkeydoc Ambient diffuse lighting.
	#end
	Property AmbientLight:Color()
		
		Return _ambientDiffuse
		
	Setter( color:Color )
		
		_ambientDiffuse=color
	End
	
	#rem monkeydoc Adds a post effect to the scene.
	#end
	Method AddPostEffect( postEffect:PostEffect )
		
		_postEffects.Add( postEffect )
	End
	
	#rem monkeydoc 	Destroys all entities in the scene.
	
	#end
	Method DestroyAllEntities()
		
		For Local entity:=Eachin _rootEntities
			
			entity.Destroy()
		Next
	End
	
	#rem monkeydoc Renders the scene to	a canvas.
	#end
	Method Render( canvas:Canvas,camera:Camera )
			
		camera.Viewport=canvas.Viewport
			
		canvas.Flush()
		
		Renderer.GetCurrent().Render( Self,camera,canvas.GraphicsDevice )
	End

	#rem monkeydoc Enumerates all entities in the scene with null parents.
	#end
	Method GetRootEntities:Entity[]()
		
		Return _rootEntities.ToArray()
	End
	
	#rem monkeydoc Gets the current scene.
	#end
	Function GetCurrent:Scene()
		If Not _current _current=New Scene
			
		Return _current
	End
	
	Internal

	Function SetCurrent( scene:Scene )
		
		_current=scene
	End
	
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
	
	Property Models:Stack<Model>()
		
		Return _models
	End
	
	Property Terrains:Stack<Terrain>()
		
		Return _terrains
	End
	
	Property Sprites:Stack<Sprite>()
		
		Return _sprites
	End
	
	Private
	
	Global _current:Scene
	
	Global _defaultEnv:Texture
	
	Field _skytex:Texture
	Field _envtex:Texture
	Field _clearColor:Color
	Field _ambientDiffuse:Color
	Field _postEffects:=New Stack<PostEffect>
	
	Field _rootEntities:=New Stack<Entity>
	
	Field _cameras:=New Stack<Camera>
	Field _lights:=New Stack<Light>
	Field _models:=New Stack<Model>
	Field _terrains:=New Stack<Terrain>
	Field _sprites:=New Stack<Sprite>
			
End
