
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

GLAPI int BBGL_draw_buffers;
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

#define GL_VERSION_1_1 1
#define GL_ZERO 0
#define GL_FALSE 0
#define GL_LOGIC_OP 0x0BF1
#define GL_NONE 0
#define GL_TEXTURE_COMPONENTS 0x1003
#define GL_NO_ERROR 0
#define GL_POINTS 0x0000
#define GL_CURRENT_BIT 0x00000001
#define GL_TRUE 1
#define GL_ONE 1
#define GL_CLIENT_PIXEL_STORE_BIT 0x00000001
#define GL_LINES 0x0001
#define GL_LINE_LOOP 0x0002
#define GL_POINT_BIT 0x00000002
#define GL_CLIENT_VERTEX_ARRAY_BIT 0x00000002
#define GL_LINE_STRIP 0x0003
#define GL_LINE_BIT 0x00000004
#define GL_TRIANGLES 0x0004
#define GL_TRIANGLE_STRIP 0x0005
#define GL_TRIANGLE_FAN 0x0006
#define GL_QUADS 0x0007
#define GL_QUAD_STRIP 0x0008
#define GL_POLYGON_BIT 0x00000008
#define GL_POLYGON 0x0009
#define GL_POLYGON_STIPPLE_BIT 0x00000010
#define GL_PIXEL_MODE_BIT 0x00000020
#define GL_LIGHTING_BIT 0x00000040
#define GL_FOG_BIT 0x00000080
#define GL_DEPTH_BUFFER_BIT 0x00000100
#define GL_ACCUM 0x0100
#define GL_LOAD 0x0101
#define GL_RETURN 0x0102
#define GL_MULT 0x0103
#define GL_ADD 0x0104
#define GL_NEVER 0x0200
#define GL_ACCUM_BUFFER_BIT 0x00000200
#define GL_LESS 0x0201
#define GL_EQUAL 0x0202
#define GL_LEQUAL 0x0203
#define GL_GREATER 0x0204
#define GL_NOTEQUAL 0x0205
#define GL_GEQUAL 0x0206
#define GL_ALWAYS 0x0207
#define GL_SRC_COLOR 0x0300
#define GL_ONE_MINUS_SRC_COLOR 0x0301
#define GL_SRC_ALPHA 0x0302
#define GL_ONE_MINUS_SRC_ALPHA 0x0303
#define GL_DST_ALPHA 0x0304
#define GL_ONE_MINUS_DST_ALPHA 0x0305
#define GL_DST_COLOR 0x0306
#define GL_ONE_MINUS_DST_COLOR 0x0307
#define GL_SRC_ALPHA_SATURATE 0x0308
#define GL_STENCIL_BUFFER_BIT 0x00000400
#define GL_FRONT_LEFT 0x0400
#define GL_FRONT_RIGHT 0x0401
#define GL_BACK_LEFT 0x0402
#define GL_BACK_RIGHT 0x0403
#define GL_FRONT 0x0404
#define GL_BACK 0x0405
#define GL_LEFT 0x0406
#define GL_RIGHT 0x0407
#define GL_FRONT_AND_BACK 0x0408
#define GL_AUX0 0x0409
#define GL_AUX1 0x040A
#define GL_AUX2 0x040B
#define GL_AUX3 0x040C
#define GL_INVALID_ENUM 0x0500
#define GL_INVALID_VALUE 0x0501
#define GL_INVALID_OPERATION 0x0502
#define GL_STACK_OVERFLOW 0x0503
#define GL_STACK_UNDERFLOW 0x0504
#define GL_OUT_OF_MEMORY 0x0505
#define GL_2D 0x0600
#define GL_3D 0x0601
#define GL_3D_COLOR 0x0602
#define GL_3D_COLOR_TEXTURE 0x0603
#define GL_4D_COLOR_TEXTURE 0x0604
#define GL_PASS_THROUGH_TOKEN 0x0700
#define GL_POINT_TOKEN 0x0701
#define GL_LINE_TOKEN 0x0702
#define GL_POLYGON_TOKEN 0x0703
#define GL_BITMAP_TOKEN 0x0704
#define GL_DRAW_PIXEL_TOKEN 0x0705
#define GL_COPY_PIXEL_TOKEN 0x0706
#define GL_LINE_RESET_TOKEN 0x0707
#define GL_EXP 0x0800
#define GL_VIEWPORT_BIT 0x00000800
#define GL_EXP2 0x0801
#define GL_CW 0x0900
#define GL_CCW 0x0901
#define GL_COEFF 0x0A00
#define GL_ORDER 0x0A01
#define GL_DOMAIN 0x0A02
#define GL_CURRENT_COLOR 0x0B00
#define GL_CURRENT_INDEX 0x0B01
#define GL_CURRENT_NORMAL 0x0B02
#define GL_CURRENT_TEXTURE_COORDS 0x0B03
#define GL_CURRENT_RASTER_COLOR 0x0B04
#define GL_CURRENT_RASTER_INDEX 0x0B05
#define GL_CURRENT_RASTER_TEXTURE_COORDS 0x0B06
#define GL_CURRENT_RASTER_POSITION 0x0B07
#define GL_CURRENT_RASTER_POSITION_VALID 0x0B08
#define GL_CURRENT_RASTER_DISTANCE 0x0B09
#define GL_POINT_SMOOTH 0x0B10
#define GL_POINT_SIZE 0x0B11
#define GL_POINT_SIZE_RANGE 0x0B12
#define GL_POINT_SIZE_GRANULARITY 0x0B13
#define GL_LINE_SMOOTH 0x0B20
#define GL_LINE_WIDTH 0x0B21
#define GL_LINE_WIDTH_RANGE 0x0B22
#define GL_LINE_WIDTH_GRANULARITY 0x0B23
#define GL_LINE_STIPPLE 0x0B24
#define GL_LINE_STIPPLE_PATTERN 0x0B25
#define GL_LINE_STIPPLE_REPEAT 0x0B26
#define GL_LIST_MODE 0x0B30
#define GL_MAX_LIST_NESTING 0x0B31
#define GL_LIST_BASE 0x0B32
#define GL_LIST_INDEX 0x0B33
#define GL_POLYGON_MODE 0x0B40
#define GL_POLYGON_SMOOTH 0x0B41
#define GL_POLYGON_STIPPLE 0x0B42
#define GL_EDGE_FLAG 0x0B43
#define GL_CULL_FACE 0x0B44
#define GL_CULL_FACE_MODE 0x0B45
#define GL_FRONT_FACE 0x0B46
#define GL_LIGHTING 0x0B50
#define GL_LIGHT_MODEL_LOCAL_VIEWER 0x0B51
#define GL_LIGHT_MODEL_TWO_SIDE 0x0B52
#define GL_LIGHT_MODEL_AMBIENT 0x0B53
#define GL_SHADE_MODEL 0x0B54
#define GL_COLOR_MATERIAL_FACE 0x0B55
#define GL_COLOR_MATERIAL_PARAMETER 0x0B56
#define GL_COLOR_MATERIAL 0x0B57
#define GL_FOG 0x0B60
#define GL_FOG_INDEX 0x0B61
#define GL_FOG_DENSITY 0x0B62
#define GL_FOG_START 0x0B63
#define GL_FOG_END 0x0B64
#define GL_FOG_MODE 0x0B65
#define GL_FOG_COLOR 0x0B66
#define GL_DEPTH_RANGE 0x0B70
#define GL_DEPTH_TEST 0x0B71
#define GL_DEPTH_WRITEMASK 0x0B72
#define GL_DEPTH_CLEAR_VALUE 0x0B73
#define GL_DEPTH_FUNC 0x0B74
#define GL_ACCUM_CLEAR_VALUE 0x0B80
#define GL_STENCIL_TEST 0x0B90
#define GL_STENCIL_CLEAR_VALUE 0x0B91
#define GL_STENCIL_FUNC 0x0B92
#define GL_STENCIL_VALUE_MASK 0x0B93
#define GL_STENCIL_FAIL 0x0B94
#define GL_STENCIL_PASS_DEPTH_FAIL 0x0B95
#define GL_STENCIL_PASS_DEPTH_PASS 0x0B96
#define GL_STENCIL_REF 0x0B97
#define GL_STENCIL_WRITEMASK 0x0B98
#define GL_MATRIX_MODE 0x0BA0
#define GL_NORMALIZE 0x0BA1
#define GL_VIEWPORT 0x0BA2
#define GL_MODELVIEW_STACK_DEPTH 0x0BA3
#define GL_PROJECTION_STACK_DEPTH 0x0BA4
#define GL_TEXTURE_STACK_DEPTH 0x0BA5
#define GL_MODELVIEW_MATRIX 0x0BA6
#define GL_PROJECTION_MATRIX 0x0BA7
#define GL_TEXTURE_MATRIX 0x0BA8
#define GL_ATTRIB_STACK_DEPTH 0x0BB0
#define GL_CLIENT_ATTRIB_STACK_DEPTH 0x0BB1
#define GL_ALPHA_TEST 0x0BC0
#define GL_ALPHA_TEST_FUNC 0x0BC1
#define GL_ALPHA_TEST_REF 0x0BC2
#define GL_DITHER 0x0BD0
#define GL_BLEND_DST 0x0BE0
#define GL_BLEND_SRC 0x0BE1
#define GL_BLEND 0x0BE2
#define GL_LOGIC_OP_MODE 0x0BF0
#define GL_INDEX_LOGIC_OP 0x0BF1
#define GL_COLOR_LOGIC_OP 0x0BF2
#define GL_AUX_BUFFERS 0x0C00
#define GL_DRAW_BUFFER 0x0C01
#define GL_READ_BUFFER 0x0C02
#define GL_SCISSOR_BOX 0x0C10
#define GL_SCISSOR_TEST 0x0C11
#define GL_INDEX_CLEAR_VALUE 0x0C20
#define GL_INDEX_WRITEMASK 0x0C21
#define GL_COLOR_CLEAR_VALUE 0x0C22
#define GL_COLOR_WRITEMASK 0x0C23
#define GL_INDEX_MODE 0x0C30
#define GL_RGBA_MODE 0x0C31
#define GL_DOUBLEBUFFER 0x0C32
#define GL_STEREO 0x0C33
#define GL_RENDER_MODE 0x0C40
#define GL_PERSPECTIVE_CORRECTION_HINT 0x0C50
#define GL_POINT_SMOOTH_HINT 0x0C51
#define GL_LINE_SMOOTH_HINT 0x0C52
#define GL_POLYGON_SMOOTH_HINT 0x0C53
#define GL_FOG_HINT 0x0C54
#define GL_TEXTURE_GEN_S 0x0C60
#define GL_TEXTURE_GEN_T 0x0C61
#define GL_TEXTURE_GEN_R 0x0C62
#define GL_TEXTURE_GEN_Q 0x0C63
#define GL_PIXEL_MAP_I_TO_I 0x0C70
#define GL_PIXEL_MAP_S_TO_S 0x0C71
#define GL_PIXEL_MAP_I_TO_R 0x0C72
#define GL_PIXEL_MAP_I_TO_G 0x0C73
#define GL_PIXEL_MAP_I_TO_B 0x0C74
#define GL_PIXEL_MAP_I_TO_A 0x0C75
#define GL_PIXEL_MAP_R_TO_R 0x0C76
#define GL_PIXEL_MAP_G_TO_G 0x0C77
#define GL_PIXEL_MAP_B_TO_B 0x0C78
#define GL_PIXEL_MAP_A_TO_A 0x0C79
#define GL_PIXEL_MAP_I_TO_I_SIZE 0x0CB0
#define GL_PIXEL_MAP_S_TO_S_SIZE 0x0CB1
#define GL_PIXEL_MAP_I_TO_R_SIZE 0x0CB2
#define GL_PIXEL_MAP_I_TO_G_SIZE 0x0CB3
#define GL_PIXEL_MAP_I_TO_B_SIZE 0x0CB4
#define GL_PIXEL_MAP_I_TO_A_SIZE 0x0CB5
#define GL_PIXEL_MAP_R_TO_R_SIZE 0x0CB6
#define GL_PIXEL_MAP_G_TO_G_SIZE 0x0CB7
#define GL_PIXEL_MAP_B_TO_B_SIZE 0x0CB8
#define GL_PIXEL_MAP_A_TO_A_SIZE 0x0CB9
#define GL_UNPACK_SWAP_BYTES 0x0CF0
#define GL_UNPACK_LSB_FIRST 0x0CF1
#define GL_UNPACK_ROW_LENGTH 0x0CF2
#define GL_UNPACK_SKIP_ROWS 0x0CF3
#define GL_UNPACK_SKIP_PIXELS 0x0CF4
#define GL_UNPACK_ALIGNMENT 0x0CF5
#define GL_PACK_SWAP_BYTES 0x0D00
#define GL_PACK_LSB_FIRST 0x0D01
#define GL_PACK_ROW_LENGTH 0x0D02
#define GL_PACK_SKIP_ROWS 0x0D03
#define GL_PACK_SKIP_PIXELS 0x0D04
#define GL_PACK_ALIGNMENT 0x0D05
#define GL_MAP_COLOR 0x0D10
#define GL_MAP_STENCIL 0x0D11
#define GL_INDEX_SHIFT 0x0D12
#define GL_INDEX_OFFSET 0x0D13
#define GL_RED_SCALE 0x0D14
#define GL_RED_BIAS 0x0D15
#define GL_ZOOM_X 0x0D16
#define GL_ZOOM_Y 0x0D17
#define GL_GREEN_SCALE 0x0D18
#define GL_GREEN_BIAS 0x0D19
#define GL_BLUE_SCALE 0x0D1A
#define GL_BLUE_BIAS 0x0D1B
#define GL_ALPHA_SCALE 0x0D1C
#define GL_ALPHA_BIAS 0x0D1D
#define GL_DEPTH_SCALE 0x0D1E
#define GL_DEPTH_BIAS 0x0D1F
#define GL_MAX_EVAL_ORDER 0x0D30
#define GL_MAX_LIGHTS 0x0D31
#define GL_MAX_CLIP_PLANES 0x0D32
#define GL_MAX_TEXTURE_SIZE 0x0D33
#define GL_MAX_PIXEL_MAP_TABLE 0x0D34
#define GL_MAX_ATTRIB_STACK_DEPTH 0x0D35
#define GL_MAX_MODELVIEW_STACK_DEPTH 0x0D36
#define GL_MAX_NAME_STACK_DEPTH 0x0D37
#define GL_MAX_PROJECTION_STACK_DEPTH 0x0D38
#define GL_MAX_TEXTURE_STACK_DEPTH 0x0D39
#define GL_MAX_VIEWPORT_DIMS 0x0D3A
#define GL_MAX_CLIENT_ATTRIB_STACK_DEPTH 0x0D3B
#define GL_SUBPIXEL_BITS 0x0D50
#define GL_INDEX_BITS 0x0D51
#define GL_RED_BITS 0x0D52
#define GL_GREEN_BITS 0x0D53
#define GL_BLUE_BITS 0x0D54
#define GL_ALPHA_BITS 0x0D55
#define GL_DEPTH_BITS 0x0D56
#define GL_STENCIL_BITS 0x0D57
#define GL_ACCUM_RED_BITS 0x0D58
#define GL_ACCUM_GREEN_BITS 0x0D59
#define GL_ACCUM_BLUE_BITS 0x0D5A
#define GL_ACCUM_ALPHA_BITS 0x0D5B
#define GL_NAME_STACK_DEPTH 0x0D70
#define GL_AUTO_NORMAL 0x0D80
#define GL_MAP1_COLOR_4 0x0D90
#define GL_MAP1_INDEX 0x0D91
#define GL_MAP1_NORMAL 0x0D92
#define GL_MAP1_TEXTURE_COORD_1 0x0D93
#define GL_MAP1_TEXTURE_COORD_2 0x0D94
#define GL_MAP1_TEXTURE_COORD_3 0x0D95
#define GL_MAP1_TEXTURE_COORD_4 0x0D96
#define GL_MAP1_VERTEX_3 0x0D97
#define GL_MAP1_VERTEX_4 0x0D98
#define GL_MAP2_COLOR_4 0x0DB0
#define GL_MAP2_INDEX 0x0DB1
#define GL_MAP2_NORMAL 0x0DB2
#define GL_MAP2_TEXTURE_COORD_1 0x0DB3
#define GL_MAP2_TEXTURE_COORD_2 0x0DB4
#define GL_MAP2_TEXTURE_COORD_3 0x0DB5
#define GL_MAP2_TEXTURE_COORD_4 0x0DB6
#define GL_MAP2_VERTEX_3 0x0DB7
#define GL_MAP2_VERTEX_4 0x0DB8
#define GL_MAP1_GRID_DOMAIN 0x0DD0
#define GL_MAP1_GRID_SEGMENTS 0x0DD1
#define GL_MAP2_GRID_DOMAIN 0x0DD2
#define GL_MAP2_GRID_SEGMENTS 0x0DD3
#define GL_TEXTURE_1D 0x0DE0
#define GL_TEXTURE_2D 0x0DE1
#define GL_FEEDBACK_BUFFER_POINTER 0x0DF0
#define GL_FEEDBACK_BUFFER_SIZE 0x0DF1
#define GL_FEEDBACK_BUFFER_TYPE 0x0DF2
#define GL_SELECTION_BUFFER_POINTER 0x0DF3
#define GL_SELECTION_BUFFER_SIZE 0x0DF4
#define GL_TEXTURE_WIDTH 0x1000
#define GL_TRANSFORM_BIT 0x00001000
#define GL_TEXTURE_HEIGHT 0x1001
#define GL_TEXTURE_INTERNAL_FORMAT 0x1003
#define GL_TEXTURE_BORDER_COLOR 0x1004
#define GL_TEXTURE_BORDER 0x1005
#define GL_DONT_CARE 0x1100
#define GL_FASTEST 0x1101
#define GL_NICEST 0x1102
#define GL_AMBIENT 0x1200
#define GL_DIFFUSE 0x1201
#define GL_SPECULAR 0x1202
#define GL_POSITION 0x1203
#define GL_SPOT_DIRECTION 0x1204
#define GL_SPOT_EXPONENT 0x1205
#define GL_SPOT_CUTOFF 0x1206
#define GL_CONSTANT_ATTENUATION 0x1207
#define GL_LINEAR_ATTENUATION 0x1208
#define GL_QUADRATIC_ATTENUATION 0x1209
#define GL_COMPILE 0x1300
#define GL_COMPILE_AND_EXECUTE 0x1301
#define GL_BYTE 0x1400
#define GL_UNSIGNED_BYTE 0x1401
#define GL_SHORT 0x1402
#define GL_UNSIGNED_SHORT 0x1403
#define GL_INT 0x1404
#define GL_UNSIGNED_INT 0x1405
#define GL_FLOAT 0x1406
#define GL_2_BYTES 0x1407
#define GL_3_BYTES 0x1408
#define GL_4_BYTES 0x1409
#define GL_DOUBLE 0x140A
#define GL_CLEAR 0x1500
#define GL_AND 0x1501
#define GL_AND_REVERSE 0x1502
#define GL_COPY 0x1503
#define GL_AND_INVERTED 0x1504
#define GL_NOOP 0x1505
#define GL_XOR 0x1506
#define GL_OR 0x1507
#define GL_NOR 0x1508
#define GL_EQUIV 0x1509
#define GL_INVERT 0x150A
#define GL_OR_REVERSE 0x150B
#define GL_COPY_INVERTED 0x150C
#define GL_OR_INVERTED 0x150D
#define GL_NAND 0x150E
#define GL_SET 0x150F
#define GL_EMISSION 0x1600
#define GL_SHININESS 0x1601
#define GL_AMBIENT_AND_DIFFUSE 0x1602
#define GL_COLOR_INDEXES 0x1603
#define GL_MODELVIEW 0x1700
#define GL_PROJECTION 0x1701
#define GL_TEXTURE 0x1702
#define GL_COLOR 0x1800
#define GL_DEPTH 0x1801
#define GL_STENCIL 0x1802
#define GL_COLOR_INDEX 0x1900
#define GL_STENCIL_INDEX 0x1901
#define GL_DEPTH_COMPONENT 0x1902
#define GL_RED 0x1903
#define GL_GREEN 0x1904
#define GL_BLUE 0x1905
#define GL_ALPHA 0x1906
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_LUMINANCE 0x1909
#define GL_LUMINANCE_ALPHA 0x190A
#define GL_BITMAP 0x1A00
#define GL_POINT 0x1B00
#define GL_LINE 0x1B01
#define GL_FILL 0x1B02
#define GL_RENDER 0x1C00
#define GL_FEEDBACK 0x1C01
#define GL_SELECT 0x1C02
#define GL_FLAT 0x1D00
#define GL_SMOOTH 0x1D01
#define GL_KEEP 0x1E00
#define GL_REPLACE 0x1E01
#define GL_INCR 0x1E02
#define GL_DECR 0x1E03
#define GL_VENDOR 0x1F00
#define GL_RENDERER 0x1F01
#define GL_VERSION 0x1F02
#define GL_EXTENSIONS 0x1F03
#define GL_S 0x2000
#define GL_ENABLE_BIT 0x00002000
#define GL_T 0x2001
#define GL_R 0x2002
#define GL_Q 0x2003
#define GL_MODULATE 0x2100
#define GL_DECAL 0x2101
#define GL_TEXTURE_ENV_MODE 0x2200
#define GL_TEXTURE_ENV_COLOR 0x2201
#define GL_TEXTURE_ENV 0x2300
#define GL_EYE_LINEAR 0x2400
#define GL_OBJECT_LINEAR 0x2401
#define GL_SPHERE_MAP 0x2402
#define GL_TEXTURE_GEN_MODE 0x2500
#define GL_OBJECT_PLANE 0x2501
#define GL_EYE_PLANE 0x2502
#define GL_NEAREST 0x2600
#define GL_LINEAR 0x2601
#define GL_NEAREST_MIPMAP_NEAREST 0x2700
#define GL_LINEAR_MIPMAP_NEAREST 0x2701
#define GL_NEAREST_MIPMAP_LINEAR 0x2702
#define GL_LINEAR_MIPMAP_LINEAR 0x2703
#define GL_TEXTURE_MAG_FILTER 0x2800
#define GL_TEXTURE_MIN_FILTER 0x2801
#define GL_TEXTURE_WRAP_S 0x2802
#define GL_TEXTURE_WRAP_T 0x2803
#define GL_CLAMP 0x2900
#define GL_REPEAT 0x2901
#define GL_POLYGON_OFFSET_UNITS 0x2A00
#define GL_POLYGON_OFFSET_POINT 0x2A01
#define GL_POLYGON_OFFSET_LINE 0x2A02
#define GL_R3_G3_B2 0x2A10
#define GL_V2F 0x2A20
#define GL_V3F 0x2A21
#define GL_C4UB_V2F 0x2A22
#define GL_C4UB_V3F 0x2A23
#define GL_C3F_V3F 0x2A24
#define GL_N3F_V3F 0x2A25
#define GL_C4F_N3F_V3F 0x2A26
#define GL_T2F_V3F 0x2A27
#define GL_T4F_V4F 0x2A28
#define GL_T2F_C4UB_V3F 0x2A29
#define GL_T2F_C3F_V3F 0x2A2A
#define GL_T2F_N3F_V3F 0x2A2B
#define GL_T2F_C4F_N3F_V3F 0x2A2C
#define GL_T4F_C4F_N3F_V4F 0x2A2D
#define GL_CLIP_PLANE0 0x3000
#define GL_CLIP_PLANE1 0x3001
#define GL_CLIP_PLANE2 0x3002
#define GL_CLIP_PLANE3 0x3003
#define GL_CLIP_PLANE4 0x3004
#define GL_CLIP_PLANE5 0x3005
#define GL_LIGHT0 0x4000
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_LIGHT1 0x4001
#define GL_LIGHT2 0x4002
#define GL_LIGHT3 0x4003
#define GL_LIGHT4 0x4004
#define GL_LIGHT5 0x4005
#define GL_LIGHT6 0x4006
#define GL_LIGHT7 0x4007
#define GL_HINT_BIT 0x00008000
#define GL_POLYGON_OFFSET_FILL 0x8037
#define GL_POLYGON_OFFSET_FACTOR 0x8038
#define GL_ALPHA4 0x803B
#define GL_ALPHA8 0x803C
#define GL_ALPHA12 0x803D
#define GL_ALPHA16 0x803E
#define GL_LUMINANCE4 0x803F
#define GL_LUMINANCE8 0x8040
#define GL_LUMINANCE12 0x8041
#define GL_LUMINANCE16 0x8042
#define GL_LUMINANCE4_ALPHA4 0x8043
#define GL_LUMINANCE6_ALPHA2 0x8044
#define GL_LUMINANCE8_ALPHA8 0x8045
#define GL_LUMINANCE12_ALPHA4 0x8046
#define GL_LUMINANCE12_ALPHA12 0x8047
#define GL_LUMINANCE16_ALPHA16 0x8048
#define GL_INTENSITY 0x8049
#define GL_INTENSITY4 0x804A
#define GL_INTENSITY8 0x804B
#define GL_INTENSITY12 0x804C
#define GL_INTENSITY16 0x804D
#define GL_RGB4 0x804F
#define GL_RGB5 0x8050
#define GL_RGB8 0x8051
#define GL_RGB10 0x8052
#define GL_RGB12 0x8053
#define GL_RGB16 0x8054
#define GL_RGBA2 0x8055
#define GL_RGBA4 0x8056
#define GL_RGB5_A1 0x8057
#define GL_RGBA8 0x8058
#define GL_RGB10_A2 0x8059
#define GL_RGBA12 0x805A
#define GL_RGBA16 0x805B
#define GL_TEXTURE_RED_SIZE 0x805C
#define GL_TEXTURE_GREEN_SIZE 0x805D
#define GL_TEXTURE_BLUE_SIZE 0x805E
#define GL_TEXTURE_ALPHA_SIZE 0x805F
#define GL_TEXTURE_LUMINANCE_SIZE 0x8060
#define GL_TEXTURE_INTENSITY_SIZE 0x8061
#define GL_PROXY_TEXTURE_1D 0x8063
#define GL_PROXY_TEXTURE_2D 0x8064
#define GL_TEXTURE_PRIORITY 0x8066
#define GL_TEXTURE_RESIDENT 0x8067
#define GL_TEXTURE_BINDING_1D 0x8068
#define GL_TEXTURE_BINDING_2D 0x8069
#define GL_VERTEX_ARRAY 0x8074
#define GL_NORMAL_ARRAY 0x8075
#define GL_COLOR_ARRAY 0x8076
#define GL_INDEX_ARRAY 0x8077
#define GL_TEXTURE_COORD_ARRAY 0x8078
#define GL_EDGE_FLAG_ARRAY 0x8079
#define GL_VERTEX_ARRAY_SIZE 0x807A
#define GL_VERTEX_ARRAY_TYPE 0x807B
#define GL_VERTEX_ARRAY_STRIDE 0x807C
#define GL_NORMAL_ARRAY_TYPE 0x807E
#define GL_NORMAL_ARRAY_STRIDE 0x807F
#define GL_COLOR_ARRAY_SIZE 0x8081
#define GL_COLOR_ARRAY_TYPE 0x8082
#define GL_COLOR_ARRAY_STRIDE 0x8083
#define GL_INDEX_ARRAY_TYPE 0x8085
#define GL_INDEX_ARRAY_STRIDE 0x8086
#define GL_TEXTURE_COORD_ARRAY_SIZE 0x8088
#define GL_TEXTURE_COORD_ARRAY_TYPE 0x8089
#define GL_TEXTURE_COORD_ARRAY_STRIDE 0x808A
#define GL_EDGE_FLAG_ARRAY_STRIDE 0x808C
#define GL_VERTEX_ARRAY_POINTER 0x808E
#define GL_NORMAL_ARRAY_POINTER 0x808F
#define GL_COLOR_ARRAY_POINTER 0x8090
#define GL_INDEX_ARRAY_POINTER 0x8091
#define GL_TEXTURE_COORD_ARRAY_POINTER 0x8092
#define GL_EDGE_FLAG_ARRAY_POINTER 0x8093
#define GL_COLOR_INDEX1_EXT 0x80E2
#define GL_COLOR_INDEX2_EXT 0x80E3
#define GL_COLOR_INDEX4_EXT 0x80E4
#define GL_COLOR_INDEX8_EXT 0x80E5
#define GL_COLOR_INDEX12_EXT 0x80E6
#define GL_COLOR_INDEX16_EXT 0x80E7
#define GL_EVAL_BIT 0x00010000
#define GL_LIST_BIT 0x00020000
#define GL_TEXTURE_BIT 0x00040000
#define GL_SCISSOR_BIT 0x00080000
#define GL_ALL_ATTRIB_BITS 0x000fffff
#define GL_CLIENT_ALL_ATTRIB_BITS 0xffffffff
GLAPI void GLAPIFUN(glAccum)(GLenum op,GLfloat value);
GLAPI void GLAPIFUN(glAlphaFunc)(GLenum func,GLclampf ref);
GLAPI GLboolean GLAPIFUN(glAreTexturesResident)(GLsizei n,const GLuint *textures,GLboolean *residences);
GLAPI void GLAPIFUN(glArrayElement)(GLint i);
GLAPI void GLAPIFUN(glBegin)(GLenum mode);
GLAPI void GLAPIFUN(glBindTexture)(GLenum target,GLuint texture);
GLAPI void GLAPIFUN(glBitmap)(GLsizei width,GLsizei height,GLfloat xorig,GLfloat yorig,GLfloat xmove,GLfloat ymove,const GLubyte *bitmap);
GLAPI void GLAPIFUN(glBlendFunc)(GLenum sfactor,GLenum dfactor);
GLAPI void GLAPIFUN(glCallList)(GLuint list);
GLAPI void GLAPIFUN(glCallLists)(GLsizei n,GLenum type,const void *lists);
GLAPI void GLAPIFUN(glClear)(GLbitfield mask);
GLAPI void GLAPIFUN(glClearAccum)(GLfloat red,GLfloat green,GLfloat blue,GLfloat alpha);
GLAPI void GLAPIFUN(glClearColor)(GLclampf red,GLclampf green,GLclampf blue,GLclampf alpha);
GLAPI void GLAPIFUN(glClearDepth)(GLclampd depth);
GLAPI void GLAPIFUN(glClearIndex)(GLfloat c);
GLAPI void GLAPIFUN(glClearStencil)(GLint s);
GLAPI void GLAPIFUN(glClipPlane)(GLenum plane,const GLdouble *equation);
GLAPI void GLAPIFUN(glColor3b)(GLbyte red,GLbyte green,GLbyte blue);
GLAPI void GLAPIFUN(glColor3bv)(const GLbyte *v);
GLAPI void GLAPIFUN(glColor3d)(GLdouble red,GLdouble green,GLdouble blue);
GLAPI void GLAPIFUN(glColor3dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glColor3f)(GLfloat red,GLfloat green,GLfloat blue);
GLAPI void GLAPIFUN(glColor3fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glColor3i)(GLint red,GLint green,GLint blue);
GLAPI void GLAPIFUN(glColor3iv)(const GLint *v);
GLAPI void GLAPIFUN(glColor3s)(GLshort red,GLshort green,GLshort blue);
GLAPI void GLAPIFUN(glColor3sv)(const GLshort *v);
GLAPI void GLAPIFUN(glColor3ub)(GLubyte red,GLubyte green,GLubyte blue);
GLAPI void GLAPIFUN(glColor3ubv)(const GLubyte *v);
GLAPI void GLAPIFUN(glColor3ui)(GLuint red,GLuint green,GLuint blue);
GLAPI void GLAPIFUN(glColor3uiv)(const GLuint *v);
GLAPI void GLAPIFUN(glColor3us)(GLushort red,GLushort green,GLushort blue);
GLAPI void GLAPIFUN(glColor3usv)(const GLushort *v);
GLAPI void GLAPIFUN(glColor4b)(GLbyte red,GLbyte green,GLbyte blue,GLbyte alpha);
GLAPI void GLAPIFUN(glColor4bv)(const GLbyte *v);
GLAPI void GLAPIFUN(glColor4d)(GLdouble red,GLdouble green,GLdouble blue,GLdouble alpha);
GLAPI void GLAPIFUN(glColor4dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glColor4f)(GLfloat red,GLfloat green,GLfloat blue,GLfloat alpha);
GLAPI void GLAPIFUN(glColor4fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glColor4i)(GLint red,GLint green,GLint blue,GLint alpha);
GLAPI void GLAPIFUN(glColor4iv)(const GLint *v);
GLAPI void GLAPIFUN(glColor4s)(GLshort red,GLshort green,GLshort blue,GLshort alpha);
GLAPI void GLAPIFUN(glColor4sv)(const GLshort *v);
GLAPI void GLAPIFUN(glColor4ub)(GLubyte red,GLubyte green,GLubyte blue,GLubyte alpha);
GLAPI void GLAPIFUN(glColor4ubv)(const GLubyte *v);
GLAPI void GLAPIFUN(glColor4ui)(GLuint red,GLuint green,GLuint blue,GLuint alpha);
GLAPI void GLAPIFUN(glColor4uiv)(const GLuint *v);
GLAPI void GLAPIFUN(glColor4us)(GLushort red,GLushort green,GLushort blue,GLushort alpha);
GLAPI void GLAPIFUN(glColor4usv)(const GLushort *v);
GLAPI void GLAPIFUN(glColorMask)(GLboolean red,GLboolean green,GLboolean blue,GLboolean alpha);
GLAPI void GLAPIFUN(glColorMaterial)(GLenum face,GLenum mode);
GLAPI void GLAPIFUN(glColorPointer)(GLint size,GLenum type,GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glCopyPixels)(GLint x,GLint y,GLsizei width,GLsizei height,GLenum type);
GLAPI void GLAPIFUN(glCopyTexImage1D)(GLenum target,GLint level,GLenum internalFormat,GLint x,GLint y,GLsizei width,GLint border);
GLAPI void GLAPIFUN(glCopyTexImage2D)(GLenum target,GLint level,GLenum internalFormat,GLint x,GLint y,GLsizei width,GLsizei height,GLint border);
GLAPI void GLAPIFUN(glCopyTexSubImage1D)(GLenum target,GLint level,GLint xoffset,GLint x,GLint y,GLsizei width);
GLAPI void GLAPIFUN(glCopyTexSubImage2D)(GLenum target,GLint level,GLint xoffset,GLint yoffset,GLint x,GLint y,GLsizei width,GLsizei height);
GLAPI void GLAPIFUN(glCullFace)(GLenum mode);
GLAPI void GLAPIFUN(glDeleteLists)(GLuint list,GLsizei range);
GLAPI void GLAPIFUN(glDeleteTextures)(GLsizei n,const GLuint *textures);
GLAPI void GLAPIFUN(glDepthFunc)(GLenum func);
GLAPI void GLAPIFUN(glDepthMask)(GLboolean flag);
GLAPI void GLAPIFUN(glDepthRange)(GLclampd zNear,GLclampd zFar);
GLAPI void GLAPIFUN(glDisable)(GLenum cap);
GLAPI void GLAPIFUN(glDisableClientState)(GLenum array);
GLAPI void GLAPIFUN(glDrawArrays)(GLenum mode,GLint first,GLsizei count);
GLAPI void GLAPIFUN(glDrawBuffer)(GLenum mode);
GLAPI void GLAPIFUN(glDrawElements)(GLenum mode,GLsizei count,GLenum type,const void *indices);
GLAPI void GLAPIFUN(glDrawPixels)(GLsizei width,GLsizei height,GLenum format,GLenum type,const void *pixels);
GLAPI void GLAPIFUN(glEdgeFlag)(GLboolean flag);
GLAPI void GLAPIFUN(glEdgeFlagPointer)(GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glEdgeFlagv)(const GLboolean *flag);
GLAPI void GLAPIFUN(glEnable)(GLenum cap);
GLAPI void GLAPIFUN(glEnableClientState)(GLenum array);
GLAPI void GLAPIFUN(glEnd)();
GLAPI void GLAPIFUN(glEndList)();
GLAPI void GLAPIFUN(glEvalCoord1d)(GLdouble u);
GLAPI void GLAPIFUN(glEvalCoord1dv)(const GLdouble *u);
GLAPI void GLAPIFUN(glEvalCoord1f)(GLfloat u);
GLAPI void GLAPIFUN(glEvalCoord1fv)(const GLfloat *u);
GLAPI void GLAPIFUN(glEvalCoord2d)(GLdouble u,GLdouble v);
GLAPI void GLAPIFUN(glEvalCoord2dv)(const GLdouble *u);
GLAPI void GLAPIFUN(glEvalCoord2f)(GLfloat u,GLfloat v);
GLAPI void GLAPIFUN(glEvalCoord2fv)(const GLfloat *u);
GLAPI void GLAPIFUN(glEvalMesh1)(GLenum mode,GLint i1,GLint i2);
GLAPI void GLAPIFUN(glEvalMesh2)(GLenum mode,GLint i1,GLint i2,GLint j1,GLint j2);
GLAPI void GLAPIFUN(glEvalPoint1)(GLint i);
GLAPI void GLAPIFUN(glEvalPoint2)(GLint i,GLint j);
GLAPI void GLAPIFUN(glFeedbackBuffer)(GLsizei size,GLenum type,GLfloat *buffer);
GLAPI void GLAPIFUN(glFinish)();
GLAPI void GLAPIFUN(glFlush)();
GLAPI void GLAPIFUN(glFogf)(GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glFogfv)(GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glFogi)(GLenum pname,GLint param);
GLAPI void GLAPIFUN(glFogiv)(GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glFrontFace)(GLenum mode);
GLAPI void GLAPIFUN(glFrustum)(GLdouble left,GLdouble right,GLdouble bottom,GLdouble top,GLdouble zNear,GLdouble zFar);
GLAPI GLuint GLAPIFUN(glGenLists)(GLsizei range);
GLAPI void GLAPIFUN(glGenTextures)(GLsizei n,GLuint *textures);
GLAPI void GLAPIFUN(glGetBooleanv)(GLenum pname,GLboolean *params);
GLAPI void GLAPIFUN(glGetClipPlane)(GLenum plane,GLdouble *equation);
GLAPI void GLAPIFUN(glGetDoublev)(GLenum pname,GLdouble *params);
GLAPI GLenum GLAPIFUN(glGetError)();
GLAPI void GLAPIFUN(glGetFloatv)(GLenum pname,GLfloat *params);
GLAPI void GLAPIFUN(glGetIntegerv)(GLenum pname,GLint *params);
GLAPI void GLAPIFUN(glGetLightfv)(GLenum light,GLenum pname,GLfloat *params);
GLAPI void GLAPIFUN(glGetLightiv)(GLenum light,GLenum pname,GLint *params);
GLAPI void GLAPIFUN(glGetMapdv)(GLenum target,GLenum query,GLdouble *v);
GLAPI void GLAPIFUN(glGetMapfv)(GLenum target,GLenum query,GLfloat *v);
GLAPI void GLAPIFUN(glGetMapiv)(GLenum target,GLenum query,GLint *v);
GLAPI void GLAPIFUN(glGetMaterialfv)(GLenum face,GLenum pname,GLfloat *params);
GLAPI void GLAPIFUN(glGetMaterialiv)(GLenum face,GLenum pname,GLint *params);
GLAPI void GLAPIFUN(glGetPixelMapfv)(GLenum map,GLfloat *values);
GLAPI void GLAPIFUN(glGetPixelMapuiv)(GLenum map,GLuint *values);
GLAPI void GLAPIFUN(glGetPixelMapusv)(GLenum map,GLushort *values);
GLAPI void GLAPIFUN(glGetPointerv)(GLenum pname,void* *params);
GLAPI void GLAPIFUN(glGetPolygonStipple)(GLubyte *mask);
GLAPI const GLubyte * GLAPIFUN(glGetString)(GLenum name);
GLAPI void GLAPIFUN(glGetTexEnvfv)(GLenum target,GLenum pname,GLfloat *params);
GLAPI void GLAPIFUN(glGetTexEnviv)(GLenum target,GLenum pname,GLint *params);
GLAPI void GLAPIFUN(glGetTexGendv)(GLenum coord,GLenum pname,GLdouble *params);
GLAPI void GLAPIFUN(glGetTexGenfv)(GLenum coord,GLenum pname,GLfloat *params);
GLAPI void GLAPIFUN(glGetTexGeniv)(GLenum coord,GLenum pname,GLint *params);
GLAPI void GLAPIFUN(glGetTexImage)(GLenum target,GLint level,GLenum format,GLenum type,void *pixels);
GLAPI void GLAPIFUN(glGetTexLevelParameterfv)(GLenum target,GLint level,GLenum pname,GLfloat *params);
GLAPI void GLAPIFUN(glGetTexLevelParameteriv)(GLenum target,GLint level,GLenum pname,GLint *params);
GLAPI void GLAPIFUN(glGetTexParameterfv)(GLenum target,GLenum pname,GLfloat *params);
GLAPI void GLAPIFUN(glGetTexParameteriv)(GLenum target,GLenum pname,GLint *params);
GLAPI void GLAPIFUN(glHint)(GLenum target,GLenum mode);
GLAPI void GLAPIFUN(glIndexMask)(GLuint mask);
GLAPI void GLAPIFUN(glIndexPointer)(GLenum type,GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glIndexd)(GLdouble c);
GLAPI void GLAPIFUN(glIndexdv)(const GLdouble *c);
GLAPI void GLAPIFUN(glIndexf)(GLfloat c);
GLAPI void GLAPIFUN(glIndexfv)(const GLfloat *c);
GLAPI void GLAPIFUN(glIndexi)(GLint c);
GLAPI void GLAPIFUN(glIndexiv)(const GLint *c);
GLAPI void GLAPIFUN(glIndexs)(GLshort c);
GLAPI void GLAPIFUN(glIndexsv)(const GLshort *c);
GLAPI void GLAPIFUN(glIndexub)(GLubyte c);
GLAPI void GLAPIFUN(glIndexubv)(const GLubyte *c);
GLAPI void GLAPIFUN(glInitNames)();
GLAPI void GLAPIFUN(glInterleavedArrays)(GLenum format,GLsizei stride,const void *pointer);
GLAPI GLboolean GLAPIFUN(glIsEnabled)(GLenum cap);
GLAPI GLboolean GLAPIFUN(glIsList)(GLuint list);
GLAPI GLboolean GLAPIFUN(glIsTexture)(GLuint texture);
GLAPI void GLAPIFUN(glLightModelf)(GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glLightModelfv)(GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glLightModeli)(GLenum pname,GLint param);
GLAPI void GLAPIFUN(glLightModeliv)(GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glLightf)(GLenum light,GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glLightfv)(GLenum light,GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glLighti)(GLenum light,GLenum pname,GLint param);
GLAPI void GLAPIFUN(glLightiv)(GLenum light,GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glLineStipple)(GLint factor,GLushort pattern);
GLAPI void GLAPIFUN(glLineWidth)(GLfloat width);
GLAPI void GLAPIFUN(glListBase)(GLuint base);
GLAPI void GLAPIFUN(glLoadIdentity)();
GLAPI void GLAPIFUN(glLoadMatrixd)(const GLdouble *m);
GLAPI void GLAPIFUN(glLoadMatrixf)(const GLfloat *m);
GLAPI void GLAPIFUN(glLoadName)(GLuint name);
GLAPI void GLAPIFUN(glLogicOp)(GLenum opcode);
GLAPI void GLAPIFUN(glMap1d)(GLenum target,GLdouble u1,GLdouble u2,GLint stride,GLint order,const GLdouble *points);
GLAPI void GLAPIFUN(glMap1f)(GLenum target,GLfloat u1,GLfloat u2,GLint stride,GLint order,const GLfloat *points);
GLAPI void GLAPIFUN(glMap2d)(GLenum target,GLdouble u1,GLdouble u2,GLint ustride,GLint uorder,GLdouble v1,GLdouble v2,GLint vstride,GLint vorder,const GLdouble *points);
GLAPI void GLAPIFUN(glMap2f)(GLenum target,GLfloat u1,GLfloat u2,GLint ustride,GLint uorder,GLfloat v1,GLfloat v2,GLint vstride,GLint vorder,const GLfloat *points);
GLAPI void GLAPIFUN(glMapGrid1d)(GLint un,GLdouble u1,GLdouble u2);
GLAPI void GLAPIFUN(glMapGrid1f)(GLint un,GLfloat u1,GLfloat u2);
GLAPI void GLAPIFUN(glMapGrid2d)(GLint un,GLdouble u1,GLdouble u2,GLint vn,GLdouble v1,GLdouble v2);
GLAPI void GLAPIFUN(glMapGrid2f)(GLint un,GLfloat u1,GLfloat u2,GLint vn,GLfloat v1,GLfloat v2);
GLAPI void GLAPIFUN(glMaterialf)(GLenum face,GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glMaterialfv)(GLenum face,GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glMateriali)(GLenum face,GLenum pname,GLint param);
GLAPI void GLAPIFUN(glMaterialiv)(GLenum face,GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glMatrixMode)(GLenum mode);
GLAPI void GLAPIFUN(glMultMatrixd)(const GLdouble *m);
GLAPI void GLAPIFUN(glMultMatrixf)(const GLfloat *m);
GLAPI void GLAPIFUN(glNewList)(GLuint list,GLenum mode);
GLAPI void GLAPIFUN(glNormal3b)(GLbyte nx,GLbyte ny,GLbyte nz);
GLAPI void GLAPIFUN(glNormal3bv)(const GLbyte *v);
GLAPI void GLAPIFUN(glNormal3d)(GLdouble nx,GLdouble ny,GLdouble nz);
GLAPI void GLAPIFUN(glNormal3dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glNormal3f)(GLfloat nx,GLfloat ny,GLfloat nz);
GLAPI void GLAPIFUN(glNormal3fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glNormal3i)(GLint nx,GLint ny,GLint nz);
GLAPI void GLAPIFUN(glNormal3iv)(const GLint *v);
GLAPI void GLAPIFUN(glNormal3s)(GLshort nx,GLshort ny,GLshort nz);
GLAPI void GLAPIFUN(glNormal3sv)(const GLshort *v);
GLAPI void GLAPIFUN(glNormalPointer)(GLenum type,GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glOrtho)(GLdouble left,GLdouble right,GLdouble bottom,GLdouble top,GLdouble zNear,GLdouble zFar);
GLAPI void GLAPIFUN(glPassThrough)(GLfloat token);
GLAPI void GLAPIFUN(glPixelMapfv)(GLenum map,GLsizei mapsize,const GLfloat *values);
GLAPI void GLAPIFUN(glPixelMapuiv)(GLenum map,GLsizei mapsize,const GLuint *values);
GLAPI void GLAPIFUN(glPixelMapusv)(GLenum map,GLsizei mapsize,const GLushort *values);
GLAPI void GLAPIFUN(glPixelStoref)(GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glPixelStorei)(GLenum pname,GLint param);
GLAPI void GLAPIFUN(glPixelTransferf)(GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glPixelTransferi)(GLenum pname,GLint param);
GLAPI void GLAPIFUN(glPixelZoom)(GLfloat xfactor,GLfloat yfactor);
GLAPI void GLAPIFUN(glPointSize)(GLfloat size);
GLAPI void GLAPIFUN(glPolygonMode)(GLenum face,GLenum mode);
GLAPI void GLAPIFUN(glPolygonOffset)(GLfloat factor,GLfloat units);
GLAPI void GLAPIFUN(glPolygonStipple)(const GLubyte *mask);
GLAPI void GLAPIFUN(glPopAttrib)();
GLAPI void GLAPIFUN(glPopClientAttrib)();
GLAPI void GLAPIFUN(glPopMatrix)();
GLAPI void GLAPIFUN(glPopName)();
GLAPI void GLAPIFUN(glPrioritizeTextures)(GLsizei n,const GLuint *textures,const GLclampf *priorities);
GLAPI void GLAPIFUN(glPushAttrib)(GLbitfield mask);
GLAPI void GLAPIFUN(glPushClientAttrib)(GLbitfield mask);
GLAPI void GLAPIFUN(glPushMatrix)();
GLAPI void GLAPIFUN(glPushName)(GLuint name);
GLAPI void GLAPIFUN(glRasterPos2d)(GLdouble x,GLdouble y);
GLAPI void GLAPIFUN(glRasterPos2dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glRasterPos2f)(GLfloat x,GLfloat y);
GLAPI void GLAPIFUN(glRasterPos2fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glRasterPos2i)(GLint x,GLint y);
GLAPI void GLAPIFUN(glRasterPos2iv)(const GLint *v);
GLAPI void GLAPIFUN(glRasterPos2s)(GLshort x,GLshort y);
GLAPI void GLAPIFUN(glRasterPos2sv)(const GLshort *v);
GLAPI void GLAPIFUN(glRasterPos3d)(GLdouble x,GLdouble y,GLdouble z);
GLAPI void GLAPIFUN(glRasterPos3dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glRasterPos3f)(GLfloat x,GLfloat y,GLfloat z);
GLAPI void GLAPIFUN(glRasterPos3fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glRasterPos3i)(GLint x,GLint y,GLint z);
GLAPI void GLAPIFUN(glRasterPos3iv)(const GLint *v);
GLAPI void GLAPIFUN(glRasterPos3s)(GLshort x,GLshort y,GLshort z);
GLAPI void GLAPIFUN(glRasterPos3sv)(const GLshort *v);
GLAPI void GLAPIFUN(glRasterPos4d)(GLdouble x,GLdouble y,GLdouble z,GLdouble w);
GLAPI void GLAPIFUN(glRasterPos4dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glRasterPos4f)(GLfloat x,GLfloat y,GLfloat z,GLfloat w);
GLAPI void GLAPIFUN(glRasterPos4fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glRasterPos4i)(GLint x,GLint y,GLint z,GLint w);
GLAPI void GLAPIFUN(glRasterPos4iv)(const GLint *v);
GLAPI void GLAPIFUN(glRasterPos4s)(GLshort x,GLshort y,GLshort z,GLshort w);
GLAPI void GLAPIFUN(glRasterPos4sv)(const GLshort *v);
GLAPI void GLAPIFUN(glReadBuffer)(GLenum mode);
GLAPI void GLAPIFUN(glReadPixels)(GLint x,GLint y,GLsizei width,GLsizei height,GLenum format,GLenum type,void *pixels);
GLAPI void GLAPIFUN(glRectd)(GLdouble x1,GLdouble y1,GLdouble x2,GLdouble y2);
GLAPI void GLAPIFUN(glRectdv)(const GLdouble *v1,const GLdouble *v2);
GLAPI void GLAPIFUN(glRectf)(GLfloat x1,GLfloat y1,GLfloat x2,GLfloat y2);
GLAPI void GLAPIFUN(glRectfv)(const GLfloat *v1,const GLfloat *v2);
GLAPI void GLAPIFUN(glRecti)(GLint x1,GLint y1,GLint x2,GLint y2);
GLAPI void GLAPIFUN(glRectiv)(const GLint *v1,const GLint *v2);
GLAPI void GLAPIFUN(glRects)(GLshort x1,GLshort y1,GLshort x2,GLshort y2);
GLAPI void GLAPIFUN(glRectsv)(const GLshort *v1,const GLshort *v2);
GLAPI GLint GLAPIFUN(glRenderMode)(GLenum mode);
GLAPI void GLAPIFUN(glRotated)(GLdouble angle,GLdouble x,GLdouble y,GLdouble z);
GLAPI void GLAPIFUN(glRotatef)(GLfloat angle,GLfloat x,GLfloat y,GLfloat z);
GLAPI void GLAPIFUN(glScaled)(GLdouble x,GLdouble y,GLdouble z);
GLAPI void GLAPIFUN(glScalef)(GLfloat x,GLfloat y,GLfloat z);
GLAPI void GLAPIFUN(glScissor)(GLint x,GLint y,GLsizei width,GLsizei height);
GLAPI void GLAPIFUN(glSelectBuffer)(GLsizei size,GLuint *buffer);
GLAPI void GLAPIFUN(glShadeModel)(GLenum mode);
GLAPI void GLAPIFUN(glStencilFunc)(GLenum func,GLint ref,GLuint mask);
GLAPI void GLAPIFUN(glStencilMask)(GLuint mask);
GLAPI void GLAPIFUN(glStencilOp)(GLenum fail,GLenum zfail,GLenum zpass);
GLAPI void GLAPIFUN(glTexCoord1d)(GLdouble s);
GLAPI void GLAPIFUN(glTexCoord1dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glTexCoord1f)(GLfloat s);
GLAPI void GLAPIFUN(glTexCoord1fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glTexCoord1i)(GLint s);
GLAPI void GLAPIFUN(glTexCoord1iv)(const GLint *v);
GLAPI void GLAPIFUN(glTexCoord1s)(GLshort s);
GLAPI void GLAPIFUN(glTexCoord1sv)(const GLshort *v);
GLAPI void GLAPIFUN(glTexCoord2d)(GLdouble s,GLdouble t);
GLAPI void GLAPIFUN(glTexCoord2dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glTexCoord2f)(GLfloat s,GLfloat t);
GLAPI void GLAPIFUN(glTexCoord2fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glTexCoord2i)(GLint s,GLint t);
GLAPI void GLAPIFUN(glTexCoord2iv)(const GLint *v);
GLAPI void GLAPIFUN(glTexCoord2s)(GLshort s,GLshort t);
GLAPI void GLAPIFUN(glTexCoord2sv)(const GLshort *v);
GLAPI void GLAPIFUN(glTexCoord3d)(GLdouble s,GLdouble t,GLdouble r);
GLAPI void GLAPIFUN(glTexCoord3dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glTexCoord3f)(GLfloat s,GLfloat t,GLfloat r);
GLAPI void GLAPIFUN(glTexCoord3fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glTexCoord3i)(GLint s,GLint t,GLint r);
GLAPI void GLAPIFUN(glTexCoord3iv)(const GLint *v);
GLAPI void GLAPIFUN(glTexCoord3s)(GLshort s,GLshort t,GLshort r);
GLAPI void GLAPIFUN(glTexCoord3sv)(const GLshort *v);
GLAPI void GLAPIFUN(glTexCoord4d)(GLdouble s,GLdouble t,GLdouble r,GLdouble q);
GLAPI void GLAPIFUN(glTexCoord4dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glTexCoord4f)(GLfloat s,GLfloat t,GLfloat r,GLfloat q);
GLAPI void GLAPIFUN(glTexCoord4fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glTexCoord4i)(GLint s,GLint t,GLint r,GLint q);
GLAPI void GLAPIFUN(glTexCoord4iv)(const GLint *v);
GLAPI void GLAPIFUN(glTexCoord4s)(GLshort s,GLshort t,GLshort r,GLshort q);
GLAPI void GLAPIFUN(glTexCoord4sv)(const GLshort *v);
GLAPI void GLAPIFUN(glTexCoordPointer)(GLint size,GLenum type,GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glTexEnvf)(GLenum target,GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glTexEnvfv)(GLenum target,GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glTexEnvi)(GLenum target,GLenum pname,GLint param);
GLAPI void GLAPIFUN(glTexEnviv)(GLenum target,GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glTexGend)(GLenum coord,GLenum pname,GLdouble param);
GLAPI void GLAPIFUN(glTexGendv)(GLenum coord,GLenum pname,const GLdouble *params);
GLAPI void GLAPIFUN(glTexGenf)(GLenum coord,GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glTexGenfv)(GLenum coord,GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glTexGeni)(GLenum coord,GLenum pname,GLint param);
GLAPI void GLAPIFUN(glTexGeniv)(GLenum coord,GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glTexImage1D)(GLenum target,GLint level,GLint internalformat,GLsizei width,GLint border,GLenum format,GLenum type,const void *pixels);
GLAPI void GLAPIFUN(glTexImage2D)(GLenum target,GLint level,GLint internalformat,GLsizei width,GLsizei height,GLint border,GLenum format,GLenum type,const void *pixels);
GLAPI void GLAPIFUN(glTexParameterf)(GLenum target,GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glTexParameterfv)(GLenum target,GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glTexParameteri)(GLenum target,GLenum pname,GLint param);
GLAPI void GLAPIFUN(glTexParameteriv)(GLenum target,GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glTexSubImage1D)(GLenum target,GLint level,GLint xoffset,GLsizei width,GLenum format,GLenum type,const void *pixels);
GLAPI void GLAPIFUN(glTexSubImage2D)(GLenum target,GLint level,GLint xoffset,GLint yoffset,GLsizei width,GLsizei height,GLenum format,GLenum type,const void *pixels);
GLAPI void GLAPIFUN(glTranslated)(GLdouble x,GLdouble y,GLdouble z);
GLAPI void GLAPIFUN(glTranslatef)(GLfloat x,GLfloat y,GLfloat z);
GLAPI void GLAPIFUN(glVertex2d)(GLdouble x,GLdouble y);
GLAPI void GLAPIFUN(glVertex2dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glVertex2f)(GLfloat x,GLfloat y);
GLAPI void GLAPIFUN(glVertex2fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glVertex2i)(GLint x,GLint y);
GLAPI void GLAPIFUN(glVertex2iv)(const GLint *v);
GLAPI void GLAPIFUN(glVertex2s)(GLshort x,GLshort y);
GLAPI void GLAPIFUN(glVertex2sv)(const GLshort *v);
GLAPI void GLAPIFUN(glVertex3d)(GLdouble x,GLdouble y,GLdouble z);
GLAPI void GLAPIFUN(glVertex3dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glVertex3f)(GLfloat x,GLfloat y,GLfloat z);
GLAPI void GLAPIFUN(glVertex3fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glVertex3i)(GLint x,GLint y,GLint z);
GLAPI void GLAPIFUN(glVertex3iv)(const GLint *v);
GLAPI void GLAPIFUN(glVertex3s)(GLshort x,GLshort y,GLshort z);
GLAPI void GLAPIFUN(glVertex3sv)(const GLshort *v);
GLAPI void GLAPIFUN(glVertex4d)(GLdouble x,GLdouble y,GLdouble z,GLdouble w);
GLAPI void GLAPIFUN(glVertex4dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glVertex4f)(GLfloat x,GLfloat y,GLfloat z,GLfloat w);
GLAPI void GLAPIFUN(glVertex4fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glVertex4i)(GLint x,GLint y,GLint z,GLint w);
GLAPI void GLAPIFUN(glVertex4iv)(const GLint *v);
GLAPI void GLAPIFUN(glVertex4s)(GLshort x,GLshort y,GLshort z,GLshort w);
GLAPI void GLAPIFUN(glVertex4sv)(const GLshort *v);
GLAPI void GLAPIFUN(glVertexPointer)(GLint size,GLenum type,GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glViewport)(GLint x,GLint y,GLsizei width,GLsizei height);
#define GL_VERSION_1_2 1
#define GL_SMOOTH_POINT_SIZE_RANGE 0x0B12
#define GL_SMOOTH_POINT_SIZE_GRANULARITY 0x0B13
#define GL_SMOOTH_LINE_WIDTH_RANGE 0x0B22
#define GL_SMOOTH_LINE_WIDTH_GRANULARITY 0x0B23
#define GL_UNSIGNED_BYTE_3_3_2 0x8032
#define GL_UNSIGNED_SHORT_4_4_4_4 0x8033
#define GL_UNSIGNED_SHORT_5_5_5_1 0x8034
#define GL_UNSIGNED_INT_8_8_8_8 0x8035
#define GL_UNSIGNED_INT_10_10_10_2 0x8036
#define GL_RESCALE_NORMAL 0x803A
#define GL_TEXTURE_BINDING_3D 0x806A
#define GL_PACK_SKIP_IMAGES 0x806B
#define GL_PACK_IMAGE_HEIGHT 0x806C
#define GL_UNPACK_SKIP_IMAGES 0x806D
#define GL_UNPACK_IMAGE_HEIGHT 0x806E
#define GL_TEXTURE_3D 0x806F
#define GL_PROXY_TEXTURE_3D 0x8070
#define GL_TEXTURE_DEPTH 0x8071
#define GL_TEXTURE_WRAP_R 0x8072
#define GL_MAX_3D_TEXTURE_SIZE 0x8073
#define GL_BGR 0x80E0
#define GL_BGRA 0x80E1
#define GL_MAX_ELEMENTS_VERTICES 0x80E8
#define GL_MAX_ELEMENTS_INDICES 0x80E9
#define GL_CLAMP_TO_EDGE 0x812F
#define GL_TEXTURE_MIN_LOD 0x813A
#define GL_TEXTURE_MAX_LOD 0x813B
#define GL_TEXTURE_BASE_LEVEL 0x813C
#define GL_TEXTURE_MAX_LEVEL 0x813D
#define GL_LIGHT_MODEL_COLOR_CONTROL 0x81F8
#define GL_SINGLE_COLOR 0x81F9
#define GL_SEPARATE_SPECULAR_COLOR 0x81FA
#define GL_UNSIGNED_BYTE_2_3_3_REV 0x8362
#define GL_UNSIGNED_SHORT_5_6_5 0x8363
#define GL_UNSIGNED_SHORT_5_6_5_REV 0x8364
#define GL_UNSIGNED_SHORT_4_4_4_4_REV 0x8365
#define GL_UNSIGNED_SHORT_1_5_5_5_REV 0x8366
#define GL_UNSIGNED_INT_8_8_8_8_REV 0x8367
#define GL_ALIASED_POINT_SIZE_RANGE 0x846D
#define GL_ALIASED_LINE_WIDTH_RANGE 0x846E
GLAPI void GLAPIFUN(glCopyTexSubImage3D)(GLenum target,GLint level,GLint xoffset,GLint yoffset,GLint zoffset,GLint x,GLint y,GLsizei width,GLsizei height);
GLAPI void GLAPIFUN(glDrawRangeElements)(GLenum mode,GLuint start,GLuint end,GLsizei count,GLenum type,const void *indices);
GLAPI void GLAPIFUN(glTexImage3D)(GLenum target,GLint level,GLint internalFormat,GLsizei width,GLsizei height,GLsizei depth,GLint border,GLenum format,GLenum type,const void *pixels);
GLAPI void GLAPIFUN(glTexSubImage3D)(GLenum target,GLint level,GLint xoffset,GLint yoffset,GLint zoffset,GLsizei width,GLsizei height,GLsizei depth,GLenum format,GLenum type,const void *pixels);
#define GL_VERSION_1_2_1 1
#define GL_VERSION_1_3 1
#define GL_MULTISAMPLE 0x809D
#define GL_SAMPLE_ALPHA_TO_COVERAGE 0x809E
#define GL_SAMPLE_ALPHA_TO_ONE 0x809F
#define GL_SAMPLE_COVERAGE 0x80A0
#define GL_SAMPLE_BUFFERS 0x80A8
#define GL_SAMPLES 0x80A9
#define GL_SAMPLE_COVERAGE_VALUE 0x80AA
#define GL_SAMPLE_COVERAGE_INVERT 0x80AB
#define GL_CLAMP_TO_BORDER 0x812D
#define GL_TEXTURE0 0x84C0
#define GL_TEXTURE1 0x84C1
#define GL_TEXTURE2 0x84C2
#define GL_TEXTURE3 0x84C3
#define GL_TEXTURE4 0x84C4
#define GL_TEXTURE5 0x84C5
#define GL_TEXTURE6 0x84C6
#define GL_TEXTURE7 0x84C7
#define GL_TEXTURE8 0x84C8
#define GL_TEXTURE9 0x84C9
#define GL_TEXTURE10 0x84CA
#define GL_TEXTURE11 0x84CB
#define GL_TEXTURE12 0x84CC
#define GL_TEXTURE13 0x84CD
#define GL_TEXTURE14 0x84CE
#define GL_TEXTURE15 0x84CF
#define GL_TEXTURE16 0x84D0
#define GL_TEXTURE17 0x84D1
#define GL_TEXTURE18 0x84D2
#define GL_TEXTURE19 0x84D3
#define GL_TEXTURE20 0x84D4
#define GL_TEXTURE21 0x84D5
#define GL_TEXTURE22 0x84D6
#define GL_TEXTURE23 0x84D7
#define GL_TEXTURE24 0x84D8
#define GL_TEXTURE25 0x84D9
#define GL_TEXTURE26 0x84DA
#define GL_TEXTURE27 0x84DB
#define GL_TEXTURE28 0x84DC
#define GL_TEXTURE29 0x84DD
#define GL_TEXTURE30 0x84DE
#define GL_TEXTURE31 0x84DF
#define GL_ACTIVE_TEXTURE 0x84E0
#define GL_CLIENT_ACTIVE_TEXTURE 0x84E1
#define GL_MAX_TEXTURE_UNITS 0x84E2
#define GL_TRANSPOSE_MODELVIEW_MATRIX 0x84E3
#define GL_TRANSPOSE_PROJECTION_MATRIX 0x84E4
#define GL_TRANSPOSE_TEXTURE_MATRIX 0x84E5
#define GL_TRANSPOSE_COLOR_MATRIX 0x84E6
#define GL_SUBTRACT 0x84E7
#define GL_COMPRESSED_ALPHA 0x84E9
#define GL_COMPRESSED_LUMINANCE 0x84EA
#define GL_COMPRESSED_LUMINANCE_ALPHA 0x84EB
#define GL_COMPRESSED_INTENSITY 0x84EC
#define GL_COMPRESSED_RGB 0x84ED
#define GL_COMPRESSED_RGBA 0x84EE
#define GL_TEXTURE_COMPRESSION_HINT 0x84EF
#define GL_NORMAL_MAP 0x8511
#define GL_REFLECTION_MAP 0x8512
#define GL_TEXTURE_CUBE_MAP 0x8513
#define GL_TEXTURE_BINDING_CUBE_MAP 0x8514
#define GL_TEXTURE_CUBE_MAP_POSITIVE_X 0x8515
#define GL_TEXTURE_CUBE_MAP_NEGATIVE_X 0x8516
#define GL_TEXTURE_CUBE_MAP_POSITIVE_Y 0x8517
#define GL_TEXTURE_CUBE_MAP_NEGATIVE_Y 0x8518
#define GL_TEXTURE_CUBE_MAP_POSITIVE_Z 0x8519
#define GL_TEXTURE_CUBE_MAP_NEGATIVE_Z 0x851A
#define GL_PROXY_TEXTURE_CUBE_MAP 0x851B
#define GL_MAX_CUBE_MAP_TEXTURE_SIZE 0x851C
#define GL_COMBINE 0x8570
#define GL_COMBINE_RGB 0x8571
#define GL_COMBINE_ALPHA 0x8572
#define GL_RGB_SCALE 0x8573
#define GL_ADD_SIGNED 0x8574
#define GL_INTERPOLATE 0x8575
#define GL_CONSTANT 0x8576
#define GL_PRIMARY_COLOR 0x8577
#define GL_PREVIOUS 0x8578
#define GL_SOURCE0_RGB 0x8580
#define GL_SOURCE1_RGB 0x8581
#define GL_SOURCE2_RGB 0x8582
#define GL_SOURCE0_ALPHA 0x8588
#define GL_SOURCE1_ALPHA 0x8589
#define GL_SOURCE2_ALPHA 0x858A
#define GL_OPERAND0_RGB 0x8590
#define GL_OPERAND1_RGB 0x8591
#define GL_OPERAND2_RGB 0x8592
#define GL_OPERAND0_ALPHA 0x8598
#define GL_OPERAND1_ALPHA 0x8599
#define GL_OPERAND2_ALPHA 0x859A
#define GL_TEXTURE_COMPRESSED_IMAGE_SIZE 0x86A0
#define GL_TEXTURE_COMPRESSED 0x86A1
#define GL_NUM_COMPRESSED_TEXTURE_FORMATS 0x86A2
#define GL_COMPRESSED_TEXTURE_FORMATS 0x86A3
#define GL_DOT3_RGB 0x86AE
#define GL_DOT3_RGBA 0x86AF
#define GL_MULTISAMPLE_BIT 0x20000000
GLAPI void GLAPIFUN(glActiveTexture)(GLenum texture);
GLAPI void GLAPIFUN(glClientActiveTexture)(GLenum texture);
GLAPI void GLAPIFUN(glCompressedTexImage1D)(GLenum target,GLint level,GLenum internalformat,GLsizei width,GLint border,GLsizei imageSize,const void *data);
GLAPI void GLAPIFUN(glCompressedTexImage2D)(GLenum target,GLint level,GLenum internalformat,GLsizei width,GLsizei height,GLint border,GLsizei imageSize,const void *data);
GLAPI void GLAPIFUN(glCompressedTexImage3D)(GLenum target,GLint level,GLenum internalformat,GLsizei width,GLsizei height,GLsizei depth,GLint border,GLsizei imageSize,const void *data);
GLAPI void GLAPIFUN(glCompressedTexSubImage1D)(GLenum target,GLint level,GLint xoffset,GLsizei width,GLenum format,GLsizei imageSize,const void *data);
GLAPI void GLAPIFUN(glCompressedTexSubImage2D)(GLenum target,GLint level,GLint xoffset,GLint yoffset,GLsizei width,GLsizei height,GLenum format,GLsizei imageSize,const void *data);
GLAPI void GLAPIFUN(glCompressedTexSubImage3D)(GLenum target,GLint level,GLint xoffset,GLint yoffset,GLint zoffset,GLsizei width,GLsizei height,GLsizei depth,GLenum format,GLsizei imageSize,const void *data);
GLAPI void GLAPIFUN(glGetCompressedTexImage)(GLenum target,GLint lod,void *img);
GLAPI void GLAPIFUN(glLoadTransposeMatrixd)(const GLdouble m[16]);
GLAPI void GLAPIFUN(glLoadTransposeMatrixf)(const GLfloat m[16]);
GLAPI void GLAPIFUN(glMultTransposeMatrixd)(const GLdouble m[16]);
GLAPI void GLAPIFUN(glMultTransposeMatrixf)(const GLfloat m[16]);
GLAPI void GLAPIFUN(glMultiTexCoord1d)(GLenum target,GLdouble s);
GLAPI void GLAPIFUN(glMultiTexCoord1dv)(GLenum target,const GLdouble *v);
GLAPI void GLAPIFUN(glMultiTexCoord1f)(GLenum target,GLfloat s);
GLAPI void GLAPIFUN(glMultiTexCoord1fv)(GLenum target,const GLfloat *v);
GLAPI void GLAPIFUN(glMultiTexCoord1i)(GLenum target,GLint s);
GLAPI void GLAPIFUN(glMultiTexCoord1iv)(GLenum target,const GLint *v);
GLAPI void GLAPIFUN(glMultiTexCoord1s)(GLenum target,GLshort s);
GLAPI void GLAPIFUN(glMultiTexCoord1sv)(GLenum target,const GLshort *v);
GLAPI void GLAPIFUN(glMultiTexCoord2d)(GLenum target,GLdouble s,GLdouble t);
GLAPI void GLAPIFUN(glMultiTexCoord2dv)(GLenum target,const GLdouble *v);
GLAPI void GLAPIFUN(glMultiTexCoord2f)(GLenum target,GLfloat s,GLfloat t);
GLAPI void GLAPIFUN(glMultiTexCoord2fv)(GLenum target,const GLfloat *v);
GLAPI void GLAPIFUN(glMultiTexCoord2i)(GLenum target,GLint s,GLint t);
GLAPI void GLAPIFUN(glMultiTexCoord2iv)(GLenum target,const GLint *v);
GLAPI void GLAPIFUN(glMultiTexCoord2s)(GLenum target,GLshort s,GLshort t);
GLAPI void GLAPIFUN(glMultiTexCoord2sv)(GLenum target,const GLshort *v);
GLAPI void GLAPIFUN(glMultiTexCoord3d)(GLenum target,GLdouble s,GLdouble t,GLdouble r);
GLAPI void GLAPIFUN(glMultiTexCoord3dv)(GLenum target,const GLdouble *v);
GLAPI void GLAPIFUN(glMultiTexCoord3f)(GLenum target,GLfloat s,GLfloat t,GLfloat r);
GLAPI void GLAPIFUN(glMultiTexCoord3fv)(GLenum target,const GLfloat *v);
GLAPI void GLAPIFUN(glMultiTexCoord3i)(GLenum target,GLint s,GLint t,GLint r);
GLAPI void GLAPIFUN(glMultiTexCoord3iv)(GLenum target,const GLint *v);
GLAPI void GLAPIFUN(glMultiTexCoord3s)(GLenum target,GLshort s,GLshort t,GLshort r);
GLAPI void GLAPIFUN(glMultiTexCoord3sv)(GLenum target,const GLshort *v);
GLAPI void GLAPIFUN(glMultiTexCoord4d)(GLenum target,GLdouble s,GLdouble t,GLdouble r,GLdouble q);
GLAPI void GLAPIFUN(glMultiTexCoord4dv)(GLenum target,const GLdouble *v);
GLAPI void GLAPIFUN(glMultiTexCoord4f)(GLenum target,GLfloat s,GLfloat t,GLfloat r,GLfloat q);
GLAPI void GLAPIFUN(glMultiTexCoord4fv)(GLenum target,const GLfloat *v);
GLAPI void GLAPIFUN(glMultiTexCoord4i)(GLenum target,GLint s,GLint t,GLint r,GLint q);
GLAPI void GLAPIFUN(glMultiTexCoord4iv)(GLenum target,const GLint *v);
GLAPI void GLAPIFUN(glMultiTexCoord4s)(GLenum target,GLshort s,GLshort t,GLshort r,GLshort q);
GLAPI void GLAPIFUN(glMultiTexCoord4sv)(GLenum target,const GLshort *v);
GLAPI void GLAPIFUN(glSampleCoverage)(GLclampf value,GLboolean invert);
#define GL_VERSION_1_4 1
#define GL_BLEND_DST_RGB 0x80C8
#define GL_BLEND_SRC_RGB 0x80C9
#define GL_BLEND_DST_ALPHA 0x80CA
#define GL_BLEND_SRC_ALPHA 0x80CB
#define GL_POINT_SIZE_MIN 0x8126
#define GL_POINT_SIZE_MAX 0x8127
#define GL_POINT_FADE_THRESHOLD_SIZE 0x8128
#define GL_POINT_DISTANCE_ATTENUATION 0x8129
#define GL_GENERATE_MIPMAP 0x8191
#define GL_GENERATE_MIPMAP_HINT 0x8192
#define GL_DEPTH_COMPONENT16 0x81A5
#define GL_DEPTH_COMPONENT24 0x81A6
#define GL_DEPTH_COMPONENT32 0x81A7
#define GL_MIRRORED_REPEAT 0x8370
#define GL_FOG_COORDINATE_SOURCE 0x8450
#define GL_FOG_COORDINATE 0x8451
#define GL_FRAGMENT_DEPTH 0x8452
#define GL_CURRENT_FOG_COORDINATE 0x8453
#define GL_FOG_COORDINATE_ARRAY_TYPE 0x8454
#define GL_FOG_COORDINATE_ARRAY_STRIDE 0x8455
#define GL_FOG_COORDINATE_ARRAY_POINTER 0x8456
#define GL_FOG_COORDINATE_ARRAY 0x8457
#define GL_COLOR_SUM 0x8458
#define GL_CURRENT_SECONDARY_COLOR 0x8459
#define GL_SECONDARY_COLOR_ARRAY_SIZE 0x845A
#define GL_SECONDARY_COLOR_ARRAY_TYPE 0x845B
#define GL_SECONDARY_COLOR_ARRAY_STRIDE 0x845C
#define GL_SECONDARY_COLOR_ARRAY_POINTER 0x845D
#define GL_SECONDARY_COLOR_ARRAY 0x845E
#define GL_MAX_TEXTURE_LOD_BIAS 0x84FD
#define GL_TEXTURE_FILTER_CONTROL 0x8500
#define GL_TEXTURE_LOD_BIAS 0x8501
#define GL_INCR_WRAP 0x8507
#define GL_DECR_WRAP 0x8508
#define GL_TEXTURE_DEPTH_SIZE 0x884A
#define GL_DEPTH_TEXTURE_MODE 0x884B
#define GL_TEXTURE_COMPARE_MODE 0x884C
#define GL_TEXTURE_COMPARE_FUNC 0x884D
#define GL_COMPARE_R_TO_TEXTURE 0x884E
GLAPI void GLAPIFUN(glBlendColor)(GLclampf red,GLclampf green,GLclampf blue,GLclampf alpha);
GLAPI void GLAPIFUN(glBlendEquation)(GLenum mode);
GLAPI void GLAPIFUN(glBlendFuncSeparate)(GLenum sfactorRGB,GLenum dfactorRGB,GLenum sfactorAlpha,GLenum dfactorAlpha);
GLAPI void GLAPIFUN(glFogCoordPointer)(GLenum type,GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glFogCoordd)(GLdouble coord);
GLAPI void GLAPIFUN(glFogCoorddv)(const GLdouble *coord);
GLAPI void GLAPIFUN(glFogCoordf)(GLfloat coord);
GLAPI void GLAPIFUN(glFogCoordfv)(const GLfloat *coord);
GLAPI void GLAPIFUN(glMultiDrawArrays)(GLenum mode,const GLint *first,const GLsizei *count,GLsizei drawcount);
GLAPI void GLAPIFUN(glMultiDrawElements)(GLenum mode,const GLsizei *count,GLenum type,const void *const* indices,GLsizei drawcount);
GLAPI void GLAPIFUN(glPointParameterf)(GLenum pname,GLfloat param);
GLAPI void GLAPIFUN(glPointParameterfv)(GLenum pname,const GLfloat *params);
GLAPI void GLAPIFUN(glPointParameteri)(GLenum pname,GLint param);
GLAPI void GLAPIFUN(glPointParameteriv)(GLenum pname,const GLint *params);
GLAPI void GLAPIFUN(glSecondaryColor3b)(GLbyte red,GLbyte green,GLbyte blue);
GLAPI void GLAPIFUN(glSecondaryColor3bv)(const GLbyte *v);
GLAPI void GLAPIFUN(glSecondaryColor3d)(GLdouble red,GLdouble green,GLdouble blue);
GLAPI void GLAPIFUN(glSecondaryColor3dv)(const GLdouble *v);
GLAPI void GLAPIFUN(glSecondaryColor3f)(GLfloat red,GLfloat green,GLfloat blue);
GLAPI void GLAPIFUN(glSecondaryColor3fv)(const GLfloat *v);
GLAPI void GLAPIFUN(glSecondaryColor3i)(GLint red,GLint green,GLint blue);
GLAPI void GLAPIFUN(glSecondaryColor3iv)(const GLint *v);
GLAPI void GLAPIFUN(glSecondaryColor3s)(GLshort red,GLshort green,GLshort blue);
GLAPI void GLAPIFUN(glSecondaryColor3sv)(const GLshort *v);
GLAPI void GLAPIFUN(glSecondaryColor3ub)(GLubyte red,GLubyte green,GLubyte blue);
GLAPI void GLAPIFUN(glSecondaryColor3ubv)(const GLubyte *v);
GLAPI void GLAPIFUN(glSecondaryColor3ui)(GLuint red,GLuint green,GLuint blue);
GLAPI void GLAPIFUN(glSecondaryColor3uiv)(const GLuint *v);
GLAPI void GLAPIFUN(glSecondaryColor3us)(GLushort red,GLushort green,GLushort blue);
GLAPI void GLAPIFUN(glSecondaryColor3usv)(const GLushort *v);
GLAPI void GLAPIFUN(glSecondaryColorPointer)(GLint size,GLenum type,GLsizei stride,const void *pointer);
GLAPI void GLAPIFUN(glWindowPos2d)(GLdouble x,GLdouble y);
GLAPI void GLAPIFUN(glWindowPos2dv)(const GLdouble *p);
GLAPI void GLAPIFUN(glWindowPos2f)(GLfloat x,GLfloat y);
GLAPI void GLAPIFUN(glWindowPos2fv)(const GLfloat *p);
GLAPI void GLAPIFUN(glWindowPos2i)(GLint x,GLint y);
GLAPI void GLAPIFUN(glWindowPos2iv)(const GLint *p);
GLAPI void GLAPIFUN(glWindowPos2s)(GLshort x,GLshort y);
GLAPI void GLAPIFUN(glWindowPos2sv)(const GLshort *p);
GLAPI void GLAPIFUN(glWindowPos3d)(GLdouble x,GLdouble y,GLdouble z);
GLAPI void GLAPIFUN(glWindowPos3dv)(const GLdouble *p);
GLAPI void GLAPIFUN(glWindowPos3f)(GLfloat x,GLfloat y,GLfloat z);
GLAPI void GLAPIFUN(glWindowPos3fv)(const GLfloat *p);
GLAPI void GLAPIFUN(glWindowPos3i)(GLint x,GLint y,GLint z);
GLAPI void GLAPIFUN(glWindowPos3iv)(const GLint *p);
GLAPI void GLAPIFUN(glWindowPos3s)(GLshort x,GLshort y,GLshort z);
GLAPI void GLAPIFUN(glWindowPos3sv)(const GLshort *p);
#define GL_VERSION_1_5 1
#define GL_CURRENT_FOG_COORD GL_CURRENT_FOG_COORDINATE
#define GL_FOG_COORD GL_FOG_COORDINATE
#define GL_FOG_COORD_ARRAY GL_FOG_COORDINATE_ARRAY
#define GL_FOG_COORD_ARRAY_BUFFER_BINDING GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING
#define GL_FOG_COORD_ARRAY_POINTER GL_FOG_COORDINATE_ARRAY_POINTER
#define GL_FOG_COORD_ARRAY_STRIDE GL_FOG_COORDINATE_ARRAY_STRIDE
#define GL_FOG_COORD_ARRAY_TYPE GL_FOG_COORDINATE_ARRAY_TYPE
#define GL_FOG_COORD_SRC GL_FOG_COORDINATE_SOURCE
#define GL_SRC0_ALPHA GL_SOURCE0_ALPHA
#define GL_SRC0_RGB GL_SOURCE0_RGB
#define GL_SRC1_ALPHA GL_SOURCE1_ALPHA
#define GL_SRC1_RGB GL_SOURCE1_RGB
#define GL_SRC2_ALPHA GL_SOURCE2_ALPHA
#define GL_SRC2_RGB GL_SOURCE2_RGB
#define GL_BUFFER_SIZE 0x8764
#define GL_BUFFER_USAGE 0x8765
#define GL_QUERY_COUNTER_BITS 0x8864
#define GL_CURRENT_QUERY 0x8865
#define GL_QUERY_RESULT 0x8866
#define GL_QUERY_RESULT_AVAILABLE 0x8867
#define GL_ARRAY_BUFFER 0x8892
#define GL_ELEMENT_ARRAY_BUFFER 0x8893
#define GL_ARRAY_BUFFER_BINDING 0x8894
#define GL_ELEMENT_ARRAY_BUFFER_BINDING 0x8895
#define GL_VERTEX_ARRAY_BUFFER_BINDING 0x8896
#define GL_NORMAL_ARRAY_BUFFER_BINDING 0x8897
#define GL_COLOR_ARRAY_BUFFER_BINDING 0x8898
#define GL_INDEX_ARRAY_BUFFER_BINDING 0x8899
#define GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING 0x889A
#define GL_EDGE_FLAG_ARRAY_BUFFER_BINDING 0x889B
#define GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING 0x889C
#define GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING 0x889D
#define GL_WEIGHT_ARRAY_BUFFER_BINDING 0x889E
#define GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING 0x889F
#define GL_READ_ONLY 0x88B8
#define GL_WRITE_ONLY 0x88B9
#define GL_READ_WRITE 0x88BA
#define GL_BUFFER_ACCESS 0x88BB
#define GL_BUFFER_MAPPED 0x88BC
#define GL_BUFFER_MAP_POINTER 0x88BD
#define GL_STREAM_DRAW 0x88E0
#define GL_STREAM_READ 0x88E1
#define GL_STREAM_COPY 0x88E2
#define GL_STATIC_DRAW 0x88E4
#define GL_STATIC_READ 0x88E5
#define GL_STATIC_COPY 0x88E6
#define GL_DYNAMIC_DRAW 0x88E8
#define GL_DYNAMIC_READ 0x88E9
#define GL_DYNAMIC_COPY 0x88EA
#define GL_SAMPLES_PASSED 0x8914
GLAPI void GLAPIFUN(glBeginQuery)(GLenum target,GLuint id);
GLAPI void GLAPIFUN(glBindBuffer)(GLenum target,GLuint buffer);
GLAPI void GLAPIFUN(glBufferData)(GLenum target,GLsizeiptr size,const void* data,GLenum usage);
GLAPI void GLAPIFUN(glBufferSubData)(GLenum target,GLintptr offset,GLsizeiptr size,const void* data);
GLAPI void GLAPIFUN(glDeleteBuffers)(GLsizei n,const GLuint* buffers);
GLAPI void GLAPIFUN(glDeleteQueries)(GLsizei n,const GLuint* ids);
GLAPI void GLAPIFUN(glEndQuery)(GLenum target);
GLAPI void GLAPIFUN(glGenBuffers)(GLsizei n,GLuint* buffers);
GLAPI void GLAPIFUN(glGenQueries)(GLsizei n,GLuint* ids);
GLAPI void GLAPIFUN(glGetBufferParameteriv)(GLenum target,GLenum pname,GLint* params);
GLAPI void GLAPIFUN(glGetBufferPointerv)(GLenum target,GLenum pname,void** params);
GLAPI void GLAPIFUN(glGetBufferSubData)(GLenum target,GLintptr offset,GLsizeiptr size,void* data);
GLAPI void GLAPIFUN(glGetQueryObjectiv)(GLuint id,GLenum pname,GLint* params);
GLAPI void GLAPIFUN(glGetQueryObjectuiv)(GLuint id,GLenum pname,GLuint* params);
GLAPI void GLAPIFUN(glGetQueryiv)(GLenum target,GLenum pname,GLint* params);
GLAPI GLboolean GLAPIFUN(glIsBuffer)(GLuint buffer);
GLAPI GLboolean GLAPIFUN(glIsQuery)(GLuint id);
GLAPI void* GLAPIFUN(glMapBuffer)(GLenum target,GLenum access);
GLAPI GLboolean GLAPIFUN(glUnmapBuffer)(GLenum target);
#define GL_VERSION_2_0 1
#define GL_BLEND_EQUATION_RGB GL_BLEND_EQUATION
#define GL_VERTEX_ATTRIB_ARRAY_ENABLED 0x8622
#define GL_VERTEX_ATTRIB_ARRAY_SIZE 0x8623
#define GL_VERTEX_ATTRIB_ARRAY_STRIDE 0x8624
#define GL_VERTEX_ATTRIB_ARRAY_TYPE 0x8625
#define GL_CURRENT_VERTEX_ATTRIB 0x8626
#define GL_VERTEX_PROGRAM_POINT_SIZE 0x8642
#define GL_VERTEX_PROGRAM_TWO_SIDE 0x8643
#define GL_VERTEX_ATTRIB_ARRAY_POINTER 0x8645
#define GL_STENCIL_BACK_FUNC 0x8800
#define GL_STENCIL_BACK_FAIL 0x8801
#define GL_STENCIL_BACK_PASS_DEPTH_FAIL 0x8802
#define GL_STENCIL_BACK_PASS_DEPTH_PASS 0x8803
#define GL_MAX_DRAW_BUFFERS 0x8824
#define GL_DRAW_BUFFER0 0x8825
#define GL_DRAW_BUFFER1 0x8826
#define GL_DRAW_BUFFER2 0x8827
#define GL_DRAW_BUFFER3 0x8828
#define GL_DRAW_BUFFER4 0x8829
#define GL_DRAW_BUFFER5 0x882A
#define GL_DRAW_BUFFER6 0x882B
#define GL_DRAW_BUFFER7 0x882C
#define GL_DRAW_BUFFER8 0x882D
#define GL_DRAW_BUFFER9 0x882E
#define GL_DRAW_BUFFER10 0x882F
#define GL_DRAW_BUFFER11 0x8830
#define GL_DRAW_BUFFER12 0x8831
#define GL_DRAW_BUFFER13 0x8832
#define GL_DRAW_BUFFER14 0x8833
#define GL_DRAW_BUFFER15 0x8834
#define GL_BLEND_EQUATION_ALPHA 0x883D
#define GL_POINT_SPRITE 0x8861
#define GL_COORD_REPLACE 0x8862
#define GL_MAX_VERTEX_ATTRIBS 0x8869
#define GL_VERTEX_ATTRIB_ARRAY_NORMALIZED 0x886A
#define GL_MAX_TEXTURE_COORDS 0x8871
#define GL_MAX_TEXTURE_IMAGE_UNITS 0x8872
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31
#define GL_MAX_FRAGMENT_UNIFORM_COMPONENTS 0x8B49
#define GL_MAX_VERTEX_UNIFORM_COMPONENTS 0x8B4A
#define GL_MAX_VARYING_FLOATS 0x8B4B
#define GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS 0x8B4C
#define GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS 0x8B4D
#define GL_SHADER_TYPE 0x8B4F
#define GL_FLOAT_VEC2 0x8B50
#define GL_FLOAT_VEC3 0x8B51
#define GL_FLOAT_VEC4 0x8B52
#define GL_INT_VEC2 0x8B53
#define GL_INT_VEC3 0x8B54
#define GL_INT_VEC4 0x8B55
#define GL_BOOL 0x8B56
#define GL_BOOL_VEC2 0x8B57
#define GL_BOOL_VEC3 0x8B58
#define GL_BOOL_VEC4 0x8B59
#define GL_FLOAT_MAT2 0x8B5A
#define GL_FLOAT_MAT3 0x8B5B
#define GL_FLOAT_MAT4 0x8B5C
#define GL_SAMPLER_1D 0x8B5D
#define GL_SAMPLER_2D 0x8B5E
#define GL_SAMPLER_3D 0x8B5F
#define GL_SAMPLER_CUBE 0x8B60
#define GL_SAMPLER_1D_SHADOW 0x8B61
#define GL_SAMPLER_2D_SHADOW 0x8B62
#define GL_DELETE_STATUS 0x8B80
#define GL_COMPILE_STATUS 0x8B81
#define GL_LINK_STATUS 0x8B82
#define GL_VALIDATE_STATUS 0x8B83
#define GL_INFO_LOG_LENGTH 0x8B84
#define GL_ATTACHED_SHADERS 0x8B85
#define GL_ACTIVE_UNIFORMS 0x8B86
#define GL_ACTIVE_UNIFORM_MAX_LENGTH 0x8B87
#define GL_SHADER_SOURCE_LENGTH 0x8B88
#define GL_ACTIVE_ATTRIBUTES 0x8B89
#define GL_ACTIVE_ATTRIBUTE_MAX_LENGTH 0x8B8A
#define GL_FRAGMENT_SHADER_DERIVATIVE_HINT 0x8B8B
#define GL_SHADING_LANGUAGE_VERSION 0x8B8C
#define GL_CURRENT_PROGRAM 0x8B8D
#define GL_POINT_SPRITE_COORD_ORIGIN 0x8CA0
#define GL_LOWER_LEFT 0x8CA1
#define GL_UPPER_LEFT 0x8CA2
#define GL_STENCIL_BACK_REF 0x8CA3
#define GL_STENCIL_BACK_VALUE_MASK 0x8CA4
#define GL_STENCIL_BACK_WRITEMASK 0x8CA5
GLAPI void GLAPIFUN(glAttachShader)(GLuint program,GLuint shader);
GLAPI void GLAPIFUN(glBindAttribLocation)(GLuint program,GLuint index,const GLchar* name);
GLAPI void GLAPIFUN(glBlendEquationSeparate)(GLenum modeRGB,GLenum modeAlpha);
GLAPI void GLAPIFUN(glCompileShader)(GLuint shader);
GLAPI GLuint GLAPIFUN(glCreateProgram)();
GLAPI GLuint GLAPIFUN(glCreateShader)(GLenum type);
GLAPI void GLAPIFUN(glDeleteProgram)(GLuint program);
GLAPI void GLAPIFUN(glDeleteShader)(GLuint shader);
GLAPI void GLAPIFUN(glDetachShader)(GLuint program,GLuint shader);
GLAPI void GLAPIFUN(glDisableVertexAttribArray)(GLuint index);
GLAPI void GLAPIFUN(glDrawBuffers)(GLsizei n,const GLenum* bufs);
GLAPI void GLAPIFUN(glEnableVertexAttribArray)(GLuint index);
GLAPI void GLAPIFUN(glGetActiveAttrib)(GLuint program,GLuint index,GLsizei maxLength,GLsizei* length,GLint* size,GLenum* type,GLchar* name);
GLAPI void GLAPIFUN(glGetActiveUniform)(GLuint program,GLuint index,GLsizei maxLength,GLsizei* length,GLint* size,GLenum* type,GLchar* name);
GLAPI void GLAPIFUN(glGetAttachedShaders)(GLuint program,GLsizei maxCount,GLsizei* count,GLuint* shaders);
GLAPI GLint GLAPIFUN(glGetAttribLocation)(GLuint program,const GLchar* name);
GLAPI void GLAPIFUN(glGetProgramInfoLog)(GLuint program,GLsizei bufSize,GLsizei* length,GLchar* infoLog);
GLAPI void GLAPIFUN(glGetProgramiv)(GLuint program,GLenum pname,GLint* param);
GLAPI void GLAPIFUN(glGetShaderInfoLog)(GLuint shader,GLsizei bufSize,GLsizei* length,GLchar* infoLog);
GLAPI void GLAPIFUN(glGetShaderSource)(GLuint obj,GLsizei maxLength,GLsizei* length,GLchar* source);
GLAPI void GLAPIFUN(glGetShaderiv)(GLuint shader,GLenum pname,GLint* param);
GLAPI GLint GLAPIFUN(glGetUniformLocation)(GLuint program,const GLchar* name);
GLAPI void GLAPIFUN(glGetUniformfv)(GLuint program,GLint location,GLfloat* params);
GLAPI void GLAPIFUN(glGetUniformiv)(GLuint program,GLint location,GLint* params);
GLAPI void GLAPIFUN(glGetVertexAttribPointerv)(GLuint index,GLenum pname,void** pointer);
GLAPI void GLAPIFUN(glGetVertexAttribdv)(GLuint index,GLenum pname,GLdouble* params);
GLAPI void GLAPIFUN(glGetVertexAttribfv)(GLuint index,GLenum pname,GLfloat* params);
GLAPI void GLAPIFUN(glGetVertexAttribiv)(GLuint index,GLenum pname,GLint* params);
GLAPI GLboolean GLAPIFUN(glIsProgram)(GLuint program);
GLAPI GLboolean GLAPIFUN(glIsShader)(GLuint shader);
GLAPI void GLAPIFUN(glLinkProgram)(GLuint program);
GLAPI void GLAPIFUN(glShaderSource)(GLuint shader,GLsizei count,const GLchar *const* string,const GLint* length);
GLAPI void GLAPIFUN(glStencilFuncSeparate)(GLenum frontfunc,GLenum backfunc,GLint ref,GLuint mask);
GLAPI void GLAPIFUN(glStencilMaskSeparate)(GLenum face,GLuint mask);
GLAPI void GLAPIFUN(glStencilOpSeparate)(GLenum face,GLenum sfail,GLenum dpfail,GLenum dppass);
GLAPI void GLAPIFUN(glUniform1f)(GLint location,GLfloat v0);
GLAPI void GLAPIFUN(glUniform1fv)(GLint location,GLsizei count,const GLfloat* value);
GLAPI void GLAPIFUN(glUniform1i)(GLint location,GLint v0);
GLAPI void GLAPIFUN(glUniform1iv)(GLint location,GLsizei count,const GLint* value);
GLAPI void GLAPIFUN(glUniform2f)(GLint location,GLfloat v0,GLfloat v1);
GLAPI void GLAPIFUN(glUniform2fv)(GLint location,GLsizei count,const GLfloat* value);
GLAPI void GLAPIFUN(glUniform2i)(GLint location,GLint v0,GLint v1);
GLAPI void GLAPIFUN(glUniform2iv)(GLint location,GLsizei count,const GLint* value);
GLAPI void GLAPIFUN(glUniform3f)(GLint location,GLfloat v0,GLfloat v1,GLfloat v2);
GLAPI void GLAPIFUN(glUniform3fv)(GLint location,GLsizei count,const GLfloat* value);
GLAPI void GLAPIFUN(glUniform3i)(GLint location,GLint v0,GLint v1,GLint v2);
GLAPI void GLAPIFUN(glUniform3iv)(GLint location,GLsizei count,const GLint* value);
GLAPI void GLAPIFUN(glUniform4f)(GLint location,GLfloat v0,GLfloat v1,GLfloat v2,GLfloat v3);
GLAPI void GLAPIFUN(glUniform4fv)(GLint location,GLsizei count,const GLfloat* value);
GLAPI void GLAPIFUN(glUniform4i)(GLint location,GLint v0,GLint v1,GLint v2,GLint v3);
GLAPI void GLAPIFUN(glUniform4iv)(GLint location,GLsizei count,const GLint* value);
GLAPI void GLAPIFUN(glUniformMatrix2fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat* value);
GLAPI void GLAPIFUN(glUniformMatrix3fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat* value);
GLAPI void GLAPIFUN(glUniformMatrix4fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat* value);
GLAPI void GLAPIFUN(glUseProgram)(GLuint program);
GLAPI void GLAPIFUN(glValidateProgram)(GLuint program);
GLAPI void GLAPIFUN(glVertexAttrib1d)(GLuint index,GLdouble x);
GLAPI void GLAPIFUN(glVertexAttrib1dv)(GLuint index,const GLdouble* v);
GLAPI void GLAPIFUN(glVertexAttrib1f)(GLuint index,GLfloat x);
GLAPI void GLAPIFUN(glVertexAttrib1fv)(GLuint index,const GLfloat* v);
GLAPI void GLAPIFUN(glVertexAttrib1s)(GLuint index,GLshort x);
GLAPI void GLAPIFUN(glVertexAttrib1sv)(GLuint index,const GLshort* v);
GLAPI void GLAPIFUN(glVertexAttrib2d)(GLuint index,GLdouble x,GLdouble y);
GLAPI void GLAPIFUN(glVertexAttrib2dv)(GLuint index,const GLdouble* v);
GLAPI void GLAPIFUN(glVertexAttrib2f)(GLuint index,GLfloat x,GLfloat y);
GLAPI void GLAPIFUN(glVertexAttrib2fv)(GLuint index,const GLfloat* v);
GLAPI void GLAPIFUN(glVertexAttrib2s)(GLuint index,GLshort x,GLshort y);
GLAPI void GLAPIFUN(glVertexAttrib2sv)(GLuint index,const GLshort* v);
GLAPI void GLAPIFUN(glVertexAttrib3d)(GLuint index,GLdouble x,GLdouble y,GLdouble z);
GLAPI void GLAPIFUN(glVertexAttrib3dv)(GLuint index,const GLdouble* v);
GLAPI void GLAPIFUN(glVertexAttrib3f)(GLuint index,GLfloat x,GLfloat y,GLfloat z);
GLAPI void GLAPIFUN(glVertexAttrib3fv)(GLuint index,const GLfloat* v);
GLAPI void GLAPIFUN(glVertexAttrib3s)(GLuint index,GLshort x,GLshort y,GLshort z);
GLAPI void GLAPIFUN(glVertexAttrib3sv)(GLuint index,const GLshort* v);
GLAPI void GLAPIFUN(glVertexAttrib4Nbv)(GLuint index,const GLbyte* v);
GLAPI void GLAPIFUN(glVertexAttrib4Niv)(GLuint index,const GLint* v);
GLAPI void GLAPIFUN(glVertexAttrib4Nsv)(GLuint index,const GLshort* v);
GLAPI void GLAPIFUN(glVertexAttrib4Nub)(GLuint index,GLubyte x,GLubyte y,GLubyte z,GLubyte w);
GLAPI void GLAPIFUN(glVertexAttrib4Nubv)(GLuint index,const GLubyte* v);
GLAPI void GLAPIFUN(glVertexAttrib4Nuiv)(GLuint index,const GLuint* v);
GLAPI void GLAPIFUN(glVertexAttrib4Nusv)(GLuint index,const GLushort* v);
GLAPI void GLAPIFUN(glVertexAttrib4bv)(GLuint index,const GLbyte* v);
GLAPI void GLAPIFUN(glVertexAttrib4d)(GLuint index,GLdouble x,GLdouble y,GLdouble z,GLdouble w);
GLAPI void GLAPIFUN(glVertexAttrib4dv)(GLuint index,const GLdouble* v);
GLAPI void GLAPIFUN(glVertexAttrib4f)(GLuint index,GLfloat x,GLfloat y,GLfloat z,GLfloat w);
GLAPI void GLAPIFUN(glVertexAttrib4fv)(GLuint index,const GLfloat* v);
GLAPI void GLAPIFUN(glVertexAttrib4iv)(GLuint index,const GLint* v);
GLAPI void GLAPIFUN(glVertexAttrib4s)(GLuint index,GLshort x,GLshort y,GLshort z,GLshort w);
GLAPI void GLAPIFUN(glVertexAttrib4sv)(GLuint index,const GLshort* v);
GLAPI void GLAPIFUN(glVertexAttrib4ubv)(GLuint index,const GLubyte* v);
GLAPI void GLAPIFUN(glVertexAttrib4uiv)(GLuint index,const GLuint* v);
GLAPI void GLAPIFUN(glVertexAttrib4usv)(GLuint index,const GLushort* v);
GLAPI void GLAPIFUN(glVertexAttribPointer)(GLuint index,GLint size,GLenum type,GLboolean normalized,GLsizei stride,const void* pointer);
#define GL_VERSION_2_1 1
#define GL_CURRENT_RASTER_SECONDARY_COLOR 0x845F
#define GL_PIXEL_PACK_BUFFER 0x88EB
#define GL_PIXEL_UNPACK_BUFFER 0x88EC
#define GL_PIXEL_PACK_BUFFER_BINDING 0x88ED
#define GL_PIXEL_UNPACK_BUFFER_BINDING 0x88EF
#define GL_FLOAT_MAT2x3 0x8B65
#define GL_FLOAT_MAT2x4 0x8B66
#define GL_FLOAT_MAT3x2 0x8B67
#define GL_FLOAT_MAT3x4 0x8B68
#define GL_FLOAT_MAT4x2 0x8B69
#define GL_FLOAT_MAT4x3 0x8B6A
#define GL_SRGB 0x8C40
#define GL_SRGB8 0x8C41
#define GL_SRGB_ALPHA 0x8C42
#define GL_SRGB8_ALPHA8 0x8C43
#define GL_SLUMINANCE_ALPHA 0x8C44
#define GL_SLUMINANCE8_ALPHA8 0x8C45
#define GL_SLUMINANCE 0x8C46
#define GL_SLUMINANCE8 0x8C47
#define GL_COMPRESSED_SRGB 0x8C48
#define GL_COMPRESSED_SRGB_ALPHA 0x8C49
#define GL_COMPRESSED_SLUMINANCE 0x8C4A
#define GL_COMPRESSED_SLUMINANCE_ALPHA 0x8C4B
GLAPI void GLAPIFUN(glUniformMatrix2x3fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat *value);
GLAPI void GLAPIFUN(glUniformMatrix2x4fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat *value);
GLAPI void GLAPIFUN(glUniformMatrix3x2fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat *value);
GLAPI void GLAPIFUN(glUniformMatrix3x4fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat *value);
GLAPI void GLAPIFUN(glUniformMatrix4x2fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat *value);
GLAPI void GLAPIFUN(glUniformMatrix4x3fv)(GLint location,GLsizei count,GLboolean transpose,const GLfloat *value);
#define GL_ARB_seamless_cube_map 1
#define GL_TEXTURE_CUBE_MAP_SEAMLESS 0x884F
#define GL_ARB_texture_filter_anisotropic 1
#define GL_TEXTURE_MAX_ANISOTROPY 0x84FE
#define GL_MAX_TEXTURE_MAX_ANISOTROPY 0x84FF
#define GL_ARB_framebuffer_object 1
#define GL_INVALID_FRAMEBUFFER_OPERATION 0x0506
#define GL_FRAMEBUFFER_ATTACHMENT_COLOR_ENCODING 0x8210
#define GL_FRAMEBUFFER_ATTACHMENT_COMPONENT_TYPE 0x8211
#define GL_FRAMEBUFFER_ATTACHMENT_RED_SIZE 0x8212
#define GL_FRAMEBUFFER_ATTACHMENT_GREEN_SIZE 0x8213
#define GL_FRAMEBUFFER_ATTACHMENT_BLUE_SIZE 0x8214
#define GL_FRAMEBUFFER_ATTACHMENT_ALPHA_SIZE 0x8215
#define GL_FRAMEBUFFER_ATTACHMENT_DEPTH_SIZE 0x8216
#define GL_FRAMEBUFFER_ATTACHMENT_STENCIL_SIZE 0x8217
#define GL_FRAMEBUFFER_DEFAULT 0x8218
#define GL_FRAMEBUFFER_UNDEFINED 0x8219
#define GL_DEPTH_STENCIL_ATTACHMENT 0x821A
#define GL_INDEX 0x8222
#define GL_MAX_RENDERBUFFER_SIZE 0x84E8
#define GL_DEPTH_STENCIL 0x84F9
#define GL_UNSIGNED_INT_24_8 0x84FA
#define GL_DEPTH24_STENCIL8 0x88F0
#define GL_TEXTURE_STENCIL_SIZE 0x88F1
#define GL_UNSIGNED_NORMALIZED 0x8C17
#define GL_DRAW_FRAMEBUFFER_BINDING 0x8CA6
#define GL_FRAMEBUFFER_BINDING 0x8CA6
#define GL_RENDERBUFFER_BINDING 0x8CA7
#define GL_READ_FRAMEBUFFER 0x8CA8
#define GL_DRAW_FRAMEBUFFER 0x8CA9
#define GL_READ_FRAMEBUFFER_BINDING 0x8CAA
#define GL_RENDERBUFFER_SAMPLES 0x8CAB
#define GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE 0x8CD0
#define GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME 0x8CD1
#define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL 0x8CD2
#define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE 0x8CD3
#define GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LAYER 0x8CD4
#define GL_FRAMEBUFFER_COMPLETE 0x8CD5
#define GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT 0x8CD6
#define GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT 0x8CD7
#define GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER 0x8CDB
#define GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER 0x8CDC
#define GL_FRAMEBUFFER_UNSUPPORTED 0x8CDD
#define GL_MAX_COLOR_ATTACHMENTS 0x8CDF
#define GL_COLOR_ATTACHMENT0 0x8CE0
#define GL_COLOR_ATTACHMENT1 0x8CE1
#define GL_COLOR_ATTACHMENT2 0x8CE2
#define GL_COLOR_ATTACHMENT3 0x8CE3
#define GL_COLOR_ATTACHMENT4 0x8CE4
#define GL_COLOR_ATTACHMENT5 0x8CE5
#define GL_COLOR_ATTACHMENT6 0x8CE6
#define GL_COLOR_ATTACHMENT7 0x8CE7
#define GL_COLOR_ATTACHMENT8 0x8CE8
#define GL_COLOR_ATTACHMENT9 0x8CE9
#define GL_COLOR_ATTACHMENT10 0x8CEA
#define GL_COLOR_ATTACHMENT11 0x8CEB
#define GL_COLOR_ATTACHMENT12 0x8CEC
#define GL_COLOR_ATTACHMENT13 0x8CED
#define GL_COLOR_ATTACHMENT14 0x8CEE
#define GL_COLOR_ATTACHMENT15 0x8CEF
#define GL_DEPTH_ATTACHMENT 0x8D00
#define GL_STENCIL_ATTACHMENT 0x8D20
#define GL_FRAMEBUFFER 0x8D40
#define GL_RENDERBUFFER 0x8D41
#define GL_RENDERBUFFER_WIDTH 0x8D42
#define GL_RENDERBUFFER_HEIGHT 0x8D43
#define GL_RENDERBUFFER_INTERNAL_FORMAT 0x8D44
#define GL_STENCIL_INDEX1 0x8D46
#define GL_STENCIL_INDEX4 0x8D47
#define GL_STENCIL_INDEX8 0x8D48
#define GL_STENCIL_INDEX16 0x8D49
#define GL_RENDERBUFFER_RED_SIZE 0x8D50
#define GL_RENDERBUFFER_GREEN_SIZE 0x8D51
#define GL_RENDERBUFFER_BLUE_SIZE 0x8D52
#define GL_RENDERBUFFER_ALPHA_SIZE 0x8D53
#define GL_RENDERBUFFER_DEPTH_SIZE 0x8D54
#define GL_RENDERBUFFER_STENCIL_SIZE 0x8D55
#define GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE 0x8D56
#define GL_MAX_SAMPLES 0x8D57
GLAPI void GLAPIFUN(glBindFramebuffer)(GLenum target,GLuint framebuffer);
GLAPI void GLAPIFUN(glBindRenderbuffer)(GLenum target,GLuint renderbuffer);
GLAPI void GLAPIFUN(glBlitFramebuffer)(GLint srcX0,GLint srcY0,GLint srcX1,GLint srcY1,GLint dstX0,GLint dstY0,GLint dstX1,GLint dstY1,GLbitfield mask,GLenum filter);
GLAPI GLenum GLAPIFUN(glCheckFramebufferStatus)(GLenum target);
GLAPI void GLAPIFUN(glDeleteFramebuffers)(GLsizei n,const GLuint* framebuffers);
GLAPI void GLAPIFUN(glDeleteRenderbuffers)(GLsizei n,const GLuint* renderbuffers);
GLAPI void GLAPIFUN(glFramebufferRenderbuffer)(GLenum target,GLenum attachment,GLenum renderbuffertarget,GLuint renderbuffer);
GLAPI void GLAPIFUN(glFramebufferTexture1D)(GLenum target,GLenum attachment,GLenum textarget,GLuint texture,GLint level);
GLAPI void GLAPIFUN(glFramebufferTexture2D)(GLenum target,GLenum attachment,GLenum textarget,GLuint texture,GLint level);
GLAPI void GLAPIFUN(glFramebufferTexture3D)(GLenum target,GLenum attachment,GLenum textarget,GLuint texture,GLint level,GLint layer);
GLAPI void GLAPIFUN(glFramebufferTextureLayer)(GLenum target,GLenum attachment,GLuint texture,GLint level,GLint layer);
GLAPI void GLAPIFUN(glGenFramebuffers)(GLsizei n,GLuint* framebuffers);
GLAPI void GLAPIFUN(glGenRenderbuffers)(GLsizei n,GLuint* renderbuffers);
GLAPI void GLAPIFUN(glGenerateMipmap)(GLenum target);
GLAPI void GLAPIFUN(glGetFramebufferAttachmentParameteriv)(GLenum target,GLenum attachment,GLenum pname,GLint* params);
GLAPI void GLAPIFUN(glGetRenderbufferParameteriv)(GLenum target,GLenum pname,GLint* params);
GLAPI GLboolean GLAPIFUN(glIsFramebuffer)(GLuint framebuffer);
GLAPI GLboolean GLAPIFUN(glIsRenderbuffer)(GLuint renderbuffer);
GLAPI void GLAPIFUN(glRenderbufferStorage)(GLenum target,GLenum internalformat,GLsizei width,GLsizei height);
GLAPI void GLAPIFUN(glRenderbufferStorageMultisample)(GLenum target,GLsizei samples,GLenum internalformat,GLsizei width,GLsizei height);

#ifdef __cplusplus
}
#endif

#endif
