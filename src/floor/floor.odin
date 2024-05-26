package floor

import "core:fmt"
import m "core:math/linalg/glsl"
import "core:testing"

import "../constants"
import "../keyboard"
import "../tile"

FLOOR_OFFSET :: 0.0004

previous_floor: i32
floor: i32

move_up :: proc() {
	previous_floor = floor
	floor = min(floor + 1, constants.WORLD_HEIGHT - 1)
    update_markers()
}

move_down :: proc() {
	previous_floor = floor
	floor = max(floor - 1, 0)
    update_markers()
}

update_markers :: proc() {
	if previous_floor != floor {
		if previous_floor > 0 {
			for x in 0 ..< constants.WORLD_CHUNK_WIDTH {
				for z in 0 ..< constants.WORLD_CHUNK_DEPTH {
					chunk := &tile.chunks[previous_floor][x][z]
					chunk.dirty = true
					triangles := &chunk.triangles
					for index, triangle in triangles {
						if triangle.texture == .Floor_Marker {
							delete_key(&chunk.triangles, index)
						}
					}
				}
			}
		}

		if floor > 0 {
			for cx in 0 ..< constants.WORLD_CHUNK_WIDTH {
				for cz in 0 ..< constants.WORLD_CHUNK_DEPTH {
					chunk := &tile.chunks[floor][cx][cz]
					chunk.dirty = true
					for x in 0 ..< constants.CHUNK_WIDTH {
						for z in 0 ..< constants.CHUNK_DEPTH {
							for side in tile.Tile_Triangle_Side {
								key := tile.Key {
									x    = cx * constants.CHUNK_WIDTH + x,
									z    = cz * constants.CHUNK_DEPTH + z,
									side = side,
								}
								if !(key in chunk.triangles) {
									chunk.triangles[key] = {
										texture      = .Floor_Marker,
										mask_texture = .Full_Mask,
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

update :: proc() {
	previous_floor = floor
	if keyboard.is_key_press(.Key_Page_Up) {
        move_up()
	} else if keyboard.is_key_press(.Key_Page_Down) {
        move_down()
	}
    
    update_markers()
}
