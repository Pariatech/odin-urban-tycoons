package renderer

import "core:os"
import "core:fmt"
import gl "vendor:OpenGL"

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
		fmt.println(
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
	shader_program: ^u32,
	vertex_shader_pathname: string,
	fragment_shader_pathname: string,
) -> (
	ok: bool = true,
) {
	shader_program^ = gl.CreateProgram()
	vertex_shader := load_shader(
		vertex_shader_pathname,
		gl.VERTEX_SHADER,
	) or_return
	fragment_shader := load_shader(
		fragment_shader_pathname,
		gl.FRAGMENT_SHADER,
	) or_return

	gl.AttachShader(shader_program^, vertex_shader)
	gl.AttachShader(shader_program^, fragment_shader)
	gl.LinkProgram(shader_program^)

	success: i32
	info_log: [512]u8
	gl.GetProgramiv(shader_program^, gl.LINK_STATUS, &success)
	if success == 0 {
		gl.GetProgramInfoLog(shader_program^, 512, nil, raw_data(&info_log))
		fmt.println("ERROR::LINKING::SHADER::PROGRAM\n", vertex_shader_pathname, fragment_shader_pathname, string(info_log[:]))
		return false
	}

	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(fragment_shader)
	gl.UseProgram(shader_program^)
	return
}
