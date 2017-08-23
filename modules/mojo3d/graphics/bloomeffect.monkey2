
Namespace mojo3d.graphics

#rem The BloomEffect class.

This class implements a 'bloom' post processing effect.

#end
Class BloomEffect Extends PostEffect
	
	#rem monkeydoc Creates a new bloom effect.
	#end
	Method New( passes:Int=2 )
		
		_shader=Shader.Open( "bloom" )
		
		_uniforms=New UniformBlock( 3 )
		
		Passes=passes
	End
	
	#rem monkeydoc The number of passes.
	
	Must be an even number greater than 0.
	
	#end
	Property Passes:Int()
		
		Return _passes
	
	Setter( passes:Int )
		Assert( passes>0 And (passes&1)=0,"BloomEffect passes must be even and >0" )
		
		_passes=passes
	End
	
	Protected
	
	#rem monkeydoc @hidden
	#end
	Method OnRender() Override
		
		Local rsize:=Device.Viewport.Size
		Local rtarget:=Device.RenderTarget
		Local rtexture:=rtarget.GetColorTexture( 0 )
		
		If Not _target0 Or rsize.x>_target0.Size.x Or rsize.y>_target0.Size.y
			
			SafeDiscard( _target0 ) ; SafeDiscard( _texture0 )
			SafeDiscard( _target1 ) ; SafeDiscard( _texture1 )
			
			_texture0=New Texture( rsize.x,rsize.y,rtexture.Format,Null )
			_texture1=New Texture( rsize.x,rsize.y,rtexture.Format,Null )

			_target0=New RenderTarget( New Texture[]( _texture0 ),Null )
			_target1=New RenderTarget( New Texture[]( _texture1 ),Null )
		Endif

		Device.Shader=_shader
		Device.BindUniformBlock( _uniforms )

		Local target:=_target0
		Local source:=rtexture
		
		For Local i:=0 Until _passes

			_uniforms.SetTexture( "SourceTexture",source )
			_uniforms.SetVec2f( "SourceTextureSize",source.Size )
			_uniforms.SetVec2f( "SourceTextureScale",Cast<Vec2f>( rsize )/Cast<Vec2f>( source.Size ) )

			Device.RenderTarget=target
			Device.RenderPass=i ? 2-(i&1) Else 0	'0,1,2,1,2,1,2...
			
			RenderQuad()
			
			If target=_target0
				source=_texture0
				target=_target1
			Else
				source=_texture1
				target=_target0
			Endif
			
		Next
		
		_uniforms.SetTexture( "SourceTexture",source )
		_uniforms.SetVec2f( "SourceTextureSize",source.Size )
		_uniforms.SetVec2f( "SourceTextureScale",Cast<Vec2f>( rsize )/Cast<Vec2f>( source.Size ) )
		
		Device.RenderTarget=rtarget
		Device.BlendMode=BlendMode.Additive
		Device.RenderPass=3
		
		RenderQuad()
	End
	
	Private
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
	
	Field _passes:Int=4
	
	Field _texture0:Texture
	Field _texture1:Texture
	
	Field _target0:RenderTarget
	Field _target1:RenderTarget
	
End
