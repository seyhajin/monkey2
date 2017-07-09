//@renderpasses 0,1

//renderer uniforms...

uniform mat4 r_ModelViewMatrix;
uniform mat4 r_ModelViewProjectionMatrix;
uniform mat3 r_ModelViewNormalMatrix;

#if MX2_RENDERPASS==0

uniform vec4 r_AmbientDiffuse;
uniform samplerCube r_EnvTexture;
uniform mat3 r_EnvMatrix;

//pbr varyings...

varying vec3 v_Position;
varying vec2 v_TexCoord0;
varying vec3 v_Normal;
varying mat3 v_TanMatrix;

#endif

//@vertex

//vertex attribs....

attribute vec4 a_Position;

#if MX2_RENDERPASS==0 

attribute vec2 a_TexCoord0;
attribute vec3 a_Normal;
attribute vec4 a_Tangent;

#endif

void main(){

#if MX2_RENDERPASS==0

	// view space position
	v_Position=( r_ModelViewMatrix * a_Position ).xyz;

	// texture coord0
	v_TexCoord0=a_TexCoord0;

	// viewspace normal
	v_Normal=r_ModelViewNormalMatrix * a_Normal;
	
	// viewspace tangent matrix
	v_TanMatrix[2]=v_Normal;
	v_TanMatrix[0]=r_ModelViewNormalMatrix * a_Tangent.xyz;
	v_TanMatrix[1]=cross( v_TanMatrix[0],v_TanMatrix[2] ) * a_Tangent.a;
	
#endif
	
	gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

//@fragment

#if MX2_RENDERPASS==0

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

#endif

#if MX2_RENDERPASS==0

uniform sampler2D m_BlendTexture;

uniform sampler2D m_ColorTexture0;
uniform sampler2D m_ColorTexture1;
uniform sampler2D m_ColorTexture2;
uniform sampler2D m_ColorTexture3;

uniform sampler2D m_NormalTexture0;
uniform sampler2D m_NormalTexture1;
uniform sampler2D m_NormalTexture2;
uniform sampler2D m_NormalTexture3;

#endif

void main(){

#if MX2_RENDERPASS==0

	vec4 blend=texture2D( m_BlendTexture,v_TexCoord0 ).rgb
	
	vec3 color0=pow( texture2D( m_ColorTexture0,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * blend.r;
	vec3 color1=pow( texture2D( m_ColorTexture1,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * blend.g;
	vec3 color2=pow( texture2D( m_ColorTexture2,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * blend.b;
	vec3 color3=pow( texture2D( m_ColorTexture3,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * blend.a;
	
	vec3 normal0=( texture2D( m_NormalTexture0,v_TexCoord0 ).xyz * 2.0 - 1.0 ) * blend.r;
	vec3 normal1=( texture2D( m_NormalTexture1,v_TexCoord0 ).xyz * 2.0 - 1.0 ) * blend.g;
	vec3 normal2=( texture2D( m_NormalTexture2,v_TexCoord0 ).xyz * 2.0 - 1.0 ) * blend.b;
	vec3 normal3=( texture2D( m_NormalTexture3,v_TexCoord0 ).xyz * 2.0 - 1.0 ) * blend.a;
	
	vec3 color=color0+color1+color2+color3;
	
	vec3 normal=normalize( normal0+normal1+normal2+normal3 );
	
	vec3 emissive=vec3( 0.0 );
	
	float metalness=0.0;
	
	float roughness=1.0;
	
	float occlusion=1.0;

	main0( color,emissive,metalness,roughness,occlusion,normal );
	
#else

	gl_FragColor=vec4( vec3( gl_FragCoord.z ),1.0 );

#endif

}
