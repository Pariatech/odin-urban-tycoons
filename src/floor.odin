package main

import "core:fmt"
import m "core:math/linalg/glsl"
import "core:testing"

import "constants"
import "keyboard"
import "tile"

FLOOR_OFFSET :: 0.0004

previous_floor: int
floor: int

floor_update :: proc() {
	previous_floor = floor
	if keyboard.is_key_press(.Key_Equal) {
		floor = min(floor + 1, constants.WORLD_HEIGHT - 1)
	} else if keyboard.is_key_press(.Key_Minus) {
		floor = max(floor - 1, 0)
	}

	if previous_floor != floor {
		if previous_floor > 0 {
			for x in 0 ..< constants.WORLD_CHUNK_WIDTH {
				for z in 0 ..< constants.WORLD_CHUNK_DEPTH {
					chunk := &world_chunks[x][z]
                    chunk.floors[previous_floor].tiles.dirty = true
					for x in 0 ..< constants.CHUNK_WIDTH {
						for z in 0 ..< constants.CHUNK_DEPTH {
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
			for x in 0 ..< constants.WORLD_CHUNK_WIDTH {
				for z in 0 ..< constants.WORLD_CHUNK_DEPTH {
					chunk := &world_chunks[x][z]
                    chunk.floors[floor].tiles.dirty = true
					for x in 0 ..< constants.CHUNK_WIDTH {
						for z in 0 ..< constants.CHUNK_DEPTH {
							t := &chunk.floors[floor].tiles.triangles[x][z]
							for tri, side in t {
								if tri == nil {
									t[side] = tile.Tile_Triangle {
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
