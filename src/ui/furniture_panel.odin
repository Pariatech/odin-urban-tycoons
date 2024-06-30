package ui

import "core:math/linalg/glsl"

import "../billboard"
import "../furniture"
import "../tools"
import "../tools/furniture_tool"
import "../window"

FURNITURE_PANEL_TILE_SIZE :: 96

FURNITURE_PANEL_ICONS :: [furniture.Type]cstring {
	.Chair    = "resources/textures/object_icons/Chair.png",
	.Table6   = "resources/textures/object_icons/Table.6Places.png",
	.Letter_A = "resources/textures/object_icons/Letter_A.png",
	.Letter_G = "resources/textures/object_icons/Letter_G.png",
	.Letter_D = "resources/textures/object_icons/Letter_D.png",
	.Letter_E = "resources/textures/object_icons/Letter_E.png",
}

furniture_panel_icon_texture_array: u32

furniture_panel_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	for i in furniture.Type {
		border_width := f32(BORDER_WIDTH)
		if furniture_tool.type == i && furniture_tool.state == .Moving {
			border_width *= 2
		}

		if icon_button(
			   ctx,
			    {
				   2 + f32(i) * (FURNITURE_PANEL_TILE_SIZE + 2),
				   window.size.y - 31 - PANEL_HEIGHT + FLOOR_PANEL_PADDING,
			   },
			   {FURNITURE_PANEL_TILE_SIZE, FURNITURE_PANEL_TILE_SIZE},
			   furniture_panel_icon_texture_array,
			   int(i),
			   top_padding = 4,
			   bottom_padding = 4,
               left_padding = 4,
               right_padding = 4,
			   left_border_width = border_width,
			   right_border_width = border_width,
			   top_border_width = border_width,
			   bottom_border_width = border_width,
		   ) {
			furniture_tool.place_furniture(i)
		}
	}
}

furniture_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Furniture {
		container(
			ctx,
			pos = {0, window.size.y - 31 - PANEL_HEIGHT},
			size = {window.size.x, PANEL_HEIGHT},
			left_border_width = 0,
			body = furniture_panel_body,
		)
	}
}

init_furniture_panel :: proc() -> bool {
	icons := FURNITURE_PANEL_ICONS

	init_icon_texture_array(
		&furniture_panel_icon_texture_array,
		raw_data(&icons)[0:len(icons)],
	) or_return

	return true
}
