
//@renderpasses 0

uniform sampler2D r_AccumBuffer;

uniform vec2 r_BufferCoordScale;

varying vec2 v_TexCoord0;

//@vertex

attribute vec2 a_Position;	//0...1 (1=viewport size)

void main(){

	v_TexCoord0=a_Position * r_BufferCoordScale;

	gl_Position=vec4( a_Position * 2.0 - 1.0,-1.0,1.0 );
}

//@fragment

void main(){

	gl_FragColor=vec4( pow( texture2D( r_AccumBuffer,v_TexCoord0 ).rgb,vec3( 1.0/2.2 ) ),1.0 );
}
