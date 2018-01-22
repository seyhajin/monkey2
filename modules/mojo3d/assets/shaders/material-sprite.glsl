
//@renderpasses 1,3

//render uniforms

uniform vec4 r_FogColor;

uniform float r_FogNear;

uniform float r_FogFar;

//material uniforms

uniform mat3 m_TextureMatrix;

//instance uniforms...

uniform mat4 i_ModelViewProjectionMatrix;

uniform mat4 i_ModelViewMatrix;

uniform float i_Alpha;

//varyings...

varying vec3 v_Position;

varying vec2 v_TexCoord0;

//@vertex

attribute vec4 a_Position;

attribute vec2 a_TexCoord0;

void main(){

	v_Position=(i_ModelViewMatrix * a_Position).xyz;

	v_TexCoord0=(m_TextureMatrix * vec3(a_TexCoord0,1.0)).st;
	
	gl_Position=i_ModelViewProjectionMatrix * a_Position;
}

//@fragment

uniform sampler2D m_ColorTexture;

uniform vec4 m_ColorFactor;

uniform float m_AlphaDiscard;

void main(){

	vec4 color=texture2D( m_ColorTexture,v_TexCoord0 );

	float alpha=color.a * m_ColorFactor.a * i_Alpha;
	
	if( alpha<m_AlphaDiscard ) discard;

	vec3 frag=pow( color.rgb,vec3( 2.2 ) ) * m_ColorFactor.rgb;
	
	float fog=clamp( (length( v_Position )-r_FogNear)/(r_FogFar-r_FogNear),0.0,1.0 ) * r_FogColor.a;
	
	frag=mix( frag,r_FogColor.rgb,fog );
	
	alpha*=1.0-fog;
	
	frag*=alpha;
	
#if defined( MX2_SRGBOUTPUT )
	gl_FragColor=vec4( pow( frag,vec3( 1.0/2.2 ) ),alpha );
#else
	gl_FragColor=vec4( frag,alpha );
#endif
}
