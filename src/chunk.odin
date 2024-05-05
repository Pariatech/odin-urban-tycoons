package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

import "constants"
import "camera"
import "tile"
import "terrain"

import "wall"

Chunk_Walls :: struct {
	north_south:           map[glsl.ivec2]wall.Wall,
	east_west:             map[glsl.ivec2]wall.Wall,
	south_west_north_east: map[glsl.ivec2]wall.Wall,
	north_west_south_east: map[glsl.ivec2]wall.Wall,
	vao, vbo, ebo:         u32,
	dirty:                 bool,
	initialized:           bool,
	num_indices:           i32,
}


Chunk_Floor :: struct {
	walls:          Chunk_Walls,
}

Chunk :: struct {
	floors: [constants.CHUNK_HEIGHT]Chunk_Floor,
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
	side:      tile.Tile_Triangle_Side,
}

Chunk_Tile_Triangle_Iterator_Value :: ^tile.Tile_Triangle

Chunk_Tile_Triangle_Iterator_Index :: struct {
	pos:  glsl.ivec3,
	side: tile.Tile_Triangle_Side,
}


chunk_draw_walls :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	floor := &chunk.floors[pos.y]
	if !floor.walls.initialized {
		floor.walls.initialized = true
		floor.walls.dirty = true
		gl.GenVertexArrays(1, &floor.walls.vao)
		gl.BindVertexArray(floor.walls.vao)
		gl.GenBuffers(1, &floor.walls.vbo)
		gl.BindBuffer(gl.ARRAY_BUFFER, floor.walls.vbo)

		gl.GenBuffers(1, &floor.walls.ebo)

		gl.VertexAttribPointer(
			0,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(wall.Wall_Vertex),
			offset_of(wall.Wall_Vertex, pos),
		)
		gl.EnableVertexAttribArray(0)

		gl.VertexAttribPointer(
			1,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(wall.Wall_Vertex),
			offset_of(wall.Wall_Vertex, light),
		)
		gl.EnableVertexAttribArray(1)

		gl.VertexAttribPointer(
			2,
			4,
			gl.FLOAT,
			gl.FALSE,
			size_of(wall.Wall_Vertex),
			offset_of(wall.Wall_Vertex, texcoords),
		)
		gl.EnableVertexAttribArray(2)
	}

	gl.BindVertexArray(floor.walls.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, floor.walls.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, floor.walls.ebo)

	if floor.walls.dirty {
		floor.walls.dirty = false

		vertices: [dynamic]wall.Wall_Vertex
		indices: [dynamic]wall.Wall_Index
		defer delete(vertices)
		defer delete(indices)

		for wall_pos, w in floor.walls.east_west {
			wall.draw_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.East_West,
				&vertices,
				&indices,
			)
		}

		for wall_pos, w in floor.walls.north_south {
			wall.draw_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.North_South,
				&vertices,
				&indices,
			)
		}

		for wall_pos, w in floor.walls.south_west_north_east {
			wall.draw_diagonal_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.South_West_North_East,
				&vertices,
				&indices,
			)
		}

		for wall_pos, w in floor.walls.north_west_south_east {
			wall.draw_diagonal_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.North_West_South_East,
				&vertices,
				&indices,
			)
		}

		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(vertices) * size_of(wall.Wall_Vertex),
			raw_data(vertices),
			gl.STATIC_DRAW,
		)

		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(indices) * size_of(wall.Wall_Index),
			raw_data(indices),
			gl.STATIC_DRAW,
		)
		floor.walls.num_indices = i32(len(indices))
	}

	gl.DrawElements(
		gl.TRIANGLES,
		floor.walls.num_indices,
		gl.UNSIGNED_INT,
		nil,
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
}
//
// chunk_tile_triangle_iterator_has_next :: proc(
// 	iterator: ^Chunk_Tile_Triangle_Iterator,
// ) -> bool {
// 	return(
// 		iterator.pos.x < iterator.end.x &&
// 		iterator.pos.z < iterator.end.z &&
// 		iterator.pos.x >= iterator.start.x &&
// 		iterator.pos.z >= iterator.start.z \
// 	)
// }
//
// chunk_tile_triangle_iterator_next :: proc(
// 	iterator: ^Chunk_Tile_Triangle_Iterator,
// ) -> (
// 	value: Chunk_Tile_Triangle_Iterator_Value,
// 	index: Chunk_Tile_Triangle_Iterator_Index,
// 	has_next: bool = true,
// ) {
// 	ok: bool = false
// 	for !ok {
// 		chunk_tile_triangle_iterator_has_next(iterator) or_return
// 		index.side = iterator.side
//
// 		value, ok =
// 		&iterator.chunk.floors[iterator.pos.y].tiles.triangles[iterator.pos.x][iterator.pos.z][iterator.side].?
//
// 		index.pos = iterator.chunk_pos + iterator.pos
// 		switch iterator.side {
// 		case .West:
// 			iterator.side = .South
// 			iterator.pos.x += 1
// 		case .South:
// 			iterator.side = .East
// 		case .East:
// 			iterator.side = .North
// 		case .North:
// 			iterator.side = .West
// 		}
//
// 		if iterator.pos.x >= iterator.end.x {
// 			iterator.pos.x = iterator.start.x
// 			iterator.pos.z += 1
// 		}
//
// 		// if iterator.pos.z >= iterator.end.z {
// 		// 	iterator.pos.x = iterator.start.x
// 		// 	iterator.pos.z = iterator.start.z
// 		// 	iterator.pos.y += 1
// 		// }
// 	}
//
// 	return
// }

