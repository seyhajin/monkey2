//@renderpasses 0

//renderer uniforms

uniform float r_Time;

uniform mat4 r_ViewProjectionMatrix;

//instance uniforms

//uniform mat4 i_ModelViewProjectionMatrix;

uniform mat4 i_ModelMatrix;

//material uniforms

uniform sampler2D m_ColorTexture;

uniform vec4 m_ColorFactor;

//pbuffer uniforms

uniform vec3 x_Gravity;		//gravity of particle

uniform float x_Duration;	//duration of particle

uniform float x_Fade;		//start fade out time

//varyings...

varying vec4 v_Color;

//@vertex

attribute vec3 a_Position;		//velocity

attribute vec2 a_TexCoord0;		//s=time, t=size

attribute vec4 a_Tangent;		//color

void main(){

	float t=(r_Time-a_TexCoord0.s);
	
	float a=1.0-clamp( (t-x_Fade)/(x_Duration-x_Fade),0.0,1.0 );
	
	v_Color=m_ColorFactor * vec4( a_Tangent.rgb,a_Tangent.a * a );
	
	vec4 position=i_ModelMatrix * vec4( a_Position * t,1.0 );
	
	position.xyz+=x_Gravity * t * t * .5;
	
	gl_Position=r_ViewProjectionMatrix * position;
	
	gl_PointSize=a_TexCoord0.t/gl_Position.w;
}

//@fragment

void main(){

	vec4 tcolor=texture2D( m_ColorTexture,gl_PointCoord );

	vec3 color=pow( tcolor.rgb,vec3( 2.2 ) ) * v_Color.rgb * v_Color.a;
	
	float alpha=tcolor.a * v_Color.a;
	
#if defined( MX2_SRGBOUTPUT )
	gl_FragColor=vec4( pow( color,vec3( 1.0/2.2 ) ),alpha );
#else
	gl_FragColor=vec4( color,alpha );
#endif
}
