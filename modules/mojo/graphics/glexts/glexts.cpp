
#include "glexts.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <EGL/egl.h>

namespace bbGLexts{

	bool GL_draw_buffers;
	bool GL_texture_float;
	bool GL_texture_half_float;
	bool GL_depth_texture;

	void(*glDrawBuffers)( int n,const GLenum *bufs );
	
	void init(){
	
		const char *exts=(const char*)glGetString( GL_EXTENSIONS );
		char *buf=(char*)malloc( strlen( exts )+3 );

		buf[0]=' ';		
		strcpy( buf+1,exts );
		strcat( buf+1," " );
		
		if( GL_draw_buffers=strstr( buf," GL_EXT_draw_buffers " ) ){
			
			glDrawBuffers=(void(*)(int,const GLenum*)) eglGetProcAddress( "glDrawBuffersEXT" );
			
		}else if( GL_draw_buffers=strstr( buf," WEBGL_draw_buffers " ) ){
		
			glDrawBuffers=(void(*)(int,const GLenum*)) eglGetProcAddress( "glDrawBuffersWEBGL" );
		}
		
		GL_texture_float=strstr( buf,"_texture_float" );
		
		GL_texture_half_float=strstr( buf,"_texture_half_float" );
		
		GL_depth_texture=strstr( buf,"_depth_texture" );
			
		printf( "GL_draw_buffers=%i\n",int( GL_draw_buffers ) );
		printf( "GL_texture_float=%i\n",int( GL_texture_float ) );
		printf( "GL_texture_half_float=%i\n",int( GL_texture_half_float ) );
		printf( "GL_depth_texture=%i\n",int( GL_depth_texture ) );
		
		fflush( stdout );
	}
	
}
