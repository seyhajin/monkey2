
//@renderpasses 0

varying vec2 v_ClipPosition;

varying vec2 v_TexCoord0;

//@vertex

uniform vec2 r_BufferCoordScale;

attribute vec2 a_Position;	//0...1 (1=viewport size)

void main(){

	v_ClipPosition=a_Position * 2.0 - 1.0;
	
	v_TexCoord0=a_Position * r_BufferCoordScale;
	
	gl_Position=vec4( v_ClipPosition,-1.0,1.0 );
}

//@fragment

uniform mat4 r_InverseProjectionMatrix;

uniform sampler2D r_DepthBuffer;
uniform float r_DepthNear;
uniform float r_DepthFar;

uniform vec4 r_FogColor;
uniform float r_FogNear;
uniform float r_FogFar;

float viewDepth( float depth ){

	return r_DepthFar * r_DepthNear / ( r_DepthFar + depth * ( r_DepthNear - r_DepthFar ) );
}

void main(){

	float fog=0.0;

	float depth=texture2D( r_DepthBuffer,v_TexCoord0 ).r;
	
	if( depth<1.0 ){

		depth=viewDepth( depth );
		
		vec4 vpos4=r_InverseProjectionMatrix * vec4( v_ClipPosition,-1.0,1.0 );
		
		vec3 vpos=vpos4.xyz/vpos4.w;
		
		vec3 v_Position=vpos/vpos.z*depth;
		
		fog=clamp( (length( v_Position )-r_FogNear)/(r_FogFar-r_FogNear),0.0,1.0 ) * r_FogColor.a;
	}
	
	gl_FragColor=vec4( r_FogColor.rgb * fog,fog );
}
