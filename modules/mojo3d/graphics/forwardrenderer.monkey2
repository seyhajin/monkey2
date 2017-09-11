
Namespace mojo3d.graphics

#rem

Render passes:

1 : opaque ambient only

2 : opaque lighting only

3 : opaque ambient + lighting

4 : shadow caster depth only

#end

#rem monkeydoc The ForwardRenderer class.
#end
Class ForwardRenderer Extends Renderer

	#rem monkeydoc @hidden
	#end
	Method New( direct:Bool )
		Super.New( Not direct )
		
		_direct=direct
		
		Print "Creating ForwardRenderer, direct="+Int( _direct )
		
		If Not _direct _copyShader=Shader.Open( "copy" )
	End
	
	Protected
	
	Method OnValidateSize( size:Vec2i ) Override 
		
		If _direct Return

		If Not _colorBuffer Or size.x>_colorBuffer.Size.x Or size.y>_colorBuffer.Size.y
			
			SafeDiscard( _colorBuffer )
			SafeDiscard( _depthBuffer )
			SafeDiscard( _colorTarget0 )
			SafeDiscard( _colorTarget1 )

			'look again at this - surely we can rgb32f on some mobile target?
			#If Not __MOBILE_TARGET__
			Const color_format:=PixelFormat.RGBA32F
			Const depth_format:=PixelFormat.Depth32
			#Else
			Const color_format:=PixelFormat.RGBA8
			Const depth_format:=PixelFormat.Depth32
			#Endif
				
			_colorBuffer=New Texture( size.x,size.y,color_format,TextureFlags.Filter|TextureFlags.Dynamic )
			_depthBuffer=New Texture( size.x,size.y,depth_format,TextureFlags.Dynamic )
			_colorTarget0=New RenderTarget( New Texture[]( _colorBuffer ),_depthBuffer )
			_colorTarget1=New RenderTarget( New Texture[]( _colorBuffer ),Null )
			
			_runiforms=RenderUniforms

			_runiforms.SetTexture( "DepthBuffer",_depthBuffer )
			
		Endif
		
	End
	
	Method OnRender( scene:Scene,camera:Camera,device:GraphicsDevice ) Override
		
		_device=Device
		_runiforms=RenderUniforms
		
		If Not _direct
			_renderTarget=device.RenderTarget
			_renderTargetSize=device.RenderTargetSize
			_renderViewport=device.Viewport
			'
			_device.RenderTarget=_colorTarget0
			_device.Viewport=New Recti( 0,0,_renderViewport.Size )
			_device.Scissor=_device.Viewport
		Else
			_device.RenderTarget=device.RenderTarget
			_device.Resize( device.RenderTargetSize )
			_device.Viewport=device.Viewport
			_device.Scissor=_device.Viewport
		Endif
				
		RenderBackground()
		
		_ambientRendered=False
		
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Directional Or Not light.CastsShadow Continue
			
			RenderOpaque( light,camera )
		Next
		
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Point Or Not light.CastsShadow Continue
			
			RenderOpaque( light,camera )
		Next
		
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Directional Or light.CastsShadow Continue
			
			RenderOpaque( light,camera )
		Next
		
		For Local light:=Eachin scene.Lights
			If light.Type<>LightType.Point Or light.CastsShadow Continue
			
			RenderOpaque( light,camera )
		Next
		
		If Not _ambientRendered
			
			RenderOpaque( Null,camera )
		Endif
		
		RenderSprites()
		
		If Not _direct
		
			_device.RenderTarget=_colorTarget1
			RenderEffects( scene )

			_device.RenderTarget=_renderTarget
			_device.Resize( _renderTargetSize )
			_device.Viewport=_renderViewport
			_device.Scissor=_device.Viewport
			RenderCopy()
		Endif
		
	End
	
	Private
	
	Field _direct:Bool
	
	Field _copyShader:Shader
	Field _colorBuffer:Texture
	Field _depthBuffer:Texture
	Field _colorTarget0:RenderTarget	'colorBuffer+depthBuffer
	Field _colorTarget1:RenderTarget	'colorBuffer only

	Field _renderTarget:RenderTarget
	Field _renderTargetSize:Vec2i
	Field _renderViewport:Recti
	
	Field _device:GraphicsDevice
	Field _runiforms:UniformBlock
	
	Field _ambientRendered:Bool
	
	Method RenderOpaque( light:Light,camera:Camera )
		
		Local pass:Int=_ambientRendered ? 0 Else 1
		
		If light
			Select light.Type
			Case LightType.Directional			
				if light.CastsShadow RenderCSMShadows( light ) ; pass|=4
			Case LightType.Point
				if light.CastsShadow RenderPointShadows( light ) ; pass|=4
				pass|=8
			End
			_runiforms.SetColor( "LightColor",light.Color )
			_runiforms.SetFloat( "LightRange",light.Range )
			_runiforms.SetMat4f( "LightViewMatrix",camera.InverseMatrix * light.Matrix )
			pass|=2
		Endif
		
		_device.ColorMask=ColorMask.All
		_device.DepthMask=True
		_device.DepthFunc=DepthFunc.LessEqual
		_device.BlendMode=_ambientRendered ? BlendMode.Additive Else BlendMode.Opaque
		_device.RenderPass=pass
		
		Super.RenderOpaqueOps()
		
		_ambientRendered=True
	End
	
	Method RenderSprites()

		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.LessEqual
		_device.RenderPass=0
		
		Super.RenderSpriteOps()
	End
	
	Method RenderEffects( scene:Scene )
		
		_runiforms.SetVec2f( "BufferCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( _colorBuffer.Size ) )
		
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
		
		_runiforms.SetTexture( "SourceTexture",_colorBuffer )
		_runiforms.SetVec2f( "SourceCoordScale",Cast<Vec2f>( _renderViewport.Size )/Cast<Vec2f>( _colorBuffer.Size ) )

		_device.ColorMask=ColorMask.All
		_device.DepthMask=False
		_device.DepthFunc=DepthFunc.Always
		_device.BlendMode=BlendMode.Opaque
		_device.CullMode=CullMode.None
		_device.Shader=_copyShader
		_device.RenderPass=0
		RenderQuad()
		
		_device.RenderTarget=Null
		_device.Resize( Null )
	End

End
