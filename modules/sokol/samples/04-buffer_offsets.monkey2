namespace sokol.samples

#import "<libc>"
#import "<std>"
#import "<sokol>"

using std.memory..
using sokol..

'/* application state */
struct state_t
	field pip:sg_pipeline
	field bind:sg_bindings
	field pass_action:sg_pass_action
end

global state:= new state_t

'/* vertex struct */
struct vertex_t
	field x:float, y:float
	field r:float, g:float, b:float
end

function Main()
	local desc:sapp_desc
	desc.window_title = CStr("sokol-buffer_offsets")
	desc.width = 800
	desc.height = 600
	
	'// callbacks
	desc.init_cb = init
	desc.frame_cb = frame
	desc.event_cb = event
	desc.fail_cb = fail
	desc.cleanup_cb = cleanup
	
	sapp_run(varptr desc)
end

function init:void()
	local desc:sg_desc
	desc.gl_force_gles2 = sapp_gles2()
	desc.mtl_device = sapp_metal_get_device()
	desc.mtl_renderpass_descriptor_cb = sapp_metal_get_renderpass_descriptor
	desc.mtl_drawable_cb = sapp_metal_get_drawable
	desc.d3d11_device = sapp_d3d11_get_device()
	desc.d3d11_device_context = sapp_d3d11_get_device_context()
	desc.d3d11_render_target_view_cb = sapp_d3d11_get_render_target_view
	desc.d3d11_depth_stencil_view_cb = sapp_d3d11_get_depth_stencil_view
	sg_setup(varptr desc)

	'/* a 2D triangle and quad in 1 vertex buffer and 1 index buffer */
	local vertices:= new float[](
		'// triangle
		 0.00, 0.55, 		1.0, 0.0, 0.0,
		 0.25, 0.05, 		0.0, 1.0, 0.0,
		-0.25, 0.05, 		0.0, 0.0, 1.0,
		 
		 '// quad
		-0.25,-0.05, 		0.0, 0.0, 1.0,
		 0.25,-0.05, 		0.0, 1.0, 0.0,
		 0.25,-0.55, 		1.0, 0.0, 0.0,
		-0.25,-0.55, 		1.0, 1.0, 0.0)
		
	local vb:sg_buffer_desc
	vb.size = vertices.Length*4
	vb.content = vertices.Data
	vb.label = CStr("vertices")
	vb.type = SG_BUFFERTYPE_VERTEXBUFFER
	state.bind.vertex_buffers[0] = sg_make_buffer(varptr vb)
	
	'/* an index buffer with 2 triangles */
	local indices:= new ushort[](
		0, 1, 2,			' triangle
		0, 1, 2, 	0, 2, 3)' quad
		
	local ib:sg_buffer_desc
	ib.size = indices.Length*2
	ib.content = indices.Data
	ib.label = CStr("indices")
	ib.type = SG_BUFFERTYPE_INDEXBUFFER
	state.bind.index_buffer = sg_make_buffer(varptr ib)

	'/* create shader glsl330 format */
	local shdesc:sg_shader_desc
	shdesc.label = CStr("shader")
	shdesc.attrs[0].name = CStr("position")
	shdesc.attrs[1].name = CStr("color0")
	shdesc.vs.entry = CStr("main")
	shdesc.vs.source = CStr(
		"#version 330~n"+
		"in vec4 position;~n"+
	    "in vec4 color0;~n"+
	    "out vec4 color;~n"+
	    "void main() {~n"+
	    "  gl_Position = position;~n"+
	    "  color = color0;~n"+
	    "}~n")
	shdesc.fs.entry = CStr("main")
	shdesc.fs.source = CStr(
		"#version 330~n"+
		"in vec4 color;~n"+
		"out vec4 frag_color;~n"+
		"void main() {~n"+
		"  frag_color = color;~n"+
		"}~n")
	local shd:sg_shader = sg_make_shader(varptr shdesc)
	
	'/* create a pipeline object (default render states are fine for triangle) */
	local pp:sg_pipeline_desc
	pp.shader = shd
	pp.label = CStr("pipeline")
	pp.index_type = SG_INDEXTYPE_UINT16

	'/* if the vertex layout doesn't have gaps, don't need to provide strides and offsets */
	pp.layout.attrs[0].format = SG_VERTEXFORMAT_FLOAT2 'vs_position
	pp.layout.attrs[1].format = SG_VERTEXFORMAT_FLOAT3 'vs_color0
	
	state.pip = sg_make_pipeline(varptr pp)
	
	'/* a pass action to framebuffer to gray */
	state.pass_action.colors[0].action = SG_ACTION_CLEAR
	state.pass_action.colors[0].val[0] = 0.12
	state.pass_action.colors[0].val[1] = 0.12
	state.pass_action.colors[0].val[2] = 0.2
	state.pass_action.colors[0].val[3] = 1.0
end

function frame:void()
	sg_begin_default_pass(varptr state.pass_action, sapp_width(), sapp_height())
	sg_apply_pipeline(state.pip)

	'/* render the triangle */
	state.bind.vertex_buffer_offsets[0] = 0
	state.bind.index_buffer_offset = 0
	sg_apply_bindings(varptr state.bind)
	sg_draw(0, 3, 1)
	
	'/* render the quad */
	state.bind.vertex_buffer_offsets[0] = 3 * libc.sizeof<vertex_t>()
	state.bind.index_buffer_offset = 3 * libc.sizeof<libc.uint16_t>()
	sg_apply_bindings(varptr state.bind)
	sg_draw(0, 6, 1)

	sg_end_pass()
	sg_commit()
end

function cleanup:void()
	sg_shutdown()
	sapp_quit()
end

function fail:void(err:libc.const_char_t ptr)
	print "sapp fail: " + String.FromCString(err)
end

function event:void(e:sapp_event ptr)
	select e->type
		case SAPP_EVENTTYPE_KEY_UP
			select e->key_code
				case SAPP_KEYCODE_ESCAPE
					sapp_request_quit()
			end
		case SAPP_EVENTTYPE_QUIT_REQUESTED
			print "Quit requested!"
	end
end

'// Convert monkey 'string' to C/C++ 'const char*'
function CStr:libc.const_char_t ptr( str:string )
	local cstr:= new DataBuffer(str.Length+1)
	str.ToCString(cstr.Data, cstr.Length)
	local cstrptr:= cast<libc.const_char_t ptr>(cstr.Data) 'mem leak?
	return cstrptr
end