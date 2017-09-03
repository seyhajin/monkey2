
//@renderpasses 2

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

varying vec2 v_ClipPosition;
varying vec2 v_TexCoord0;

//@vertex

attribute vec2 a_Position;
	
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

vec3 evalLight( vec3 color,float metalness,float roughness ){

	vec3 normal=v_Normal;
	
	float glosiness=1.0-roughness;
	
	vec3 color0=vec3( 0.04,0.04,0.04 );
	
	vec3 diffuse=color * (1.0-metalness);
	
	vec3 specular=(color-color0) * metalness + color0;
	
	//lighting
	
	vec3 lightDir=r_LightViewMatrix[3].xyz-v_Position;

	//Cool! https://imdoingitwrong.wordpress.com/2011/01/31/light-attenuation/
	//	
	float atten=1.0/( pow( length( lightDir/r_LightRange ),2.0 ) );
	
	vec3 vvec=normalize( -v_Position );
	vec3 lvec=normalize( lightDir );
	vec3 hvec=normalize( lvec+vvec );

	float spow=pow( 2.0,glosiness * 12.0 );
//	float spow=pow( 4096.0,glosiness );
//	float spow=exp2( 12.0 * glosiness + 1.0 );

	float fnorm=(spow+2.0)/8.0;
	
	float hdotl=max( dot( hvec,lvec ),0.0 );
	vec3 fschlick=specular + (1.0-specular) * pow( 1.0-hdotl,5.0 ) * glosiness;
	
	float ndotl=max( dot( normal,lvec ),0.0 );
	float ndoth=max( dot( normal,hvec ),0.0 );
	
	vec3 lightColor=r_LightColor.rgb * ndotl * atten;
	
	specular=pow( ndoth,spow ) * fnorm * fschlick;
	
	return (diffuse+specular) * lightColor;
}

void main(){

	vec4 color_m=texture2D( r_ColorBuffer,v_TexCoord0 );
	
	vec4 normal_r=texture2D( r_NormalBuffer,v_TexCoord0 );
	
	float depth=viewDepth( texture2D( r_DepthBuffer,v_TexCoord0 ).r );

	vec4 vpos4=r_InverseProjectionMatrix * vec4( v_ClipPosition,-1.0,1.0 );
	
	vec3 vpos=vpos4.xyz/vpos4.w;

	/*	
	if( abs( vpos.z-r_DepthNear)>0.00001 ){
		gl_FragColor=vec4( 1.0,0.0,0.0,1.0 );
		return;
	}
	if( abs( vpos.x )>=1.0 || abs( vpos.y )>=1.0 ){
		gl_FragColor=vec4( 0.0,1.0,0.0,1.0 );
		return;
	}
	*/
	
	v_Position=vpos/vpos.z*depth;
	
	v_Normal=normalize( normal_r.xyz * 2.0 - 1.0 );
	
	vec3 light=evalLight( color_m.rgb,color_m.a,normal_r.a );
	
	gl_FragColor=vec4( min( light,8.0 ),1.0 );
}

