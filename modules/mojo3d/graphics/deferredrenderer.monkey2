
Namespace mojo3d.graphics

#rem

Material render passes:

1 : opaque ambient

4 : opaque shadow depth

#end

#rem monkeydoc The DeferredRenderer class.
#end
Class DeferredRenderer Extends Renderer

	#rem monkeydoc @hidden
	#end
	Method New()
		Super.New( True )
		
		Print "Creating DeferredRenderer"
	
		_lightShader=Shader.Open( "lighting-deferred",ShaderDefs )
		_copyShader=Shader.Open( "copy" )
		
	End

	Protected

	Method OnValidateSize( size:Vec2i ) Override
		
		If Not _hdrTexture Or size.x>_hdrTexture.Size.x Or size.y>_hdrTexture.Size.y
		
			SafeDiscard( _hdrTexture )
			SafeDiscard( _colorTexture )
			SafeDiscard( _normalTexture )
			SafeDiscard( _depthTexture )
			SafeDiscard( _rpass0Target )
			SafeDiscard( _rpass2Target )
		
			'look at this again later - surely we can rgba32f on some mobile targets, eg: nvidia shield?
			#If Not __MOBILE_TARGET__
			Const color_format:=PixelFormat.RGBA32F
			Const depth_format:=PixelFormat.Depth32
			#Else
			Const color_format:=PixelFormat.RGBA8
			Const depth_format:=PixelFormat.Depth32
			#Endif
				
			_hdrTexture=New Texture( size.x,size.y,color_format,TextureFlags.Filter|TextureFlags.Dynamic )		'output hdr image
			_colorTexture=New Texture( size.x,size.y,color_format,TextureFlags.Filter|TextureFlags.Dynamic )		'metalness in 'a'
			_normalTexture=New Texture( size.x,size.y,color_format,TextureFlags.Filter|TextureFlags.Dynamic )		'roughness in 'a'
			_depthTexture=New Texture( size.x,size.y,depth_format,TextureFlags.Dynamic )
				
			_rpass0Target=New RenderTarget( New Texture[]( _hdrTexture,_colorTexture,_normalTexture ),_depthTexture )
			_rpass2Target=New RenderTarget( New Texture[]( _hdrTexture ),Null )
			
			_runiforms=RenderUniforms
				
			_runiforms.SetTexture( "ColorBuffer",_colorTexture )
			_runiforms.SetTexture( "NormalBuffer",_normalTexture )
			_runiforms.SetTexture( "DepthBuffer",_depthTexture )
			
		Endif
	
	End

	Method OnRender( scene:Scene,camera:Camera,device:GraphicsDevice ) Override
	
		_device=Device
		_runiforms=RenderUniforms
		_renderTarget=device.RenderTarget
		_renderTargetSize=device.RenderTargetSize
		_renderViewport=device.Viewport
	
		_device.RenderTarget=_rpass0Target
		_device.Viewport=New Recti( 0,0,_renderViewport.Size )
		_device.Scissor=_device.Viewport

		RenderBackground()
		
		RenderOpaque()

		_device.RenderTarget=_rpass2Target
		
		_runiforms.SetVec2f( "BufferCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( _hdrTexture.Size ) )
		
		'directional with shadows
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Directional Or Not light.CastsShadow Continue
			
			RenderLight( light,camera )
		Next
		
		'point with shadows (not supported yet)
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Point Or Not light.CastsShadow Continue
			
			RenderLight( light,camera )
		Next
		
		'directional without  shadows
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Directional Or light.CastsShadow Continue

			RenderLight( light,camera )
		Next
		
		'point without shadows
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Point Or light.CastsShadow Continue

			RenderLight( light,camera )
		Next
		
		_device.RenderTarget=_rpass0Target
		
		RenderSprites()

		_device.RenderTarget=_rpass2Target

		RenderEffects( scene )
		
		_device.RenderTarget=_renderTarget
		_device.Resize( _renderTargetSize )
		_device.Viewport=_renderViewport
		_device.Scissor=_device.Viewport

		RenderCopy()
	End
		
	Private
	
	Field _lightShader:Shader
	Field _copyShader:Shader
	
	Field _hdrTexture:Texture		'contains output linear HDR color
	Field _colorTexture:Texture		'contains surface color/M
	Field _normalTexture:Texture	'contains surface normal/R
	Field _depthTexture:Texture		'contains surface depth
	Field _rpass0Target:RenderTarget
	Field _rpass2Target:RenderTarget
	
	Field _device:GraphicsDevice
	Field _runiforms:UniformBlock
	Field _renderTarget:RenderTarget
	Field _renderTargetSize:Vec2i
	Field _renderViewport:Recti
	
	Method RenderOpaque()
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=True
		_device.DepthFunc=DepthFunc.LessEqual
		_device.BlendMode=BlendMode.Opaque
		_device.RenderPass=0

		Super.RenderOpaqueOps()
	End
	
	Method RenderSprites()

		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.LessEqual
		_device.RenderPass=0
		
		Super.RenderSpriteOps()
	End
	
	Method RenderLight( light:Light,camera:Camera )
		
		Local pass:=0
		
		Select light.Type
		Case LightType.Directional
			If light.CastsShadow RenderCSMShadows( light ) ; pass|=2
		Case LightType.Point
			If light.CastsShadow RenderPointShadows( light ) ; pass|=2
			pass|=1
		End
	
		_runiforms.SetColor( "LightColor",light.Color )
		_runiforms.SetFloat( "LightRange",light.Range )
		_runiforms.SetMat4f( "LightViewMatrix",camera.InverseMatrix * light.Matrix )
		
		_runiforms.SetMat4f( "InverseProjectionMatrix",-camera.ProjectionMatrix )
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.BlendMode=BlendMode.Additive
		_device.CullMode=CullMode.None
		_device.Shader=_lightShader
		_device.RenderPass=pass
		RenderQuad()

	End

	Method RenderEffects( scene:Scene )
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.CullMode=CullMode.None

		For Local effect:=Eachin scene.PostEffects
			
			If Not effect.Enabled Continue
			
			_device.BlendMode=BlendMode.Opaque
			_device.RenderPass=0
			
			effect.Render( _device )
		Next
		
	End
	
	Method RenderCopy()
	
		_runiforms.SetTexture( "SourceTexture",_hdrTexture )
		_runiforms.SetVec2f( "SourceCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( _hdrTexture.Size ) )

		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.BlendMode=BlendMode.Opaque
		_device.CullMode=CullMode.None
		_device.Shader=_copyShader
		_device.RenderPass=0

		Super.RenderQuad()
		
		_device.RenderTarget=Null
		_device.Resize( Null )
	End

End
