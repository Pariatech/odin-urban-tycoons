package ui

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../window"

MENU_ICON_TEXTURES :: []cstring {
	"resources/icons/info.png",
	"resources/icons/floor_up.png",
	"resources/icons/floor_down.png",
	"resources/icons/camera_rotate_left.png",
	"resources/icons/camera_rotate_right.png",
	"resources/icons/landscape.png",
	"resources/icons/wall.png",
	"resources/icons/floor.png",
}

Menu_Icon :: enum (int) {
	Info,
	Floor_Up,
	Floor_Down,
	Camera_Rotate_Left,
	Camera_Rotate_Right,
	Landscape,
	Wall,
	Floor,
}

Draw_Call :: union {
	Text,
	Rect,
	Icon,
}

Context :: struct {
	ubo:                     u32,
	uniform_object:          Uniform_Object,
	text_renderer:           Text_Renderer,
	rect_renderer:           Rect_Renderer,
	icon_renderer:           Icon_Renderer,
	draw_calls:              [dynamic]Draw_Call,
	menu_icon_texture_array: u32,
}

Uniform_Object :: struct {
	border_inner_color: glsl.vec4,
	border_outer_color: glsl.vec4,
	border_width:       f32,
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
	init_icon_renderer(ctx) or_return

	init_icon_texture_array(
		&menu_icon_texture_array,
		MENU_ICON_TEXTURES,
	) or_return

	return true
}

to_screen_pos :: proc(pos: glsl.vec2) -> glsl.vec2 {
	return {pos.x / window.size.x * 2 - 1, -(pos.y / window.size.y * 2 - 1)}
}

update :: proc(using ctx: ^Context) {
	update_text_draws(&text_renderer)
	clear(&draw_calls)

	rect(
		ctx,
		{x = 175, y = 175, w = 500, h = 26, color = {0.0, 0.251, 0.502, 1}},
	)

	text(ctx, {175 + 500 / 2, 180}, "Help", .CENTER, .TOP, 16)

	rect(
		ctx,
		{x = 175, y = 200, w = 500, h = 400, color = {0.255, 0.412, 0.882, 1}},
	)

	text(
		ctx,
		{185, 210},
		`---- Camera ----
W,A,S,D:      Move camera
Q,E:          Rotate camera
Mouse Scroll: Zoom

---- Terrain Tool [T] ----
Only work on grass tiles

Left Click:              Raise land
Right Click:             Lower land
+:                       Increase brush size
-:                       Reduce brush size
Shift +:                 Increase brush strength
Shift -:                 Reduce brush strength
Ctrl Click:              Smooth terrain
Shift Click & Drag:      Level terrain
Ctrl Shift Click & Drag: Flatten terrain

---- Wall Tool [G] ----
Left Click & Drag:              Place Wall
Shift Left Click & Drag:        Place Wall Rectangle
Ctrl Left Click & Drag:         Remove Wall
Ctrl Shift Left Click & Drag:   Remove Wall Rectangle
`,
		ah = .LEFT,
		av = .TOP,
		size = 18,
		clip_start = {185, 210},
		clip_end = {175 + 500 - 10, 200 + 400 - 10},
	)

	for ic, i in Menu_Icon {
		icon(
			ctx,
			 {
				texture_array = menu_icon_texture_array,
				pos = {f32(i * 31) - 3, window.size.y - 29},
				size = {32, 32},
				color = {0.255, 0.412, 0.882, 1},
				texture = int(ic),
			},
		)
	}
}

draw :: proc(using ctx: ^Context) {
	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	defer gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

	uniform_object = Uniform_Object {
		border_width = 1,
		border_inner_color = {0.529, 0.808, 0.922, 1},
		border_outer_color = {0, 0, 0.502, 1},
	}

	gl.BufferSubData(
		gl.UNIFORM_BUFFER,
		0,
		size_of(Uniform_Object),
		&uniform_object,
	)

	for draw_call in draw_calls {
		switch dc in draw_call {
		case Text:
			draw_text(ctx, dc)
		case Rect:
			draw_rect(ctx, dc)
		case Icon:
			draw_icon(ctx, dc)
		}
	}

}
