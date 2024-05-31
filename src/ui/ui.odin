package ui

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../camera"
import "../floor"
import "../tools"
import "../window"
import "../world"

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


ROYAL_BLUE :: glsl.vec4{0.255, 0.412, 0.882, 1}

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
	Scroll_Bar,
}

Context :: struct {
	ubo:                      u32,
	uniform_object:           Uniform_Object,
	text_renderer:            Text_Renderer,
	rect_renderer:            Rect_Renderer,
	icon_renderer:            Icon_Renderer,
	scroll_bar_renderer:      Scroll_Bar_Renderer,
	draw_calls:               [dynamic]Draw_Call,
	menu_icon_texture_array:  u32,
	scroll_bar_texture_array: u32,
	help_window_ctx:          Help_Window,
	floor_panel_ctx:          Floor_Panel,
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
	init_scroll_bar_renderer(ctx) or_return

	init_icon_texture_array(
		&menu_icon_texture_array,
		MENU_ICON_TEXTURES,
	) or_return

	init_icon_texture_array(
		&scroll_bar_texture_array,
		SCROLL_BAR_TEXTURES,
	) or_return

	return true
}

to_screen_pos :: proc(pos: glsl.vec2) -> glsl.vec2 {
	return {pos.x / window.size.x * 2 - 1, -(pos.y / window.size.y * 2 - 1)}
}

handle_menu_item_clicked :: proc(using ctx: ^Context, item: Menu_Icon) {
	// help_window_ctx.opened = false
    // floor_panel_ctx.opened = false
	switch item {
	case .Info:
		// help_window_ctx.opened = true
        help_window_ctx.opened = !help_window_ctx.opened
	case .Floor_Up:
		floor.move_up()
	case .Floor_Down:
		floor.move_down()
	case .Camera_Rotate_Left:
		camera.rotate_clockwise()
		world.update_after_rotation(.Clockwise)
	case .Camera_Rotate_Right:
		camera.rotate_counter_clockwise()
		world.update_after_rotation(.Counter_Clockwise)
	case .Landscape:
        floor_panel_ctx.opened = false
		tools.open_land_tool()
	case .Wall:
        floor_panel_ctx.opened = false
		tools.open_wall_tool()
	case .Floor:
        floor_panel_ctx.opened = true
		tools.open_floor_tool()
	}
}

update :: proc(using ctx: ^Context) {
	update_text_draws(&text_renderer)
	clear(&draw_calls)

	if help_window_ctx.opened {
		help_window(ctx)
	}

    if floor_panel_ctx.opened {
        floor_panel(ctx)
    }

	for ic, i in Menu_Icon {
		if icon_button(
			   ctx,
			   {f32(i * 31) - 3, window.size.y - 29},
			   {32, 32},
			   menu_icon_texture_array,
			   int(ic),
		   ) {
			handle_menu_item_clicked(ctx, ic)
		}
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
		case Scroll_Bar:
			draw_scroll_bar(ctx, dc)
		}
	}

}
