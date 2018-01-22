
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
	
	vec3 frag=pow( textureCube( r_SkyTexture,tv ).rgb,vec3( 2.2 ) );
	
	gl_FragData[0]=vec4( frag,1.0 );					//accum
	
	gl_FragData[1]=vec4( 0.0,0.0,0.0,1.0 );				//color_m
	
	gl_FragData[2]=vec4( 0.5,0.5,1.0,1.0 );				//normal_r
}
