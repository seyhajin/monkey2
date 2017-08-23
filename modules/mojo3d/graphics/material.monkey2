
Namespace mojo3d.graphics

#rem monkeydoc The Material class.
#end
Class Material Extends Resource
	
	#rem monkeydoc Creates a new material
	#end
	Method New( shader:Shader=Null )
		_shader=shader
		_uniforms=New UniformBlock( 3 )
		_blendMode=BlendMode.Opaque
		_cullMode=CullMode.Back
		TextureMatrix=New AffineMat3f
	End
	
	#rem monkeydoc Creates a copy of the material.
	#end
	Method Copy:Material() abstract
	
	#rem monkeydoc The material shader.
	#end
	Property Shader:Shader()
		
		Return _shader
	End
	
	#Rem monkeydoc @hidden The material uniforms.
	#End
	Property Uniforms:UniformBlock()
	
		Return _uniforms
	End

	#Rem monkeydoc The material blendmode.
	#End
	Property BlendMode:BlendMode()
		
		Return _blendMode
	
	Setter( mode:BlendMode )
		
		_blendMode=mode
	End
	
	#Rem monkeydoc The material cullmode.
	#End
	Property CullMode:CullMode()
		
		Return _cullMode
	
	Setter( mode:CullMode )
		
		_cullMode=mode
	End
	
	#rem monkeydoc The material texture matrix.
	#end
	Property TextureMatrix:AffineMat3f()
		
		Return Uniforms.GetAffineMat3f( "TextureMatrix" )
		
	Setter( matrix:AffineMat3f )
		
		Uniforms.SetAffineMat3f( "TextureMatrix",matrix )
	End
	
	#rem monkeydoc Translates the texture matrix.
	#end
	Method TranslateTextureMatrix( tv:Vec2f )
		
		TextureMatrix=TextureMatrix.Translate( tv )
	End
	
	Method TranslateTextureMatrix( tx:Float,ty:Float )
		
		TextureMatrix=TextureMatrix.Translate( tx,ty )
	End

	#rem monkeydoc Rotates the texture matrix.
	#end
	Method RotateTextureMatrix( angle:Float )
		
		TextureMatrix=TextureMatrix.Rotate( angle )
	End
		
	#rem monkeydoc Scales the texture matrix.
	#end
	Method ScaleTextureMatrix( sv:Vec2f )
		
		TextureMatrix=TextureMatrix.Scale( sv )
	End
	
	Method ScaleTextureMatrix( sx:Float,sy:Float )
		
		TextureMatrix=TextureMatrix.Scale( sx,sy )
	End

	Protected
	#rem monkeydoc @hidden
	#end
	Method New( material:Material )
		_shader=material._shader
		_uniforms=New UniformBlock( material._uniforms )
		_blendMode=material._blendMode
		_cullMode=material._cullMode
		TextureMatrix=material.TextureMatrix
	End
	
	Method SetShader( shader:Shader )
		
		_shader=shader
	End
	
	Private

	Field _shader:Shader
	Field _uniforms:UniformBlock
	Field _blendMode:BlendMode
	Field _cullMode:CullMode

End
