
#ifndef BB_GL_EXTS
#define BB_GL_EXTS

#if __APPLE__
#include <OpenGLES/ES2/gl.h>
#else
#include <GLES2/gl2.h>
#endif

#if __EMSCRIPTEN__
extern "C" void glDrawBuffers( int n,const GLenum *bufs );
#endif

namespace bbGLexts{

	extern bool GL_draw_buffers;
	extern bool GL_texture_float;
	extern bool GL_texture_half_float;
	extern bool GL_depth_texture;

	extern void(*glDrawBuffers)( int n,const GLenum *bufs );

	void init();
}

#endif
