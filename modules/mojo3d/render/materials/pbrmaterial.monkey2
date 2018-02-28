
Namespace mojo3d

Private

Function MakeColor:Color( jobj:JsonObject )
	
	Local r:=jobj.Contains( "r" ) ? jobj.GetNumber( "r" ) Else 1.0
	Local g:=jobj.Contains( "g" ) ? jobj.GetNumber( "g" ) Else 1.0
	Local b:=jobj.Contains( "b" ) ? jobj.GetNumber( "b" ) Else 1.0
	Local a:=jobj.Contains( "a" ) ? jobj.GetNumber( "a" ) Else 1.0
	
	Return New Color( r,g,b,a )
End

Class JsonObject Extension

	Method GetColor:Color( key:String )
		
		Local jobj:=GetObject( key )
		If Not jobj Return Color.White
		
		Return MakeColor( jobj )
	End
End

Public

#rem monkeydoc The PbrMaterial class.
#end
Class PbrMaterial Extends Material
	
	#rem monkeydoc Creates a new pbr material.
	
	All properties default to white or '1' except for emissive factor which defaults to black. 
	
	If you set an emissive texture, you will also need to set emissive factor to white to 'enable' it.
	
	The metalness value should be stored in the 'blue' channel of the metalness texture if the texture has multiple color channels.
	
	The roughness value should be stored in the 'green' channel of the metalness texture if the texture has multiple color channels.
	
	The occlusion value should be stored in the 'red' channel of the occlusion texture if the texture has multiple color channels.
	
	The above last 3 rules allow you to pack metalness, roughness and occlusion into a single texture.
	
	#end
	Method New( boned:Bool=False )
		
		_boned=boned
		
		Uniforms.DefaultTexture=Texture.ColorTexture( Color.White )
		
		ColorTexture=Null
		EmissiveTexture=Null
		MetalnessTexture=Null
		RoughnessTexture=Null
		OcclusionTexture=Null
		NormalTexture=Null
		
		ColorFactor=Color.White
		EmissiveFactor=Color.Black
		MetalnessFactor=1.0
		RoughnessFactor=1.0
	End
	
	Method New( color:Color,metalness:Float=1.0,roughness:Float=1.0,boned:Bool=False )
		Self.New( boned )
		
		ColorFactor=color
		MetalnessFactor=metalness
		RoughnessFactor=roughness
	End
	
	Method New( material:PbrMaterial )
		Super.New( material )
		
		_textured=material._textured
		_bumpmapped=material._bumpmapped
		_boned=material._boned
	End
	
	#rem monkeydoc Creates a copy of the pbr material.
	#end
	Method Copy:PbrMaterial() Override
	
		Return New PbrMaterial( Self )
	End
	
	Method GetOpaqueShader:Shader() Override
		
		ValidateShaders()
		
		Return _opaqueShader
	End
	
	Method GetTransparentShader:Shader() Override
		
		ValidateShaders()
		
		Return _transparentShader
	End
	
	'***** textures *****
	
	Property ColorTexture:Texture()
	
		Return Uniforms.GetTexture( "ColorTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "ColorTexture",texture )
		
		If (Uniforms.NumTextures<>0)<>_textured _dirty=True
	End
	
	Property EmissiveTexture:Texture()
	
		Return Uniforms.GetTexture( "EmissiveTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "EmissiveTexture",texture )
		
		If (Uniforms.NumTextures<>0)<>_textured _dirty=True
	End
	
	Property MetalnessTexture:Texture()
	
		Return Uniforms.GetTexture( "MetalnessTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "MetalnessTexture",texture )
		
		If (Uniforms.NumTextures<>0)<>_textured _dirty=true
	End

	Property RoughnessTexture:Texture()
	
		Return Uniforms.GetTexture( "RoughnessTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "RoughnessTexture",texture )
		
		If (Uniforms.NumTextures<>0)<>_textured _dirty=true
	End
	
	Property OcclusionTexture:Texture()
	
		Return Uniforms.GetTexture( "OcclusionTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "OcclusionTexture",texture )
		
		If (Uniforms.NumTextures<>0)<>_textured _dirty=true
	End
	
	Property NormalTexture:Texture()
	
		Return Uniforms.GetTexture( "NormalTexture" )
		
	Setter( texture:Texture )
	
		Uniforms.SetTexture( "NormalTexture",texture )
		
		If (texture<>null)<>_bumpmapped _dirty=true
	End
	
	'***** factors *****

	Property ColorFactor:Color()
	
		Return Uniforms.GetColor( "ColorFactor" )
		
	Setter( color:Color )
	
		Uniforms.SetColor( "ColorFactor",color )
	End
	
	Property EmissiveFactor:Color()
	
		Return Uniforms.GetColor( "EmissiveFactor" )
		
	Setter( color:Color )
	
		Uniforms.SetColor( "EmissiveFactor",color )
	End
	
	Property MetalnessFactor:Float()
	
		Return Uniforms.GetFloat( "MetalnessFactor" )
		
	Setter( factor:Float )

		Uniforms.SetFloat( "MetalnessFactor",factor )
	End
	
	Property RoughnessFactor:Float()
	
		Return Uniforms.GetFloat( "RoughnessFactor" )
		
	Setter( factor:Float )
	
		Uniforms.SetFloat( "RoughnessFactor",factor )
	End

	#rem monkeydoc Loads a PbrMaterial from a 'file'.
	
	A .pbr file is actually a directory containing a number of textures in png format. These textures are:
	
	color.png (required)
	emissive.png
	metalness.png
	roughness.png
	occlusion.png
	normal.png
	
	#end
	Function Load:PbrMaterial( path:String,textureFlags:TextureFlags=TextureFlags.WrapST|TextureFlags.FilterMipmap )
		
		Local material:=New PbrMaterial
		
		Local texture:=LoadTexture( path,"color",textureFlags )
		If texture
			material.ColorTexture=texture
		Endif
		
		texture=LoadTexture(path,"emissive",textureFlags )
		If texture
			material.EmissiveTexture=texture
			material.EmissiveFactor=Color.White
		Endif
		
		texture=LoadTexture( path,"metalness",textureFlags )
		If texture
			material.MetalnessTexture=texture
		Endif
		
		texture=LoadTexture( path,"roughness",textureFlags )
		If texture
			material.RoughnessTexture=texture
		Endif
		
		texture=LoadTexture( path,"occlusion",textureFlags )
		If texture
			material.OcclusionTexture=texture
		Endif
		
		texture=LoadTexture( path,"normal",textureFlags )
		If Not texture texture=LoadTexture( path,"unormal",textureFlags,True )
		If texture
			material.NormalTexture=texture
		Endif
		
		Local jobj:=JsonObject.Load( path+"/material.json" )
		If jobj
			If jobj.Contains( "colorFactor" ) material.ColorFactor=jobj.GetColor( "colorFactor" )
			If jobj.Contains( "emissiveFactor" ) material.EmissiveFactor=jobj.GetColor( "emissiveFactor" )
			If jobj.Contains( "metalnessFactor" ) material.MetalnessFactor=jobj.GetNumber( "metalnessFactor" )
			If jobj.Contains( "roughnessFactor" ) material.RoughnessFactor=jobj.GetNumber( "roughnessFactor" )
		Endif
		
		Return material
	End
	
	Protected
	
	Field _textured:Bool
	Field _bumpmapped:Bool
	Field _boned:Bool
	
	Field _opaqueShader:Shader
	Field _transparentShader:Shader
	Field _shadowShader:Shader
	
	Field _dirty:=True
	
	Function LoadTexture:Texture( path:String,name:String,flags:TextureFlags,flipy:Bool=False )
		
		Local texture:=Texture.Load( path+"/"+name+".png",flags,flipy )
		
		If Not texture texture=Texture.Load( path+"/"+name+".jpg",flags,flipy )
			
		Return texture
	End
	
	Method ValidateShaders()
		
		If Not _dirty Return
		
		_textured=True'False
		_bumpmapped=False
		
		If Uniforms.NumTextures
			_textured=True
			_bumpmapped=(Uniforms.GetTexture( "NormalTexture" )<>null)
		Endif
		
		Local defs:=Renderer.GetCurrent().ShaderDefs
		
		If _textured
			defs+="MX2_TEXTURED~n"
			If _bumpmapped
				defs+="MX2_BUMPMAPPED~n"
			Endif
		Endif
		
		If _boned defs+="MX2_BONED~n"
			
		_transparentShader=Shader.Open( "material-pbr-forward",defs )
		
		If Renderer.GetCurrent().Deferred
			
			_opaqueShader=Shader.Open( "material-pbr-deferred",defs )
		
		Else
			
			_opaqueShader=_transparentShader
			
		Endif
		
		_shadowShader=_opaqueShader
		
		_dirty=False
		
	End
	
End
