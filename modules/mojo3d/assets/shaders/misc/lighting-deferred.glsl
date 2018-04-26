
//@renderpasses 4,8,20,24

//@import "pbr"

//@vertex

void main(){

	transformQuadVertex();
}

//@fragment

void main(){

	vec4 color_m=texture2D( r_ColorBuffer,v_BufferCoords );
	
	vec4 normal_r=texture2D( r_NormalBuffer,v_BufferCoords );
	
	vec3 position=fragmentPosition();

	vec3 normal=normalize( normal_r.xyz * 2.0 - 1.0 );
	
	emitPbrFragment( color_m.rgb,color_m.a,normal_r.a,position,normal );
}


