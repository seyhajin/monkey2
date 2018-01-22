
Namespace mojo3d

Class Renderer

	#rem monkeydoc Creates a new renderer
	#end
	Method New()
		
		If Not _current _current=Self
		
		_direct=False
		_deferred=False
		
		Select GetConfig( "MOJO3D_RENDERER" )
		Case "deferred"
			
			_deferred=True
			
		Case "forward"
			
			_deferred=False
		
		Default
			
#If __DESKTOP_TARGET__ Or __WEB_TARGET__

			_deferred=True
#else

			_deferred=False
#endif
		End
		
		Print "GL_VERSION="+opengl.glGetString( opengl.GL_VERSION )
		
		If _deferred
			Print "Renderer is using deferred rendering"
		Else
			Print "Renderer is using forward rendering"
		Endif
	End
	
	#rem monkeydoc True if renderer is using deferred rendering.
	#end
	Property Deferred:Bool()
		
		Return _deferred
	End

	#rem monkeydoc @hidden
	#end
	Property ShaderDefs:String()
		
		Return "MX2_LINEAROUTPUT=1~n"'MX2_RGBADEPTHTEXTURES=1~n"
	End
	
	#rem monkeydoc Size of the cascaded shadow map texture.
	
	Must be a power of 2 size. Defaults to 2048.
	
	#end
	Property CSMTextureSize:Int()
		
		Return _csmSize
		
	Setter( size:Int )
		Assert( Log2( size )=Floor( Log2( size ) ),"CSMTextureSize must be a power of 2" )
		
		_csmSize=size
	End

	#rem monkeydoc Size of the cube texture used for point light shadow mapping.
	
	Must be a power of 2. Defaults to 2048.
		
	#end
	Property PSMTextureSize:Int()
		
		Return _psmSize
		
	Setter( size:Int )
		Assert( Log2( size )=Floor( Log2( size ) ),"PSMTextureSize must be a power of 2" )
		
		_psmSize=size
	End
	
	#rem monkeydoc Gets the current renderer.
	
	If there is no current renderer and new renderer is created.
		
	#end
	Function GetCurrent:Renderer()
		
		If Not _current New Renderer
			
		Return _current
	End
	
	Method Render( target:RenderTarget,targetSize:Vec2i,viewport:Recti,scene:Scene,viewMatrix:AffineMat4f,projMatrix:Mat4f,near:Float,far:Float ) Virtual
		
		Init()
		
		ValidateCSMShadows()
		
		ValidatePSMShadows()
		
		SetOutputRenderTarget( target,targetSize,viewport )

		SetScene( scene )
		
		SetCamera( viewMatrix,projMatrix,near,far )
		
		RenderBackground()
		
		RenderOpaque()
		
		RenderTransparent()
		
