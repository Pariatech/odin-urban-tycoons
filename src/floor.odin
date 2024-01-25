package main

import m "core:math/linalg/glsl"

FLOOR_OFFSET :: 0.0004

draw_tile_floor_trianges :: proc(pos: m.ivec3, y: f32) {
	lights := [3]m.vec3{1, 1, 1}
	heights := [3]f32{y + FLOOR_OFFSET, y + FLOOR_OFFSET, y + FLOOR_OFFSET}
	if tri, ok := north_floor_tile_triangles[pos]; ok {
		draw_tile_triangle(
			tri,
			.North,
			lights,
			heights,
			{f32(pos.x), f32(pos.z)},
		)
	}
	if tri, ok := east_floor_tile_triangles[pos]; ok {
		draw_tile_triangle(
			tri,
			.East,
			lights,
			heights,
			{f32(pos.x), f32(pos.z)},
		)
	}
	if tri, ok := south_floor_tile_triangles[pos]; ok {
		draw_tile_triangle(
			tri,
			.South,
			lights,
			heights,
			{f32(pos.x), f32(pos.z)},
		)
	}
	if tri, ok := west_floor_tile_triangles[pos]; ok {
		draw_tile_triangle(
			tri,
			.West,
			lights,
			heights,
			{f32(pos.x), f32(pos.z)},
		)
	}
}

insert_north_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	north_floor_tile_triangles[pos] = tri
}

insert_east_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	east_floor_tile_triangles[pos] = tri
}

insert_west_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	west_floor_tile_triangles[pos] = tri
}

insert_south_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	south_floor_tile_triangles[pos] = tri
}

insert_floor_tile :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	insert_north_floor_tile_triangle(pos, tri)
	insert_south_floor_tile_triangle(pos, tri)
	insert_east_floor_tile_triangle(pos, tri)
	insert_west_floor_tile_triangle(pos, tri)
}
