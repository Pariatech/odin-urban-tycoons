package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:runtime"
import "vendor:glfw"

import "constants"
import "window"

cursor_scroll: glsl.vec2
cursor_pos: glsl.vec2
cursor_moved: bool
cursor_ray: Cursor_Ray

Cursor_Ray :: struct {
	origin:    glsl.vec3,
	direction: glsl.vec3,
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	context = runtime.default_context()

	cursor_pos.x = f32(xpos)
	cursor_pos.y = f32(ypos)

	cursor_update_ray()
}

cursor_update_ray :: proc() {
	screen_pos: glsl.vec4
	screen_pos.x = cursor_pos.x / window_size.x
	screen_pos.y = cursor_pos.y / window_size.y

	screen_pos.x = screen_pos.x * 2 - 1
	screen_pos.y = (1 - screen_pos.y) * 2 - 1
	screen_pos.z = -1
	screen_pos.w = 1

	end_pos := screen_pos
	end_pos.z = 1

	last_origin := cursor_ray.origin
	cursor_ray.origin = (icamera_vp * screen_pos).xyz
	cursor_moved = last_origin != cursor_ray.origin
	cursor_ray.direction = (icamera_vp * end_pos).xyz - cursor_ray.origin
	cursor_ray.direction = glsl.normalize(cursor_ray.direction)
}

scroll_callback :: proc "c" (
	window: glfw.WindowHandle,
	xoffset, yoffset: f64,
) {
	context = runtime.default_context()
	cursor_scroll.x = f32(xoffset)
	cursor_scroll.y = f32(yoffset)
}

init_cursor :: proc() {
	glfw.SetCursorPosCallback(window.handle, cursor_pos_callback)
	glfw.SetScrollCallback(window.handle, scroll_callback)
}

update_cursor :: proc() {
	cursor_scroll = {0, 0}
	cursor_update_ray()
}

cursor_ray_intersect_plane :: proc(
	pos: glsl.vec3,
	normal: glsl.vec3,
) -> Maybe(glsl.vec3) {
	dot_product := glsl.dot(cursor_ray.direction, normal)

	if dot_product == 0 {
		return nil
	}

	t := glsl.dot(pos - cursor_ray.origin, normal) / dot_product
	if t < 0 {
		return nil
	}

	return cursor_ray.origin + t * cursor_ray.direction
}

cursor_ray_intersect_triangle :: proc(
	triangle: [3]glsl.vec3,
) -> Maybe(glsl.vec3) {
	EPSILON :: 0.000001

	edge1, edge2, h, s, q: glsl.vec3
	a, f, u, v: f32

	edge1.x = triangle[1].x - triangle[0].x
	edge1.y = triangle[1].y - triangle[0].y
	edge1.z = triangle[1].z - triangle[0].z

	edge2.x = triangle[2].x - triangle[0].x
	edge2.y = triangle[2].y - triangle[0].y
	edge2.z = triangle[2].z - triangle[0].z

	h = glsl.cross(cursor_ray.direction, edge2)
	a = glsl.dot(edge1, h)

	if a > -EPSILON && a < EPSILON {
		return nil
	}

	f = 1 / a
	s.x = cursor_ray.origin.x - triangle[0].x
	s.y = cursor_ray.origin.y - triangle[0].y
	s.z = cursor_ray.origin.z - triangle[0].z

	u = f * glsl.dot(s, h)
	if u < 0 || u > 1 {
		return nil
	}

	q = glsl.cross(s, edge1)
	v = f * glsl.dot(cursor_ray.direction, q)
	if v < 0 || u + v > 1 {
		return nil
	}

	t := f * glsl.dot(edge2, q)
	if t > EPSILON {
		return(
			glsl.vec3 {
				cursor_ray.origin.x + cursor_ray.direction.x * t,
				cursor_ray.origin.y + cursor_ray.direction.y * t,
				cursor_ray.origin.z + cursor_ray.direction.z * t,
			} \
		)
	}

	return nil
}

cursor_intersect_with_tile_triangle :: proc(
	tri: Tile_Triangle,
	side: Tile_Triangle_Side,
	heights: [3]f32,
	pos: glsl.vec2,
	on_intersect: proc(_: glsl.vec3),
) -> bool {
	triangle: [3]glsl.vec3

	vertices := tile_triangle_side_vertices_map[side]
	for vertex, i in vertices {
		triangle[i] = vertex.pos
		triangle[i].x += pos.x
		triangle[i].z += pos.y
		triangle[i].y += heights[i]
	}

	intersect, ok := cursor_ray_intersect_triangle(triangle).?
	if ok {
		on_intersect(intersect)
	}

	return ok
}

cursor_intersect_with_tile :: proc(
	x, z: f32,
	on_intersect: proc(_: glsl.vec3),
) -> bool {
	tile := world_get_tile({i32(x), i32(floor), i32(z)})

	for tile_triangle, side in tile {
		pos := glsl.vec2{math.floor(x), math.floor(z)}

		x := int(pos.x)
		z := int(pos.y)

		heights := get_terrain_tile_triangle_heights(side, x, z, 1)
		for h in &heights {
			h += f32(floor) * constants.WALL_HEIGHT
		}

		if cursor_intersect_with_tile_triangle(
			   tile_triangle.?,
			   side,
			   heights,
			   pos,
			   on_intersect,
		   ) {
			return true
		}
	}
	return false
}

