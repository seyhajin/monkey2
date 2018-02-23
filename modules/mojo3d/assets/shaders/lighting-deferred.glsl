
//@renderpasses 2,6,10,14

//renderpasses:
//
// 2=directional without shadows
// 6=directional with  shadows
// 10=point without shadows
// 14=point with shadows
 
uniform mat4 r_InverseProjectionMatrix;

#define MX2_POINT_LIGHT ((MX2_RENDERPASS&8)!=0)
#define MX2_DIRECTIONAL_LIGHT ((MX2_RENDERPASS&8)==0)
#define MX2_SHADOWED_LIGHT ((MX2_RENDERPASS&4)!=0)

uniform vec2 r_BufferCoordScale;
uniform sampler2D r_ColorBuffer;
uniform sampler2D r_NormalBuffer;
uniform sampler2D r_DepthBuffer;

uniform float r_DepthNear;
uniform float r_DepthFar;

uniform mat4 r_LightViewMatrix;
uniform float r_LightRange;
uniform vec4 r_LightColor;

#if MX2_SHADOWED_LIGHT

uniform float r_ShadowAlpha;

#if MX2_DIRECTIONAL_LIGHT
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

#if MX2_SHADOWED_LIGHT

#if MX2_DIRECTIONAL_LIGHT

float shadowColor(){

//	vec3 dx=dFdx( v_Position );
//	vec3 dy=dFdy( v_Position );
//	vec3 vn=vec4( cross( dx,dy ),0.0 );
//	vec4 vpos=vec4( v_Position + v_Normal*0.01,1.0 );

	if( v_Position.z>=r_ShadowCSMSplits.w ) return 1.0;//(1.0-r_ShadowAlpha)*0.5;
	
	vec4 vpos=vec4( v_Position,1.0 );
	vec2 off;
	
	if( vpos.z<r_ShadowCSMSplits.x ){
		vpos=r_ShadowMatrix0 * vpos;
		off=vec2( 0.0,0.0 );
	}else if( vpos.z<r_ShadowCSMSplits.y ){
		vpos=r_ShadowMatrix1 * vpos;
		off=vec2( 0.5,0.0 );
	}else if( vpos.z<r_ShadowCSMSplits.z ){
		vpos=r_ShadowMatrix2 * vpos;
		off=vec2( 0.0,0.5 );
	}else{
		vpos=r_ShadowMatrix3 * vpos;
		off=vec2( 0.5,0.5 );
	}
	
	vec3 spos=vpos.xyz/vpos.w * vec3( 0.25,0.25,0.5 ) + vec3( 0.25,0.25,0.5 );
	
#if defined( MX2_RGBADEPTHTEXTURES )
	float d=RGBAToFloat( texture2D( r_ShadowCSMTexture,spos.xy+off ) );
#else
	float d=texture2D( r_ShadowCSMTexture,spos.xy+off ).r;
#endif
	
	if( spos.z>d ) return 1.0-r_ShadowAlpha;
	
	return 1.0;
}

#else

float shadowColor(){

	vec4 vpos=vec4( v_Position,1.0 );
	
	vec3 lpos=(r_ShadowMatrix0 * vpos).xyz;
	
	float d=RGBAToFloat( textureCube( r_ShadowCubeTexture,lpos ) );
	
	if( length(lpos) > d * r_LightRange ) return 1.0-r_ShadowAlpha;
	
	return 1.0;
}

#endif

#endif

vec3 lightColor( vec3 color,float metalness,float roughness ){

	vec3 normal=v_Normal;
	float glosiness=1.0-roughness;
	vec3 color0=vec3( 0.04,0.04,0.04 );
	vec3 diffuse=color * (1.0-metalness);
	vec3 specular=(color-color0) * metalness + color0;
	
#if MX2_DIRECTIONAL_LIGHT
	vec3 lvec=normalize( -r_LightViewMatrix[2].xyz );
	float atten=1.0;
#else
	// TODO: https://imdoingitwrong.wordpress.com/2011/01/31/light-attenuation/
	vec3 lvec=r_LightViewMatrix[3].xyz-v_Position;
	float atten=max( 1.0-length( lvec )/r_LightRange,0.0 );
	lvec=normalize( lvec );
#endif

	vec3 vvec=normalize( -v_Position );
	vec3 hvec=normalize( lvec+vvec );

	float hdotl=max( dot( hvec,lvec ),0.0 );
	float ndotl=max( dot( normal,lvec ),0.0 );
	float ndoth=max( dot( normal,hvec ),0.0 );
	
	float spow=pow( 2.0,glosiness * 12.0 );
//	float spow=pow( 2048.0,glosiness );
	
	float fnorm=(spow+2.0)/8.0;
	
	vec3 fschlick=specular + (1.0-specular) * pow( 1.0-hdotl,5.0 ) * glosiness;
	
	specular=fschlick * pow( ndoth,spow ) * fnorm;

	vec3 light=r_LightColor.rgb * ndotl * atten;
	
#if MX2_SHADOWED_LIGHT

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
	
	//debug z coord...
	//
	if( abs( vpos.z-r_DepthNear)>0.00001 ){
		gl_FragColor=vec4( 1.0,0.0,0.0,1.0 );
		return;
	}
	
	v_Position=vpos/vpos.z*depth;
	
	v_Normal=normalize( normal_r.xyz * 2.0 - 1.0 );
	
	vec3 frag=lightColor( color_m.rgb,color_m.a,normal_r.a );
	
	gl_FragColor=vec4( min( frag,8.0 ),1.0 );
}
