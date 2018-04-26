
//@renderpasses 0

//@import "std"

//@vertex

void main(){

	transformQuadVertex();
}

//@fragment

void main(){

	vec4 clip=r_InverseProjectionMatrix * vec4( v_ClipPosition,1.0,1.0 );

	vec3 tv=r_EnvMatrix * (clip.xyz/clip.w);
	
	vec3 frag=pow( textureCube( r_SkyTexture,tv ).rgb,vec3( 2.2 ) );
	
#if MX2_DEFERREDRENDERER
	gl_FragData[0]=vec4( frag,1.0 );					//accum
	gl_FragData[1]=vec4( 0.0,0.0,0.0,1.0 );				//color_m
	gl_FragData[2]=vec4( 0.5,0.5,0.5,1.0 );				//normal_r
#else
	emitLinearFragment( frag,1.0 );
#endif
}
