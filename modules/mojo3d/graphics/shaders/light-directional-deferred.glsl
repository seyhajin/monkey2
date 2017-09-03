
//@renderpasses 3

uniform mat4 r_InverseProjectionMatrix;

uniform vec2 r_BufferCoordScale;
uniform sampler2D r_ColorBuffer;
uniform sampler2D r_NormalBuffer;
uniform sampler2D r_DepthBuffer;

uniform float r_DepthNear;
uniform float r_DepthFar;

uniform mat4 r_LightViewMatrix;
uniform vec4 r_LightColor;
uniform float r_LightRange;

uniform sampler2D r_ShadowTexture;
uniform mat4 r_ShadowMatrix0;
uniform mat4 r_ShadowMatrix1;
uniform mat4 r_ShadowMatrix2;
uniform mat4 r_ShadowMatrix3;
uniform vec4 r_ShadowSplits;

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

float viewDepth( float depth ){

	return r_DepthFar * r_DepthNear / ( r_DepthFar + depth * ( r_DepthNear - r_DepthFar ) );
}

float evalShadow(){

	vec4 vpos=vec4( v_Position + v_Normal * .05,1.0 );
//	vec4 vpos=vec4( v_Position,1.0 );
	vec4 lpos;
	vec2 off;
	
	if( vpos.z<r_ShadowSplits.x ){
		lpos=r_ShadowMatrix0 * vpos;
		off=vec2( 0.0,0.0 );
	}else if( vpos.z<r_ShadowSplits.y ){
		lpos=r_ShadowMatrix1 * vpos;
		off=vec2( 0.5,0.0 );
	}else if( vpos.z<r_ShadowSplits.z ){
		lpos=r_ShadowMatrix2 * vpos;
		off=vec2( 0.0,0.5 );
	}else{
		lpos=r_ShadowMatrix3 * vpos;
		off=vec2( 0.5,0.5 );
	}
	
	vec3 spos=lpos.xyz/lpos.w * vec3( 0.25,0.25,0.5 ) + vec3( 0.25,0.25,0.5 );

//	spos.z*=0.999;
	
	float d=texture2D( r_ShadowTexture,spos.xy+off ).r;
	
	if( spos.z>d ) return 0.0;
	
	return 1.0;
}

vec3 evalLight( vec3 color,float metalness,float roughness ){

	vec3 normal=v_Normal;
	
	float glosiness=1.0-roughness;
	
	vec3 color0=vec3( 0.04,0.04,0.04 );
	
	vec3 diffuse=color * (1.0-metalness);
	
	vec3 specular=(color-color0) * metalness + color0;
	
	//lighting
	
	vec3 vvec=normalize( -v_Position );
	vec3 lvec=normalize( -r_LightViewMatrix[2].xyz );
	vec3 hvec=normalize( lvec+vvec );

	float spow=pow( 2.0,glosiness * 12.0 );
//	float spow=pow( 4096.0,glosiness );
//	float spow=exp2( 12.0 * glosiness + 1.0 );

	float fnorm=(spow+2.0)/8.0;
	
	float hdotl=max( dot( hvec,lvec ),0.0 );
	vec3 fschlick=specular + (1.0-specular) * pow( 1.0-hdotl,5.0 ) * glosiness;
	
	float ndotl=max( dot( normal,lvec ),0.0 );
	float ndoth=max( dot( normal,hvec ),0.0 );
	
	vec3 light=r_LightColor.rgb * ndotl;
	
	specular=pow( ndoth,spow ) * fnorm * fschlick;
	
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
	
	float shadow=evalShadow();
	
	vec3 light=evalLight( color_m.rgb,color_m.a,normal_r.a );
	
	gl_FragColor=vec4( min( light * shadow,8.0 ),1.0 );
	
//	gl_FragColor=vec4( light * shadow,1.0 );
}

