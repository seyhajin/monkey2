
Namespace mojo3d.graphics

#rem monkeydoc The Renderer class.
#end
Class Renderer
	
	#rem monkeydoc Size of the cascaded shadow map texture.
	
	Must be a power of 2 size. Defaults to 1024.
	
	#end
	Property CSMTextureSize:Int()
		
		Return _csmSize
		
	Setter( size:Int )
		Assert( Log2( size )=Floor( Log2( size ) ),"CSMTextureSize must be a power of 2" )
		
		_csmSize=size
	End
	
	#rem monkeydoc Array containing the cascaded shadow map frustum splits for directional light shadows.
	
	Defaults to Float[]( 1.0/64.0,1.0/16.0,1.0/4.0 )
	
	Must have length 3.
		
	#end
	Property CSMSplits:Float[]()
		
		Return _csmSplits
		
	Setter( splits:Float[] )
		Assert( splits.Length=3,"CSMSplits array must have 3 elements" )
		
		_csmSplits=splits.Slice( 0 )
	End
	
	#rem monkeydoc Size of the cube texture used for point light shadow mapping.
	
	Must be a power of 2.
	
	Defaults to 1024.
		
	#end
	Property PSMTextureSize:Int()
		
		Return _psmSize
		
	Setter( size:Int )
		Assert( Log2( size )=Floor( Log2( size ) ),"PSMTextureSize must be a power of 2" )
		
		_psmSize=size
	End
	
	#rem monkeydoc Gets the current renderer.
	#end
	Function GetCurrent:Renderer()
		
		Global _current:Renderer
		
		If Not _current
			
			Local hasDepth:=Int( App.GetConfig( "GL_depth_buffer_enabled","0" ) )<>0
			
			Select App.GetConfig( "mojo3d_renderer","" )
			Case "deferred"
				_current=New DeferredRenderer
			Case "forward-direct"
				_current=New ForwardRenderer( True )
			Case "forward"
				_current=New ForwardRenderer( False )
			Default
#If Not __MOBILE_TARGET__					
				If glexts.GL_draw_buffers _current=New DeferredRenderer
