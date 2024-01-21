package main

import m "core:math/linalg/glsl"

draw_tile_floor_trianges :: proc(pos: m.ivec3, y: f32) {
    lights := [3]m.vec3{1, 1, 1}
    heights := [3]f32{y, y, y}
	if tri, ok := north_floor_tile_triangles[pos]; ok {
	    draw_tile_triangle(tri, .North, lights, heights, {f32(pos.x), f32(pos.z)})
	}
	if tri, ok := east_floor_tile_triangles[pos]; ok {
	    draw_tile_triangle(tri, .East, lights, heights, {f32(pos.x), f32(pos.z)})
	}
	if tri, ok := south_floor_tile_triangles[pos]; ok {
	    draw_tile_triangle(tri, .South, lights, heights, {f32(pos.x), f32(pos.z)})
	}
	if tri, ok := west_floor_tile_triangles[pos]; ok {
	    draw_tile_triangle(tri, .West, lights, heights, {f32(pos.x), f32(pos.z)})
	}
}
