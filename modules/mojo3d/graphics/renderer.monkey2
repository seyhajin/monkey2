
Namespace mojo3d.graphics

#rem

Renderpasses:

1 : opaque ambient

2 : opaque shadow depth

3 : transparent

#end

#rem monkeydoc @hidden
#end
Class RenderOp
	Field material:Material
	Field vbuffer:VertexBuffer
	Field ibuffer:IndexBuffer
	Field instance:Entity
	Field bones:Mat4f[]
	Field order:Int
	Field count:Int
	Field first:Int
End

#rem monkeydoc @hidden
#end
Class RenderQueue
	
	Property OpaqueOps:Stack<RenderOp>()
		
		Return _opaqueOps
	End
	
	Property TransparentOps:Stack<RenderOp>()
	
		Return _transparentOps
	End
	
	Property ShadowOps:Stack<RenderOp>()
		
		Return _shadowOps
	End
	
	Property AddShadowOps:Bool()
		
		Return _addShadowOps
		
	Setter( addShadowOps:Bool )
		
		_addShadowOps=addShadowOps
	End
	
	Method Clear()
		
		_opaqueOps.Clear()
		_shadowOps.Clear()
		_transparentOps.Clear()
	End
	
	Method AddRenderOp( op:RenderOp )
		
		If op.material.BlendMode<>BlendMode.Opaque
			_transparentOps.Push( op )
		Else
			_opaqueOps.Push( op )
		Endif
		
		If _addShadowOps _shadowOps.Push( op )
	End
	
	Method AddRenderOp( material:Material,vbuffer:VertexBuffer,ibuffer:IndexBuffer,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Method AddRenderOp( material:Material,vbuffer:VertexBuffer,ibuffer:IndexBuffer,instance:Entity,order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.instance=instance
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Method AddRenderOp( material:Material,vbuffer:VertexBuffer,ibuffer:IndexBuffer,instance:Entity,bones:Mat4f[],order:Int,count:Int,first:Int )
		Local op:=New RenderOp
		op.material=material
		op.vbuffer=vbuffer
		op.ibuffer=ibuffer
		op.instance=instance
		op.bones=bones
		op.order=order
		op.count=count
		op.first=first
		AddRenderOp( op )
	End
	
	Private
	
	Field _opaqueOps:=New Stack<RenderOp>
	Field _transparentOps:=New Stack<RenderOp>
	Field _shadowOps:=New Stack<RenderOp>
	
	Field _addShadowOps:Bool
End

#rem monkeydoc The Renderer class.
#end
Class Renderer

	#rem monkeydoc @hidden
	#end
	Method New()
	
		_device=New GraphicsDevice( 0,0 )
		
		_runiforms=New UniformBlock( 1 )
		_iuniforms=New UniformBlock( 2 )
		
		_device.BindUniformBlock( _runiforms )
		_device.BindUniformBlock( _iuniforms )

		_csmSplits=New Float[]( 1,20,60,180,1000 )

		_quadVertices=New VertexBuffer( New Vertex3f[](
			New Vertex3f( 0,1,0 ),
			New Vertex3f( 1,1,0 ),
			New Vertex3f( 1,0,0 ),
			New Vertex3f( 0,0,0 ) ) )
			
		_defaultEnv=Texture.Load( "asset::textures/env_default.jpg",TextureFlags.FilterMipmap|TextureFlags.Cubemap )
		
		_skyboxShader=Shader.Open( "skybox" )
		_plightShader=Shader.Open( "point-light" )
		_dlightShader=Shader.Open( "directional-light" )
		_copyShader=Shader.Open( "copy" )

		For Local i:=0 Until _nullBones.Length
			_nullBones[i]=New Mat4f
		Next
	End
	
	#rem monkeydoc Size of the cascading shadow map texture.
	
	Must be a power of 2 size.
	
	Defaults to 4096.
		
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
		
		Global _current:=New Renderer
		
		Return _current
	End
	
	#rem monkeydoc @hidden
	#end
	Method Render( scene:Scene,camera:Camera,device:GraphicsDevice )
		
		_renderTarget=device.RenderTarget
		_renderTargetSize=device.RenderTargetSize
		_renderViewport=device.Viewport
		
		ValidateSize( _renderViewport.Size )
		
		_renderScene=scene

		_runiforms.SetFloat( "Time",Now() )
		_runiforms.SetTexture( "SkyTexture",_renderScene.SkyTexture )
		
		_runiforms.SetVec4f( "ClearColor",_renderScene.ClearColor )
		_runiforms.SetVec4f( "AmbientDiffuse",_renderScene.AmbientLight )
	
		_runiforms.SetTexture( "ShadowTexture",_csmTexture )
		_runiforms.SetVec4f( "ShadowSplits",New Vec4f( _csmSplits[1],_csmSplits[2],_csmSplits[3],_csmSplits[4] ) )
		
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
		
		OnRender()
		
		_renderCamera=Null
		
		_renderScene=null
	End
	
	'***** INTERNAL *****
	
	Protected
	
	Field _device:GraphicsDevice
	Field _runiforms:UniformBlock
	Field _iuniforms:UniformBlock
	
	Field _csmSize:=4096
	Field _csmSplits:=New Float[]( 1,20,60,180,1000 )
	Field _csmTexture:Texture
	Field _csmTarget:RenderTarget
	Field _quadVertices:VertexBuffer
	Field _skyboxShader:Shader
	Field _plightShader:Shader
	Field _dlightShader:Shader
	Field _copyShader:Shader

	Field _defaultEnv:Texture
	
	Field _hdrTexture:Texture		'contains output linear HDR color
	Field _colorTexture:Texture		'contains surface color/M
	Field _normalTexture:Texture	'contains surface normal/R
	Field _depthTexture:Texture		'contains surface depth
	Field _rpass0Target:RenderTarget
	Field _rpass2Target:RenderTarget
	
	Field _renderQueue:=New RenderQueue
	Field _spriteQueue:=New RenderQueue
	Field _spriteBuffer:=New SpriteBuffer
	
	Field _nullBones:=New Mat4f[96]
	
	Field _renderTarget:RenderTarget
	Field _renderTargetSize:Vec2i
	Field _renderViewport:Recti
	Field _renderScene:Scene
	Field _renderCamera:Camera
	Field _renderLight:Light

	Method ValidateSize( size:Vec2i )
		
		size.x=Max( size.x,1920 )
		size.y=Max( size.y,1080 )
		
		If Not _hdrTexture Or size.x>_hdrTexture.Size.x Or size.y>_hdrTexture.Size.y
		
			SafeDiscard( _hdrTexture )
			SafeDiscard( _colorTexture )
			SafeDiscard( _normalTexture )
			SafeDiscard( _depthTexture )
			SafeDiscard( _rpass0Target )
			SafeDiscard( _rpass2Target )
	
			Const format:=PixelFormat.RGBA32F		'32 bit float
			
			_hdrTexture=New Texture( size.x,size.y,format,TextureFlags.Filter|TextureFlags.Dynamic )		'output hdr image
			_colorTexture=New Texture( size.x,size.y,format,TextureFlags.Filter|TextureFlags.Dynamic )		'metalness in 'a'
			_normalTexture=New Texture( size.x,size.y,format,TextureFlags.Filter|TextureFlags.Dynamic )		'roughness in 'a'
			_depthTexture=New Texture( size.x,size.y,PixelFormat.Depth32F,TextureFlags.Dynamic )
			
			_rpass0Target=New RenderTarget( New Texture[]( _hdrTexture,_colorTexture,_normalTexture ),_depthTexture )
			_rpass2Target=New RenderTarget( New Texture[]( _hdrTexture ),Null )
			
			_runiforms.SetTexture( "ColorBuffer",_colorTexture )
			_runiforms.SetTexture( "NormalBuffer",_normalTexture )
			_runiforms.SetTexture( "DepthBuffer",_depthTexture )
		
		Endif

		If Not _csmTexture Or _csmSize<>_csmTexture.Size.x
			
			SafeDiscard( _csmTexture )
			SafeDiscard( _csmTarget )
			
			_csmTexture=New Texture( _csmSize,_csmSize,PixelFormat.Depth32F,TextureFlags.Dynamic )
			_csmTarget=New RenderTarget( Null,_csmTexture )
			
		Endif
		
	End

	Method OnRender()
		
		_device.RenderTarget=_rpass0Target
		_device.Viewport=New Recti( 0,0,_renderViewport.Size )
		_device.Scissor=_device.Viewport

		RenderBackground()
		
		RenderAmbient()

		_device.RenderTarget=_rpass2Target
		
		_runiforms.SetVec2f( "BufferCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( _hdrTexture.Size ) )
		
		For Local light:=Eachin _renderScene.Lights
			
			If light.Type=LightType.Point Continue

			_renderLight=light
			
			RenderCSMShadows()
			
			RenderLight()
		Next
		
		_renderLight=null
		
		_device.RenderTarget=_rpass0Target
		
		RenderSprites()

		_device.RenderTarget=_rpass2Target

		RenderEffects()
		
		RenderCopy()
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
			_device.RenderPass=0
			
			_device.VertexBuffer=_quadVertices
			_device.Shader=_skyboxShader
			_device.Render( 4,1 )
			
		Else
			_device.ColorMask=ColorMask.All
			_device.DepthMask=True
		
			_device.Clear( _renderScene.ClearColor,1.0 )

		Endif
		
	End
	
	Method RenderAmbient()
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=True
		_device.DepthFunc=DepthFunc.LessEqual
		_device.RenderPass=1
		
		RenderRenderOps( _renderQueue.OpaqueOps,_renderCamera.InverseMatrix,_renderCamera.ProjectionMatrix )
	End
	
	Method RenderCSMShadows()
	
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
		_device.RenderPass=2

		Local invLightMatrix:=_renderLight.InverseMatrix
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
				
			If _renderLight.ShadowsEnabled
				RenderRenderOps( _renderQueue.ShadowOps,invLightMatrix,lightProj )
			Endif
			
		Next
		
		_device.RenderTarget=t_rtarget
		_device.Viewport=t_viewport
		_device.Scissor=t_scissor
	End
	
	Method RenderLight()
	
		_runiforms.SetVec4f( "LightColor",_renderLight.Color )
		_runiforms.SetFloat( "LightRange",_renderLight.Range )
		_runiforms.SetMat4f( "LightViewMatrix",_renderCamera.InverseMatrix * _renderLight.Matrix )
		
		_runiforms.SetMat4f( "InverseProjectionMatrix",-_renderCamera.ProjectionMatrix )
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.BlendMode=BlendMode.Additive
		_device.CullMode=CullMode.None
		_device.RenderPass=3
		
		Select _renderLight.Type
		Case LightType.Directional
		
			_device.Shader=_dlightShader
			_device.VertexBuffer=_quadVertices
			_device.Render( 4,1,0 )
		
		Case LightType.Point

			_device.Shader=_plightShader
			_device.VertexBuffer=_quadVertices
			_device.Render( 4,1,0 )
		End

	End

	Method RenderSprites()
	
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.LessEqual
		_device.RenderPass=0

		RenderRenderOps( _spriteQueue.TransparentOps,_renderCamera.InverseMatrix,_renderCamera.ProjectionMatrix )
	End
	
	Method RenderEffects()
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.CullMode=CullMode.None

		_device.VertexBuffer=_quadVertices
		
		For Local effect:=Eachin _renderScene.PostEffects
			
			If Not effect.Enabled Continue
			
			_device.BlendMode=BlendMode.Opaque
			_device.RenderPass=0
			
			effect.Render( _device )
		Next
		
	End
	
	Method RenderCopy()
		
		Local source:=_device.RenderTarget.GetColorTexture( 0 )
		
		_runiforms.SetTexture( "SourceTexture",source )
		_runiforms.SetVec2f( "SourceCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( source.Size ) )

		_device.RenderTarget=_renderTarget
		_device.Resize( _renderTargetSize )
		_device.Viewport=_renderViewport
		_device.Scissor=_device.Viewport
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.BlendMode=BlendMode.Opaque
		_device.CullMode=CullMode.None
		_device.RenderPass=0
		
		_device.VertexBuffer=_quadVertices
		_device.Shader=_copyShader
		
		_device.Render( 4,1 )
		
		_device.RenderTarget=Null
		_device.Resize( Null )
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
				_device.BlendMode=material.BlendMode
				_device.CullMode=material.CullMode
				
			Endif
			
			_device.VertexBuffer=op.vbuffer
			_device.IndexBuffer=op.ibuffer
			_device.RenderIndexed( op.order,op.count,op.first )
			
		Next
	End

End
