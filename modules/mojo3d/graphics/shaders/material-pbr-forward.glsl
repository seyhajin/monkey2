
//@renderpasses 1,2,3,6,7,10,11,14,15,16,17

//render passes:
//
// 1  = ambient.
// 2  = lighting.
// 4  = shadowed.
// 8  = light type - 0=directional, 1=point
// 16 = directional shadow casters.
// 17 = point shadow casters.

#define MX2_COLORPASS ((MX2_RENDERPASS&16)==0)
#define MX2_AMBIENTPASS (MX2_RENDERPASS&1)
#define MX2_LIGHTINGPASS (MX2_RENDERPASS&2)
#define MX2_SHADOWEDPASS (MX2_RENDERPASS&4)
#define MX2_DIRECTIONALLIGHT ((MX2_RENDERPASS&8)==0)
 
//instance uniforms
//
uniform mat4 i_ModelViewMatrix;
uniform mat4 i_ModelViewProjectionMatrix;
uniform mat3 i_ModelViewNormalMatrix;

#if defined( MX2_BONED )
uniform mat4 i_ModelBoneMatrices[96];
#endif

//material uniforms

#if MX2_COLORPASS && defined( MX2_TEXTURED )
uniform mat3 m_TextureMatrix;
#endif

#if MX2_AMBIENTPASS

//renderer uniforms
//
uniform vec4 r_AmbientDiffuse;
uniform samplerCube r_EnvTexture;
uniform mat3 r_EnvMatrix;

#endif

#if MX2_LIGHTINGPASS

uniform mat4 r_LightViewMatrix;
uniform vec4 r_LightColor;
uniform float r_LightRange;

#if MX2_SHADOWEDPASS

#if MX2_DIRECTIONALLIGHT
uniform sampler2D r_ShadowCSMTexture;
uniform vec4 r_ShadowCSMSplits;
uniform mat4 r_ShadowMatrix0;
uniform mat4 r_ShadowMatrix1;
uniform mat4 r_ShadowMatrix2;
uniform mat4 r_ShadowMatrix3;
#else
uniform samplerCube r_ShadowCubeTexture;
uniform mat4 r_ShadowMatrix0;
#endif

#endif	//MX2_SHADOWEDPASS

#endif	//MX2_LIGHTINGPASS

#if MX2_RENDERPASS==17
uniform float r_LightRange;
#endif

//pbr varyings...
//
varying vec3 v_Position;
varying vec3 v_Normal;
#if MX2_COLORPASS && defined( MX2_TEXTURED )
varying vec2 v_TexCoord0;
#if defined( MX2_BUMPMAPPED )
varying mat3 v_TanMatrix;
#endif
#endif

//@vertex

attribute vec4 a_Position;

#if MX2_COLORPASS
attribute vec3 a_Normal;
#if defined( MX2_TEXTURED )
attribute vec2 a_TexCoord0;
#if defined( MX2_BUMPMAPPED )
attribute vec4 a_Tangent;
#endif
#endif
#endif
	
#if defined( MX2_BONED )

attribute vec4 a_Weights;
attribute vec4 a_Bones;

void main(){

	mat4 m0=i_ModelBoneMatrices[ int( a_Bones.x ) ];
	mat4 m1=i_ModelBoneMatrices[ int( a_Bones.y ) ];
	mat4 m2=i_ModelBoneMatrices[ int( a_Bones.z ) ];
	mat4 m3=i_ModelBoneMatrices[ int( a_Bones.a ) ];
	
	vec4 b_Position=
		m0 * a_Position * a_Weights.x +
		m1 * a_Position * a_Weights.y +
		m2 * a_Position * a_Weights.z +
		m3 * a_Position * a_Weights.a;
		
	// view space position
	v_Position=( i_ModelViewMatrix * b_Position ).xyz;

#if MX2_COLORPASS

	mat3 n0=mat3( m0[0].xyz,m0[1].xyz,m0[2].xyz );
	mat3 n1=mat3( m1[0].xyz,m1[1].xyz,m1[2].xyz );
	mat3 n2=mat3( m2[0].xyz,m2[1].xyz,m2[2].xyz );
	mat3 n3=mat3( m3[0].xyz,m3[1].xyz,m3[2].xyz );

	vec3 b_Normal=normalize( 
		n0 * a_Normal * a_Weights.x +
		n1 * a_Normal * a_Weights.y +
		n2 * a_Normal * a_Weights.z +
		n3 * a_Normal * a_Weights.a );
		
#if defined( MX2_BUMPMAPPED )
	vec4 b_Tangent=vec4( normalize( 
		n0 * a_Tangent.xyz * a_Weights.x +
		n1 * a_Tangent.xyz * a_Weights.y +
		n2 * a_Tangent.xyz * a_Weights.z +
		n3 * a_Tangent.xyz * a_Weights.a ),a_Tangent.w );
#endif

	// viewspace normal
	v_Normal=i_ModelViewNormalMatrix * b_Normal;
	
#if MX2_COLORPASS && defined( MX2_TEXTURED )
	// texture coord0
	v_TexCoord0=(m_TextureMatrix * vec3(a_TexCoord0,1.0)).st;
#if defined( MX2_BUMPMAPPED )
	// viewspace tangent matrix
	v_TanMatrix[2]=v_Normal;
	v_TanMatrix[0]=i_ModelViewNormalMatrix * b_Tangent.xyz;
	v_TanMatrix[1]=cross( v_TanMatrix[0],v_TanMatrix[2] ) * b_Tangent.a;
#endif
#endif
	
#endif	//MX2_COLORPASS
	
	gl_Position=i_ModelViewProjectionMatrix * b_Position;
}

