
Namespace mojo3d

#rem monkeydoc The MonochromeEffect class.
#end
Class MonochromeEffect Extends PostEffect

	#rem monkeydoc Creates a new monochrome effect shader.
	#end
	Method New( level:Float=1.0 )
		
		_shader=Shader.Open( "effects/monochrome" )
		
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
	
	Method OnRender() Override
		
		Device.Shader=_shader
		
		Device.BindUniformBlock( _uniforms )
		
		RenderQuad()
	End
	
	Private
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
	
End
