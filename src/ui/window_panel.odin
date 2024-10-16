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

        border_width:= f32(BORDER_WIDTH)
        if window_tool.texture == tex {
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
			   int(texmap[tex][.E_W][.South_West]),
               left_padding = -10,
               right_padding = 10,
               top_padding = 0,
               bottom_padding = 0,
               left_border_width = border_width,
               right_border_width = border_width,
               top_border_width = border_width,
               bottom_border_width = border_width,
			   color = DAY_SKY_BLUE,
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
			size = {window.size.x, PANEL_HEIGHT},
			left_border_width = 0,
			body = window_panel_body,
		)
	}
}