#else	//MX2_BONED

void main(){

	// view space position
	v_Position=(i_ModelViewMatrix * a_Position).xyz;

#if MX2_COLORPASS

	// viewspace normal
	v_Normal=i_ModelViewNormalMatrix * a_Normal;
	
#if defined( MX2_TEXTURED )
	// texture coord0
	v_TexCoord0=(m_TextureMatrix * vec3(a_TexCoord0,1.0)).st;
#if defined( MX2_BUMPMAPPED )
	// viewspace tangent matrix
	v_TanMatrix[2]=v_Normal;
	v_TanMatrix[0]=i_ModelViewNormalMatrix * a_Tangent.xyz;
	v_TanMatrix[1]=cross( v_TanMatrix[0],v_TanMatrix[2] ) * a_Tangent.a;
#endif
#endif

#endif	//MX2_COLORPASS
	
	gl_Position=i_ModelViewProjectionMatrix * a_Position;
}

#endif	//MX2_BONED

//@fragment

vec4 FloatToRGBA( float value ){

	const float MaxFloat=0.9999999;

	value=clamp( value,0.0,MaxFloat );

	vec4 rgba=fract( vec4( 1.0, 255.0, 65025.0, 16581375.0 ) * value );
	
	return rgba-rgba.yzww * vec4( 1.0/255.0, 1.0/255.0, 1.0/255.0, 0.0 );
}

float RGBAToFloat( vec4 rgba ){

	return dot( rgba,vec4( 1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0 ) );
}

#if MX2_COLORPASS

#if MX2_SHADOWEDPASS

#if MX2_DIRECTIONALLIGHT

float shadowColor( vec3 normal ){

	vec4 vpos=vec4( v_Position + normal * .05,1.0 );
	vec4 lpos;
	vec2 off;
	
	if( vpos.z<r_ShadowCSMSplits.x ){
		lpos=r_ShadowMatrix0 * vpos;
		off=vec2( 0.0,0.0 );
	}else if( vpos.z<r_ShadowCSMSplits.y ){
		lpos=r_ShadowMatrix1 * vpos;
		off=vec2( 0.5,0.0 );
	}else if( vpos.z<r_ShadowCSMSplits.z ){
		lpos=r_ShadowMatrix2 * vpos;
		off=vec2( 0.0,0.5 );
	}else{
		lpos=r_ShadowMatrix3 * vpos;
		off=vec2( 0.5,0.5 );
	}
	
	vec3 spos=lpos.xyz/lpos.w * vec3( 0.25,0.25,0.5 ) + vec3( 0.25,0.25,0.5 );

//	spos.z*=0.999;

#if defined( MX2_RGBADEPTHTEXTURES )
	float d=RGBAToFloat( texture2D( r_ShadowCSMTexture,spos.xy+off ) );
#else
	float d=texture2D( r_ShadowCSMTexture,spos.xy+off ).r;
#endif
	
	if( spos.z>d ) return 0.0;
	
	return 1.0;
}

#else	//MX2_DIRECTIONALLIGHT

float shadowColor( vec3 normal ){

	vec4 vpos=vec4( v_Position + normal * .05,1.0 );
	
	vec3 lpos=(r_ShadowMatrix0 * vpos).xyz;
	
	float d=RGBAToFloat( textureCube( r_ShadowCubeTexture,lpos ) );
	
	if( length(lpos) > d * r_LightRange ) return 0.0;
	
	return 1.0;
}

#endif	//MX2_DIRECTIONALLIGHT

#endif	//MX2_SHADOWEDPASS

