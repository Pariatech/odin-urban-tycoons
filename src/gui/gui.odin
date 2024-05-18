package gui

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import stbi "vendor:stb/image"

import "../window"
import "../renderer"

gui_vbo, gui_vao: u32
gui_texture: u32
gui_texture_size: glsl.ivec2
gui_shader: u32
gui_vertices: [dynamic]Gui_Vertex =  {
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, -1}, texcoords = {1, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, 1}, texcoords = {0, 0}},
}

GUI_TEXTURE_PATH :: "resources/textures/gui/terrain-tool-info.png"
GUI_VERTEX_SHADER_PATH :: "resources/shaders/gui.vert"
GUI_FRAGMENT_SHADER_PATH :: "resources/shaders/gui.frag"

Gui_Vertex :: struct {
	pos:       glsl.vec2,
	texcoords: glsl.vec2,
}

init :: proc() -> (ok: bool = false) {
	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.GenVertexArrays(1, &gui_vao)
	gl.BindVertexArray(gui_vao)

	gl.GenBuffers(1, &gui_vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, gui_vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(gui_vertices) * size_of(Gui_Vertex),
		raw_data(gui_vertices),
		gl.STATIC_DRAW,
	)

	gl.GenTextures(1, &gui_texture)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, gui_texture)
	load_texture(GUI_TEXTURE_PATH) or_return

	renderer.load_shader_program(
		&gui_shader,
		GUI_VERTEX_SHADER_PATH,
		GUI_FRAGMENT_SHADER_PATH,
	) or_return

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(
		0,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Gui_Vertex),
		offset_of(Gui_Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Gui_Vertex),
		offset_of(Gui_Vertex, texcoords),
	)

	return true
}

gui_to_screen_space :: proc(pos: glsl.ivec2) -> (screen_pos: glsl.vec2) {
	screen_pos.x = f32(pos.x) / f32(window.size.x) * 2 - 1
	screen_pos.y = f32(pos.y) / f32(window.size.y) * 2 - 1

	return screen_pos
}

draw :: proc() {
	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.Enable(gl.DEPTH_TEST)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.Disable(gl.DEPTH_TEST)

	gl.BindVertexArray(gui_vao)
	gl.UseProgram(gui_shader)
	gl.BindTexture(gl.TEXTURE_2D, gui_texture)
	gl.BindBuffer(gl.ARRAY_BUFFER, gui_vbo)

	gui_vertices[0].pos = gui_to_screen_space(
		glsl.ivec2 {
			i32(window.size.x) - gui_texture_size.x - 5,
			i32(window.size.y) - gui_texture_size.y - 5,
		},
	)
	gui_vertices[1].pos = gui_to_screen_space(
		glsl.ivec2 {
			i32(window.size.x) - 5,
			i32(window.size.y) - gui_texture_size.y - 5,
		},
	)
	gui_vertices[2].pos = gui_to_screen_space(
		glsl.ivec2 {
			i32(window.size.x) - 5,
			i32(window.size.y) - 5,
		},
	)

    gui_vertices[3] = gui_vertices[0]
    gui_vertices[4] = gui_vertices[2]

	gui_vertices[5].pos = gui_to_screen_space(
		glsl.ivec2 {
			i32(window.size.x) - gui_texture_size.x - 5,
			i32(window.size.y) - 5,
		},
	)

	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, gui_texture)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(gui_vertices) * size_of(Gui_Vertex),
		raw_data(gui_vertices),
		gl.STATIC_DRAW,
	)

	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(gui_vertices)))
}

load_texture :: proc(path: cstring) -> (ok: bool = false) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	pixels := stbi.load(path, &gui_texture_size.x, &gui_texture_size.y, nil, 4)
	gl.TexStorage2D(
		gl.TEXTURE_2D,
		1,
		gl.RGBA8,
		gui_texture_size.x,
		gui_texture_size.y,
	)

	defer stbi.image_free(pixels)

	if pixels == nil {
		fmt.eprintln("Failed to load texture: ", path)
		return
	}

	gl.TexSubImage2D(
		gl.TEXTURE_2D,
		0,
		0,
		0,
		gui_texture_size.x,
		gui_texture_size.y,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		pixels,
	)

	return true
}
