
//@renderpasses 0

varying vec2 v_ClipPosition;

//@vertex

attribute vec2 a_Position;	//0...1

void main(){

	v_ClipPosition=a_Position * 2.0 - 1.0;

	gl_Position=vec4( v_ClipPosition,0.0,1.0 );
}

//@fragment

uniform mat3 r_EnvMatrix;

uniform samplerCube r_SkyTexture;

uniform mat4 r_InverseProjectionMatrix;

void main(){

	vec4 clip=r_InverseProjectionMatrix * vec4( v_ClipPosition,0.0,1.0 );

	vec3 tv=r_EnvMatrix * (clip.xyz/clip.w);
	
	gl_FragColor=vec4( pow( textureCube( r_SkyTexture,tv ).rgb,vec3( 2.2 ) ),1.0 );
}