vec3 fragColor( vec3 color,vec3 emissive,float metalness,float roughness,float occlusion,vec3 normal ){

	float glosiness=1.0-roughness;
	vec3 color0=vec3( 0.04,0.04,0.04 );
	vec3 diffuse=color * (1.0-metalness);
	vec3 specular=(color-color0) * metalness + color0;
	vec3 vvec=normalize( -v_Position );
	
	vec3 frag=vec3( 0.0 );

#if MX2_AMBIENTPASS
	
	//ambient color
	
	vec3 rvec=r_EnvMatrix * reflect( v_Position,normal );
	float lod=textureCube( r_EnvTexture,rvec,10.0 ).a * 255.0 - 10.0;
	if( lod>0.0 ) lod=textureCube( r_EnvTexture,rvec ).a * 255.0;
	vec3 ambenv=pow( textureCube( r_EnvTexture,rvec,max( roughness*10.0-lod,0.0 ) ).rgb,vec3( 2.2 ) );
	
	float ndotv=max( dot( normal,vvec ),0.0 );

	vec3 fschlick1=specular + (1.0-specular) * pow( 1.0-ndotv,5.0 ) * glosiness;

	vec3 ambdiff=diffuse * r_AmbientDiffuse.rgb;
	vec3 ambspec=ambenv * fschlick1;
	frag+=(ambdiff+ambspec) * occlusion + emissive;

#endif	//MX2_AMBIENTPASS

#if MX2_LIGHTINGPASS

	//lighting color
	
	float spow=pow( 2.0,glosiness * 12.0 );				//specular power
	float fnorm=(spow+2.0)/8.0;							//normalization factor
	float atten=1.0;
	
#if MX2_DIRECTIONALLIGHT
	vec3 lvec=normalize( -r_LightViewMatrix[2].xyz );
#else
	vec3 lvec=r_LightViewMatrix[3].xyz-v_Position;
	float ldist=length( lvec );
    lvec/=ldist;
	atten=max( 1.0-(ldist/r_LightRange),0.0 );
#endif
	
	vec3 hvec=normalize( lvec+vvec );					//halfway vector

	float hdotl=max( dot( hvec,lvec ),0.0 );
	
	vec3 fschlick2=specular + (1.0-specular) * pow( 1.0-hdotl,5.0 ) * glosiness;

	float ndotl=max( dot( normal,lvec ),0.0 );
	float ndoth=max( dot( normal,hvec ),0.0 );
	
	vec3 lightspec=pow( ndoth,spow ) * fschlick2 * fnorm;
	
	vec3 light=(diffuse+lightspec) * r_LightColor.rgb * ndotl * atten;

#if MX2_SHADOWEDPASS
	float shadow=shadowColor( normal );
	
	light*=shadow;
#endif

	frag+=light;
	
#endif	//MX2_LIGHTINGPASS

	return frag;
}

#if defined( MX2_TEXTURED)
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

void main(){

#if defined( MX2_TEXTURED )
	vec3 color=pow( texture2D( m_ColorTexture,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * m_ColorFactor.rgb;
	vec3 emissive=pow( texture2D( m_EmissiveTexture,v_TexCoord0 ).rgb,vec3( 2.2 ) ) * m_EmissiveFactor.rgb;
	float metalness=texture2D( m_MetalnessTexture,v_TexCoord0 ).b * m_MetalnessFactor;
	float roughness=texture2D( m_RoughnessTexture,v_TexCoord0 ).g * m_RoughnessFactor;
	float occlusion=texture2D( m_OcclusionTexture,v_TexCoord0 ).r;
	
#if defined( MX2_BUMPMAPPED )
	vec3 normal=texture2D( m_NormalTexture,v_TexCoord0 ).xyz * 2.0 - 1.0;
	normal=normalize( v_TanMatrix * normal );
#else
	vec3 normal=normalize( v_Normal );
#endif
	
#else
	vec3 color=m_ColorFactor.rgb;
	vec3 emissive=m_EmissiveFactor.rgb;
	float metalness=m_MetalnessFactor;
	float roughness=m_RoughnessFactor;
	float occlusion=1.0;
	vec3 normal=normalize( v_Normal );
#endif

	vec3 frag=fragColor( color,emissive,metalness,roughness,occlusion,normal );
	
#if defined( MX2_SRGBOUTPUT )
	gl_FragColor=vec4( pow( frag,vec3( 1.0/2.2 ) ),1.0 );
#else
	gl_FragColor=vec4( frag,1.0 );
#endif
}

#else	//MX2_COLORPASS

void main(){

#if MX2_RENDERPASS==17
	gl_FragColor=FloatToRGBA( min( length( v_Position )/r_LightRange,1.0 ) );
#elif defined( MX2_RGBADEPTHTEXTURES )
	gl_FragColor=FloatToRGBA( gl_FragCoord.z ),1.0 );
#else
	gl_FragColor=vec4( vec3( gl_FragCoord.z ),1.0 );
#endif

}

#endif	//MX2_COLORPASS
