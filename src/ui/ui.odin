package ui

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"
import "vendor:fontstash"
import stbi "vendor:stb/image"

import "../renderer"
import "../window"

VERTEX_SHADER :: "resources/shaders/ui.vert"
FRAGMENT_SHADER :: "resources/shaders/ui.frag"
FONT :: "resources/fonts/ComicMono.ttf"

QUAD_VERTICES := [?]Vertex {
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, -1}, texcoords = {1, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, -1}, texcoords = {0, 1}},
	{pos = {1, 1}, texcoords = {1, 0}},
	{pos = {-1, 1}, texcoords = {0, 0}},
}

Context :: struct {
	fs:         fontstash.FontContext,
	vbo, vao:   u32,
	font:       int,
	font_atlas: u32,
	shader:     u32,
}

Vertex :: struct {
	pos:       glsl.vec2,
	texcoords: glsl.vec2,
}

font_atlas_resize :: proc(data: rawptr, w, h: int) {
	using ctx := (^Context)(data)

	gl.DeleteTextures(1, &font_atlas)
	create_font_atlas_texture(ctx)
}

font_atlas_update :: proc(
	data: rawptr,
	dirty_rect: [4]f32,
	texture_data: rawptr,
) {
	using ctx := (^Context)(data)

	defer gl.BindTexture(gl.TEXTURE_2D, 0)
	gl.BindTexture(gl.TEXTURE_2D, font_atlas)

	gl.TexSubImage2D(
		gl.TEXTURE_2D,
		0,
		0,
		0,
		i32(fs.width),
		i32(fs.height),
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(fs.textureData),
	)

	// font_atlas_resize(ctx, 0, 0)
}

create_font_atlas_texture :: proc(using ctx: ^Context) {
	gl.CreateTextures(gl.TEXTURE_2D, 1, &font_atlas)

	defer gl.BindTexture(gl.TEXTURE_2D, 0)
	gl.BindTexture(gl.TEXTURE_2D, font_atlas)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	gl.TexImage2D(
		gl.TEXTURE_2D,
		0,
		gl.RED,
		i32(fs.width),
		i32(fs.height),
		0,
		gl.RED,
		gl.UNSIGNED_BYTE,
		raw_data(fs.textureData),
	)
}

init :: proc(using ctx: ^Context) -> (ok: bool = false) {
	fontstash.Init(&fs, 1024, 1024, .TOPLEFT)
	fs.callbackResize = font_atlas_resize
	fs.callbackUpdate = font_atlas_update
	fs.userData = ctx
	// font = fontstash.AddFont(&fs, "ComicMono", "resources/fonts/ComicMono.ttf")
	font = fontstash.AddFont(&fs, "ComicMono", "resources/fonts/ComicNeue-Regular.otf")
	fontstash.AddFallbackFont(
		&fs,
		font,
		fontstash.AddFont(
			&fs,
			"NotoColorEmoji",
			"resources/fonts/Symbola_hint.ttf",
		),
	)
	// fontstash.AddFallbackFont(
	// 	&fs,
	// 	font,
	// 	fontstash.AddFont(
	// 		&fs,
	// 		"NotoSans-Regular",
	// 		"resources/fonts/NotoSans-Regular.ttf",
	// 	),
	// )
	fontstash.AddFallbackFont(
		&fs,
		font,
		fontstash.AddFont(
			&fs,
			"NotoSansJP-Regular",
			"resources/fonts/NotoSansJP-Regular.ttf",
		),
	)

	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
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
		&shader,
		VERTEX_SHADER,
		FRAGMENT_SHADER,
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

}

draw :: proc(using ctx: ^Context) {
	fontstash.BeginState(&fs)
	fontstash.SetFont(&fs, font)
	fontstash.SetSize(&fs, 32)
	fontstash.SetColor(&fs, {1, 1, 1, 1})
	fontstash.SetAlignVertical(&fs, .BASELINE)
	fontstash.SetAlignHorizontal(&fs, .LEFT)
	fontstash.SetSpacing(&fs, 1)
	fontstash.SetBlur(&fs, 0)
	// fontstash.set
	// fs.dirtyRect
	// font_atlas_update(ctx, fs.dirtyRect, &fs.textureData)

	defer gl.BindVertexArray(0)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	defer gl.UseProgram(0)
	defer gl.Enable(gl.DEPTH_TEST)
	defer gl.BindTexture(gl.TEXTURE_2D, 0)

	gl.Disable(gl.DEPTH_TEST)

	gl.BindVertexArray(vao)
	gl.UseProgram(shader)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D, font_atlas)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	it := fontstash.TextIterInit(
		&fs,
		10,
		40,
		"📌☻😆😻 Hello, World! hola, cómo estás, こんにちは, Straße",
	)
	quad: fontstash.Quad
	for fontstash.TextIterNext(&fs, &it, &quad) {
		vertices := QUAD_VERTICES
		// log.info(quad)
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
		// gl.BufferData(
		// 	gl.ARRAY_BUFFER,
		// 	len(vertices) * size_of(Vertex),
		// 	raw_data(&vertices),
		// 	gl.STATIC_DRAW,
		// )

		gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices)))
	}
	// vertices := QUAD_VERTICES
	// gl.BufferSubData(
	// 	gl.ARRAY_BUFFER,
	// 	0,
	// 	len(vertices) * size_of(Vertex),
	// 	raw_data(&vertices),
	// )
	// gl.BufferData(
	// 	gl.ARRAY_BUFFER,
	// 	len(vertices) * size_of(Vertex),
	// 	raw_data(&vertices),
	// 	gl.STATIC_DRAW,
	// )

	// gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices)))

	fontstash.EndState(&fs)
}
