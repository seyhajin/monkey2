
Namespace mojo3d.graphics

#rem monkeydoc The MonochromeEffect class.
#end
Class MonochromeEffect Extends PostEffect

	#rem monkeydoc Creates a new monochrome effect shader.
	#end
	Method New( level:Float=1.0 )
		
		_shader=Shader.Open( "effect-monochrome" )
		
		_uniforms=New UniformBlock( 3 )
		
		Level=level
	End
	
	#rem monkeydoc The effect level.
	
	0=no effect, 1=full effect.
	
	#end
	Property Level:Float()
		
		Return _uniforms.GetFloat( "Level" )
	
	Setter( level:Float )
		
		_uniforms.SetFloat( "Level",level )
	End

	Protected
	
	#rem monkeydoc @hidden
	#end	
	Method OnRender() Override
		
		Local rsize:=Device.Viewport.Size
		Local rtarget:=Device.RenderTarget
		Local rtexture:=rtarget.GetColorTexture( 0 )
		
		If Not _target Or rsize.x>_target.Size.x Or rsize.y>_target.Size.y
			
			SafeDiscard( _target ) ; SafeDiscard( _texture )
			
			_texture=New Texture( rsize.x,rsize.y,rtexture.Format,Null )
			
			_target=New RenderTarget( New Texture[]( _texture ),Null )
		End
					
		_uniforms.SetTexture( "SourceTexture",rtexture )
		_uniforms.SetVec2f( "SourceTextureSize",rsize )
		_uniforms.SetVec2f( "SourceCoordScale",Cast<Vec2f>( rsize )/Cast<Vec2f>( rtexture.Size ) )
		
		Device.RenderTarget=_target
		Device.Shader=_shader
		Device.BindUniformBlock( _uniforms )
		
		RenderQuad()
	End
	
	Private
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
	Field _target:RenderTarget
	Field _texture:Texture
	
End
