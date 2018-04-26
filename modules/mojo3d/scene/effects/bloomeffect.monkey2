
Namespace mojo3d

#rem The BloomEffect class.

This class implements a 'bloom' post processing effect.

#end
Class BloomEffect Extends PostEffect
	
	#rem monkeydoc Creates a new bloom effect.
	#end
	Method New( passes:Int=2 )
		
		_shader=Shader.Open( "effects/bloom" )
		
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
	
	Method OnRender() Override
		
		Device.Shader=_shader
		
		Device.BindUniformBlock( _uniforms )
		
		For Local i:=0 Until _passes
			
			If i Flip()
			
			Device.RenderPass=i ? 2-(i&1) Else 0	'0,1,2,1,2,1,2...
			
			RenderQuad()
		End
	End
	
	Private
	
	Field _shader:Shader
	Field _uniforms:UniformBlock
	Field _passes:Int=4
	
End
