package main

import "core:fmt"
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

Chunk_Iterator :: struct {
	pos:   glsl.ivec2,
	start: glsl.ivec2,
	end:   glsl.ivec2,
}

Chunk_Tile_Triangle_Iterator :: struct {
	chunk_iterator: Chunk_Iterator,
	chunk:          ^Chunk,
	chunk_pos:      glsl.ivec3,
	pos:            glsl.ivec3,
	start:          glsl.ivec3,
	end:            glsl.ivec3,
	side:           Tile_Triangle_Side,
}

Chunk_Tile_Triangle_Iterator_Value :: ^Tile_Triangle

Chunk_Tile_Triangle_Iterator_Index :: struct {
	pos:  glsl.ivec3,
	side: Tile_Triangle_Side,
}

chunk_tile_triangle_iterator_has_next :: proc(
	iterator: ^Chunk_Tile_Triangle_Iterator,
) -> bool {
	return(
		iterator.pos.x < iterator.end.x &&
		iterator.pos.y < iterator.end.y &&
		iterator.pos.z < iterator.end.z &&
		iterator.pos.x >= iterator.start.x &&
		iterator.pos.y >= iterator.start.y &&
		iterator.pos.z >= iterator.start.z \
	)
}

chunk_tile_triangle_iterator_next :: proc(
	iterator: ^Chunk_Tile_Triangle_Iterator,
) -> (
	value: Chunk_Tile_Triangle_Iterator_Value,
	index: Chunk_Tile_Triangle_Iterator_Index,
	has_next: bool = true,
) {
	ok: bool = false
	for !ok {
		chunk_tile_triangle_iterator_has_next(iterator) or_return
		index.side = iterator.side

		value, ok =
		&iterator.chunk.tiles.items[iterator.pos.y][iterator.pos.x][iterator.pos.z][iterator.side].?

		index.pos = iterator.chunk_pos + iterator.pos
		switch iterator.side {
		case .West:
			iterator.side = .South
			iterator.pos.x += 1
		case .South:
			iterator.side = .East
		case .East:
			iterator.side = .North
		case .North:
			iterator.side = .West
		}

		if iterator.pos.x >= iterator.end.x {
			iterator.pos.x = iterator.start.x
			iterator.pos.z += 1
		}

		if iterator.pos.z >= iterator.end.z {
			iterator.pos.x = iterator.start.x
			iterator.pos.z = iterator.start.z
			iterator.pos.y += 1
		}

		if iterator.pos.y >= iterator.end.y {
			iterator.pos.x = iterator.start.x
			iterator.pos.y = iterator.start.y
			iterator.pos.z = iterator.start.z
			iterator.chunk, iterator.chunk_pos = chunk_iterator_next(
				&iterator.chunk_iterator,
			) or_return
		}
	}

	return
}

chunk_iterate_all_tile_triangle :: proc(
	chunk_iterator: Chunk_Iterator,
) -> (
	it: Chunk_Tile_Triangle_Iterator,
) {
	it = {
		chunk_iterator = chunk_iterator,
		pos = {0, 0, 0},
		start = {0, 0, 0},
		end = {CHUNK_WIDTH, CHUNK_HEIGHT, CHUNK_DEPTH},
	}

	ok: bool
	it.chunk, it.chunk_pos, ok = chunk_iterator_next(&it.chunk_iterator)
	if !ok {
		it.end = {0, 0, 0}
	}

	return
}

chunk_iterate_all_ground_tile_triangle :: proc(
	chunk_iterator: Chunk_Iterator,
) -> (
	it: Chunk_Tile_Triangle_Iterator,
) {
	it = {
		chunk_iterator = chunk_iterator,
		pos = {0, 0, 0},
		start = {0, 0, 0},
		end = {CHUNK_WIDTH, 1, CHUNK_DEPTH},
	}

	ok: bool
	it.chunk, it.chunk_pos, ok = chunk_iterator_next(&it.chunk_iterator)
	if !ok {
		it.end = {0, 0, 0}
	}

	return
}

chunk_iterator_has_next :: proc(iterator: ^Chunk_Iterator) -> bool {
	return(
		iterator.pos.x < iterator.end.x &&
		iterator.pos.y < iterator.end.y &&
		iterator.pos.x >= iterator.start.x &&
		iterator.pos.y >= iterator.start.y \
	)
}

chunk_iterator_next :: proc(
	iterator: ^Chunk_Iterator,
) -> (
	chunk: ^Chunk,
	pos: glsl.ivec3,
	has_next: bool = true,
) {
	chunk_iterator_has_next(iterator) or_return
	chunk = &world_chunks[iterator.pos.x][iterator.pos.y]
	pos = {i32(iterator.pos.x * CHUNK_WIDTH), 0, i32(iterator.pos.y * CHUNK_DEPTH)}
	iterator.pos.x += 1
	if iterator.pos.x >= iterator.end.x {
		iterator.pos.x = iterator.start.x
		iterator.pos.y += 1
	}
	return
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
