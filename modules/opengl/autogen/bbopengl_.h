
#ifndef BB_OPENGL_H
#define BB_OPENGL_H

#include <stddef.h>

#ifdef __cplusplus
extern "C"{
#endif

#ifndef GLAPI
#define GLAPI extern
#endif

#if _WIN32
#define GLAPIENTRY __stdcall
#else
#define GLAPIENTRY
#endif

#if __EMSCRIPTEN__
#define GLAPIFUN(X) X
#else
#define GLAPIFUN(X) (GLAPIENTRY*X)
#endif

void bbglInit();

GLAPI int BBGL_ES;

GLAPI int BBGL_draw_buffers;				'MRT support?
GLAPI int BBGL_depth_texture;
GLAPI int BBGL_seamless_cube_map;
GLAPI int BBGL_texture_filter_anisotropic;
GLAPI int BBGL_standard_derivatives;

typedef unsigned int GLenum;
typedef unsigned int GLbitfield;
typedef unsigned int GLuint;
typedef int GLint;
typedef int GLsizei;
typedef unsigned char GLboolean;
typedef signed char GLbyte;
typedef short GLshort;
typedef unsigned char GLubyte;
typedef unsigned short GLushort;
typedef unsigned long GLulong;
typedef float GLfloat;
typedef float GLclampf;
typedef double GLdouble;
typedef double GLclampd;
typedef void GLvoid;
typedef char GLchar;
typedef ptrdiff_t GLintptr;
typedef ptrdiff_t GLsizeiptr;
typedef struct __GLsync *GLsync;

${DECLS}

#ifdef __cplusplus
}
#endif

#endif
