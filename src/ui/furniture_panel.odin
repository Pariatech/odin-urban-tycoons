package ui

import "core:math/linalg/glsl"

import "../billboard"
import "../furniture"
import "../tools"
import "../tools/furniture_tool"
import "../window"


furniture_panel_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	for texmap, i in furniture.texture_map {
		border_width := f32(BORDER_WIDTH)
		if furniture_tool.type == i && furniture_tool.state == .Moving {
			border_width *= 2
		}

		if icon_button(
			   ctx,
			    {
				   2 + f32(i) * (FLOOR_PANEL_TILE_SIZE + 2),
				   window.size.y - 31 - PANEL_HEIGHT + FLOOR_PANEL_PADDING,
			   },
			   {FLOOR_PANEL_TILE_SIZE, FLOOR_PANEL_TILE_SIZE * 2},
			   billboard.billboard_1x1_draw_context.texture_array,
			   int(texmap[.South][.South_West][0][0]),
			   top_padding = -8,
			   bottom_padding = 8,
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
			size = {PANEL_WIDTH, PANEL_HEIGHT},
			left_border_width = 0,
			body = furniture_panel_body,
		)
	}
}
