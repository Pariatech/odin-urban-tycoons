package floor_tool

import "core:math"
import "core:math/linalg/glsl"

import "../../cursor"
import "../../floor"
import "../../tile"

previous_tile: Maybe([tile.Tile_Triangle_Side]Maybe(tile.Tile_Triangle))
position: glsl.ivec2
drag_start: glsl.ivec2

init :: proc() {
    previous_tile = nil
}

deinit :: proc() {
}

on_intersect :: proc(intersect: glsl.vec3) {
	position.x = i32(intersect.x + 0.5)
	position.y = i32(intersect.z + 0.5)
}

update :: proc() {
	previous_position := position
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	if previous_position != position {
		if pt, ok := previous_tile.?; ok {
			tile.set_tile(
				{previous_position.x, i32(floor.floor), previous_position.y},
				pt,
			)
		}
		previous_tile = tile.get_tile(
			{position.x, i32(floor.floor), position.y},
		)
		tile.set_tile(
			{position.x, i32(floor.floor), position.y},
			tile.tile({texture = .Wood, mask_texture = .Grid_Mask}),
		)
	}
}
