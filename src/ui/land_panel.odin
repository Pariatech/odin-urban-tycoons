package ui

import "core:math/linalg/glsl"

import "../tools"
import "../tools/terrain_tool"
import "../window"

LAND_ICON_TEXTURES :: []cstring {
	"resources/icons/land_brush_size.png",
	"resources/icons/land_brush_strength.png",
	"resources/icons/land_raise.png",
	"resources/icons/land_lower.png",
	"resources/icons/land_level.png",
	"resources/icons/land_trim.png",
	"resources/icons/land_smooth.png",
}

Land_Icon_Texture :: enum {
	Brush_Size,
	Brush_Strength,
	Raise,
	Lower,
    Level,
    Trim,
    Smooth,
}

land_panel_texture_array: u32

init_land_panel :: proc() -> (ok: bool = true) {
	init_icon_texture_array(
		&land_panel_texture_array,
		LAND_ICON_TEXTURES,
	) or_return

	return
}

land_panel_body :: proc(using ctx: ^Context, pos: glsl.vec2, size: glsl.vec2) {
	if icon_button(
		   ctx,
		   pos = {pos.x + 4, pos.y + 4},
		   size = {32, 32},
		   color = ROYAL_BLUE,
		   texture_array = land_panel_texture_array,
		   texture = int(Land_Icon_Texture.Raise),
	   ) {

	}

	if icon_button(
		   ctx,
		   pos = {pos.x + 4, pos.y + size.y - 32 - 4},
		   size = {32, 32},
		   color = ROYAL_BLUE,
		   texture_array = land_panel_texture_array,
		   texture = int(Land_Icon_Texture.Lower),
	   ) {

	}

	if icon_button(
		   ctx,
		   pos = {pos.x + 32 + 4 + 2, pos.y + 4},
		   size = {32, 32},
		   color = ROYAL_BLUE,
		   texture_array = land_panel_texture_array,
		   texture = int(Land_Icon_Texture.Level),
	   ) {

	}

	if icon_button(
		   ctx,
		   pos = {pos.x + 34 + 4, pos.y + size.y - 32 - 4},
		   size = {32, 32},
		   color = ROYAL_BLUE,
		   texture_array = land_panel_texture_array,
		   texture = int(Land_Icon_Texture.Trim),
	   ) {

	}

	if icon_button(
		   ctx,
		   pos = {pos.x + 68 + 4, pos.y + 4},
		   size = {32, 32},
		   color = ROYAL_BLUE,
		   texture_array = land_panel_texture_array,
		   texture = int(Land_Icon_Texture.Smooth),
	   ) {

	}
}

land_panel_brush_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	if button(
		   ctx,
		   {pos.x + 2, pos.y + 4},
		   {16, 16},
		   "+",
		   txt_size = 32,
		   padding_top = 4,
	   ) {
		terrain_tool.increase_brush_size()
	} else if button(
		   ctx,
		   {pos.x + 2, pos.y + 20},
		   {16, 16},
		   "-",
		   txt_size = 32,
		   padding_top = 1,
	   ) {
		terrain_tool.decrease_brush_size()
	}

	icon(
		ctx,
		 {
			pos = {pos.x + 2 + 16 + 2, pos.y + 4},
			size = {32, 32},
			color = ROYAL_BLUE,
			texture_array = land_panel_texture_array,
			texture = int(Land_Icon_Texture.Brush_Size),
			left_border_width = BORDER_WIDTH,
			right_border_width = BORDER_WIDTH,
			top_border_width = BORDER_WIDTH,
			bottom_border_width = BORDER_WIDTH,
		},
	)

	if button(
		   ctx,
		   {pos.x + 2, pos.y + size.y - 32 - 4},
		   {16, 16},
		   "+",
		   txt_size = 32,
		   padding_top = 4,
	   ) {
		terrain_tool.increase_brush_strength()
	} else if button(
		   ctx,
		   {pos.x + 2, pos.y + size.y - 16 - 4},
		   {16, 16},
		   "-",
		   txt_size = 32,
		   padding_top = 1,
	   ) {
		terrain_tool.decrease_brush_strength()
	}

	icon(
		ctx,
		 {
			pos = {pos.x + 2 + 16 + 2, pos.y + size.y - 32 - 4},
			size = {32, 32},
			color = ROYAL_BLUE,
			texture_array = land_panel_texture_array,
			texture = int(Land_Icon_Texture.Brush_Strength),
			left_border_width = BORDER_WIDTH,
			right_border_width = BORDER_WIDTH,
			top_border_width = BORDER_WIDTH,
			bottom_border_width = BORDER_WIDTH,
		},
	)
}

land_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Terrain {
		container(
			ctx,
			pos = {0, window.size.y - 31 - FLOOR_PANEL_HEIGHT},
			size = {56, FLOOR_PANEL_HEIGHT},
			left_border_width = 0,
			body = land_panel_brush_body,
		)

		container(
			ctx,
			pos = {55, window.size.y - 31 - FLOOR_PANEL_HEIGHT},
			size = {249 - 55, FLOOR_PANEL_HEIGHT},
			body = land_panel_body,
		)
	}
}
