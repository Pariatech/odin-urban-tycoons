package main

import "core:math/linalg/glsl"

CHUNK_WIDTH :: 8
CHUNK_DEPTH :: 8
CHUNK_HEIGHT :: 8

Chunk_Items :: struct($T: typeid) {
	items: [CHUNK_HEIGHT][CHUNK_WIDTH][CHUNK_DEPTH]T,
}

Chunk :: struct {
	tiles: Chunk_Items([Tile_Triangle_Side]Maybe(Tile_Triangle)),
}

chunk_tile :: proc(
	tile_triangle: Tile_Triangle,
) -> [Tile_Triangle_Side]Maybe(Tile_Triangle) {
	return(
		 {
			.West = tile_triangle,
			.South = tile_triangle,
			.East = tile_triangle,
			.North = tile_triangle,
		} \
	)
}

chunk_init :: proc(chunk: ^Chunk) {
	for x in 0 ..< CHUNK_WIDTH {
		for z in 0 ..< CHUNK_DEPTH {
			for side in Tile_Triangle_Side {
				chunk.tiles.items[0][x][z][side] = Tile_Triangle {
					texture      = .Grass,
					mask_texture = .Grid_Mask,
				}
			}
		}
	}
}

chunk_get_tile :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> ^[Tile_Triangle_Side]Maybe(Tile_Triangle) {
	return &chunk.tiles.items[pos.y][pos.x % CHUNK_WIDTH][pos.z % CHUNK_DEPTH]
}

chunk_set_tile :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	tile: [Tile_Triangle_Side]Maybe(Tile_Triangle),
) {
	chunk_get_tile(chunk, pos)^ = tile
}

chunk_set_tile_triangle :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	side: Tile_Triangle_Side,
	tile_triangle: Maybe(Tile_Triangle),
) {
	chunk_get_tile(chunk, pos)[side] = tile_triangle
}

chunk_set_tile_mask_texture :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	mask_texture: Mask,
) {
	item := chunk_get_tile(chunk, pos)
	for side in Tile_Triangle_Side {
		if tile_triangle, ok := &item[side].?; ok {
			tile_triangle.mask_texture = mask_texture
		}
	}
}

chunk_draw_tiles :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	for y in 0 ..< CHUNK_HEIGHT {
		for x in 0 ..< CHUNK_WIDTH {
			for z in 0 ..< CHUNK_DEPTH {
				for side in Tile_Triangle_Side {
					if tile_triangle, ok := chunk.tiles.items[y][x][z][side].?;
					   ok {
						x := int(pos.x) + x
						z := int(pos.z) + z
						lights := get_terrain_tile_triangle_lights(
							side,
							x,
							z,
							1,
						)

						heights := get_terrain_tile_triangle_heights(
							side,
							x,
							z,
							1,
						)

                        for i in 0 ..< 3 {
                            heights[i] += f32(y * WALL_HEIGHT)
                        }

						draw_tile_triangle(
							tile_triangle,
							side,
							lights,
							heights,
							glsl.vec2{f32(x), f32(z)},
							1,
						)
					}
				}
			}
		}
	}
}