#Endif
			End
			If Not _current _current=New ForwardRenderer( hasDepth )
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
		
		ValidateShadowMaps()
		
		_csmSplitDepths[0]=camera.Near
		For Local i:=1 Until 4
			_csmSplitDepths[i]=camera.Near+_csmSplits[i-1]*(camera.Far-camera.Near)
		Next
		_csmSplitDepths[4]=camera.Far
		
		Local time:=Float( Now() )

		_runiforms.SetFloat( "Time",time )
		
		_runiforms.SetTexture( "ShadowCSMTexture",_csmTexture )
		_runiforms.SetVec4f( "ShadowCSMSplits",New Vec4f( _csmSplitDepths[1],_csmSplitDepths[2],_csmSplitDepths[3],_csmSplitDepths[4] ) )

		_runiforms.SetTexture( "ShadowCubeTexture",_psmTexture )
		
		'***** Set render scene *****
		
		_renderScene=scene

		_runiforms.SetTexture( "SkyTexture",_renderScene.SkyTexture )
		
		_runiforms.SetColor( "ClearColor",_renderScene.ClearColor )
		_runiforms.SetColor( "AmbientDiffuse",_renderScene.AmbientLight )
	
		Local env:Texture
		
		If _renderScene.EnvTexture
			env=_renderScene.EnvTexture
		ElseIf _renderScene.SkyTexture
			env=_renderScene.SkyTexture
		Else
			env=_defaultEnv
		Endif
		
		_runiforms.SetTexture( "EnvTexture",env )
		
		_renderQueue.Clear()
		
		_renderQueue.Time=time
		
		For Local model:=Eachin _renderScene.Models
			
			_renderQueue.AddShadowOps=model.CastsShadow
			
			model.OnRender( _renderQueue )
		Next
		
		_spriteQueue.Clear()
		
		_spriteQueue.Time=time
		
		For Local psystem:=Eachin _renderScene.ParticleSystems
		
			psystem.OnRender( _spriteQueue )
		End
		
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
		
		_spriteBuffer.AddSprites( _spriteQueue,_renderScene.Sprites,_renderCamera )
		
		OnRender( scene,camera,device )
		
		_renderCamera=Null
		
		_renderScene=Null
	End
	
	Protected
	
	Method OnValidateSize( size:Vec2i ) Virtual
	End
	
	Method OnRender( scene:Scene,camera:Camera,device:GraphicsDevice ) Virtual
	End

	Method New( linearOutput:Bool )
		
		_linearOutput=linearOutput

		_rgbaDepthTextures=False
		
		_shaderDefs+=_linearOutput ? "MX2_LINEAROUTPUT~n" Else "MX2_SRGBOUTPUT~n"
		
		If _rgbaDepthTextures _shaderDefs+="MX2_RGBADEPTHTEXTURES~n"
		
		Print "Renderer.ShaderDefs="+ShaderDefs
		
		_device=New GraphicsDevice( 0,0 )
		
		_runiforms=New UniformBlock( 1,True )
		_iuniforms=New UniformBlock( 2,True )
		
		_device.BindUniformBlock( _runiforms )
		_device.BindUniformBlock( _iuniforms )

		_defaultEnv=Texture.Load( "asset::textures/env_default.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		_skyboxShader=Shader.Open( "skybox",_shaderDefs )
		
		_psmFaceTransforms=New Mat3f[]( 
			New Mat3f(  0,0,+1, 0,-1,0, -1, 0,0 ),	'+X
			New Mat3f(  0,0,-1, 0,-1,0, +1, 0,0 ),	'-X
			New Mat3f( +1,0, 0, 0,0,+1,  0,+1,0 ),	'+Y
			New Mat3f( +1,0, 0, 0,0,-1,  0,-1,0 ),	'-Y
			New Mat3f( +1,0, 0, 0,-1,0,  0,0,+1 ),	'+Z
			New Mat3f( -1,0, 0, 0,-1,0,  0,0,-1 ) )	'-Z
			
		#rem
		Matxf tforms[]={
		{ {0,0,+1},{0,-1,0},{-1,0,0},{0,0,0} },	//+X
		{ {0,0,-1},{0,-1,0},{+1,0,0},{0,0,0} },	//-X
		{ {+1,0,0},{0,0,+1},{0,+1,0},{0,0,0} },	//+Y test me!
		{ {+1,0,0},{0,0,-1},{0,-1,0},{0,0,0} },	//-Y
		{ {+1,0,0},{0,-1,0},{0,0,+1},{0,0,0} },	//+Z
		{ {-1,0,0},{0,-1,0},{0,0,-1},{0,0,0} }	//-Z
	};		
		
		#end
	
	
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
			
			Local color:=_renderScene.ClearColor
			If _linearOutput
				color.r=Pow( color.r,2.2 )
				color.g=Pow( color.g,2.2 )
				color.b=Pow( color.b,2.2 )
			Endif
		
			_device.Clear( color,1.0 )

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
		_device.ColorMask=ColorMask.All
		_device.DepthMask=True
		_device.Clear( Color.White,1.0 )
'		_device.ColorMask=ColorMask.None
'		_device.DepthMask=True
'		_device.Clear( Null,1.0 )
		
		_device.DepthFunc=DepthFunc.LessEqual
		_device.BlendMode=BlendMode.Opaque
		_device.CullMode=CullMode.Back
		_device.RenderPass=16

		Local invLightMatrix:=light.InverseMatrix
		
		Local viewLight:=invLightMatrix * _renderCamera.Matrix
		
		For Local i:=0 Until _csmSplitDepths.Length-1
			
			Local znear:=_csmSplitDepths[i]
			Local zfar:=_csmSplitDepths[i+1]
			
			Local splitProj:=Mat4f.Perspective( _renderCamera.FOV,_renderCamera.Aspect,znear,zfar )
						
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
				
			RenderRenderOps( _renderQueue.ShadowOps,invLightMatrix,lightProj )
			
		Next
		
		_device.RenderTarget=t_rtarget
		_device.Viewport=t_viewport
		_device.Scissor=t_scissor
	End

	Method RenderPointShadows( light:Light )
	
		'Perhaps use a different device for CSM...?
		'
		Local t_rtarget:=_device.RenderTarget
		Local t_viewport:=_device.Viewport
		Local t_scissor:=_device.Scissor
		
		_device.Viewport=New Recti( 0,0,_psmTexture.Size )
		_device.Scissor=_device.Viewport
		_device.ColorMask=ColorMask.All
		_device.DepthMask=True
		_device.DepthFunc=DepthFunc.LessEqual
		'
		_device.BlendMode=BlendMode.Opaque
		_device.CullMode=CullMode.Back
		_device.RenderPass=17
		
		Local lightProj:=Mat4f.Frustum( -1,+1,-1,+1,1,light.Range )
		
		Local invLightMatrix:=light.InverseMatrix
		
		Local viewLight:=invLightMatrix * _renderCamera.Matrix
		
		_runiforms.SetFloat( "LightRange",light.Range )
		_runiforms.SetMat4f( "ShadowMatrix0",viewLight )
		
		For Local i:=0 Until 6
			
			_device.RenderTarget=_psmTargets[i]
			_device.Clear( Color.White,1.0 )
			
			Local viewMatrix:=New AffineMat4f( _psmFaceTransforms[i] ) * invLightMatrix

			RenderRenderOps( _renderQueue.ShadowOps,viewMatrix,lightProj )
			
		Next

		_device.RenderTarget=t_rtarget
		_device.Viewport=t_viewport
		_device.Scissor=t_scissor
	End

	Internal
	
	Property ShaderDefs:String()
		
		Return _shaderDefs
	End
	
	Property LinearOutput:Bool()
	
		Return _linearOutput
	
	End

	Private
	
	Field _rgbaDepthTextures:=False
	
	Field _shaderDefs:String
	
	Field _linearOutput:bool
	
	Field _device:GraphicsDevice
	Field _runiforms:UniformBlock
	Field _iuniforms:UniformBlock

	Field _skyboxShader:Shader
	
	Field _psmFaceTransforms:Mat3f[]
	
	Field _csmSize:=2048
	Field _csmSplits:=New Float[]( 1.0/64.0,1.0/16.0,1.0/4.0 )
	Field _csmSplitDepths:=New Float[5]
	Field _csmTexture:Texture
	Field _csmDepth:Texture
	Field _csmTarget:RenderTarget
	
	Field _psmSize:=2048
	Field _psmTexture:Texture
	Field _psmDepth:Texture
	Field _psmTargets:=New RenderTarget[6]

	Field _defaultEnv:Texture
	
	Field _renderQueue:=New RenderQueue
	Field _spriteQueue:=New RenderQueue
	Field _spriteBuffer:=New SpriteBuffer
	
	Field _renderScene:Scene
	Field _renderCamera:Camera
	
	Method ValidateShadowMaps()
		
		If Not _csmTexture Or _csmSize<>_csmTexture.Size.x
			
			SafeDiscard( _csmTarget )
			SafeDiscard( _csmTexture )
			SafeDiscard( _csmDepth )

			const color_format:=PixelFormat.RGBA8
			const depth_format:=PixelFormat.Depth32
			
			If _rgbaDepthTextures
				_csmTexture=New Texture( _csmSize,_csmSize,color_format,TextureFlags.Dynamic )
				_csmDepth=New Texture( _csmSize,_csmSize,depth_format,TextureFlags.Dynamic )
				_csmTarget=New RenderTarget( New Texture[]( _csmTexture ),_csmDepth )
			Else
				_csmTexture=New Texture( _csmSize,_csmSize,depth_format,TextureFlags.Dynamic )
				_csmTarget=New RenderTarget( Null,_csmTexture )
				_csmDepth=Null
			Endif
			
		Endif
		
		If Not _psmTexture Or _psmSize*2>_psmTexture.Size.x
			
			SafeDiscard( _psmTexture )
			SafeDiscard( _psmDepth )
			For Local i:=0 Until 6
				SafeDiscard( _psmTargets[i] )
			Next
			
			Local size:=_psmSize*2

			const color_format:=PixelFormat.RGBA8
			const depth_format:=PixelFormat.Depth32
			
			_psmTexture=New Texture( size,size,color_format,TextureFlags.Cubemap|TextureFlags.Dynamic )
			_psmDepth=New Texture( size,size,depth_format,TextureFlags.Dynamic )
			For Local i:=0 Until 6
				Local face:=_psmTexture.GetCubeFace( Cast<CubeFace>( i ) )
				_psmTargets[i]=New RenderTarget( New Texture[]( face ),_psmDepth )
			Next
			
			glCheck()
		
		Endif
		
	End

	Method RenderRenderOps( ops:Stack<RenderOp>,viewMatrix:AffineMat4f,projMatrix:Mat4f )
		
		_runiforms.SetMat4f( "ViewMatrix",viewMatrix )
		_runiforms.SetMat4f( "ProjectionMatrix",projMatrix )
		_runiforms.SetMat4f( "ViewProjectionMatrix",projMatrix * viewMatrix )
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
					
				_iuniforms.SetMat4f( "ModelMatrix",modelMat )
				_iuniforms.SetMat4f( "ModelViewMatrix",modelViewMat )
				_iuniforms.SetMat4f( "ModelViewProjectionMatrix",modelViewProjMat )
				_iuniforms.SetMat3f( "ModelViewNormalMatrix",modelViewNormMat )
				
				_iuniforms.SetMat4fArray( "ModelBoneMatrices",op.bones )
				
			Endif
			
			If op.material<>material
				
				material=op.material
				
				_device.Shader=material.Shader
				_device.BindUniformBlock( material.Uniforms )
				If material.BlendMode<>BlendMode.Opaque
					_device.BlendMode=material.BlendMode
				Endif
				_device.CullMode=material.CullMode
				
			Endif
			
			If op.uniforms _device.BindUniformBlock( op.uniforms )
						
			_device.VertexBuffer=op.vbuffer
			If op.ibuffer
				_device.IndexBuffer=op.ibuffer
				_device.RenderIndexed( op.order,op.count,op.first )
			Else
				_device.Render( op.order,op.count,op.first )
			Endif
			
		Next
	End

End
