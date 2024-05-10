package floor_tool

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"

import "../../cursor"
import "../../floor"
import "../../tile"

previous_tiles: map[tile.Key]tile.Tile_Triangle
position: glsl.ivec2
drag_start: glsl.ivec2

copy_tile :: proc() {
	chunk := tile.get_chunk({position.x, i32(floor.floor), position.y})
	for side in tile.Tile_Triangle_Side {
		key := tile.Key {
			x    = int(position.x),
			z    = int(position.y),
			side = side,
		}
		tri, ok := chunk.triangles[key]
		if ok {
			previous_tiles[key] = tri
		}
	}
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

	if previous_position != position {
		previous_chunk := tile.get_chunk(
			{previous_position.x, i32(floor.floor), previous_position.y},
		)
		for side in tile.Tile_Triangle_Side {
			key := tile.Key {
				x    = int(previous_position.x),
				z    = int(previous_position.y),
				side = side,
			}
			tile.set_tile_triangle(
				{previous_position.x, i32(floor.floor), previous_position.y},
				side,
				previous_tiles[key],
			)
		}

		clear(&previous_tiles)

        copy_tile()

		tile.set_tile(
			{position.x, i32(floor.floor), position.y},
			tile.tile({texture = .Wood, mask_texture = .Grid_Mask}),
		)
	}
}
