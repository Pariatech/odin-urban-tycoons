package main

import m "core:math/linalg/glsl"

FLOOR_OFFSET :: 0.0004

insert_north_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	y := f32(pos.y * WALL_HEIGHT)
	north_tile_triangles[pos] = tri
	lights := [3]m.vec3{1, 1, 1}
	heights := [3]f32{y + FLOOR_OFFSET, y + FLOOR_OFFSET, y + FLOOR_OFFSET}
	draw_tile_triangle(tri, .North, lights, heights, {f32(pos.x), f32(pos.z)}, 1)
}

insert_east_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	y := f32(pos.y * WALL_HEIGHT)
	east_tile_triangles[pos] = tri
	lights := [3]m.vec3{1, 1, 1}
	heights := [3]f32{y + FLOOR_OFFSET, y + FLOOR_OFFSET, y + FLOOR_OFFSET}
	draw_tile_triangle(tri, .East, lights, heights, {f32(pos.x), f32(pos.z)}, 1)
}

insert_west_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	y := f32(pos.y * WALL_HEIGHT)
	west_tile_triangles[pos] = tri
	lights := [3]m.vec3{1, 1, 1}
	heights := [3]f32{y + FLOOR_OFFSET, y + FLOOR_OFFSET, y + FLOOR_OFFSET}
	draw_tile_triangle(tri, .West, lights, heights, {f32(pos.x), f32(pos.z)}, 1)
}

insert_south_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	y := f32(pos.y * WALL_HEIGHT)
	south_tile_triangles[pos] = tri
	lights := [3]m.vec3{1, 1, 1}
	heights := [3]f32{y + FLOOR_OFFSET, y + FLOOR_OFFSET, y + FLOOR_OFFSET}
	draw_tile_triangle(tri, .South, lights, heights, {f32(pos.x), f32(pos.z)}, 1)
}

insert_floor_tile :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	insert_north_floor_tile_triangle(pos, tri)
	insert_south_floor_tile_triangle(pos, tri)
	insert_east_floor_tile_triangle(pos, tri)
	insert_west_floor_tile_triangle(pos, tri)
}
