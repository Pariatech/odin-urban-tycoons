package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

import "constants"
import "camera"
import "tile"
import "terrain"

import "wall"


// Chunk_Iterator :: struct {
// 	pos:   glsl.ivec2,
// 	start: glsl.ivec2,
// 	end:   glsl.ivec2,
// }
//
// Chunk_Tile_Triangle_Iterator :: struct {
// 	chunk:     ^Chunk,
// 	chunk_pos: glsl.ivec3,
// 	pos:       glsl.ivec3,
// 	start:     glsl.ivec3,
// 	end:       glsl.ivec3,
// 	side:      tile.Tile_Triangle_Side,
// }
//
// Chunk_Tile_Triangle_Iterator_Value :: ^tile.Tile_Triangle
//
// Chunk_Tile_Triangle_Iterator_Index :: struct {
// 	pos:  glsl.ivec3,
// 	side: tile.Tile_Triangle_Side,
// }

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

// chunk_iterate_all_tile_triangle :: proc(
// 	chunk: ^Chunk,
// 	chunk_pos: glsl.ivec3,
// ) -> (
// 	it: Chunk_Tile_Triangle_Iterator,
// ) {
// 	return(
// 		 {
// 			chunk = chunk,
// 			chunk_pos = {chunk_pos.x, 0, chunk_pos.z},
// 			pos = {0, chunk_pos.y, 0},
// 			start = {0, chunk_pos.y, 0},
// 			end =  {
// 				constants.CHUNK_WIDTH,
// 				constants.CHUNK_HEIGHT,
// 				constants.CHUNK_DEPTH,
// 			},
// 		} \
// 	)
// }
//
// chunk_iterate_all_ground_tile_triangle :: proc(
// 	chunk: ^Chunk,
// 	chunk_pos: glsl.ivec3,
// ) -> (
// 	it: Chunk_Tile_Triangle_Iterator,
// ) {
// 	return(
// 		 {
// 			chunk = chunk,
// 			chunk_pos = chunk_pos,
// 			pos = {0, 0, 0},
// 			start = {0, 0, 0},
// 			end = {constants.CHUNK_WIDTH, 1, constants.CHUNK_DEPTH},
// 		} \
// 	)
// }
//
// chunk_iterator_has_next :: proc(iterator: ^Chunk_Iterator) -> bool {
// 	return(
// 		iterator.pos.x < iterator.end.x &&
// 		iterator.pos.y < iterator.end.y &&
// 		iterator.pos.x >= iterator.start.x &&
// 		iterator.pos.y >= iterator.start.y \
// 	)
// }
//
// chunk_iterator_next :: proc(
// 	iterator: ^Chunk_Iterator,
// ) -> (
// 	chunk: ^Chunk,
// 	pos: glsl.ivec3,
// 	has_next: bool = true,
// ) {
// 	chunk_iterator_has_next(iterator) or_return
// 	chunk = &world_chunks[iterator.pos.x][iterator.pos.y]
// 	pos =  {
// 		i32(iterator.pos.x * constants.CHUNK_WIDTH),
// 		0,
// 		i32(iterator.pos.y * constants.CHUNK_DEPTH),
// 	}
// 	if camera.rotation == .South_West || camera.rotation == .South_East {
// 		iterator.pos.x -= 1
// 	} else {
// 		iterator.pos.x += 1
// 	}
// 	if iterator.pos.x >= iterator.end.x || iterator.pos.x < iterator.start.x {
// 		if iterator.pos.x < iterator.start.x {
// 			iterator.pos.x = iterator.end.x - 1
// 		} else {
// 			iterator.pos.x = iterator.start.x
// 		}
//
// 		if camera.rotation == .South_West || camera.rotation == .North_West {
// 			iterator.pos.y -= 1
// 		} else {
// 			iterator.pos.y += 1
// 		}
// 	}
// 	return
// }