'		RenderSprites()
		
		RenderPostEffects()
		
		RenderCopy()
	End
	
	Method RenderBackground()
	
		If _scene.SkyTexture
		
			_gdevice.ColorMask=ColorMask.None
			_gdevice.DepthMask=True
			
			_gdevice.Clear( Null,1.0 )
			
			_gdevice.ColorMask=ColorMask.All
			_gdevice.DepthMask=False
			_gdevice.DepthFunc=DepthFunc.Always
			_gdevice.BlendMode=BlendMode.Opaque
			_gdevice.CullMode=CullMode.None
			_gdevice.Shader=_skyboxShader
			_gdevice.RenderPass=0
			
			RenderQuad()
		Else
			_gdevice.ColorMask=ColorMask.All
			_gdevice.DepthMask=True
			
			Local color:=_scene.ClearColor
			color.r=Pow( color.r,2.2 )
			color.g=Pow( color.g,2.2 )
			color.b=Pow( color.b,2.2 )
		
			_gdevice.Clear( color,1.0 )

		Endif
	End
	
	Method RenderDeferredLighting( light:Light )
		
		Local renderPass:=2
		
		Select light.Type
		Case LightType.Directional
			If light.CastsShadow RenderCSMShadows( light ) ; renderPass|=4
		Case LightType.Point
			If light.CastsShadow RenderPSMShadows( light ) ; renderPass|=4
			renderPass|=8
		End
		
		_runiforms.SetColor( "LightColor",light.Color )
		_runiforms.SetFloat( "LightRange",light.Range )
		_runiforms.SetMat4f( "LightViewMatrix",_viewMatrix * light.Matrix )
		
		_runiforms.SetMat4f( "InverseProjectionMatrix",_invProjMatrix )
		
		_gdevice.ColorMask=ColorMask.All
		_gdevice.DepthMask=False
		_gdevice.DepthFunc=DepthFunc.Always
		_gdevice.BlendMode=BlendMode.Additive
		_gdevice.RenderPass=renderPass
		
		_gdevice.Shader=_deferredLightingShader
		_gdevice.CullMode=CullMode.None
		
		_gdevice.RenderTarget=_renderTarget1
		
		RenderQuad()
		
		_gdevice.RenderTarget=_renderTarget0
	End
	
	Method RenderOpaqueDeferred()

		_gdevice.ColorMask=ColorMask.All
		_gdevice.DepthMask=True
		_gdevice.DepthFunc=DepthFunc.LessEqual
		_gdevice.BlendMode=BlendMode.Opaque
		_gdevice.RenderPass=1
		
		RenderOpaqueOps()
		
		For Local light:=Eachin _scene.Lights
			
			RenderDeferredLighting( light )
		Next
		
	End
	
	Method RenderOpaqueForward()
		
		Local first:=True
		
		For Local light:=Eachin _scene.Lights
			
			Local renderPass:=first ? 3 Else 2
			
			Select light.Type
			Case LightType.Directional			
				If light.CastsShadow RenderCSMShadows( light ) ; renderPass|=4
			Case LightType.Point
				If light.CastsShadow RenderPSMShadows( light ) ; renderPass|=4
				renderPass|=8
			End
			
			_runiforms.SetColor( "LightColor",light.Color )
			_runiforms.SetFloat( "LightRange",light.Range )
			_runiforms.SetMat4f( "LightViewMatrix",_viewMatrix * light.Matrix )

			_gdevice.ColorMask=ColorMask.All
			_gdevice.DepthMask=first
			_gdevice.DepthFunc=DepthFunc.LessEqual
			_gdevice.BlendMode=first ? BlendMode.Opaque Else BlendMode.Additive
			_gdevice.RenderPass=renderPass
			
			RenderOpaqueOps()
			
			first=False
		Next
		
		If first
			_gdevice.ColorMask=ColorMask.All
			_gdevice.DepthMask=True
			_gdevice.DepthFunc=DepthFunc.LessEqual
			_gdevice.BlendMode=BlendMode.Opaque
			_gdevice.RenderPass=1
			
			RenderOpaqueOps()
		Endif
		
	End
	
	Method RenderDeferredFog()
		
		If _scene.FogColor.a=0 Return
		
		_gdevice.ColorMask=ColorMask.All
		_gdevice.DepthMask=False
		_gdevice.DepthFunc=DepthFunc.Always
		_gdevice.BlendMode=BlendMode.Alpha
		_gdevice.RenderPass=0
		
		_gdevice.RenderTarget=_renderTarget1
		_gdevice.Shader=_deferredFogShader
		_gdevice.CullMode=CullMode.None
		
		RenderQuad()

		_gdevice.RenderTarget=_renderTarget0
	End
	
	Method RenderOpaque()
		
		If _deferred 
			RenderOpaqueDeferred()
			RenderDeferredFog()
		Else 
			RenderOpaqueForward()
		Endif
	End

	Method RenderTransparent()

		Local first:=True
		
		For Local light:=Eachin _scene.Lights
			
			Local renderPass:=first ? 3 Else 2	'amgient+light or just light
			
			Select light.Type
			Case LightType.Directional			
	'			If light.CastsShadow RenderCSMShadows( light ) ; renderPass|=4
			Case LightType.Point
	'			If light.CastsShadow RenderPSMShadows( light ) ; renderPass|=4
				renderPass|=8
			End
			
			_runiforms.SetColor( "LightColor",light.Color )
			_runiforms.SetFloat( "LightRange",light.Range )
			_runiforms.SetMat4f( "LightViewMatrix",_viewMatrix * light.Matrix )
			
			_gdevice.ColorMask=ColorMask.All
			_gdevice.DepthMask=False
			_gdevice.DepthFunc=DepthFunc.LessEqual
			_gdevice.RenderPass=renderPass
			
			RenderTransparentOps()
			
			first=False
			
			Exit
		Next
		
		If first
			_gdevice.ColorMask=ColorMask.All
			_gdevice.DepthMask=False
			_gdevice.DepthFunc=DepthFunc.LessEqual
			_gdevice.RenderPass=1
			
			RenderTransparentOps()
		Endif
		
	End
	
	Method RenderCSMShadows( light:Light )
		
		'Perhaps use a different device for CSM...?
		'
		Local t_rtarget:=_gdevice.RenderTarget
		Local t_viewport:=_gdevice.Viewport
		Local t_scissor:=_gdevice.Scissor

		_gdevice.RenderTarget=_csmTarget
		_gdevice.Viewport=New Recti( 0,0,_csmTexture.Size )
		_gdevice.Scissor=_gdevice.Viewport
		_gdevice.ColorMask=ColorMask.All
		_gdevice.DepthMask=True
		
		_gdevice.Clear( Color.White,1.0 )
		
		_gdevice.DepthFunc=DepthFunc.LessEqual
		_gdevice.BlendMode=BlendMode.Opaque
		_gdevice.CullMode=CullMode.Front
		_gdevice.RenderPass=4

		Local invLightMatrix:=light.InverseMatrix
		
		Local viewLight:=invLightMatrix * -_viewMatrix
		
		For Local i:=0 Until _csmSplitDepths.Length-1
			
			Local znear:=_csmSplitDepths[i]
			Local zfar:=_csmSplitDepths[i+1]

			Local splitProj:=_projMatrix
			splitProj.k.z=(zfar+znear)/(zfar-znear)
			splitProj.t.z=-(zfar*znear*2)/(zfar-znear)
						
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
			Case 0 _gdevice.Viewport=New Recti( 0,0,hsize.x,hsize.y )
			Case 1 _gdevice.Viewport=New Recti( hsize.x,0,size.x,hsize.y )
			Case 2 _gdevice.Viewport=New Recti( 0,hsize.y,hsize.x,size.y )
			Case 3 _gdevice.Viewport=New Recti( hsize.x,hsize.y,size.x,size.y )
			End
			
			_gdevice.Scissor=_gdevice.Viewport
				
			RenderShadowOps( invLightMatrix,lightProj )
		Next
		
		_gdevice.RenderTarget=t_rtarget
		_gdevice.Viewport=t_viewport
		_gdevice.Scissor=t_scissor
	End
	
	Method RenderPSMShadows( light:Light )
	
		'Perhaps use a different device for CSM...?
		'
		Local t_rtarget:=_gdevice.RenderTarget
		Local t_viewport:=_gdevice.Viewport
		Local t_scissor:=_gdevice.Scissor
		
		_gdevice.Viewport=New Recti( 0,0,_psmTexture.Size )
		_gdevice.Scissor=_gdevice.Viewport
		_gdevice.ColorMask=ColorMask.All
		_gdevice.DepthMask=True
		
		_gdevice.DepthFunc=DepthFunc.LessEqual
		_gdevice.BlendMode=BlendMode.Opaque
		_gdevice.CullMode=CullMode.Back'Front
		_gdevice.RenderPass=12
		
		Local lnear:=0.1
		
		Local lightProj:=Mat4f.Frustum( -lnear,+lnear,-lnear,+lnear,lnear,light.Range )
		
		Local invLightMatrix:=light.InverseMatrix
		
		Local viewLight:=invLightMatrix * _invViewMatrix
		
		_runiforms.SetFloat( "LightRange",light.Range )
		_runiforms.SetMat4f( "ShadowMatrix0",viewLight )
		
		For Local i:=0 Until 6
			
			_gdevice.RenderTarget=_psmTargets[i]
			
			_gdevice.Clear( Color.White,1.0 )
			
			Local viewMatrix:=New AffineMat4f( _psmFaceTransforms[i] ) * invLightMatrix

			RenderShadowOps( viewMatrix,lightProj )
		Next

		_gdevice.RenderTarget=t_rtarget
		_gdevice.Viewport=t_viewport
		_gdevice.Scissor=t_scissor
	End
	
	Method RenderPostEffects()
		
		_gdevice.ColorMask=ColorMask.All
		_gdevice.DepthMask=False
		_gdevice.DepthFunc=DepthFunc.Always
		_gdevice.CullMode=CullMode.None

		For Local effect:=Eachin _scene.PostEffects
			
			If Not effect.Enabled Continue
			
			_gdevice.BlendMode=BlendMode.Opaque
			_gdevice.RenderPass=0
			
			effect.Render( _gdevice )
		Next
		
	End
	
	Method RenderCopy()
		
		If _direct Return
		
		_gdevice.RenderTarget=_outputRenderTarget
		_gdevice.Resize( _outputRenderTargetSize )
		_gdevice.Viewport=_outputViewport
		_gdevice.Scissor=_outputViewport

		_gdevice.ColorMask=ColorMask.All
		_gdevice.DepthMask=False
		_gdevice.DepthFunc=DepthFunc.Always
		_gdevice.BlendMode=BlendMode.Opaque
		_gdevice.CullMode=CullMode.None
		_gdevice.Shader=_copyShader
		_gdevice.RenderPass=0
		
		RenderQuad()
		
		_gdevice.RenderTarget=Null
		_gdevice.Resize( Null )
	End

	Method RenderQuad()

		Global _vertices:=New VertexBuffer( New Vertex3f[](
			New Vertex3f( 0,1,0 ),
			New Vertex3f( 1,1,0 ),
			New Vertex3f( 1,0,0 ),
			New Vertex3f( 0,0,0 ) ) )
			
		_gdevice.VertexBuffer=_vertices
		
		_gdevice.Render( 4,1 )
	End
	
	Method SortTransparentOps()
		
		_renderQueue.TransparentOps.Sort( Lambda:Int( x:RenderOp,y:RenderOp )
		
			If y.distance<x.distance Return -1
			If x.distance<y.distance Return 1
			Return 0
		End )
	End
	
	Method SortSpriteOps()
		
		_renderQueue.SpriteOps.Sort( Lambda:Int( x:SpriteOp,y:SpriteOp )
		
			If y.distance<x.distance Return -1
			If x.distance<y.distance Return 1
			Return 0
		End )
	End

	Method RenderOpaqueOps()
		
		RenderRenderOps( _renderQueue.OpaqueOps,_viewMatrix,_projMatrix )
	End
	
	Method RenderTransparentOps()
		
		RenderRenderOps( _renderQueue.TransparentOps,_viewMatrix,_projMatrix )
	End

	Method RenderRenderOps( ops:Stack<RenderOp>,viewMatrix:AffineMat4f,projMatrix:Mat4f )
		
		Local viewProjMatrix:=projMatrix * viewMatrix
		
		_runiforms.SetMat4f( "ViewMatrix",viewMatrix )
		_runiforms.SetMat4f( "ProjectionMatrix",projMatrix )
		_runiforms.SetMat4f( "ViewProjectionMatrix",viewProjMatrix )
		_runiforms.SetMat4f( "InverseProjectionMatrix",-projMatrix )
		
		Local instance:Entity=Null,first:=True
		Local material:Material
		Local bones:Mat4f[]
		
		For Local op:=Eachin ops
			
			If op.instance<>instance Or first
				
				first=False
				
				instance=op.instance
				
				Local modelMat:=instance ? instance.Matrix Else New AffineMat4f
				Local modelViewMat:=viewMatrix * modelMat
				Local modelViewNormMat:=modelViewMat.m.Cofactor()
				Local modelViewProjMat:=projMatrix * modelViewMat
				
				_iuniforms.SetMat4f( "ModelMatrix",modelMat )
				_iuniforms.SetMat4f( "ModelViewMatrix",modelViewMat )
				_iuniforms.SetMat3f( "ModelViewNormalMatrix",modelViewNormMat )
				_iuniforms.SetMat4f( "ModelViewProjectionMatrix",modelViewProjMat )
				_iuniforms.SetFloat( "Alpha",instance ? instance.Alpha Else 1.0 )
				
			Endif
				
			If op.bones _iuniforms.SetMat4fArray( "ModelBoneMatrices",op.bones )
				
			If op.uniforms _gdevice.BindUniformBlock( op.uniforms )
						
			If op.material<>material
				
				material=op.material
				
				If op.blendMode=BlendMode.Opaque
					_gdevice.Shader=material.GetOpaqueShader()
				Else
					_gdevice.Shader=material.GetTransparentShader()
				Endif
				
				_gdevice.BindUniformBlock( material.Uniforms )
				_gdevice.CullMode=material.CullMode
				
			Endif

			_gdevice.BlendMode=op.blendMode
			
			_gdevice.VertexBuffer=op.vbuffer
			
			If op.ibuffer
				_gdevice.IndexBuffer=op.ibuffer
				_gdevice.RenderIndexed( op.order,op.count,op.first )
			Else
				_gdevice.Render( op.order,op.count,op.first )
			Endif
			
		Next
	End
	
	Method RenderShadowOps( viewMatrix:AffineMat4f,projMatrix:Mat4f )
		
		Local ops:=_renderQueue.ShadowOps
		
		Local viewProjMatrix:=projMatrix * viewMatrix
		
		_runiforms.SetMat4f( "ViewMatrix",viewMatrix )
		_runiforms.SetMat4f( "ProjectionMatrix",projMatrix )
		_runiforms.SetMat4f( "ViewProjectionMatrix",viewProjMatrix )
		_runiforms.SetMat4f( "InverseProjectionMatrix",-projMatrix )
		
		Local instance:Entity=Null,first:=True
		Local material:Material
		Local bones:Mat4f[]
		
		For Local op:=Eachin ops
			
			If op.instance<>instance Or first
				first=False
				instance=op.instance
				Local modelMat:=instance ? instance.Matrix Else New AffineMat4f
				Local modelViewMat:=viewMatrix * modelMat
				Local modelViewNormMat:=modelViewMat.m.Cofactor()
				Local modelViewProjMat:=projMatrix * modelViewMat
				_iuniforms.SetMat4f( "ModelMatrix",modelMat )
				_iuniforms.SetMat4f( "ModelViewMatrix",modelViewMat )
				_iuniforms.SetMat3f( "ModelViewNormalMatrix",modelViewNormMat )
				_iuniforms.SetMat4f( "ModelViewProjectionMatrix",modelViewProjMat )
			Endif
				
			If op.bones _iuniforms.SetMat4fArray( "ModelBoneMatrices",op.bones )
			
			If op.uniforms _gdevice.BindUniformBlock( op.uniforms )
						
			If op.material<>material
				material=op.material
				_gdevice.Shader=material.GetShadowShader()
				_gdevice.BindUniformBlock( material.Uniforms )
			Endif
			
			_gdevice.VertexBuffer=op.vbuffer
			
			If op.ibuffer
				_gdevice.IndexBuffer=op.ibuffer
				_gdevice.RenderIndexed( op.order,op.count,op.first )
			Else
				_gdevice.Render( op.order,op.count,op.first )
			Endif
			
		Next

	End
	
	Private
	
	Field _direct:Bool=False
	Field _deferred:Bool=True
	
	Field _gdevice:GraphicsDevice
	
	Field _runiforms:UniformBlock
	Field _iuniforms:UniformBlock
	
	Field _defaultEnv:Texture
	
	Field _skyboxShader:Shader
	Field _copyShader:Shader
	
	Field _deferredLightingShader:Shader
	Field _deferredFogShader:Shader
	
	Field _renderQueue:RenderQueue
	
	Field _spriteBuffer:=New SpriteBuffer
	
	Field _accumBuffer:Texture
	Field _colorBuffer:Texture
	Field _normalBuffer:Texture
	Field _depthBuffer:Texture

	Field _renderTarget0:RenderTarget	'all buffers
	Field _renderTarget1:RenderTarget	'accum buffer only
	
	Field _csmSize:=2048
	Field _csmSplits:Float[]
	Field _csmSplitDepths:=New Float[5]
	Field _csmTexture:Texture
	Field _csmDepth:Texture
	Field _csmTarget:RenderTarget

	Field _psmSize:=2048
	Field _psmTexture:Texture
	Field _psmDepth:Texture
	Field _psmTargets:=New RenderTarget[6]
	Field _psmFaceTransforms:Mat3f[]
	
	Field _outputRenderTarget:RenderTarget
	Field _outputRenderTargetSize:Vec2i
	Field _outputViewport:Recti
	
	Field _scene:Scene
	
	Field _viewMatrix:AffineMat4f
	Field _projMatrix:Mat4f
	Field _near:Float
	Field _far:Float
	
	Field _invViewMatrix:AffineMat4f
	Field _invProjMatrix:Mat4f
	
	Field _ambientRendered:Bool

	Global _current:Renderer
	
	Method Init()
		
		Global inited:Bool
		If inited Return
		inited=True
		
		_gdevice=New GraphicsDevice( 0,0 )
		
		_runiforms=New UniformBlock( 1,True )
		_iuniforms=New UniformBlock( 2,True )
		
		_gdevice.BindUniformBlock( _runiforms )
		_gdevice.BindUniformBlock( _iuniforms )
		
		_defaultEnv=Texture.Load( "asset::textures/env_default.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		_copyShader=Shader.Open( "copy" )
		
		If _deferred 
			_skyboxShader=Shader.Open( "skybox-deferred",ShaderDefs )
			_deferredLightingShader=Shader.Open( "lighting-deferred",ShaderDefs )
			_deferredFogShader=Shader.Open( "fog-deferred",ShaderDefs )
		Else
			_skyboxShader=Shader.Open( "skybox",ShaderDefs )
		Endif
		
		_renderQueue=New RenderQueue
		
		_psmFaceTransforms=New Mat3f[]( 
			New Mat3f(  0,0,+1, 0,-1,0, -1, 0,0 ),	'+X
			New Mat3f(  0,0,-1, 0,-1,0, +1, 0,0 ),	'-X
			New Mat3f( +1,0, 0, 0,0,+1,  0,+1,0 ),	'+Y
			New Mat3f( +1,0, 0, 0,0,-1,  0,-1,0 ),	'-Y
			New Mat3f( +1,0, 0, 0,-1,0,  0,0,+1 ),	'+Z
			New Mat3f( -1,0, 0, 0,-1,0,  0,0,-1 ) )	'-Z
			
		ValidateSize( New Vec2i( 1920,1080 ) )
	End

	Method ValidateSize( size:Vec2i )
		
		If _direct Return
		
		If _accumBuffer And size.x<=_accumBuffer.Size.x And size.y<=_accumBuffer.Size.y Return
		
		_accumBuffer?.Discard()
		_depthBuffer?.Discard()
		_renderTarget0?.Discard()
		_renderTarget1?.Discard()

		#If Not __MOBILE_TARGET__
		Const color_format:=PixelFormat.RGBA32F
		Const depth_format:=PixelFormat.Depth32
		#Else
		Const color_format:=PixelFormat.RGBA8
		Const depth_format:=PixelFormat.Depth32
		#Endif
		
		If _deferred
		
			_accumBuffer=New Texture( size.x,size.y,color_format,TextureFlags.Dynamic|TextureFlags.Filter )
			_colorBuffer=New Texture( size.x,size.y,color_format,TextureFlags.Dynamic|TextureFlags.Filter )
			_normalBuffer=New Texture( size.x,size.y,color_format,TextureFlags.Dynamic|TextureFlags.Filter )
			_depthBuffer=New Texture( size.x,size.y,depth_format,TextureFlags.Dynamic )
			
			_renderTarget0=New RenderTarget( New Texture[]( _accumBuffer,_colorBuffer,_normalBuffer ),_depthBuffer )
			_renderTarget1=New RenderTarget( New Texture[]( _accumBuffer ),Null )

			_runiforms.SetTexture( "AccumBuffer",_accumBuffer )
			_runiforms.SetTexture( "ColorBuffer",_colorBuffer )
			_runiforms.SetTexture( "NormalBuffer",_normalBuffer )
			_runiforms.SetTexture( "DepthBuffer",_depthBuffer )
		Else
			
			_accumBuffer=New Texture( size.x,size.y,color_format,TextureFlags.Dynamic|TextureFlags.Filter )
			_depthBuffer=New Texture( size.x,size.y,depth_format,TextureFlags.Dynamic )
			
			_renderTarget0=New RenderTarget( New Texture[]( _accumBuffer ),_depthBuffer )
			_renderTarget1=New RenderTarget( New Texture[]( _accumBuffer ),Null )

			_runiforms.SetTexture( "AccumBuffer",_accumBuffer )
			_runiforms.SetTexture( "DepthBuffer",_depthBuffer )
		Endif
		
	End
	
	Method ValidateCSMShadows()
		
		If Not _csmTexture Or _csmSize*2<>_csmTexture.Size.x
			
			_csmTarget?.Discard()
			_csmTexture?.Discard()
			_csmDepth?.Discard()

			const depth_format:=PixelFormat.Depth32
			
			_csmTexture=New Texture( _csmSize*2,_csmSize*2,depth_format,TextureFlags.Dynamic )'|TextureFlags.Filter )
			_csmTarget=New RenderTarget( Null,_csmTexture )
			_csmDepth=Null
			
			_runiforms.SetTexture( "ShadowCSMTexture",_csmTexture )
		Endif
		
	End

	Method ValidatePSMShadows()
		
		If Not _psmTexture Or _psmSize<>_psmTexture.Size.x
			
			_psmTexture?.Discard()
			_psmDepth?.Discard()
			For Local i:=0 Until 6
				_psmTargets[i]?.Discard()
			Next
			
			const color_format:=PixelFormat.RGBA8
			const depth_format:=PixelFormat.Depth32
			
			_psmTexture=New Texture( _psmSize,_psmSize,color_format,TextureFlags.Cubemap|TextureFlags.Dynamic )
			_psmDepth=New Texture( _psmSize,_psmSize,depth_format,TextureFlags.Dynamic )
			For Local i:=0 Until 6
				Local face:=_psmTexture.GetCubeFace( Cast<CubeFace>( i ) )
				_psmTargets[i]=New RenderTarget( New Texture[]( face ),_psmDepth )
			Next
			
			_runiforms.SetTexture( "ShadowCubeTexture",_psmTexture )
		Endif
		
	End
	
	Method SetOutputRenderTarget( renderTarget:RenderTarget,renderTargetSize:Vec2i,viewport:Recti )
		
		_outputRenderTarget=renderTarget
		_outputRenderTargetSize=renderTargetSize
		_outputViewport=viewport
		
		ValidateSize( viewport.Size )

		If _direct
			_gdevice.RenderTarget=renderTarget
			_gdevice.Resize( renderTargetSize )
			_gdevice.Viewport=viewport
			_gdevice.Scissor=viewport
			Return
		Endif
		
		_gdevice.RenderTarget=_renderTarget0
		_gdevice.Viewport=New Recti( 0,0,viewport.Size )
		_gdevice.Scissor=_gdevice.Viewport
	
		_runiforms.SetVec2f( "BufferCoordScale",Cast<Vec2f>( viewport.Size )/Cast<Vec2f>( _accumBuffer.Size ) )
	End
	
	Method SetScene( scene:Scene )
		
		_scene=scene
		
		_runiforms.SetTexture( "SkyTexture",_scene.SkyTexture )
		_runiforms.SetColor( "ClearColor",_scene.ClearColor )
		_runiforms.SetColor( "AmbientDiffuse",_scene.AmbientLight )
		
		Local env:Texture
		
		If _scene.EnvTexture
			env=_scene.EnvTexture
		ElseIf _scene.SkyTexture
			env=_scene.SkyTexture
		Else
			env=_defaultEnv
		Endif
		
		_runiforms.SetTexture( "EnvTexture",env )
		_runiforms.SetFloat( "EnvTextureMaxLod",Log2( env.Size.x ) )
		_runiforms.SetColor( "EnvColor",_scene.EnvColor )
		
		_runiforms.SetColor( "FogColor",_scene.FogColor )
		_runiforms.SetFloat( "FogNear",_scene.FogNear )
		_runiforms.SetFloat( "FogFar",_scene.FogFar )
		
		_runiforms.SetFloat( "ShadowAlpha",_scene.ShadowAlpha )
		
		_csmSplits=_scene.CSMSplits
		
	End
	
	Method SetCamera( viewMatrix:AffineMat4f,projMatrix:Mat4f,near:Float,far:Float )
		
		_viewMatrix=viewMatrix
		_projMatrix=projMatrix
		_near=near
		_far=far
		
		_invViewMatrix=-_viewMatrix
		_invProjMatrix=-_projMatrix

		_runiforms.SetMat3f( "EnvMatrix",_invViewMatrix.m )
		_runiforms.SetMat4f( "ProjectionMatrix",_projMatrix )
		_runiforms.SetMat4f( "InverseProjectionMatrix",_invProjMatrix )
		_runiforms.SetMat4f( "ViewMatrix",_viewMatrix )
		_runiforms.SetMat4f( "CameraMatrix",_invViewMatrix )
		_runiforms.SetFloat( "DepthNear",_near )
		_runiforms.SetFloat( "DepthFar",_far )
		
		_csmSplitDepths[0]=_near
		
		For Local i:=1 Until 5
			_csmSplitDepths[i]=Min( _csmSplitDepths[i-1]+_csmSplits[i-1],_far )
		Next
		
		_runiforms.SetVec4f( "ShadowCSMSplits",New Vec4f( _csmSplitDepths[1],_csmSplitDepths[2],_csmSplitDepths[3],_csmSplitDepths[4] ) )
		
		_renderQueue.Clear()
		
		Local time:=Float( Now() )

		_renderQueue.Time=time
		
		_runiforms.SetFloat( "Time",time )
		
		_renderQueue.EyePos=_invViewMatrix.t
		
		For Local r:=Eachin _scene.Renderables
		
			_renderQueue.CastsShadow=r.CastsShadow
			
			r.OnRender( _renderQueue )
		Next
		
		SortTransparentOps()
		
		SortSpriteOps()
		
		_spriteBuffer.InsertRenderOps( _renderQueue,_invViewMatrix )
	End
	
End
