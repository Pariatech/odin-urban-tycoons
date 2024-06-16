package ui

import "core:math/linalg/glsl"

import "../tools"
import "../tools/paint_tool"
import "../wall"
import "../window"

init_paint_panel :: proc() -> (ok: bool = true) {
	return
}

paint_panel_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	i: int = 0
	for tex in wall.Wall_Texture {
		if tex == .Wall_Top || tex == .Frame || tex == .Drywall {
			continue
		}

        border_width:= f32(BORDER_WIDTH)
        if paint_tool.texture == tex {
            border_width *= 2
        }

		if icon_button(
			   ctx,
			    {
				   2 + f32(i / 2) * (FLOOR_PANEL_TILE_SIZE + 2),
				   window.size.y -
				   31 -
				   PANEL_HEIGHT +
				   FLOOR_PANEL_PADDING +
				   f32(i % 2) * (FLOOR_PANEL_TILE_SIZE + 2),
			   },
			   {FLOOR_PANEL_TILE_SIZE, FLOOR_PANEL_TILE_SIZE},
			   wall.wall_texture_array,
			   int(tex),
               left_border_width = border_width,
               right_border_width = border_width,
               top_border_width = border_width,
               bottom_border_width = border_width,
		   ) {
			paint_tool.set_texture(tex)
		}

		i += 1
	}
}

paint_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Paint {
		container(
			ctx,
			pos = {0, window.size.y - 31 - PANEL_HEIGHT},
			size = {PANEL_WIDTH, PANEL_HEIGHT},
			left_border_width = 0,
			body = paint_panel_body,
		)
	}
}