chunk_iterate_all_tile_triangle :: proc(
	chunk: ^Chunk,
	chunk_pos: glsl.ivec3,
) -> (
	it: Chunk_Tile_Triangle_Iterator,
) {
	return(
		 {
			chunk = chunk,
			chunk_pos = {chunk_pos.x, 0, chunk_pos.z},
			pos = {0, chunk_pos.y, 0},
			start = {0, chunk_pos.y, 0},
			end =  {
				constants.CHUNK_WIDTH,
				constants.CHUNK_HEIGHT,
				constants.CHUNK_DEPTH,
			},
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
			end = {constants.CHUNK_WIDTH, 1, constants.CHUNK_DEPTH},
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
		i32(iterator.pos.x * constants.CHUNK_WIDTH),
		0,
		i32(iterator.pos.y * constants.CHUNK_DEPTH),
	}
	if camera.rotation == .South_West || camera.rotation == .South_East {
		iterator.pos.x -= 1
	} else {
		iterator.pos.x += 1
	}
	if iterator.pos.x >= iterator.end.x || iterator.pos.x < iterator.start.x {
		if iterator.pos.x < iterator.start.x {
			iterator.pos.x = iterator.end.x - 1
		} else {
			iterator.pos.x = iterator.start.x
		}

		if camera.rotation == .South_West || camera.rotation == .North_West {
			iterator.pos.y -= 1
		} else {
			iterator.pos.y += 1
		}
	}
	return
}


chunk_set_north_south_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	wall: wall.Wall,
) {
	chunk.floors[pos.y].walls.north_south[pos.xz] = wall
	chunk.floors[pos.y].walls.dirty = true
}

chunk_has_north_south_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) -> bool {
	return pos.xz in chunk.floors[pos.y].walls.north_south
}

chunk_get_north_south_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	wall.Wall,
	bool,
) {
	return chunk.floors[pos.y].walls.north_south[pos.xz]
}

chunk_remove_north_south_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	delete_key(&chunk.floors[pos.y].walls.north_south, glsl.ivec2(pos.xz))
	chunk.floors[pos.y].walls.dirty = true
}

chunk_set_east_west_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3, wall: wall.Wall) {
	chunk.floors[pos.y].walls.east_west[pos.xz] = wall
	chunk.floors[pos.y].walls.dirty = true
}

chunk_has_east_west_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) -> bool {
	return pos.xz in chunk.floors[pos.y].walls.east_west
}

chunk_get_east_west_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	wall.Wall,
	bool,
) {
	return chunk.floors[pos.y].walls.east_west[pos.xz]
}

chunk_remove_east_west_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	delete_key(&chunk.floors[pos.y].walls.east_west, glsl.ivec2(pos.xz))
	chunk.floors[pos.y].walls.dirty = true
}


chunk_set_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	wall: wall.Wall,
) {
	chunk.floors[pos.y].walls.north_west_south_east[pos.xz] = wall
	chunk.floors[pos.y].walls.dirty = true
}

chunk_has_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> bool {
	return pos.xz in chunk.floors[pos.y].walls.north_west_south_east
}

chunk_get_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	wall.Wall,
	bool,
) {
	return chunk.floors[pos.y].walls.north_west_south_east[pos.xz]
}

chunk_remove_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) {
	delete_key(
		&chunk.floors[pos.y].walls.north_west_south_east,
		glsl.ivec2(pos.xz),
	)
	chunk.floors[pos.y].walls.dirty = true
}

chunk_set_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	wall: wall.Wall,
) {
	chunk.floors[pos.y].walls.south_west_north_east[pos.xz] = wall
	chunk.floors[pos.y].walls.dirty = true
}

chunk_has_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> bool {
	return pos.xz in chunk.floors[pos.y].walls.south_west_north_east
}

chunk_get_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	wall.Wall,
	bool,
) {
	return chunk.floors[pos.y].walls.south_west_north_east[pos.xz]
}

chunk_remove_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) {
	delete_key(
		&chunk.floors[pos.y].walls.south_west_north_east,
		glsl.ivec2(pos.xz),
	)
	chunk.floors[pos.y].walls.dirty = true
}
