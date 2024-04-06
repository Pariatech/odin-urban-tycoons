package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

CHUNK_WIDTH :: 8
CHUNK_DEPTH :: 8
CHUNK_HEIGHT :: 8

Chunk_Tiles :: struct {
	triangles:     [CHUNK_HEIGHT][CHUNK_WIDTH][CHUNK_DEPTH][Tile_Triangle_Side]Maybe(
		Tile_Triangle,
	),
	dirty:         bool,
	initialized:   bool,
	vao, vbo, ebo: u32,
	num_indices:   i32,
}

Chunk_Walls :: struct {
	north_south: [dynamic]Wall,
	east_west:   [dynamic]Wall,
	vao, vbo, ebo: u32,
	dirty:         bool,
	initialized:   bool,
	num_indices:   i32,
}

Chunk :: struct {
	tiles: Chunk_Tiles,
    walls: Chunk_Walls,
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

chunk_draw_tiles :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	if !chunk.tiles.initialized {
		chunk.tiles.initialized = true
		chunk.tiles.dirty = true
		gl.GenVertexArrays(1, &chunk.tiles.vao)
		gl.BindVertexArray(chunk.tiles.vao)
		gl.GenBuffers(1, &chunk.tiles.vbo)
		gl.BindBuffer(gl.ARRAY_BUFFER, chunk.tiles.vbo)

		gl.GenBuffers(1, &chunk.tiles.ebo)

		gl.VertexAttribPointer(
			0,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Tile_Triangle_Vertex),
			offset_of(Tile_Triangle_Vertex, pos),
		)
		gl.EnableVertexAttribArray(0)

		gl.VertexAttribPointer(
			1,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Tile_Triangle_Vertex),
			offset_of(Tile_Triangle_Vertex, light),
		)
		gl.EnableVertexAttribArray(1)

		gl.VertexAttribPointer(
			2,
			4,
			gl.FLOAT,
			gl.FALSE,
			size_of(Tile_Triangle_Vertex),
			offset_of(Tile_Triangle_Vertex, texcoords),
		)
		gl.EnableVertexAttribArray(2)
	}

	gl.BindVertexArray(chunk.tiles.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, chunk.tiles.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, chunk.tiles.ebo)

	if chunk.tiles.dirty {
		chunk.tiles.dirty = false
		it := chunk_iterate_all_tile_triangle(chunk, pos)

		vertices: [dynamic]Tile_Triangle_Vertex
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

		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(vertices) * size_of(Vertex),
			raw_data(vertices),
			gl.STATIC_DRAW,
		)

		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(indices) * size_of(u32),
			raw_data(indices),
			gl.STATIC_DRAW,
		)
		chunk.tiles.num_indices = i32(len(indices))
	}

	gl.DrawElements(
		gl.TRIANGLES,
		chunk.tiles.num_indices,
		gl.UNSIGNED_INT,
		nil,
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
}

chunk_draw_walls :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	if !chunk.walls.initialized {
		chunk.walls.initialized = true
		chunk.walls.dirty = true
		gl.GenVertexArrays(1, &chunk.walls.vao)
		gl.BindVertexArray(chunk.walls.vao)
		gl.GenBuffers(1, &chunk.walls.vbo)
		gl.BindBuffer(gl.ARRAY_BUFFER, chunk.walls.vbo)

		gl.GenBuffers(1, &chunk.walls.ebo)

		gl.VertexAttribPointer(
			0,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Wall_Vertex),
			offset_of(Wall_Vertex, pos),
		)
		gl.EnableVertexAttribArray(0)

		gl.VertexAttribPointer(
			1,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Wall_Vertex),
			offset_of(Wall_Vertex, light),
		)
		gl.EnableVertexAttribArray(1)

		gl.VertexAttribPointer(
			2,
			4,
			gl.FLOAT,
			gl.FALSE,
			size_of(Wall_Vertex),
			offset_of(Wall_Vertex, texcoords),
		)
		gl.EnableVertexAttribArray(2)
	}

	gl.BindVertexArray(chunk.walls.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, chunk.walls.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, chunk.walls.ebo)

	if chunk.walls.dirty {
		chunk.walls.dirty = false

		vertices: [dynamic]Wall_Vertex
		indices: [dynamic]Wall_Index
		defer delete(vertices)
		defer delete(indices)

		for wall in chunk.walls.east_west {
			draw_wall(wall, .East_West, &vertices, &indices)
		}

		for wall in chunk.walls.north_south {
			draw_wall(wall, .North_South, &vertices, &indices)
		}

		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(vertices) * size_of(Wall_Vertex),
			raw_data(vertices),
			gl.STATIC_DRAW,
		)

		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(indices) * size_of(Wall_Index),
			raw_data(indices),
			gl.STATIC_DRAW,
		)
		chunk.walls.num_indices = i32(len(indices))
	}

	gl.DrawElements(
		gl.TRIANGLES,
		chunk.walls.num_indices,
		gl.UNSIGNED_INT,
		nil,
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
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
		&iterator.chunk.tiles.triangles[iterator.pos.y][iterator.pos.x][iterator.pos.z][iterator.side].?

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
				chunk.tiles.triangles[0][x][z][side] = Tile_Triangle {
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
	return(
		&chunk.tiles.triangles[pos.y][pos.x % CHUNK_WIDTH][pos.z % CHUNK_DEPTH] \
	)
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


chunk_set_north_south_wall :: proc(chunk: ^Chunk, wall: Wall) {
	for existing_wall, i in &chunk.walls.north_south {
        if existing_wall.pos == wall.pos {
            existing_wall = wall
            return
        }
    }
	append(&chunk.walls.north_south, wall)
}

chunk_set_east_west_wall :: proc(chunk: ^Chunk, wall: Wall) {
	for existing_wall, i in &chunk.walls.east_west {
        if existing_wall.pos == wall.pos {
            existing_wall = wall
            return
        }
    }
	append(&chunk.walls.east_west, wall)
}
