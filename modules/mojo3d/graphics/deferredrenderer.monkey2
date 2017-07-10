
Namespace mojo3d.graphics

Private

Const WIDTH:=1920
Const HEIGHT:=1080
'Const MRT_COLOR_FORMAT:=PixelFormat.RGBA8		'8 bit
Const MRT_COLOR_FORMAT:=PixelFormat.RGBA32F		'32 bit float

Public

#rem monkeydoc @hidden The DeferredRenderer class.
#end
Class DeferredRenderer Extends Renderer
	
	Method New()
	
		Local size:=New Vec2i( WIDTH,HEIGHT )
	
		_copyShader=Shader.Open( "copy" )
		_plightShader=Shader.Open( "point-light" )
		_dlightShader=Shader.Open( "directional-light" )
		
		_hdrTexture=New Texture( size.x,size.y,MRT_COLOR_FORMAT,TextureFlags.Filter|TextureFlags.Dynamic )			'output hdr image
		_colorTexture=New Texture( size.x,size.y,MRT_COLOR_FORMAT,TextureFlags.Filter|TextureFlags.Dynamic )		'metalness in 'a'
		_normalTexture=New Texture( size.x,size.y,MRT_COLOR_FORMAT,TextureFlags.Filter|TextureFlags.Dynamic )		'roughness in 'a'
		_depthTexture=New Texture( size.x,size.y,PixelFormat.Depth32F,TextureFlags.Dynamic )
		
		_rpass0Target=New RenderTarget( New Texture[]( _hdrTexture,_colorTexture,_normalTexture ),_depthTexture )
		_rpass2Target=New RenderTarget( New Texture[]( _hdrTexture ),Null )
		
		'_uniforms.SetTexture( "HdrTexture",_hdrTexture )
		
		_uniforms.SetTexture( "ColorBuffer",_colorTexture )
		_uniforms.SetTexture( "NormalBuffer",_normalTexture )
		_uniforms.SetTexture( "DepthBuffer",_depthTexture )
	End

	Protected
	
	Method OnRender() Override
		
		_device.RenderTarget=_rpass0Target
		_device.Viewport=New Recti( 0,0,_renderViewport.Size )
		_device.Scissor=_device.Viewport

		RenderBackground()
		
		RenderAmbient()

		_device.RenderTarget=_rpass2Target
		
		_uniforms.SetVec2f( "BufferCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( _hdrTexture.Size ) )
		
		For Local light:=Eachin _scene.Lights
			
			If light.Type=LightType.Point Continue
			
			RenderCSMShadows( light )
			
			RenderLight( light )
		Next
		
		RenderSprites()

		RenderEffects()
		
		RenderCopy()
	End
	
	Method RenderLight( light:Light )
	
		_uniforms.SetVec4f( "LightColor",light.Color )
		_uniforms.SetFloat( "LightRange",light.Range )
		_uniforms.SetMat4f( "LightViewMatrix",_camera.InverseWorldMatrix * light.WorldMatrix )
		
		_uniforms.SetMat4f( "InverseProjectionMatrix",-_camera.ProjectionMatrix )
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.BlendMode=BlendMode.Additive
		_device.CullMode=CullMode.None
		_device.RenderPass=3
		
		Select light.Type
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
	
	Method RenderEffects()
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.CullMode=CullMode.None

		_device.VertexBuffer=_quadVertices
		
		For Local effect:=Eachin _scene.PostEffects
			
			If Not effect.Enabled Continue
			
			_device.BlendMode=BlendMode.Opaque
			_device.RenderPass=0
			
			effect.Render( _device )
		Next
		
	End
	
	Method RenderCopy()
		
		Local source:=_device.RenderTarget.GetColorTexture( 0 )
		
		_uniforms.SetTexture( "SourceTexture",source )
		_uniforms.SetVec2f( "SourceCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( source.Size ) )

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
	
	Private
	
	Field _copyShader:Shader
	Field _plightShader:Shader
	Field _dlightShader:Shader
	
	Field _hdrTexture:Texture		'contains output linear HDR color
	Field _colorTexture:Texture		'contains surface color/M
	Field _normalTexture:Texture	'contains surface normal/R
	Field _depthTexture:Texture		'contains surface depth
	Field _shadowTexture:Texture
	
	Field _rpass0Target:RenderTarget
	Field _rpass2Target:RenderTarget
	
End
