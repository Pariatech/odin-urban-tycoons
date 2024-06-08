package ui

import "core:math/linalg/glsl"

import "../billboard"
import "../tools"
import "../tools/window_tool"
import "../window"

init_window_panel :: proc() -> (ok: bool = true) {
	return
}

window_panel_body :: proc(using ctx: ^Context, pos: glsl.vec2, size: glsl.vec2) {
	for tex, i in window_tool.Texture {
		texmap := window_tool.TEXTURE_BILLBOARD_TEXTURES_MAP
		if icon_button(
			   ctx,
			    {
				   2 + f32(i) * (FLOOR_PANEL_TILE_SIZE + 2),
				   window.size.y - 31 - PANEL_HEIGHT + FLOOR_PANEL_PADDING,
			   },
			   {FLOOR_PANEL_TILE_SIZE, FLOOR_PANEL_TILE_SIZE * 2},
			   billboard.billboard_1x1_draw_context.texture_array,
			   int(texmap[tex][.E_W][.South_West]),
               left_padding = -7,
               right_padding = 7,
               top_padding = -8,
               bottom_padding = 8,
		   ) {
			window_tool.texture = tex
		}
	}
}

window_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Window {
		container(
			ctx,
			pos = {0, window.size.y - 31 - PANEL_HEIGHT},
			size = {PANEL_WIDTH, PANEL_HEIGHT},
			left_border_width = 0,
			body = window_panel_body,
		)
	}
}
