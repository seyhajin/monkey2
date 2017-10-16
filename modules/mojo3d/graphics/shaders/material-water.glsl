
//@renderpasses 0

//material uniforms

uniform mat3 m_TextureMatrix;

//renderer uniforms

uniform mat4 i_ModelViewMatrix;
uniform mat4 i_ModelViewProjectionMatrix;
uniform mat3 i_ModelViewNormalMatrix;

uniform vec4 r_AmbientDiffuse;
uniform samplerCube r_EnvTexture;
uniform mat3 r_EnvMatrix;

//pbr varyings...

varying vec3 v_Position;
varying vec2 v_TexCoord0;
varying vec3 v_Normal;
varying mat3 v_TanMatrix;

//@vertex

//vertex attribs....

attribute vec4 a_Position;

attribute vec2 a_TexCoord0;
attribute vec3 a_Normal;
attribute vec4 a_Tangent;

void main(){

	// texture coord0
	v_TexCoord0=(m_TextureMatrix * vec3(a_TexCoord0,1.0)).st;

	// view space position
	v_Position=( i_ModelViewMatrix * a_Position ).xyz;

	// viewspace normal
	v_Normal=i_ModelViewNormalMatrix * a_Normal;
	
	// viewspace tangent matrix
	v_TanMatrix[2]=v_Normal;
	v_TanMatrix[0]=i_ModelViewNormalMatrix * a_Tangent.xyz;
	v_TanMatrix[1]=cross( v_TanMatrix[0],v_TanMatrix[2] ) * a_Tangent.a;
	
	gl_Position=i_ModelViewProjectionMatrix * a_Position;
}

//@fragment

void main0( vec3 color,vec3 emissive,float metalness,float roughness,float occlusion,vec3 normal ){

	normal=normalize( v_TanMatrix * normal );

	vec3 color0=vec3( 0.04,0.04,0.04 );
	
	vec3 diffuse=color * (1.0-metalness);
	
	vec3 specular=(color-color0) * metalness + color0;
	
	vec3 rvec=r_EnvMatrix * reflect( v_Position,normal );
	
	float lod=textureCube( r_EnvTexture,rvec,10.0 ).a * 255.0 - 10.0;
	
	if( lod>0.0 ) lod=textureCube( r_EnvTexture,rvec ).a * 255.0;
	
	vec3 env=pow( textureCube( r_EnvTexture,rvec,max( roughness*10.0-lod,0.0 ) ).rgb,vec3( 2.2 ) );

	vec3 vvec=normalize( -v_Position );
	
	float ndotv=max( dot( normal,vvec ),0.0 );
	
	vec3 fschlick=specular + (1.0-specular) * pow( 1.0-ndotv,5.0 ) * (1.0-roughness);

	vec3 ambdiff=diffuse * r_AmbientDiffuse.rgb;
		
	vec3 ambspec=env * fschlick;

	gl_FragData[0]=vec4( min( (ambdiff+ambspec) * occlusion + emissive,8.0 ),1.0 );
	
	gl_FragData[1]=vec4( color,metalness );
	
	gl_FragData[2]=vec4( normal * 0.5 + 0.5,roughness );
}

uniform float r_Time;

uniform sampler2D m_ColorTexture;
uniform vec4 m_ColorFactor;

uniform float m_Metalness;
uniform float m_Roughness;

uniform sampler2D m_NormalTexture0;
uniform sampler2D m_NormalTexture1;

uniform vec2 m_Velocity0;
uniform vec2 m_Velocity1;

void main(){

	vec3 color=pow( texture2D( m_ColorTexture,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * m_ColorFactor.rgb;

	vec3 normal0=texture2D( m_NormalTexture0,v_TexCoord0 + m_Velocity0 * r_Time ).xyz * 2.0 - 1.0;
	
	vec3 normal1=texture2D( m_NormalTexture1,v_TexCoord0 + m_Velocity1 * r_Time ).xyz * 2.0 - 1.0;
	
	vec3 normal=normalize( normal0+normal1 );
	
	vec3 emissive=vec3( 0.0 );
	
	float metalness=m_Metalness;
	
	float roughness=m_Roughness;
	
	float occlusion=1.0;

	main0( color,emissive,metalness,roughness,occlusion,normal );

}
