package ui

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"
import "vendor:fontstash"
import stbi "vendor:stb/image"

import "../renderer"
import "../window"

FONT_VERTEX_SHADER :: "resources/shaders/ui/font.vert"
FONT_FRAGMENT_SHADER :: "resources/shaders/ui/font.frag"
RECT_VERTEX_SHADER :: "resources/shaders/ui/rect.vert"
RECT_FRAGMENT_SHADER :: "resources/shaders/ui/rect.frag"
FONT :: "resources/fonts/ComicMono.ttf"

FONT_QUAD_VERTICES := [?]Vertex {
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, -1}, texcoords = {1, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, 1}, texcoords = {0, 0}},
}

RECT_QUAD_VERTICES := [?]Rect_Vertex {
	{pos = {-1, -1}, color = {1, 1, 1, 1}},
	{pos = {1, -1}, color = {1, 1, 1, 1}},
	{pos = {1, 1}, color = {1, 1, 1, 1}},
	{pos = {-1, -1}, color = {1, 1, 1, 1}},
	{pos = {1, 1}, color = {1, 1, 1, 1}},
	{pos = {-1, 1}, color = {1, 1, 1, 1}},
}

Text_Renderer :: struct {
	fs:       fontstash.FontContext,
	vbo, vao: u32,
	id:       int,
	atlas:    u32,
	shader:   u32,
}

Rect_Renderer :: struct {
	vbo, vao: u32,
	shader:   u32,
}

Rect :: struct {
	x, y, w, h: f32,
	color:      glsl.vec4,
}

Context :: struct {
	ubo:            u32,
	uniform_object: Uniform_Object,
	text_renderer:  Text_Renderer,
	rect_renderer:  Rect_Renderer,
}

Vertex :: struct {
	pos:       glsl.vec2,
	texcoords: glsl.vec2,
}

Rect_Vertex :: struct {
	pos:   glsl.vec2,
	start: glsl.vec2,
	end:   glsl.vec2,
	color: glsl.vec4,
}

Uniform_Object :: struct {
	border_inner_color: glsl.vec4,
	border_outer_color: glsl.vec4,
	border_width:       f32,
}

font_atlas_resize :: proc(data: rawptr, w, h: int) {
	using ctx := (^Context)(data)

	gl.DeleteTextures(1, &text_renderer.atlas)
	create_font_atlas_texture(ctx)
}

font_atlas_update :: proc(
	data: rawptr,
	dirty_rect: [4]f32,
	texture_data: rawptr,
) {
	using ctx := (^Context)(data)

	defer gl.BindTexture(gl.TEXTURE_2D, 0)
	gl.BindTexture(gl.TEXTURE_2D, text_renderer.atlas)

	gl.TexSubImage2D(
		gl.TEXTURE_2D,
		0,
		0,
		0,
		i32(text_renderer.fs.width),
		i32(text_renderer.fs.height),
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(text_renderer.fs.textureData),
	)
}

create_font_atlas_texture :: proc(using ctx: ^Context) {
	gl.CreateTextures(gl.TEXTURE_2D, 1, &text_renderer.atlas)

	defer gl.BindTexture(gl.TEXTURE_2D, 0)
	gl.BindTexture(gl.TEXTURE_2D, text_renderer.atlas)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RED,
		i32(text_renderer.fs.width),
		i32(text_renderer.fs.height),
		0,
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(text_renderer.fs.textureData),
	)
}

init :: proc(using ctx: ^Context) -> (ok: bool = false) {
	gl.GenBuffers(1, &ubo)

	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	defer gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Uniform_Object),
		nil,
		gl.STATIC_DRAW,
	)

	gl.BindBufferBase(gl.UNIFORM_BUFFER, 0, ubo)

	init_text_renderer(ctx) or_return
	init_rect_renderer(ctx) or_return

	return true
}

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

