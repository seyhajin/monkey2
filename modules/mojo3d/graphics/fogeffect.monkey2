
Namespace mojo3d.graphics

#rem The FogEffect class.

This class implements a 'fog' post processing effect.

#end
Class FogEffect Extends PostEffect

	#rem monkeydoc Creates a new fog effect.
	#end	
	Method New( color:Color=std.graphics.Color.Sky,near:Float=0,far:Float=1000 )

		_shader=Shader.Open( "fog" )
		
		_uniforms=New UniformBlock( 3 )
		
		Color=color
		Near=near
		Far=far
	End

	#rem monkeydoc Color of the fog.
	#end
	Property Color:Color()
		
		Return _uniforms.GetColor( "Color" )
	
	Setter( color:Color )
		
		_uniforms.SetColor( "Color",color )
	End

	#rem monkeydoc Near distance of the fog.
	#end	
	Property Near:Float()
		
		Return _uniforms.GetFloat( "Near" )
	
	Setter( near:Float )
		
		_uniforms.SetFloat( "Near",near )
	End
	
	#rem monkeydoc Far distance of the fog.
	#end	
	Property Far:Float()
		
		Return _uniforms.GetFloat( "Far" )
	
	Setter( far:Float )
		
		_uniforms.SetFloat( "Far",far )
	End
	
	Protected
	
	#rem monkeydoc @hidden
	#end
	Method OnRender() Override
		
		Device.Shader=_shader
		
		Device.BindUniformBlock( _uniforms )

		Device.BlendMode=BlendMode.Alpha
		
		RenderQuad()
	End
	
	Private
	
	Field _shader:Shader
	
	Field _uniforms:UniformBlock
	
End
