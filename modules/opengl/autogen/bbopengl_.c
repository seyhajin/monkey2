
#define GLAPI

#include "bbopengl.h"

#include <stdio.h>

#if __EMSCRIPTEN__

void GLAPIENTRY glClearDepthf( GLclampf depth );

void GLAPIENTRY glClearDepth( GLclampd depth ){

	glClearDepthf( (GLclampf)depth );
}

#else

#define SDL_GL_CONTEXT_PROFILE_MASK		21
#define SDL_GL_CONTEXT_PROFILE_ES		0x0004 

void *SDL_GL_GetProcAddress( const char *proc );
int SDL_GL_ExtensionSupported( const char *ext );
int SDL_GL_GetAttribute( int attr,int *value );

void (GLAPIENTRY*glClearDepthf)( GLclampf depth );

void GLAPIENTRY glClearDepthd( GLclampd depth ){

	glClearDepthf( (GLclampf)depth );
}

#endif

void bbglInit(){

#if __EMSCRIPTEN__

	BBGL_ES=1;

#else

${INITS}

	int profile=0;
	SDL_GL_GetAttribute( SDL_GL_CONTEXT_PROFILE_MASK,&profile );
	BBGL_ES=( profile==SDL_GL_CONTEXT_PROFILE_ES );

#endif

	if( BBGL_ES ){
#if __EMSCRIPTEN__		
		BBGL_draw_buffers=SDL_GL_ExtensionSupported( "GL_WEBGL_draw_buffers" );
#else
		glClearDepthf=SDL_GL_GetProcAddress( "glClearDepthf" );
		glClearDepth=glClearDepthd;
		
		if( BBGL_draw_buffers=SDL_GL_ExtensionSupported( "GL_EXT_draw_buffers" ) ){
			glDrawBuffers=SDL_GL_GetProcAddress( "glDrawBuffersEXT" );
		}else if( BBGL_draw_buffers=SDL_GL_ExtensionSupported( "GL_NV_draw_buffers" ) ){	//MRTs on nvidia shield!
			glDrawBuffers=SDL_GL_GetProcAddress( "glDrawBuffersNV" );
		}
#endif
	}else{
		BBGL_draw_buffers=1;
	}
	
	BBGL_depth_texture=SDL_GL_ExtensionSupported( "GL_EXT_depth_texture" ) || 
		SDL_GL_ExtensionSupported( "GL_ANGLE_depth_texture" ) ||
		SDL_GL_ExtensionSupported( "GL_WEBGL_depth_texture" ) ||
		SDL_GL_ExtensionSupported( "GL_OES_depth_texture" );
	
	BBGL_seamless_cube_map=SDL_GL_ExtensionSupported( "GL_ARB_seamless_cube_map" );
		
	BBGL_texture_filter_anisotropic=SDL_GL_ExtensionSupported( "GL_ARB_texture_filter_anisotropic" ) ||
		SDL_GL_ExtensionSupported( "GL_EXT_texture_filter_anisotropic" );
		
	BBGL_standard_derivatives=!BBGL_ES  || SDL_GL_ExtensionSupported( "GL_OES_standard_derivatives" );
}
