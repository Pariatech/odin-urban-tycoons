package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

CHUNK_WIDTH :: 8
CHUNK_DEPTH :: 8
CHUNK_HEIGHT :: 8

Chunk_Items :: struct($T: typeid) {
	items: [CHUNK_HEIGHT][CHUNK_WIDTH][CHUNK_DEPTH]T,
}

Chunk :: struct {
	tiles:             Chunk_Items([Tile_Triangle_Side]Maybe(Tile_Triangle)),
	tiles_vertices:    [dynamic]Vertex,
	tiles_indices:     [dynamic]u32,
	tiles_dirty:       bool,
	tiles_initialized: bool,
	tiles_vbo:         u32,
}

Chunk_Iterator :: struct {
	pos:   glsl.ivec2,
	start: glsl.ivec2,
	end:   glsl.ivec2,
}

Chunk_Tile_Triangle_Iterator :: struct {
	chunk:     ^Chunk,
	chunk_pos: glsl.ivec3,
	pos:       glsl.ivec3,
	start:     glsl.ivec3,
	end:       glsl.ivec3,
	side:      Tile_Triangle_Side,
}

Chunk_Tile_Triangle_Iterator_Value :: ^Tile_Triangle

Chunk_Tile_Triangle_Iterator_Index :: struct {
	pos:  glsl.ivec3,
	side: Tile_Triangle_Side,
}

chunk_draw :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	if !chunk.tiles_initialized {
		chunk.tiles_initialized = true
		chunk.tiles_dirty = true

		gl.GenBuffers(1, &chunk.tiles_vbo)
	}

	if chunk.tiles_dirty {
		it := chunk_iterate_all_tile_triangle(chunk, pos)
		vertices: [dynamic]Vertex
		indices: [dynamic]u32
		defer delete(vertices)
		defer delete(indices)
		for tile_triangle, index in chunk_tile_triangle_iterator_next(&it) {
			side := index.side
			pos := glsl.vec2{f32(index.pos.x), f32(index.pos.z)}

			x := int(index.pos.x)
			z := int(index.pos.z)
			lights := get_terrain_tile_triangle_lights(side, x, z, 1)

			heights := get_terrain_tile_triangle_heights(side, x, z, 1)

			for i in 0 ..< 3 {
				heights[i] += f32(index.pos.y * WALL_HEIGHT)
			}

			draw_tile_triangle(
				tile_triangle^,
				side,
				lights,
				heights,
				pos,
				1,
				&vertices,
				&indices,
			)
		}
	}
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
	}

	return
}

chunk_iterate_all_tile_triangle :: proc(
	chunk: ^Chunk,
	chunk_pos: glsl.ivec3,
) -> (
	it: Chunk_Tile_Triangle_Iterator,
) {
	return(
		 {
			chunk = chunk,
			chunk_pos = chunk_pos,
			pos = {0, 0, 0},
			start = {0, 0, 0},
			end = {CHUNK_WIDTH, CHUNK_HEIGHT, CHUNK_DEPTH},
		} \
	)
}

chunk_iterate_all_ground_tile_triangle :: proc(
	chunk: ^Chunk,
	chunk_pos: glsl.ivec3,
) -> (
	it: Chunk_Tile_Triangle_Iterator,
) {
	return(
		 {
			chunk = chunk,
			chunk_pos = chunk_pos,
			pos = {0, 0, 0},
			start = {0, 0, 0},
			end = {CHUNK_WIDTH, 1, CHUNK_DEPTH},
		} \
	)
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
	pos =  {
		i32(iterator.pos.x * CHUNK_WIDTH),
		0,
		i32(iterator.pos.y * CHUNK_DEPTH),
	}
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
