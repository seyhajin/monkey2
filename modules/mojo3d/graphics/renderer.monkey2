
Namespace mojo3d.graphics

#rem monkeydoc The Renderer class.
#end
Class Renderer
	
	#rem monkeydoc @hidden
	#end
	Property ShaderDefs:String()
		
		Return _shaderDefs
	End

	#rem monkeydoc Size of cascading shadow map texture.
	
	Must be a power of 2 size. Defaults to 1024.
	
	#end
	Property CSMTextureSize:Float()
		
		Return _csmSize
		
	Setter( size:Float )
		Assert( Log2( size )=Floor( Log2( size ) ),"CSMTextureSize must be a power of 2" )
		
		_csmSize=size
	End
	
	#rem monkeydoc Array containing the Z depths of the cascading shadow map frustum splits.
	
	Defaults to Float[]( 1,20,60,180,1000 ).
		
	#end
	Property CSMSplitDepths:Float[]()
		
		Return _csmSplits
	
	Setter( splits:Float[] )
		Assert( splits.Length=5,"CSMSplitDepths array must have 5 elements" )
		
		_csmSplits=splits
	End
	
	#rem monkeydoc Gets the current renderer.
	#end
	Function GetCurrent:Renderer()
		
		Global _current:Renderer
		
		If Not _current
			Select App.GetConfig( "mojo3d_renderer","" )
			Case "deferred"
				_current=New DeferredRenderer
			Case "forward"
				_current=New ForwardRenderer( False )
			Default
#If __DESKTOP_TARGET__					
				If glexts.GL_draw_buffers
					_current=New DeferredRenderer
				Else
					_current=New ForwardRenderer( True )
				Endif
