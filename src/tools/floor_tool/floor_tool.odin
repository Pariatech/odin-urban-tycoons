package floor_tool

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"

import "../../cursor"
import "../../floor"
import "../../tile"

previous_tiles: map[glsl.ivec3][tile.Tile_Triangle_Side]Maybe(
	tile.Tile_Triangle,
)
position: glsl.ivec2
drag_start: glsl.ivec3

revert_tile :: proc(position: glsl.ivec2) {
	pos := glsl.ivec3{position.x, floor.previous_floor, position.y}
	previous_tile := previous_tiles[pos]
	if floor.previous_floor != floor.floor {
		for side in tile.Tile_Triangle_Side {
			if tri, ok := previous_tile[side].?; ok {
				if tri.texture == .Floor_Marker {
					tile.set_tile_triangle(pos, side, nil)
				} else {
					tile.set_tile_triangle(pos, side, tri)
				}
			} else {
				tile.set_tile_triangle(pos, side, nil)
			}
		}
	} else {
		tile.set_tile(pos, previous_tile)
	}
}

copy_tile :: proc() {
	pos := glsl.ivec3{position.x, floor.floor, position.y}
	previous_tiles[pos] = tile.get_tile(pos)
}

init :: proc() {
	copy_tile()
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

	if previous_position != position || floor.previous_floor != floor.floor {
		revert_tile(previous_position)

		clear(&previous_tiles)

		copy_tile()

		tile.set_tile(
			{position.x, i32(floor.floor), position.y},
			tile.tile({texture = .Wood, mask_texture = .Grid_Mask}),
		)
	}
}
