package game

import "core:log"
import "core:math/linalg/glsl"
import "core:os"
import gl "vendor:OpenGL"

Shader :: struct {
	handle:   u32,
	vertex:   string,
	fragment: string,
}

Shaders_Context :: struct {
	active_shader_handle: u32,
}

init_shader :: proc(ctx: ^Shaders_Context, shader: ^Shader) -> bool {
	shader.handle = load_shader_program(
		shader.vertex,
		shader.fragment,
	) or_return
	return true
}

set_shader_uniform_f32 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: f32,
) {
	gl.Uniform1f(gl.GetUniformLocation(shader.handle, location), value)
}

set_shader_uniform_vec2 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: glsl.vec2,
) {
	gl.Uniform2f(
		gl.GetUniformLocation(shader.handle, location),
		value.x,
		value.y,
	)
}

set_shader_uniform_vec3 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: glsl.vec3,
) {
	gl.Uniform3f(
		gl.GetUniformLocation(shader.handle, location),
		value.x,
		value.y,
		value.z,
	)
}

set_shader_uniform_vec4 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: glsl.vec4,
) {
	gl.Uniform4f(
		gl.GetUniformLocation(shader.handle, location),
		value.x,
		value.y,
		value.z,
		value.w,
	)
}

set_shader_uniform_i32 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: i32,
) {
	gl.Uniform1i(gl.GetUniformLocation(shader.handle, location), value)
}

set_shader_uniform_ivec2 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: glsl.ivec2,
) {
	gl.Uniform2i(
		gl.GetUniformLocation(shader.handle, location),
		value.x,
		value.y,
	)
}

set_shader_uniform_ivec3 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: glsl.ivec3,
) {
	gl.Uniform3i(
		gl.GetUniformLocation(shader.handle, location),
		value.x,
		value.y,
		value.z,
	)
}

set_shader_uniform_ivec4 :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: glsl.ivec4,
) {
	gl.Uniform4i(
		gl.GetUniformLocation(shader.handle, location),
		value.x,
		value.y,
		value.z,
		value.w,
	)
}

set_shader_uniform_f32_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []f32,
) {
	gl.Uniform1fv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(value),
	)
}

set_shader_uniform_vec2_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []glsl.vec2,
) {
	gl.Uniform2fv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_vec3_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []glsl.vec3,
) {
	gl.Uniform3fv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_vec4_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []glsl.vec4,
) {
	gl.Uniform4fv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_i32_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []i32,
) {
	gl.Uniform1iv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(value),
	)
}

set_shader_uniform_ivec2_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []glsl.ivec2,
) {
	gl.Uniform2iv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_ivec3_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []glsl.ivec3,
) {
	gl.Uniform3iv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_ivec4_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	value: []glsl.ivec4,
) {
	gl.Uniform4iv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_mat2_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	transpose: bool,
	value: []glsl.mat2,
) {
	gl.UniformMatrix2fv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		transpose,
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_mat3_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	transpose: bool,
	value: []glsl.mat3,
) {
	gl.UniformMatrix3fv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		transpose,
		raw_data(raw_data(value)),
	)
}

set_shader_uniform_mat4_slice :: proc(
	ctx: ^Shaders_Context,
	shader: ^Shader,
	location: cstring,
	transpose: bool,
	value: []glsl.mat4,
) {
	gl.UniformMatrix4fv(
		gl.GetUniformLocation(shader.handle, location),
		i32(len(value)),
		transpose,
		raw_data(raw_data(value)),
	)
}

set_shader_uniform :: proc {
	set_shader_uniform_f32,
	set_shader_uniform_vec2,
	set_shader_uniform_vec3,
	set_shader_uniform_vec4,
	set_shader_uniform_i32,
	set_shader_uniform_ivec2,
	set_shader_uniform_ivec3,
	set_shader_uniform_ivec4,
	set_shader_uniform_f32_slice,
	set_shader_uniform_vec2_slice,
	set_shader_uniform_vec3_slice,
	set_shader_uniform_vec4_slice,
	set_shader_uniform_i32_slice,
	set_shader_uniform_ivec2_slice,
	set_shader_uniform_ivec3_slice,
	set_shader_uniform_ivec4_slice,
	set_shader_uniform_mat2_slice,
	set_shader_uniform_mat3_slice,
	set_shader_uniform_mat4_slice,
}

set_shader_unifrom_block_binding :: proc(
	shader: ^Shader,
	name: cstring,
	binding: u32,
) {
	ubo_index := gl.GetUniformBlockIndex(shader.handle, name)
	gl.UniformBlockBinding(shader.handle, ubo_index, binding)
}


bind_shader :: proc(ctx: ^Shaders_Context, shader: ^Shader) -> bool {
	ctx.active_shader_handle = shader.handle

	gl.UseProgram(shader.handle)

	return true
}

load_shader :: proc(
	pathname: string,
	shader_type: u32,
) -> (
	shader: u32,
	ok: bool = true,
) {
	shader = gl.CreateShader(shader_type)

	source := os.read_entire_file(pathname) or_return
	defer delete(source)

	length := i32(len(source))
	source_code := cstring(raw_data(source))
	gl.ShaderSource(shader, 1, &source_code, &length)
	gl.CompileShader(shader)

	success: i32
	info_log: [512]u8
	gl.GetShaderiv(shader, gl.COMPILE_STATUS, &success)
	if success == 0 {
		gl.GetShaderInfoLog(shader, 512, nil, raw_data(&info_log))
		log.error(
			"ERROR::SHADER::",
			pathname,
			"::COMPILATION_FAILED: ",
			string(info_log[:]),
		)
		return 0, false
	}

	return
}

load_shader_program :: proc(
	vertex_shader_pathname: string,
	fragment_shader_pathname: string,
) -> (
	shader_program: u32,
	ok: bool = true,
) {
	shader_program = gl.CreateProgram()
	vertex_shader := load_shader(
		vertex_shader_pathname,
		gl.VERTEX_SHADER,
	) or_return
	fragment_shader := load_shader(
		fragment_shader_pathname,
		gl.FRAGMENT_SHADER,
	) or_return

	gl.AttachShader(shader_program, vertex_shader)
	gl.AttachShader(shader_program, fragment_shader)
	gl.LinkProgram(shader_program)

	success: i32
	info_log: [512]u8
	gl.GetProgramiv(shader_program, gl.LINK_STATUS, &success)
	if success == 0 {
		gl.GetProgramInfoLog(shader_program, 512, nil, raw_data(&info_log))
		log.error(
			"ERROR::LINKING::SHADER::PROGRAM\n",
			vertex_shader_pathname,
			fragment_shader_pathname,
			string(info_log[:]),
		)
		return 0, false
	}

	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(fragment_shader)
	return
}
