
//@renderpasses 1,2,3

#define MX2_AMBIENTPASS (MX2_RENDERPASS==1)
#define MX2_CASTSHADOWPASS (MX2_RENDERPASS==2)
#define MX2_TRANSPARENTPASS (MX2_RENDERPASS==3)
 
//material uniforms

#ifdef MX2_TEXTURED
uniform mat3 m_TextureMatrix;
#endif

//renderer uniforms...

uniform mat4 r_ModelViewMatrix;
uniform mat4 r_ModelViewProjectionMatrix;
uniform mat3 r_ModelViewNormalMatrix;

#if MX2_AMBIENTPASS

uniform vec4 r_AmbientDiffuse;
uniform samplerCube r_EnvTexture;
uniform mat3 r_EnvMatrix;

//pbr varyings...

varying vec3 v_Position;
varying vec3 v_Normal;
#ifdef MX2_TEXTURED
varying vec2 v_TexCoord0;
#ifdef MX2_BUMPMAPPED
varying mat3 v_TanMatrix;
#endif
#endif

#endif	//MX2_AMBIENTPASS

//@vertex

#ifdef MX2_BONED
uniform mat4 r_BoneMatrices[96];
#endif

//vertex attribs....

attribute vec4 a_Position;
#ifdef MX2_BONED
attribute vec4 a_Weights;
attribute vec4 a_Bones;
#endif

#if MX2_AMBIENTPASS

attribute vec3 a_Normal;
#ifdef MX2_TEXTURED
attribute vec2 a_TexCoord0;
#ifdef MX2_BUMPMAPPED
attribute vec4 a_Tangent;
#endif
#endif

#endif	//MX2_AMBIENTPASS

#ifdef MX2_BONED

void main(){

	mat4 m0=r_BoneMatrices[ int( a_Bones.x ) ];
	mat4 m1=r_BoneMatrices[ int( a_Bones.y ) ];
	mat4 m2=r_BoneMatrices[ int( a_Bones.z ) ];
	mat4 m3=r_BoneMatrices[ int( a_Bones.a ) ];
	
	vec4 b_Position=
		m0 * a_Position * a_Weights.x +
		m1 * a_Position * a_Weights.y +
		m2 * a_Position * a_Weights.z +
		m3 * a_Position * a_Weights.a;
		
#if MX2_AMBIENTPASS

	mat3 n0=mat3( m0[0].xyz,m0[1].xyz,m0[2].xyz );
	mat3 n1=mat3( m1[0].xyz,m1[1].xyz,m1[2].xyz );
	mat3 n2=mat3( m2[0].xyz,m2[1].xyz,m2[2].xyz );
	mat3 n3=mat3( m3[0].xyz,m3[1].xyz,m3[2].xyz );

	vec3 b_Normal=normalize( 
		n0 * a_Normal * a_Weights.x +
		n1 * a_Normal * a_Weights.y +
		n2 * a_Normal * a_Weights.z +
		n3 * a_Normal * a_Weights.a );
		
#ifdef MX2_BUMPMAPPED
	vec4 b_Tangent=vec4( normalize( 
		n0 * a_Tangent.xyz * a_Weights.x +
		n1 * a_Tangent.xyz * a_Weights.y +
		n2 * a_Tangent.xyz * a_Weights.z +
		n3 * a_Tangent.xyz * a_Weights.a ),a_Tangent.w );
#endif

	// view space position
	v_Position=( r_ModelViewMatrix * b_Position ).xyz;

	// viewspace normal
	v_Normal=r_ModelViewNormalMatrix * b_Normal;
	
#ifdef MX2_TEXTURED
	// texture coord0
	v_TexCoord0=(m_TextureMatrix * vec3(a_TexCoord0,1.0)).st;
#ifdef MX2_BUMPMAPPED
	// viewspace tangent matrix
	v_TanMatrix[2]=v_Normal;
	v_TanMatrix[0]=r_ModelViewNormalMatrix * b_Tangent.xyz;
	v_TanMatrix[1]=cross( v_TanMatrix[0],v_TanMatrix[2] ) * b_Tangent.a;
#endif
#endif
	
#endif	//MX2_AMBIENTPASS
	
	gl_Position=r_ModelViewProjectionMatrix * b_Position;
}

#else	//MX2_BONED

void main(){

#if MX2_AMBIENTPASS

	// view space position
	v_Position=( r_ModelViewMatrix * a_Position ).xyz;

	// viewspace normal
	v_Normal=r_ModelViewNormalMatrix * a_Normal;
	
#ifdef MX2_TEXTURED
	// texture coord0
	v_TexCoord0=(m_TextureMatrix * vec3(a_TexCoord0,1.0)).st;
#ifdef MX2_BUMPMAPPED
	// viewspace tangent matrix
	v_TanMatrix[2]=v_Normal;
	v_TanMatrix[0]=r_ModelViewNormalMatrix * a_Tangent.xyz;
	v_TanMatrix[1]=cross( v_TanMatrix[0],v_TanMatrix[2] ) * a_Tangent.a;
#endif
#endif

#endif	//MX2_AMBIENTPASS
	
	gl_Position=r_ModelViewProjectionMatrix * a_Position;
}

#endif	//MX2_BONED

//@fragment

#if MX2_AMBIENTPASS

void pbr_WriteFragData( vec3 color,vec3 emissive,float metalness,float roughness,float occlusion,vec3 normal ){

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

#if MX2_AMBIENTPASS

#ifdef MX2_TEXTURED
uniform sampler2D m_ColorTexture;
uniform sampler2D m_EmissiveTexture;
uniform sampler2D m_MetalnessTexture;
uniform sampler2D m_RoughnessTexture;
uniform sampler2D m_OcclusionTexture;
uniform sampler2D m_NormalTexture;
#endif

uniform vec4 m_ColorFactor;
uniform vec4 m_EmissiveFactor;
uniform float m_MetalnessFactor;
uniform float m_RoughnessFactor;

#endif

void main(){

#if MX2_AMBIENTPASS

#ifdef MX2_TEXTURED

	vec3 color=pow( texture2D( m_ColorTexture,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * m_ColorFactor.rgb;
	vec3 emissive=pow( texture2D( m_EmissiveTexture,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * m_EmissiveFactor.rgb;
	float metalness=texture2D( m_MetalnessTexture,v_TexCoord0 ).b * m_MetalnessFactor;
	float roughness=texture2D( m_RoughnessTexture,v_TexCoord0 ).g * m_RoughnessFactor;
	float occlusion=texture2D( m_OcclusionTexture,v_TexCoord0 ).r;
	
#ifdef MX2_BUMPMAPPED
	vec3 normal=texture2D( m_NormalTexture,v_TexCoord0 ).xyz * 2.0 - 1.0;
	normal=normalize( v_TanMatrix * normal );
#else
	vec3 normal=v_Normal;
#endif
	
#else

	vec3 color=m_ColorFactor.rgb;
	vec3 emissive=m_EmissiveFactor.rgb;
	float metalness=m_MetalnessFactor;
	float roughness=m_RoughnessFactor;
	float occlusion=1.0;
	vec3 normal=v_Normal;

#endif

	pbr_WriteFragData( color,emissive,metalness,roughness,occlusion,normal );
	
#else

	gl_FragColor=vec4( vec3( gl_FragCoord.z ),1.0 );

#endif
}
