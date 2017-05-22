
#include "glexts.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void* SDL_GL_GetProcAddress( const char *proc );
int SDL_GL_ExtensionSupported( const char *extension );

namespace bbGLexts{

	bool GL_draw_buffers;
	bool GL_texture_float;
	bool GL_texture_half_float;
	bool GL_depth_texture;

	void(*glDrawBuffers)( int n,const GLenum *bufs );
	
	void init(){
	
		if( GL_draw_buffers=SDL_GL_ExtensionSupported( "GL_EXT_draw_buffer" ) ){
			
			glDrawBuffers=(void(*)(int,const GLenum*)) SDL_GL_GetProcAddress( "glDrawBuffersEXT" );
			
		}else if( GL_draw_buffers=SDL_GL_ExtensionSupported( "GL_WEBGL_draw_buffer" ) ){
		
			glDrawBuffers=(void(*)(int,const GLenum*)) SDL_GL_GetProcAddress( "glDrawBuffersWEBGL" );
		}

		GL_texture_float=SDL_GL_ExtensionSupported( "GL_OES_texture_float" );
		
		GL_texture_half_float=SDL_GL_ExtensionSupported( "GL_OES_texture_half_float" );
		
		GL_depth_texture=SDL_GL_ExtensionSupported( "GL_OES_depth_texture" );
	
		printf( "GL_draw_buffers=%i\n",int( GL_draw_buffers ) );
		printf( "GL_texture_float=%i\n",int( GL_texture_float ) );
		printf( "GL_texture_half_float=%i\n",int( GL_texture_half_float ) );
		printf( "GL_depth_texture=%i\n",int( GL_depth_texture ) );
		
		fflush( stdout );
	}
	
}
