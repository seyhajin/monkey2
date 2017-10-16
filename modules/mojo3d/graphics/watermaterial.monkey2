
Namespace mojo3d.graphics

#rem monkeydoc The WaterMaterial class.
#end
Class WaterMaterial Extends Material
	
	#rem monkeydoc Creates a new water material.
	#end
	Method New()
		Assert( Cast<DeferredRenderer>( Renderer.GetCurrent() ),"Water material requires deferred renderer" )
		
		SetShader( Shader.Open( "material-water" ) )
		
		ColorTexture=Texture.ColorTexture( Color.White )
		ColorFactor=Color.SeaGreen
		
		Metalness=0
		Roughness=0
		
		Local normal:=Texture.ColorTexture( New Color( .5,.5,1 ) )
		
		NormalTextures=New Texture[]( normal,normal )
		
		Velocities=New Vec2f[]( New Vec2f( 0,0 ),New Vec2f( 0,0 ) )
	End
	
	Method New( material:WaterMaterial )
		
		Super.New( material )
	End
	
	#rem monkeydoc Creates a copy of the water material.
	#end
	Method Copy:WaterMaterial() Override
	
		Return New WaterMaterial( Self )
	End
	
	Property ColorTexture:Texture()
		
		Return Uniforms.GetTexture( "ColorTexture" )
	
	Setter( texture:Texture )
		
		Uniforms.SetTexture( "ColorTexture",texture )
	End
	
	Property ColorFactor:Color()
		
		Return Uniforms.GetColor( "ColorFactor" )
	
	Setter( factor:Color )
	
		Uniforms.SetColor( "ColorFactor",factor )
	End
	
	Property Metalness:Float()
		
		Return Uniforms.GetFloat( "Metalness" )
	
	Setter( metalness:Float )
		
		Uniforms.SetFloat( "Metalness",metalness )
	End
	
	property Roughness:Float()
		
		Return Uniforms.GetFloat( "Roughness" )
	
	Setter( roughness:Float )
		
		Uniforms.SetFloat( "Roughness",roughness )
	End
	
	Property NormalTextures:Texture[]()
		
		Return New Texture[]( Uniforms.GetTexture( "NormalTexture0" ),Uniforms.GetTexture( "NormalTexture1" ) )
	
	Setter( textures:Texture[] )
		Assert( textures.Length=2,"NormalTextures array must havre length 2" )
		
		Uniforms.SetTexture( "NormalTexture0",textures[0] )
		Uniforms.SetTexture( "NormalTexture1",textures[1] )
	End
	
	Property Velocities:Vec2f[]()
		
		Return New Vec2f[]( Uniforms.GetVec2f( "Velocity0" ),Uniforms.GetVec2f( "Velocity1" ) )
	
	Setter( velocities:Vec2f[] )
		Assert( velocities.Length=2,"Velocities array must have length 2" )
		
		Uniforms.SetVec2f( "Velocity0",velocities[0] )
		Uniforms.SetVec2f( "Velocity1",velocities[1] )
	End
	
End
