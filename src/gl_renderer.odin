package main

import "core:fmt"
import "core:os"
import "core:runtime"
import gl "vendor:OpenGL"
import "vendor:glfw"
import stbi "vendor:stb/image"
import m "core:math/linalg/glsl"

GL_MAJOR_VERSION :: 4
GL_MINOR_VERSION :: 5
TEXTURE_SIZE :: 512
VERTEX_SHADER_PATH :: "resources/shaders/shader.vert"
FRAGMENT_SHADER_PATH :: "resources/shaders/shader.frag"

texture_array: u32
vbo, vao, ubo: u32
shader_program: u32
vertices: [dynamic]Vertex
indices: [dynamic]u32
uniform_object: Uniform_Object

Uniform_Object :: struct {
	proj, view: m.mat4,
}

Vertex :: struct {
	pos:       m.vec3,
	light:     m.vec3,
	texcoords: m.vec4,
}

gl_debug_callback :: proc "c" (
	source: u32,
	type: u32,
	id: u32,
	severity: u32,
	length: i32,
	message: cstring,
	userParam: rawptr,
) {
	context = runtime.default_context()
	fmt.println("OpenGL Debug: ", message)
}

load_texture_array :: proc() -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)

	textures :: len(texture_paths)

	if (textures == 0) {
		fmt.println("No textures to load.")
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexStorage3D(
		gl.TEXTURE_2D_ARRAY,
		1,
		gl.RGBA8,
		TEXTURE_SIZE,
		TEXTURE_SIZE,
		textures,
	)

	for path, i in texture_paths {
		width: i32
		height: i32
		pixels := stbi.load(path, &width, &height, nil, 4)
		defer stbi.image_free(pixels)

		if pixels == nil {
			fmt.eprintln("Failed to load texture: ", path)
			return false
		}

		if width != TEXTURE_SIZE {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				TEXTURE_SIZE,
				" got: ",
				width,
			)
			return false
		}

		if height != TEXTURE_SIZE {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				TEXTURE_SIZE,
				" got: ",
				height,
			)
			return false
		}

		gl.TexSubImage3D(
			gl.TEXTURE_2D_ARRAY,
			0,
			0,
			0,
			i32(i),
			TEXTURE_SIZE,
			TEXTURE_SIZE,
			1,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			pixels,
		)
	}

	return
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
		fmt.println(
			"ERROR::SHADER::",
			shader_type,
			"::COMPILATION_FAILED: ",
			string(info_log[:]),
		)
		return 0, false
	}

	return
}

load_shader_program :: proc() -> (ok: bool = true) {
	shader_program = gl.CreateProgram()
	vertex_shader := load_shader(
		VERTEX_SHADER_PATH,
		gl.VERTEX_SHADER,
	) or_return
	fragment_shader := load_shader(
		FRAGMENT_SHADER_PATH,
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
		fmt.println("ERROR::LINKING::SHADER::PROGRAM\n", string(info_log[:]))
		return false
	}

	gl.DeleteShader(vertex_shader)
	gl.DeleteShader(fragment_shader)
	gl.UseProgram(shader_program)
	return
}

init_renderer :: proc() -> (ok: bool = true) {
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	gl.Enable(gl.DEBUG_OUTPUT)
	gl.DebugMessageCallback(gl_debug_callback, nil)
	gl.Enable(gl.BLEND)
	gl.BlendEquation(gl.FUNC_ADD)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)

	gl.GenTextures(1, &texture_array)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)

	load_texture_array() or_return

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.GenBuffers(1, &ubo)
	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Uniform_Object),
		nil,
		gl.STATIC_DRAW,
	)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)

	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, pos),
	)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(
		1,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, light),
	)
	gl.EnableVertexAttribArray(1)

	gl.VertexAttribPointer(
		2,
		4,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, texcoords),
	)
	gl.EnableVertexAttribArray(2)

	load_shader_program() or_return

	return
}

deinit_renderer :: proc() {
	gl.DeleteTextures(1, &texture_array)
	gl.DeleteBuffers(1, &vao)
	gl.DeleteBuffers(1, &vbo)
	gl.DeleteBuffers(1, &ubo)
	gl.DeleteProgram(shader_program)
}

begin_draw :: proc() {
	if (framebuffer_resized) {
		width, height := glfw.GetWindowSize(window_handle)
		gl.Viewport(0, 0, width, height)
	}

	framebuffer_resized = false

	gl.ClearColor(0.0, 0.0, 0.0, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT)

	clear(&vertices)
	clear(&indices)
}

end_draw :: proc() {
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)

	gl.BufferSubData(
		gl.UNIFORM_BUFFER,
		0,
		size_of(Uniform_Object),
		&uniform_object,
	)

	gl.DrawElements(
		gl.TRIANGLES,
		i32(len(indices)),
		gl.UNSIGNED_INT,
		raw_data(indices),
	)

	glfw.SwapBuffers(window_handle)

	gl_error := gl.GetError()
	if (gl_error != gl.NO_ERROR) {
		fmt.println("error?: ", gl_error)
	}
}

draw_triangle :: proc(v0, v1, v2: Vertex) {
	index_offset := u32(len(vertices))
	append(&vertices, v0, v1, v2)
	append(&indices, index_offset + 0, index_offset + 1, index_offset + 2)
}

draw_quad :: proc(v0, v1, v2, v3: Vertex) {
	index_offset := u32(len(vertices))
	append(&vertices, v0, v1, v2, v3)
	append(
		&indices,
		index_offset + 0,
		index_offset + 1,
		index_offset + 2,
		index_offset + 0,
		index_offset + 2,
		index_offset + 3,
	)
}
