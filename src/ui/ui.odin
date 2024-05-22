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
FONT :: "resources/fonts/ComicMono.ttf"

QUAD_VERTICES := [?]Vertex {
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, -1}, texcoords = {1, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, 1}, texcoords = {0, 0}},
}

Font :: struct {
	fs:          fontstash.FontContext,
	vbo, vao:    u32,
	id:        int,
	atlas:  u32,
	shader: u32,
}

Context :: struct {
    font: Font,
}

Vertex :: struct {
	pos:       glsl.vec2,
	texcoords: glsl.vec2,
}

font_atlas_resize :: proc(data: rawptr, w, h: int) {
	using ctx := (^Context)(data)

	gl.DeleteTextures(1, &font.atlas)
	create_font_atlas_texture(ctx)
}

font_atlas_update :: proc(
	data: rawptr,
	dirty_rect: [4]f32,
	texture_data: rawptr,
) {
	using ctx := (^Context)(data)

	defer gl.BindTexture(gl.TEXTURE_2D, 0)
	gl.BindTexture(gl.TEXTURE_2D, font.atlas)

	gl.TexSubImage2D(
		gl.TEXTURE_2D,
		0,
		0,
		0,
		i32(font.fs.width),
		i32(font.fs.height),
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(font.fs.textureData),
	)

	// font_atlas_resize(ctx, 0, 0)
}

create_font_atlas_texture :: proc(using ctx: ^Context) {
	gl.CreateTextures(gl.TEXTURE_2D, 1, &font.atlas)

	defer gl.BindTexture(gl.TEXTURE_2D, 0)
	gl.BindTexture(gl.TEXTURE_2D, font.atlas)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RED,
		i32(font.fs.width),
		i32(font.fs.height),
		0,
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(font.fs.textureData),
	)
}

init :: proc(using ctx: ^Context) -> (ok: bool = false) {
	fontstash.Init(&font.fs, 1024, 1024, .TOPLEFT)
	font.fs.callbackResize = font_atlas_resize
	font.fs.callbackUpdate = font_atlas_update
	font.fs.userData = ctx
	font.id = fontstash.AddFont(&font.fs, "ComicMono", "resources/fonts/ComicMono.ttf")
	// font = fontstash.AddFont(&fs, "ComicMono", "resources/fonts/ComicNeue-Regular.otf")
	fontstash.AddFallbackFont(
		&font.fs,
		font.id,
		fontstash.AddFont(
			&font.fs,
			"NotoSans-Regular",
			"resources/fonts/ComicNeue-Bold.otf",
		),
	)
	fontstash.AddFallbackFont(
		&font.fs,
		font.id,
		fontstash.AddFont(
			&font.fs,
			"NotoColorEmoji",
			"resources/fonts/Symbola_hint.ttf",
		),
	)
	fontstash.AddFallbackFont(
		&font.fs,
		font.id,
		fontstash.AddFont(
			&font.fs,
			"NotoSansJP-Regular",
			"resources/fonts/NotoSansJP-Regular.ttf",
		),
	)

	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.GenVertexArrays(1, &font.vao)
	gl.BindVertexArray(font.vao)

	gl.GenBuffers(1, &font.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, font.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(QUAD_VERTICES) * size_of(Vertex),
		nil,
		gl.STATIC_DRAW,
	)

	// gl.GenTextures(1, &font_atlas)
	// gl.ActiveTexture(gl.TEXTURE0)
	// gl.BindTexture(gl.TEXTURE_2D, font_atlas)

	create_font_atlas_texture(ctx)

	renderer.load_shader_program(
		&font.shader,
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

draw_text :: proc(using ctx: ^Context, position: glsl.vec2, text: string) {
	fontstash.BeginState(&font.fs)
	fontstash.SetFont(&font.fs, font.id)
	fontstash.SetSize(&font.fs, 32)
	fontstash.SetColor(&font.fs, {1, 1, 1, 1})
	fontstash.SetAlignVertical(&font.fs, .BASELINE)
	fontstash.SetAlignHorizontal(&font.fs, .LEFT)
	fontstash.SetSpacing(&font.fs, 1)
	fontstash.SetBlur(&font.fs, 0)

	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.Enable(gl.DEPTH_TEST)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.Disable(gl.DEPTH_TEST)

	gl.BindVertexArray(font.vao)
	gl.UseProgram(font.shader)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, font.atlas)
	gl.BindBuffer(gl.ARRAY_BUFFER, font.vbo)

	it := fontstash.TextIterInit(&font.fs, position.x, position.y, text)
	quad: fontstash.Quad
	for fontstash.TextIterNext(&font.fs, &it, &quad) {
		vertices := QUAD_VERTICES
		vertices[0].pos = glsl.vec2 {
			quad.x0 / window.size.x * 2 - 1,
			-(quad.y0 / window.size.y * 2 - 1),
		}
		vertices[0].texcoords = glsl.vec2{quad.s0, quad.t0}
		vertices[1].pos = glsl.vec2 {
			quad.x1 / window.size.x * 2 - 1,
			-(quad.y0 / window.size.y * 2 - 1),
		}
		vertices[1].texcoords = glsl.vec2{quad.s1, quad.t0}
		vertices[2].pos = glsl.vec2 {
			quad.x1 / window.size.x * 2 - 1,
			-(quad.y1 / window.size.y * 2 - 1),
		}
		vertices[2].texcoords = glsl.vec2{quad.s1, quad.t1}
		vertices[3] = vertices[0]
		vertices[4] = vertices[2]
		vertices[5].pos = glsl.vec2 {
			quad.x0 / window.size.x * 2 - 1,
			-(quad.y1 / window.size.y * 2 - 1),
		}
		vertices[5].texcoords = glsl.vec2{quad.s0, quad.t1}
		gl.BufferSubData(
			gl.ARRAY_BUFFER,
			0,
			len(vertices) * size_of(Vertex),
			raw_data(&vertices),
		)
		gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices)))
	}

	fontstash.EndState(&font.fs)
}

draw :: proc(using ctx: ^Context) {
	draw_text(
		ctx,
		{10, 40},
		"📌☻😆😻 Hello, World! hola, cómo estás, こんにちは, Straße $398",
	)
}
