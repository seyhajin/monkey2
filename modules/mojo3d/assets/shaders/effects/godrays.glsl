
//@renderpasses 0

uniform sampler2D r_SourceBuffer;
uniform sampler2D r_DepthBuffer;

uniform vec2 r_SourceBufferScale;

varying vec2 v_SourceBufferCoords;

//@vertex

attribute vec2 a_Position;
	
void main(){

	v_SourceBufferCoords=a_Position * r_SourceBufferScale;

	gl_Position=vec4( a_Position * 2.0 - 1.0,-1.0,1.0 );
}

//@fragment

uniform vec2 m_LightPosBufferCoords;

uniform int m_NumSamples;

uniform float m_Exposure;

uniform float m_Decay;

uniform float m_Density;

uniform vec4 m_Color;

void main(){

	vec2 coords=v_SourceBufferCoords;

	vec2 delta=m_LightPosBufferCoords-coords;
	
	delta*=1.0/float( m_NumSamples ) * m_Density;
	
	vec3 fragColor=vec3( 0.0 );
	
	for( int i=0;i<m_NumSamples;++i ){
	
		coords+=delta;

		float depth=texture2D( r_DepthBuffer,coords ).r;
		
		vec3 sample=(depth==1.0) ? m_Color.rgb : vec3( 0.0 );
		
		fragColor+=sample;
	}
	
	gl_FragColor=vec4( fragColor*m_Exposure,1.0 );
}
