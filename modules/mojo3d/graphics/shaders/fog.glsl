
//@renderpasses 0

varying vec2 v_TexCoord0;

//@vertex

uniform vec2 r_BufferCoordScale;

attribute vec2 a_Position;	//0...1 (1=viewport size)

void main(){

	v_TexCoord0=a_Position * r_BufferCoordScale;
	
	gl_Position=vec4( a_Position * 2.0 - 1.0,-1.0,1.0 );
}

//@fragment

uniform sampler2D r_DepthBuffer;
uniform float r_DepthNear;
uniform float r_DepthFar;

uniform vec4 m_Color;
uniform float m_Near;
uniform float m_Far;

float viewDepth( float depth ){

	return r_DepthFar * r_DepthNear / ( r_DepthFar + depth * ( r_DepthNear - r_DepthFar ) );
}

void main(){

	float depth=viewDepth( texture2D( r_DepthBuffer,v_TexCoord0 ).r );
	
	float fog=clamp( (depth-m_Near)/(m_Far-m_Near),0.0,1.0 ) * m_Color.a;
	
	gl_FragColor=vec4( m_Color.rgb * fog,fog );	//premultiplied alpha!
}
