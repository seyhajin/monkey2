
#include <GLES2/gl2.h>
#include <GLES2/gl2ext.h>

namespace bbGLexts{

	extern bool GL_draw_buffers;
	extern bool GL_texture_float;
	extern bool GL_texture_half_float;
	extern bool GL_depth_texture;

	extern void(*glDrawBuffers)( int n,const GLint *bufs );

	void init();
}