#Endif
			End
			If Not _current _current=New ForwardRenderer( False )
		Endif
		
		Return _current
	End
	
	Internal

	#rem monkeydoc @hidden
	#end
	Method Render( scene:Scene,camera:Camera,device:GraphicsDevice )

		'***** validate stuff *****
			
		Local size:=device.Viewport.Size
		size.x=Max( size.x,1920 )
		size.y=Max( size.y,1080 )
		
		OnValidateSize( size )
		
		ValidateCSM()

		_runiforms.SetFloat( "Time",Now() )

		_runiforms.SetTexture( "ShadowTexture",_csmTexture )
		_runiforms.SetVec4f( "ShadowSplits",New Vec4f( _csmSplits[1],_csmSplits[2],_csmSplits[3],_csmSplits[4] ) )
		
		'***** Set render scene *****
		
		_renderScene=scene

		_runiforms.SetTexture( "SkyTexture",_renderScene.SkyTexture )
		
		_runiforms.SetVec4f( "ClearColor",_renderScene.ClearColor )
		_runiforms.SetVec4f( "AmbientDiffuse",_renderScene.AmbientLight )
	
		Local env:Texture
		
		If _renderScene.SkyTexture
			env=_renderScene.SkyTexture
		Else If _renderScene.EnvTexture
			env=_renderScene.EnvTexture
		Else
			env=_defaultEnv
		Endif
		
		_runiforms.SetTexture( "EnvTexture",env )
		
		_renderQueue.Clear()
		
		For Local model:=Eachin _renderScene.Models
			
			_renderQueue.AddShadowOps=model.CastsShadow
			
			model.OnRender( _renderQueue )
		Next
		
		'***** Set render camera *****

		_renderCamera=camera

		Local envMat:=_renderCamera.Matrix.m
		Local viewMat:=_renderCamera.InverseMatrix
		Local projMat:=_renderCamera.ProjectionMatrix
		Local invProjMat:=-projMat
			
		_runiforms.SetMat3f( "EnvMatrix",envMat )
		_runiforms.SetMat4f( "ProjectionMatrix",projMat )
		_runiforms.SetMat4f( "InverseProjectionMatrix",invProjMat )
		_runiforms.SetFloat( "DepthNear",_renderCamera.Near )
		_runiforms.SetFloat( "DepthFar",_renderCamera.Far )
		
		_spriteQueue.Clear()
		
		_spriteBuffer.AddSprites( _spriteQueue,_renderScene.Sprites,_renderCamera )
		
		OnRender( scene,camera,device )
		
		_renderCamera=Null
		
		_renderScene=null
	End
	
	Protected
	
	Method OnValidateSize( size:Vec2i ) Virtual
	End
	
	Method OnRender( scene:Scene,camera:Camera,device:GraphicsDevice ) Virtual
	End

	Method New( shaderDefs:String )
		
		_shaderDefs=shaderDefs
		
		_device=New GraphicsDevice( 0,0 )
		
		_runiforms=New UniformBlock( 1 )
		_iuniforms=New UniformBlock( 2 )
		
		_device.BindUniformBlock( _runiforms )
		_device.BindUniformBlock( _iuniforms )

		_csmSplits=New Float[]( 1,20,60,180,1000 )

		_defaultEnv=Texture.Load( "asset::textures/env_default.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		_skyboxShader=Shader.Open( "skybox",_shaderDefs )

	End

	Property Device:GraphicsDevice()
	
		Return _device
	End
	
	Property RenderUniforms:UniformBlock()
	
		Return _runiforms
	End
	
	Method RenderQuad()

		Global _vertices:VertexBuffer
	
		If Not _vertices
			_vertices=New VertexBuffer( New Vertex3f[](
			New Vertex3f( 0,1,0 ),
			New Vertex3f( 1,1,0 ),
			New Vertex3f( 1,0,0 ),
			New Vertex3f( 0,0,0 ) ) )
		Endif
			
		_device.VertexBuffer=_vertices
		_device.Render( 4,1 )
	End

	Method RenderBackground()
	
		If _renderScene.SkyTexture
		
			_device.ColorMask=ColorMask.None
			_device.DepthMask=True
			
			_device.Clear( Null,1.0 )
			
			_device.ColorMask=ColorMask.All
			_device.DepthMask=False
			_device.DepthFunc=DepthFunc.Always
			_device.BlendMode=BlendMode.Opaque
			_device.CullMode=CullMode.None
			_device.Shader=_skyboxShader
			_device.RenderPass=0
			
			RenderQuad()
			
		Else
			_device.ColorMask=ColorMask.All
			_device.DepthMask=True
		
			_device.Clear( _renderScene.ClearColor,1.0 )

		Endif
		
	End
	
	Method RenderOpaqueOps()

		RenderRenderOps( _renderQueue.OpaqueOps,_renderCamera.InverseMatrix,_renderCamera.ProjectionMatrix )
	End

	Method RenderSpriteOps()

		RenderRenderOps( _spriteQueue.TransparentOps,_renderCamera.InverseMatrix,_renderCamera.ProjectionMatrix )
	End
	
	#rem
	Method RenderAmbient()
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=True
		_device.DepthFunc=DepthFunc.LessEqual
		_device.BlendMode=BlendMode.Opaque
		_device.RenderPass=1

		RenderRenderOps( _renderQueue.OpaqueOps,_renderCamera.InverseMatrix,_renderCamera.ProjectionMatrix )
	End
	
	Method RenderSprites()

		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.LessEqual
		_device.RenderPass=0

		RenderRenderOps( _spriteQueue.TransparentOps,_renderCamera.InverseMatrix,_renderCamera.ProjectionMatrix )
	End
	#end
	
	Method RenderCSMShadows( light:Light )
	
		'Perhaps use a different device for CSM...?
		'
		Local t_rtarget:=_device.RenderTarget
		Local t_viewport:=_device.Viewport
		Local t_scissor:=_device.Scissor

		_device.RenderTarget=_csmTarget
		_device.Viewport=New Recti( 0,0,_csmTarget.Size )
		_device.Scissor=_device.Viewport
		_device.ColorMask=ColorMask.None
		_device.DepthMask=True
		_device.Clear( Null,1.0 )
		
		_device.DepthFunc=DepthFunc.LessEqual
		_device.BlendMode=BlendMode.Opaque
		_device.CullMode=CullMode.Back
		_device.RenderPass=4

		Local invLightMatrix:=light.InverseMatrix
		Local viewLight:=invLightMatrix * _renderCamera.Matrix
		
		For Local i:=0 Until _csmSplits.Length-1
			
			Local znear:=_csmSplits[i]
			Local zfar:=_csmSplits[i+1]
			
			Local splitProj:=Mat4f.Perspective( _renderCamera.Fov,_renderCamera.Aspect,znear,zfar )
						
			Local invSplitProj:=-splitProj
			
			Local bounds:=Boxf.EmptyBounds
			
			For Local z:=-1 To 1 Step 2
				For Local y:=-1 To 1 Step 2
					For Local x:=-1 To 1 Step 2
						Local c:=New Vec3f( x,y,z )				'clip coords
						Local v:=invSplitProj * c				'clip->view
						Local l:=viewLight * v					'view->light
						bounds|=l
					Next
				Next
			Next
			
			bounds.min.z-=100
			
			Local lightProj:=Mat4f.Ortho( bounds.min.x,bounds.max.x,bounds.min.y,bounds.max.y,bounds.min.z,bounds.max.z )
			
			'set matrices for next pass...
			_runiforms.SetMat4f( "ShadowMatrix"+i,lightProj * viewLight )
			
			Local size:=_csmTexture.Size,hsize:=size/2
			
			Select i
			Case 0 _device.Viewport=New Recti( 0,0,hsize.x,hsize.y )
			Case 1 _device.Viewport=New Recti( hsize.x,0,size.x,hsize.y )
			Case 2 _device.Viewport=New Recti( 0,hsize.y,hsize.x,size.y )
			Case 3 _device.Viewport=New Recti( hsize.x,hsize.y,size.x,size.y )
			End
			
			_device.Scissor=_device.Viewport
				
			If light.ShadowsEnabled
				RenderRenderOps( _renderQueue.ShadowOps,invLightMatrix,lightProj )
			Endif
			
		Next
		
		_device.RenderTarget=t_rtarget
		_device.Viewport=t_viewport
		_device.Scissor=t_scissor
	End

	Private
	
	Field _shaderDefs:String
	
	Field _device:GraphicsDevice
	Field _runiforms:UniformBlock
	Field _iuniforms:UniformBlock
	
	Field _csmSize:=4096
	Field _csmSplits:=New Float[]( 1,20,60,180,1000 )
	Field _csmTexture:Texture
	Field _csmTarget:RenderTarget
	Field _skyboxShader:Shader

	Field _defaultEnv:Texture
	
	Field _renderQueue:=New RenderQueue
	Field _spriteQueue:=New RenderQueue
	Field _spriteBuffer:=New SpriteBuffer
	
	Field _renderScene:Scene
	Field _renderCamera:Camera
	
	Method ValidateCSM()
		
		If Not _csmTexture Or _csmSize<>_csmTexture.Size.x
			
			SafeDiscard( _csmTexture )
			SafeDiscard( _csmTarget )
			
			_csmTexture=New Texture( _csmSize,_csmSize,PixelFormat.Depth32F,TextureFlags.Dynamic )
			_csmTarget=New RenderTarget( Null,_csmTexture )
			
		Endif
		
	End

	Method RenderRenderOps( ops:Stack<RenderOp>,viewMatrix:AffineMat4f,projMatrix:Mat4f )
		
		_runiforms.SetMat4f( "ViewMatrix",viewMatrix )
		_runiforms.SetMat4f( "ProjectionMatrix",projMatrix )
		_runiforms.SetMat4f( "InverseProjectionMatrix",-projMatrix )
		
		Local instance:Entity=_renderCamera
		Local material:Material
		
		For Local op:=Eachin ops
			
			If op.instance<>instance
				
				instance=op.instance
				
				Local modelMat:= instance ? instance.Matrix Else New AffineMat4f
				Local modelViewMat:=viewMatrix * modelMat
				Local modelViewProjMat:=projMatrix * modelViewMat
				Local modelViewNormMat:=~-modelViewMat.m
					
				_iuniforms.SetMat4f( "ModelViewMatrix",modelViewMat )
				_iuniforms.SetMat4f( "ModelViewProjectionMatrix",modelViewProjMat )
				_iuniforms.SetMat3f( "ModelViewNormalMatrix",modelViewNormMat )
				If op.bones _iuniforms.SetMat4fArray( "ModelBoneMatrices",op.bones )
				
			Endif
			
			If op.material<>material
				
				material=op.material
				
				_device.Shader=material.Shader
				_device.BindUniformBlock( material.Uniforms )
				If material.BlendMode<>BlendMode.Opaque _device.BlendMode=material.BlendMode
				_device.CullMode=material.CullMode
				
			Endif
			
			_device.VertexBuffer=op.vbuffer
			_device.IndexBuffer=op.ibuffer
			_device.RenderIndexed( op.order,op.count,op.first )
			
		Next
	End

End
