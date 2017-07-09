
Namespace mojo3d.graphics

#rem monkeydoc The TerrainMaterial class.
#end
Class TerrainMaterial Extends Material

	#rem monkeydoc Creates a new terrain material.
	#end
	Method New()
		Super.New( Shader.Open( "terrain" ) )
		
		BlendTexture=Texture.ColorTexture( Color.Black )
		
		ColorTextures=New Texture[](
			Texture.ColorTexture( Color.White ),
			Texture.ColorTexture( Color.White ),
			Texture.ColorTexture( Color.White ),
			Texture.ColorTexture( Color.White ) )
			
		NormalTextures=New Texture[]( 
			Texture.FlatNormal(),
			Texture.FlatNormal(),
			Texture.FlatNormal(),
			Texture.FlatNormal() )
	End
	
	Property BlendTexture:Texture()
		
		Return Uniforms.GetTexture( "BlendTexture" )
		
	Setter( texture:Texture )
		
		Uniforms.SetTexture( "BlendTexture",texture )
	End
	
	Property ColorTextures:Texture[]()
		
		Return New Texture[](
			Uniforms.GetTexture( "ColorTexture0" ),
			Uniforms.GetTexture( "ColorTexture1" ),
			Uniforms.GetTexture( "ColorTexture2" ),
			Uniforms.GetTexture( "ColorTexture3" ) )
	
	Setter( textures:Texture[] )
		Assert( textures.Length=4,"ColorTextures length must be 4" )
		
		Uniforms.SetTexture( "ColorTexture0",textures[0] )
		Uniforms.SetTexture( "ColorTexture1",textures[1] )
		Uniforms.SetTexture( "ColorTexture2",textures[2] )
		Uniforms.SetTexture( "ColorTexture3",textures[3] )
	End
	
	Property NormalTextures:Texture[]()
		
		Return New Texture[](
			Uniforms.GetTexture( "NormalTexture0" ),
			Uniforms.GetTexture( "NormalTexture1" ),
			Uniforms.GetTexture( "NormalTexture2" ),
			Uniforms.GetTexture( "NormalTexture3" ) )
	
	Setter( textures:Texture[] )
		Assert( textures.Length=4,"NormalTextures length must be 4" )
		
		Uniforms.SetTexture( "NormalTexture0",textures[0] )
		Uniforms.SetTexture( "NormalTexture1",textures[1] )
		Uniforms.SetTexture( "NormalTexture2",textures[2] )
		Uniforms.SetTexture( "NormalTexture3",textures[3] )
	End
	
End