cursor_intersect_with_tiles_south_west :: proc(
	on_intersect: proc(_: glsl.vec3),
) {
	x := cursor_ray.origin.x + 0.5
	z := cursor_ray.origin.z + 0.5
	dx := cursor_ray.direction.x
	dz := cursor_ray.direction.z


	left_x := f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH)
	left_z := z + ((left_x - x) / dx) * dz

	right_z := f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH)
	right_x := x + ((right_z - z) / dz) * dx

	if right_x >= f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	   right_x <= f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH) {
		x = right_x
		z = right_z
	} else if left_z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   left_z <= f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = left_x
		z = left_z
	} else {
		return
	}

	for x <= f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH) &&
	    z <= f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) {

		next_x := x + 1
		next_z := z + 1

		if cursor_intersect_with_tile(x, z, on_intersect) {
			break
		}

		if (next_x <= f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH) &&
			   cursor_intersect_with_tile(next_x, z, on_intersect)) ||
		   next_z <= f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) &&
			   cursor_intersect_with_tile(x, next_z, on_intersect) {
			break
		}

		x += 1
		z += 1
	}
}

cursor_intersect_with_tiles_south_east :: proc(
	on_intersect: proc(_: glsl.vec3),
) {
	x := cursor_ray.origin.x - 0.5
	z := cursor_ray.origin.z + 0.5
	dx := cursor_ray.direction.x
	dz := cursor_ray.direction.z

	left_z := f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH)
	left_x := x + ((left_z - z) / dz) * dx

	right_x := f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH - 1)
	right_z := z + ((right_x - x) / dx) * dz

	if left_x >= f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	   left_x < f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH) {
		x = left_x
		z = left_z
	} else if right_z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   right_z < f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = right_x
		z = right_z
	} else {
		return
	}

	for x >= f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	    z < f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) {

		next_x := x - 1
		next_z := z + 1

		if cursor_intersect_with_tile(x, z, on_intersect) {
			break
		}

		if (next_x >= f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH) &&
			   cursor_intersect_with_tile(next_x, z, on_intersect)) ||
		   (next_z < f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) &&
				   cursor_intersect_with_tile(x, next_z, on_intersect)) {
			break
		}

		x -= 1
		z += 1
	}
}

cursor_intersect_with_tiles_north_west :: proc(
	on_intersect: proc(_: glsl.vec3),
) {
	x := cursor_ray.origin.x + 0.5
	z := cursor_ray.origin.z - 0.5
	dx := cursor_ray.direction.x
	dz := cursor_ray.direction.z

	left_z := f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH - 1)
	left_x := x + ((left_z - z) / dz) * dx

	right_x := f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH)
	right_z := z + ((right_x - x) / dx) * dz

	if left_x >= f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	   left_x < f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH) {
		x = left_x
		z = left_z
	} else if right_z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   right_z < f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = right_x
		z = right_z
	} else {
		return
	}

	for x < f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH) &&
	    z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) {

		next_x := x + 1
		next_z := z - 1

		if cursor_intersect_with_tile(x, z, on_intersect) {
			break
		}

		if (next_x < f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH) &&
			   cursor_intersect_with_tile(next_x, z, on_intersect)) ||
		   (next_z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) &&
				   cursor_intersect_with_tile(x, next_z, on_intersect)) {
			break
		}

		x += 1
		z -= 1
	}
}

cursor_intersect_with_tiles_north_east :: proc(
	on_intersect: proc(_: glsl.vec3),
) {
	x := cursor_ray.origin.x - 0.5
	z := cursor_ray.origin.z - 0.5
	dx := cursor_ray.direction.x
	dz := cursor_ray.direction.z

	right_z := f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH - 1)
	right_x := x + ((right_z - z) / dz) * dx

	left_x := f32(world_visible_chunks_end.x * constants.CHUNK_WIDTH - 1)
	left_z := z + ((left_x - x) / dx) * dz

	if left_z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   left_z < f32(world_visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = left_x
		z = left_z
	} else if right_x >= f32(world_visible_chunks_start.x * constants.CHUNK_DEPTH) &&
	   right_x < f32(world_visible_chunks_end.x * constants.CHUNK_DEPTH) {
		x = right_x
		z = right_z
	} else {
		return
	}

	for x >= f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	    z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) {

		next_x := x - 1
		next_z := z - 1

		if cursor_intersect_with_tile(x, z, on_intersect) {
			break
		}

		if (next_x >= f32(world_visible_chunks_start.x * constants.CHUNK_WIDTH) &&
			   cursor_intersect_with_tile(next_x, z, on_intersect)) ||
		   (next_z >= f32(world_visible_chunks_start.y * constants.CHUNK_DEPTH) &&
				   cursor_intersect_with_tile(x, next_z, on_intersect)) {
			break
		}

		x -= 1
		z -= 1
	}
}

cursor_intersect_with_tiles :: proc(on_intersect: proc(_: glsl.vec3)) {
	switch camera_rotation {
	case .South_West:
		cursor_intersect_with_tiles_south_west(on_intersect)
	case .South_East:
		cursor_intersect_with_tiles_south_east(on_intersect)
	case .North_West:
		cursor_intersect_with_tiles_north_west(on_intersect)
	case .North_East:
		cursor_intersect_with_tiles_north_east(on_intersect)
	}
}


cursor_on_tile_intersect :: proc(on_intersect: proc(_: glsl.vec3)) {
	if cursor_moved || previous_floor != floor {
		cursor_intersect_with_tiles(on_intersect)
	}
}
