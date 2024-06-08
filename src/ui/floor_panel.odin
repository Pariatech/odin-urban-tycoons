package ui

import "core:math/linalg/glsl"

import "../tile"
import "../tools/floor_tool"
import "../window"

Floor_Panel :: struct {
	opened: bool,
}

FLOOR_PANEL_TILE_SIZE :: 32
FLOOR_PANEL_PADDING :: 4

floor_panel_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	i: int = 0
	for tex in tile.Texture {
		if tex == .Floor_Marker || tex == .Grass {
			continue
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
			   tile.texture_array,
			   int(tex),
		   ) {
			floor_tool.active_texture = tex
		}

		i += 1
	}
}

floor_panel :: proc(using ctx: ^Context) {
	container(
		ctx,
		pos = {0, window.size.y - 31 - PANEL_HEIGHT},
		size = {PANEL_WIDTH, PANEL_HEIGHT},
		left_border_width = 0,
		body = floor_panel_body,
	)
}
