package ui

import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../renderer"

RECT_VERTEX_SHADER :: "resources/shaders/ui/rect.vert"
RECT_FRAGMENT_SHADER :: "resources/shaders/ui/rect.frag"

RECT_QUAD_VERTICES := [?]Rect_Vertex {
	{pos = {-1, -1}, color = {1, 1, 1, 1}},
	{pos = {1, -1}, color = {1, 1, 1, 1}},
	{pos = {1, 1}, color = {1, 1, 1, 1}},
	{pos = {-1, -1}, color = {1, 1, 1, 1}},
	{pos = {1, 1}, color = {1, 1, 1, 1}},
	{pos = {-1, 1}, color = {1, 1, 1, 1}},
}

Rect_Vertex :: struct {
	pos:   glsl.vec2,
	start: glsl.vec2,
	end:   glsl.vec2,
	color: glsl.vec4,
}

Rect_Renderer :: struct {
	vbo, vao: u32,
	shader:   u32,
}

Rect :: struct {
	x, y, w, h: f32,
	color:      glsl.vec4,
}

Rect_Draw_Call :: Rect

init_rect_renderer :: proc(using ctx: ^Context) -> (ok: bool = false) {
	using ctx.rect_renderer

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)
	defer gl.BindVertexArray(0)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(RECT_QUAD_VERTICES) * size_of(Rect_Vertex),
		nil,
		gl.STATIC_DRAW,
	)

	renderer.load_shader_program(
		&shader,
		RECT_VERTEX_SHADER,
		RECT_FRAGMENT_SHADER,
	) or_return
	defer gl.UseProgram(0)

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(
		0,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Rect_Vertex),
		offset_of(Rect_Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Rect_Vertex),
		offset_of(Rect_Vertex, start),
	)

	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(
		2,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Rect_Vertex),
		offset_of(Rect_Vertex, end),
	)

	gl.EnableVertexAttribArray(3)
	gl.VertexAttribPointer(
		3,
		4,
		gl.FLOAT,
		gl.FALSE,
		size_of(Rect_Vertex),
		offset_of(Rect_Vertex, color),
	)

	return true
}

draw_rect :: proc(using ctx: ^Context, rect: Rect) {
	using rect_renderer

	gl.Disable(gl.DEPTH_TEST)
	defer gl.Enable(gl.DEPTH_TEST)

	gl.BindVertexArray(vao)
	defer gl.BindVertexArray(0)

	gl.UseProgram(shader)
	defer gl.UseProgram(0)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	vertices := RECT_QUAD_VERTICES

	vertices[0].pos = to_screen_pos({rect.x, rect.y})
	vertices[1].pos = to_screen_pos({rect.x + rect.w, rect.y})
	vertices[2].pos = to_screen_pos({rect.x + rect.w, rect.y + rect.h})
	vertices[3] = vertices[0]
	vertices[4] = vertices[2]
	vertices[5].pos = to_screen_pos({rect.x, rect.y + rect.h})

	for &v in vertices {
		v.start = {rect.x, rect.y}
		v.end = {rect.x + rect.w, rect.y + rect.h}
		// v.start = to_screen_pos({rect.x, rect.y})
		// v.end = to_screen_pos({rect.x + rect.w, rect.y + rect.h})
		v.color = rect.color
	}

	gl.BufferSubData(
		gl.ARRAY_BUFFER,
		0,
		len(vertices) * size_of(Rect_Vertex),
		raw_data(&vertices),
	)
	gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices)))
}

rect :: proc(using ctx: ^Context, rect: Rect) {
    append(&draw_calls, rect)
}

