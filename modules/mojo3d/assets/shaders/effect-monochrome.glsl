//@renderpasses 0

uniform vec2 m_SourceCoordScale;

varying vec2 v_TexCoord0;

//@vertex

attribute vec2 a_Position;	//0...1 (1=viewport size)

void main(){

	v_TexCoord0=a_Position * m_SourceCoordScale;

	gl_Position=vec4( a_Position * 2.0 - 1.0,-1.0,1.0 );
}

//@fragment

uniform sampler2D m_SourceTexture;

uniform float m_Level;

void main(){

	vec4 color=texture2D( m_SourceTexture,v_TexCoord0 );

	float i=(color.r+color.g+color.b)/3.0;
	
	gl_FragColor=vec4( mix( color.rgb,vec3( i ),m_Level ),color.a );
}
