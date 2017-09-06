//@renderpasses 0,1,2,3

//renderpasses:
// 0=directional light without shadow.
// 1=point light without shadow.
// 2=directional light with shadow.
// 3=point light with shadow.

uniform mat4 r_InverseProjectionMatrix;

#define MX2_DIRECTIONALPASS (MX2_RENDERPASS==0 || MX2_RENDERPASS==2)
#define MX2_SHADOWEDPASS (MX2_RENDERPASS==2 || MX2_RENDERPASS==3)

uniform vec2 r_BufferCoordScale;
uniform sampler2D r_ColorBuffer;
uniform sampler2D r_NormalBuffer;
uniform sampler2D r_DepthBuffer;

uniform float r_DepthNear;
uniform float r_DepthFar;

uniform mat4 r_LightViewMatrix;
uniform float r_LightRange;
uniform vec4 r_LightColor;

#if MX2_RENDERPASS==2
uniform sampler2D r_ShadowCSMTexture;
uniform vec4 r_ShadowCSMSplits;
uniform mat4 r_ShadowMatrix0;
uniform mat4 r_ShadowMatrix1;
uniform mat4 r_ShadowMatrix2;
uniform mat4 r_ShadowMatrix3;
#elif MX2_RENDERPASS==3
uniform samplerCube r_ShadowCubeTexture;
uniform mat4 r_ShadowMatrix0;
#endif

varying vec2 v_ClipPosition;
varying vec2 v_TexCoord0;

//@vertex

attribute vec2 a_Position;	//0...1 (1=viewport size)

void main(){

	v_ClipPosition=a_Position * 2.0 - 1.0;
	
	v_TexCoord0=a_Position * r_BufferCoordScale;
	
	gl_Position=vec4( v_ClipPosition,-1.0,1.0 );
}

//@fragment

vec3 v_Position;
vec3 v_Normal;

//can't handle 1!
vec4 FloatToRGBA( float value ){

	const float MaxFloat=0.9999999;

	value=clamp( value,0.0,MaxFloat );

	vec4 rgba=fract( vec4( 1.0, 255.0, 65025.0, 16581375.0 ) * value );
	
	return rgba-rgba.yzww * vec4( 1.0/255.0, 1.0/255.0, 1.0/255.0, 0.0 );
}

float RGBAToFloat( vec4 rgba ){

	return dot( rgba,vec4( 1.0, 1.0/255.0, 1.0/65025.0, 1.0/16581375.0 ) );
}

float viewDepth( float depth ){

	return r_DepthFar * r_DepthNear / ( r_DepthFar + depth * ( r_DepthNear - r_DepthFar ) );
}

#if MX2_RENDERPASS==2

float shadowColor(){

//	vec4 vpos=vec4( v_Position + v_Normal * .05,1.0 );
	vec4 vpos=vec4( v_Position + v_Normal * .06,1.0 );
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

#elif MX2_RENDERPASS==3

float shadowColor(){

	vec4 vpos=vec4( v_Position + v_Normal * .05,1.0 );
	vec3 lpos=(r_ShadowMatrix0 * vpos).xyz;
	
	float d=RGBAToFloat( textureCube( r_ShadowCubeTexture,lpos ) );
	
	if( length( lpos )>=d*r_LightRange ) return 0.0;
	
	return 1.0;
}

#endif

vec3 lightColor( vec3 color,float metalness,float roughness ){

	vec3 normal=v_Normal;
	float glosiness=1.0-roughness;
	vec3 color0=vec3( 0.04,0.04,0.04 );
	vec3 diffuse=color * (1.0-metalness);
	vec3 specular=(color-color0) * metalness + color0;
	float atten=1.0;
	
#if MX2_DIRECTIONALPASS
	vec3 lvec=normalize( -r_LightViewMatrix[2].xyz );
#else
	// https://imdoingitwrong.wordpress.com/2011/01/31/light-attenuation/
	//
	vec3 lvec=r_LightViewMatrix[3].xyz-v_Position;
	float ldist=length( lvec );
    lvec/=ldist;
	atten=max( 1.0-(ldist/r_LightRange),0.0 );
    
//    atten=1.0;
	
//	atten=1.0/( pow( length( lvec/r_LightRange ),2.0 ) );	//Cool! https://imdoingitwrong.wordpress.com/2011/01/31/light-attenuation/
//	atten=1.0/( pow( length( lvec )/r_LightRange,2.0 ) );	//Cool! https://imdoingitwrong.wordpress.com/2011/01/31/light-attenuation/
//	lvec=normalize( lvec );

#endif
	vec3 vvec=normalize( -v_Position );
	vec3 hvec=normalize( lvec+vvec );

	float spow=pow( 2.0,glosiness * 12.0 );
//	float spow=pow( 4096.0,glosiness );
//	float spow=exp2( 12.0 * glosiness + 1.0 );
	float fnorm=(spow+2.0)/8.0;
	
	float hdotl=max( dot( hvec,lvec ),0.0 );
	
	vec3 fschlick=specular + (1.0-specular) * pow( 1.0-hdotl,5.0 ) * glosiness;
	
	float ndotl=max( dot( normal,lvec ),0.0 );
	float ndoth=max( dot( normal,hvec ),0.0 );
	
	specular=pow( ndoth,spow ) * fnorm * fschlick;

	vec3 light=r_LightColor.rgb * ndotl * atten;
	
#if MX2_SHADOWEDPASS
	light*=shadowColor();
#endif
	
	return (diffuse+specular) * light;
}

void main(){

	vec4 color_m=texture2D( r_ColorBuffer,v_TexCoord0 );
	
	vec4 normal_r=texture2D( r_NormalBuffer,v_TexCoord0 );
	
	float depth=viewDepth( texture2D( r_DepthBuffer,v_TexCoord0 ).r );

	vec4 vpos4=r_InverseProjectionMatrix * vec4( v_ClipPosition,-1.0,1.0 );
	
	vec3 vpos=vpos4.xyz/vpos4.w;

	//debug vpos x/y
	//
	//if( abs( vpos.x )>=1.0 || abs( vpos.y )>=1.0 ){
	//	gl_FragColor=vec4( 0.0,0.0,1.0,1.0 );
	//	return;
	//}
	
	//debug z
	//
	//if( abs( vpos.z-r_DepthNear)>0.00001 ){
	//	gl_FragColor=vec4( 1.0,0.0,0.0,1.0 );
	//	return;
	//}
	
	v_Position=vpos/vpos.z*depth;
	
	v_Normal=normalize( normal_r.xyz * 2.0 - 1.0 );
	
	vec3 light=lightColor( color_m.rgb,color_m.a,normal_r.a );

	gl_FragColor=vec4( min( light,8.0 ),1.0 );
}