init_text_renderer :: proc(using ctx: ^Context) -> (ok: bool = false) {
	fontstash.Init(&text_renderer.fs, 1024, 1024, .TOPLEFT)
	text_renderer.fs.callbackResize = font_atlas_resize
	text_renderer.fs.callbackUpdate = font_atlas_update
	text_renderer.fs.userData = ctx
	text_renderer.id = fontstash.AddFont(
		&text_renderer.fs,
		"ComicMono",
		"resources/fonts/ComicMono.ttf",
	)
	// font = fontstash.AddFont(&fs, "ComicMono", "resources/fonts/ComicNeue-Regular.otf")
	fontstash.AddFallbackFont(
		&text_renderer.fs,
		text_renderer.id,
		fontstash.AddFont(
			&text_renderer.fs,
			"NotoSans-Regular",
			"resources/fonts/ComicNeue-Bold.otf",
		),
	)
	fontstash.AddFallbackFont(
		&text_renderer.fs,
		text_renderer.id,
		fontstash.AddFont(
			&text_renderer.fs,
			"NotoColorEmoji",
			"resources/fonts/Symbola_hint.ttf",
		),
	)
	fontstash.AddFallbackFont(
		&text_renderer.fs,
		text_renderer.id,
		fontstash.AddFont(
			&text_renderer.fs,
			"NotoSansJP-Regular",
			"resources/fonts/NotoSansJP-Regular.ttf",
		),
	)

	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.GenVertexArrays(1, &text_renderer.vao)
	gl.BindVertexArray(text_renderer.vao)

	gl.GenBuffers(1, &text_renderer.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, text_renderer.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(FONT_QUAD_VERTICES) * size_of(Vertex),
		nil,
		gl.STATIC_DRAW,
	)

	// gl.GenTextures(1, &font_atlas)
	// gl.ActiveTexture(gl.TEXTURE0)
	// gl.BindTexture(gl.TEXTURE_2D, font_atlas)

	create_font_atlas_texture(ctx)

	renderer.load_shader_program(
		&text_renderer.shader,
		FONT_VERTEX_SHADER,
		FONT_FRAGMENT_SHADER,
	) or_return

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(
		0,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, texcoords),
	)

	return true
}

to_screen_pos :: proc(pos: glsl.vec2) -> glsl.vec2 {
	return {pos.x / window.size.x * 2 - 1, -(pos.y / window.size.y * 2 - 1)}
}

draw_text :: proc(
	using ctx: ^Context,
	position: glsl.vec2,
	text: string,
	ah: fontstash.AlignHorizontal = .LEFT,
	av: fontstash.AlignVertical = .BASELINE,
    size: f32 = 32,
) {
	using text_renderer
	fontstash.BeginState(&fs)
	fontstash.SetFont(&fs, id)
	fontstash.SetSize(&fs, size)
	// fontstash.SetColor(&fs, {0, 0, 0, 0})
	fontstash.SetAlignVertical(&fs, av)
	fontstash.SetAlignHorizontal(&fs, ah)
	// fontstash.SetSpacing(&fs, 0)
	// fontstash.SetBlur(&fs, 0.0)

	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.Enable(gl.DEPTH_TEST)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.Disable(gl.DEPTH_TEST)

	gl.BindVertexArray(vao)
	gl.UseProgram(shader)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, atlas)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	it := fontstash.TextIterInit(&fs, position.x, position.y, text)
	quad: fontstash.Quad
	for fontstash.TextIterNext(&fs, &it, &quad) {
		vertices := FONT_QUAD_VERTICES
		vertices[0].pos = to_screen_pos({quad.x0, quad.y0})
		vertices[0].texcoords = glsl.vec2{quad.s0, quad.t0}
		vertices[1].pos = to_screen_pos({quad.x1, quad.y0})
		vertices[1].texcoords = glsl.vec2{quad.s1, quad.t0}
		vertices[2].pos = to_screen_pos({quad.x1, quad.y1})
		vertices[2].texcoords = glsl.vec2{quad.s1, quad.t1}
		vertices[3] = vertices[0]
		vertices[4] = vertices[2]
		vertices[5].pos = to_screen_pos({quad.x0, quad.y1})
		vertices[5].texcoords = glsl.vec2{quad.s0, quad.t1}
		gl.BufferSubData(
			gl.ARRAY_BUFFER,
			0,
			len(vertices) * size_of(Vertex),
			raw_data(&vertices),
		)
		gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices)))
	}

	fontstash.EndState(&fs)
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

draw :: proc(using ctx: ^Context) {
	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	defer gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

	uniform_object = Uniform_Object {
		border_width = 2,
		border_inner_color = {0.529, 0.808, 0.922, 1},
		border_outer_color = {0, 0, 0.502, 1},
	}

	gl.BufferSubData(
		gl.UNIFORM_BUFFER,
		0,
		size_of(Uniform_Object),
		&uniform_object,
	)

	draw_text(
		ctx,
		{10, 40},
		"📌☻😆😻 Hello, World! hola, cómo estás, こんにちは, Straße $398",
	)
	draw_rect(
		ctx,
		{x = 175, y = 175, w = 500, h = 26, color = {0.0, 0.251, 0.502, 1}},
	)

	draw_text(ctx, {175 + 500 / 2, 180}, "Help", .CENTER, .TOP, 16)

	draw_rect(
		ctx,
		{x = 175, y = 200, w = 500, h = 400, color = {0.255, 0.412, 0.882, 1}},
	)
}
