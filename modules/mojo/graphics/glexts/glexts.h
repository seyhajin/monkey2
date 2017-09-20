
#ifndef BB_GL_EXTS
#define BB_GL_EXTS

#if __APPLE__
#include <OpenGLES/ES2/gl.h>
#else
#include <GLES2/gl2.h>
#endif

namespace bbGLexts{

	extern bool GL_draw_buffers;
	extern bool GL_texture_float;
	extern bool GL_texture_half_float;
	extern bool GL_depth_texture;
	extern bool GL_seamless_cube_map;
	extern bool GL_texture_filter_anisotropic;
	
	typedef void (GL_APIENTRY *PFNGLDRAWBUFFERSPROC)( GLsizei n,const GLenum *bufs );

	extern PFNGLDRAWBUFFERSPROC glDrawBuffers;
	
	void init();
}

#endif
