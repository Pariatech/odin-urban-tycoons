package main

import "core:fmt"
import m "core:math/linalg/glsl"
import "core:testing"

FLOOR_OFFSET :: 0.0004

previous_floor: int
floor: int

floor_update :: proc() {
	previous_floor = floor
	if is_key_press(.Key_Equal) {
		floor = min(floor + 1, WORLD_HEIGHT - 1)
	} else if is_key_press(.Key_Minus) {
		floor = max(floor - 1, 0)
	}

	if previous_floor != floor {
		if previous_floor > 0 {
			for x in 0 ..< WORLD_CHUNK_WIDTH {
				for z in 0 ..< WORLD_CHUNK_DEPTH {
					chunk := &world_chunks[x][z]
                    chunk.floors[previous_floor].tiles.dirty = true
					for x in 0 ..< CHUNK_WIDTH {
						for z in 0 ..< CHUNK_DEPTH {
							tile := &chunk.floors[previous_floor].tiles.triangles[x][z]
							for tri, side in tile {
								if triangle, ok := tri.?; ok {
									if triangle.texture == .Floor_Marker {
										tile[side] = nil
									}
								}
							}
						}
					}
				}
			}
		}

		if floor > 0 {
			for x in 0 ..< WORLD_CHUNK_WIDTH {
				for z in 0 ..< WORLD_CHUNK_DEPTH {
					chunk := &world_chunks[x][z]
                    chunk.floors[floor].tiles.dirty = true
					for x in 0 ..< CHUNK_WIDTH {
						for z in 0 ..< CHUNK_DEPTH {
							tile := &chunk.floors[floor].tiles.triangles[x][z]
							for tri, side in tile {
								if tri == nil {
									tile[side] = Tile_Triangle {
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
