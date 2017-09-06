
#include "glexts.h"

#include <bbmonkey.h>

extern "C" void* SDL_GL_GetProcAddress( const char *proc );
extern "C" int SDL_GL_ExtensionSupported( const char *extension );

#if __EMSCRIPTEN__
extern "C" GL_APICALL void GL_APIENTRY glDrawBuffers( GLsizei n,const GLenum *bufs );
#endif

namespace bbGLexts{

	bool GL_draw_buffers=true;
	bool GL_texture_float;
	bool GL_texture_half_float;
	bool GL_depth_texture;
	bool GL_seamless_cube_map;
	
	PFNGLDRAWBUFFERSPROC glDrawBuffers;
	
	void init(){
	
		static bool done;
		if( done ) return;
		done=true;
		
		#if __EMSCRIPTEN__

		if( GL_draw_buffers=SDL_GL_ExtensionSupported( "GL_WEBGL_draw_buffers" ) ){
	
			// Don't actually call this, will crash emscripten...extension is 'just there'!
			//
			// glDrawBuffers=(void(*)(int,const GLenum*)) SDL_GL_GetProcAddress( "glDrawBuffersWEBGL" );
			
			glDrawBuffers=::glDrawBuffers;
		}
		
		#else
	
		if( GL_draw_buffers=SDL_GL_ExtensionSupported( "GL_EXT_draw_buffers" ) ){
		
			glDrawBuffers=(PFNGLDRAWBUFFERSPROC)SDL_GL_GetProcAddress( "glDrawBuffersEXT" );
			
		}else if( GL_draw_buffers=SDL_GL_ExtensionSupported( "GL_NV_draw_buffers" ) ){

			glDrawBuffers=(PFNGLDRAWBUFFERSPROC)SDL_GL_GetProcAddress( "glDrawBuffersNV" );
		}
		
		#endif
		
		GL_texture_float=SDL_GL_ExtensionSupported( "GL_EXT_texture_float" ) ||
			SDL_GL_ExtensionSupported( "GL_ANGLE_texture_half_float" ) ||
			SDL_GL_ExtensionSupported( "GL_WEBGL_texture_float" ) ||
			SDL_GL_ExtensionSupported( "GL_OES_texture_float" );
		
		GL_texture_half_float=SDL_GL_ExtensionSupported( "GL_EXT_texture_half_float" ) ||
			SDL_GL_ExtensionSupported( "GL_ANGLE_texture_half_float" ) ||
			SDL_GL_ExtensionSupported( "GL_WEBGL_texture_half_float" ) ||
			SDL_GL_ExtensionSupported( "GL_OES_texture_half_float" );
		
		GL_depth_texture=SDL_GL_ExtensionSupported( "GL_EXT_depth_texture" ) || 
			SDL_GL_ExtensionSupported( "GL_ANGLE_depth_texture" ) ||
			SDL_GL_ExtensionSupported( "GL_WEBGL_depth_texture" ) ||
			SDL_GL_ExtensionSupported( "GL_OES_depth_texture" );
		
		GL_seamless_cube_map=SDL_GL_ExtensionSupported( "GL_ARB_seamless_cube_map" );
			
//		bb_printf( "GL_draw_buffers=%i\n",int( GL_draw_buffers ) );
//		bb_printf( "GL_texture_float=%i\n",int( GL_texture_float ) );
//		bb_printf( "GL_texture_half_float=%i\n",int( GL_texture_half_float ) );
//		bb_printf( "GL_depth_texture=%i\n",int( GL_depth_texture ) );
//		fflush( stdout );
	}
	
}
