package ui

import "../tile"
import "../window"
import "../tools/floor_tool"

Floor_Panel :: struct {
	opened: bool,
}

FLOOR_PANEL_HEIGHT :: 74
FLOOR_PANEL_TILE_SIZE :: 32
FLOOR_PANEL_PADDING :: 4

floor_panel :: proc(using ctx: ^Context) {
	rect(
		ctx,
		 {
			x = -3,
			y = window.size.y - 29 - FLOOR_PANEL_HEIGHT,
			w = 249,
			h = FLOOR_PANEL_HEIGHT,
			color = ROYAL_BLUE,
		},
	)

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
				29 -
				FLOOR_PANEL_HEIGHT +
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
