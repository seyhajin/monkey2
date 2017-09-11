
Namespace mojo3d.graphics

#rem monkeydoc The ParticleMaterial class.
#end
Class ParticleMaterial Extends Material
	
	#rem monkeydoc Creates a new particle material.
	#end	
	Method New()

		Local shader:="material-particle"
		Local defs:=Renderer.GetCurrent().ShaderDefs
			
		SetShader( Shader.Open( shader,defs ) )
		
		BlendMode=BlendMode.Additive
		CullMode=CullMode.None
		
		ColorTexture=Texture.ColorTexture( Color.White )
		ColorFactor=Color.White
		Gravity=New Vec3f( 0,-9.81,0 )
		Duration=10.0
		Fade=0.0
		
	End
	
	Method New( material:ParticleMaterial )
	
		Super.New( material )
	End
	
	#rem monkeydoc Creates a copy of the particle material.
	#end
	Method Copy:ParticleMaterial() Override
	
		Return New ParticleMaterial( Self )
	End
	
	Property ColorTexture:Texture()
		
		Return Uniforms.GetTexture( "ColorTexture" )
	
	Setter( texture:Texture )
		
		Uniforms.SetTexture( "ColorTexture",texture )
	End
	
	Property ColorFactor:Color()
	
		Return Uniforms.GetColor( "ColorFactor" )
		
	Setter( color:Color )
	
		Uniforms.SetColor( "ColorFactor",color )
	End
	
	Property Gravity:Vec3f()
	
		Return Uniforms.GetVec3f( "Gravity" )
	
	Setter( gravity:Vec3f )
	
		Uniforms.SetVec3f( "Gravity",gravity )
	End
	
	Property Duration:Float()
	
		Return _duration
	
	Setter( duration:Float )
	
		Uniforms.SetFloat( "Duration",duration )
		
		_duration=duration
	End
	
	Property Fade:Float ()
	
		Return Uniforms.GetFloat( "Fade" )
		
	Setter( fade:Float )
	
		Uniforms.SetFloat( "Fade",fade )
	End

	Private
	
	Field _duration:Float

End

