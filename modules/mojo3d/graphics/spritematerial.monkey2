
Namespace mojo3d.graphics

#rem monkeydoc The SpriteMaterial class.
#end
Class SpriteMaterial Extends Material
	
	#rem monkeydoc Creates a new sprite material.
	#end	
	Method New()
		Super.New( Shader.Open( "sprite3d" ) )
		
		BlendMode=BlendMode.Alpha
		CullMode=CullMode.None
		
		ColorTexture=Texture.ColorTexture( Color.White )
		ColorFactor=Color.White
	End
	
	Method New( material:SpriteMaterial )
	
		Super.New( material )
	End
	
	#rem monkeydoc Creates a copy of the sprite material.
	#end
	Method Copy:SpriteMaterial() Override
	
		Return New SpriteMaterial( Self )
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

	#rem monkeydoc Loads a sprite material from an image file.
	#end	
	Function Load:SpriteMaterial( path:String,textureFlags:TextureFlags=TextureFlags.FilterMipmap )
		
		Local texture:=Texture.Load( path,textureFlags )
		If Not texture texture=Texture.ColorTexture( Color.Magenta )
		
		Local material:=New SpriteMaterial
		material.ColorTexture=texture
		
		Return material
	End
	
End

