
//@renderpasses 1,3

//renderer uniforms

uniform float r_Time;

uniform mat4 r_ProjectionMatrix;

uniform mat4 r_ViewMatrix;

uniform vec4 r_FogColor;

uniform float r_FogNear;

uniform float r_FogFar;

//instance uniforms

uniform mat4 i_ModelViewMatrix;

uniform mat4 i_ModelMatrix;

uniform float i_Alpha;

//material uniforms

uniform sampler2D m_ColorTexture;

uniform vec4 m_ColorFactor;

//pbuffer uniforms

uniform vec3 x_Gravity;		//gravity of particle

uniform float x_Duration;	//duration of particle

uniform float x_Fade;		//start fade out time

//varyings...

varying vec3 v_Position;

varying vec4 v_Color;

//@vertex

attribute vec3 a_Position;		//velocity

attribute vec2 a_TexCoord0;		//s=time, t=size

attribute vec4 a_Tangent;		//color

void main(){

	float t=(r_Time-a_TexCoord0.s);
	
	float a=1.0-clamp( (t-x_Fade)/(x_Duration-x_Fade),0.0,1.0 );

	v_Color=m_ColorFactor * vec4( a_Tangent.rgb,a_Tangent.a * a * i_Alpha );
	
	vec4 position=i_ModelMatrix * vec4( a_Position * t,1.0 );
	
	position.xyz+=x_Gravity * t * t * .5;
	
	position=r_ViewMatrix * position;
	
	v_Position=position.xyz;
	
	gl_Position=r_ProjectionMatrix * position;
	
	gl_PointSize=a_TexCoord0.t/gl_Position.w;
}

//@fragment

void main(){

	vec4 color=texture2D( m_ColorTexture,gl_PointCoord );

	float alpha=color.a * v_Color.a;
	
	vec3 frag=pow( color.rgb,vec3( 2.2 ) ) * v_Color.rgb;
	
	float fog=clamp( (length( v_Position )-r_FogNear)/(r_FogFar-r_FogNear),0.0,1.0 ) * r_FogColor.a;
	
	frag=mix( frag,r_FogColor.rgb,fog );
	
	frag*=alpha;
	
#if defined( MX2_SRGBOUTPUT )
	gl_FragColor=vec4( pow( frag,vec3( 1.0/2.2 ) ),alpha );
#else
	gl_FragColor=vec4( frag,alpha );
#endif
}
