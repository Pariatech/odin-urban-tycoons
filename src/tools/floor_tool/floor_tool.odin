package floor_tool

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"

import "../../cursor"
import "../../floor"
import "../../mouse"
import "../../tile"

previous_tiles: map[glsl.ivec3][tile.Tile_Triangle_Side]Maybe(
	tile.Tile_Triangle,
)
position: glsl.ivec2
drag_start: glsl.ivec3

revert_tile :: proc(position: glsl.ivec3) {
	previous_tile := previous_tiles[position]
	if floor.previous_floor != floor.floor {
		for side in tile.Tile_Triangle_Side {
			if tri, ok := previous_tile[side].?; ok {
				if tri.texture == .Floor_Marker {
					tile.set_tile_triangle(position, side, nil)
				} else {
					tile.set_tile_triangle(position, side, tri)
				}
			} else {
				tile.set_tile_triangle(position, side, nil)
			}
		}
	} else {
		tile.set_tile(position, previous_tile)
	}
}

set_tile :: proc(position: glsl.ivec3) {
	copy_tile(position)

	tile.set_tile(
		position,
		tile.tile({texture = .Wood, mask_texture = .Grid_Mask}),
	)
}

copy_tile :: proc(position: glsl.ivec3) {
	previous_tiles[position] = tile.get_tile(position)
}

init :: proc() {
	copy_tile({position.x, floor.floor, position.y})
}

deinit :: proc() {
}

on_intersect :: proc(intersect: glsl.vec3) {
	position.x = i32(intersect.x + 0.5)
	position.y = i32(intersect.z + 0.5)
}

revert_tiles :: proc(position: glsl.ivec2) {
	start_x := min(drag_start.x, position.x)
	end_x := max(drag_start.x, position.x)
	start_y := min(drag_start.y, floor.previous_floor)
	end_y := max(drag_start.y, floor.previous_floor)
	start_z := min(drag_start.z, position.y)
	end_z := max(drag_start.z, position.y)

	for x in start_x ..= end_x {
		for y in start_y ..= end_y {
			for z in start_z ..= end_z {
				revert_tile({x, y, z})
			}
		}
	}
}

set_tiles :: proc() {
	fmt.println(drag_start)
	start_x := min(drag_start.x, position.x)
	end_x := max(drag_start.x, position.x)
	start_y := min(drag_start.y, floor.floor)
	end_y := max(drag_start.y, floor.floor)
	start_z := min(drag_start.z, position.y)
	end_z := max(drag_start.z, position.y)

	for x in start_x ..= end_x {
		for y in start_y ..= end_y {
			for z in start_z ..= end_z {
				set_tile({x, y, z})
			}
		}
	}
}

update :: proc() {
	previous_position := position
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)


	if mouse.is_button_press(.Left) {
		fmt.println("uh??")
		drag_start = {position.x, floor.floor, position.y}
	} else if mouse.is_button_down(.Left) {
		if previous_position != position ||
		   floor.previous_floor != floor.floor {
			revert_tiles(previous_position)
			clear(&previous_tiles)
			set_tiles()
		}
	} else if mouse.is_button_release(.Left) {
		clear(&previous_tiles)
	    copy_tile({position.x, floor.floor, position.y})
	} else {
		if previous_position != position ||
		   floor.previous_floor != floor.floor {
			revert_tile(
				 {
					previous_position.x,
					floor.previous_floor,
					previous_position.y,
				},
			)
			clear(&previous_tiles)
			set_tile({position.x, floor.floor, position.y})
		}
	}
}
