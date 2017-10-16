
//@renderpasses 0

varying vec2 v_ClipPosition;

//@vertex

attribute vec2 a_Position;	//0...1

void main(){

	v_ClipPosition=a_Position * 2.0 - 1.0;

	gl_Position=vec4( v_ClipPosition,1.0,1.0 );
}

//@fragment

uniform mat3 r_EnvMatrix;

uniform samplerCube r_SkyTexture;

uniform mat4 r_InverseProjectionMatrix;

void main(){

	vec4 clip=r_InverseProjectionMatrix * vec4( v_ClipPosition,1.0,1.0 );

	vec3 tv=r_EnvMatrix * (clip.xyz/clip.w);
	
	vec3 color=textureCube( r_SkyTexture,tv ).rgb;
	
#if defined( MX2_LINEAROUTPUT )
	gl_FragColor=vec4( pow( color,vec3( 2.2 ) ),1.0 );
#else
	gl_FragColor=vec4( color,1.0 );
#endif
}
