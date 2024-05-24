package ui

import "core:log"
import "core:math/linalg/glsl"
import "core:strings"

import gl "vendor:OpenGL"
import "vendor:fontstash"
import stbi "vendor:stb/image"

import "../renderer"
import "../window"

FONT_VERTEX_SHADER :: "resources/shaders/ui/font.vert"
FONT_FRAGMENT_SHADER :: "resources/shaders/ui/font.frag"
FONT :: "resources/fonts/ComicMono.ttf"

FONT_QUAD_VERTICES := [?]Text_Vertex {
	{pos = {-1, -1}, texcoords = {0, 1}, color = {1, 1, 1, 1}},
	{pos = {1, -1}, texcoords = {1, 1}, color = {1, 1, 1, 1}},
	{pos = {1, 1}, texcoords = {1, 0}, color = {1, 1, 1, 1}},
	{pos = {-1, -1}, texcoords = {0, 1}, color = {1, 1, 1, 1}},
	{pos = {1, 1}, texcoords = {1, 0}, color = {1, 1, 1, 1}},
	{pos = {-1, 1}, texcoords = {0, 0}, color = {1, 1, 1, 1}},
}

Text_Renderer :: struct {
	fs:       fontstash.FontContext,
	vbo, vao: u32,
	id:       int,
	atlas:    u32,
	shader:   u32,
}

Text_Vertex :: struct {
	pos:       glsl.vec2,
	texcoords: glsl.vec2,
	color:     glsl.vec4,
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
		len(FONT_QUAD_VERTICES) * size_of(Text_Vertex),
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
		size_of(Text_Vertex),
		offset_of(Text_Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Text_Vertex),
		offset_of(Text_Vertex, texcoords),
	)

	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(
		2,
		4,
		gl.FLOAT,
		gl.FALSE,
		size_of(Text_Vertex),
		offset_of(Text_Vertex, color),
	)

	return true
}

draw_text :: proc(
	using ctx: ^Context,
	position: glsl.vec2,
	text: string,
	ah: fontstash.AlignHorizontal = .LEFT,
	av: fontstash.AlignVertical = .BASELINE,
	size: f32 = 32,
	color: glsl.vec4 = {1, 1, 1, 1},
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

	lines := strings.split_lines(text)
	defer delete(lines)

    y := position.y
	for line in lines {
		it := fontstash.TextIterInit(&fs, position.x, y, line)

        miny, maxy := fontstash.LineBounds(&fs, y)
        y = maxy

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
			for &v in vertices {
				v.color = color
			}
			gl.BufferSubData(
				gl.ARRAY_BUFFER,
				0,
				len(vertices) * size_of(Text_Vertex),
				raw_data(&vertices),
			)
			gl.DrawArrays(gl.TRIANGLES, 0, i32(len(vertices)))
		}
	}

	fontstash.EndState(&fs)
}
