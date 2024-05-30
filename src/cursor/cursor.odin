package cursor

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:runtime"
import "vendor:glfw"

import "../camera"
import "../constants"
import "../terrain"
import "../tile"
import "../window"

previous_pos: glsl.vec2
pos: glsl.vec2
moved: bool
ray: Ray

Ray :: struct {
	origin:    glsl.vec3,
	direction: glsl.vec3,
}

pos_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	context = runtime.default_context()

	pos.x = f32(xpos)
	pos.y = f32(ypos)

	update_ray()
}

update_ray :: proc() {
	screen_pos: glsl.vec4
	screen_pos.x = pos.x / window.size.x
	screen_pos.y = pos.y / window.size.y

	screen_pos.x = screen_pos.x * 2 - 1
	screen_pos.y = (1 - screen_pos.y) * 2 - 1
	screen_pos.z = -1
	screen_pos.w = 1

	end_pos := screen_pos
	end_pos.z = 1

	last_origin := ray.origin
	ray.origin = (camera.inverse_view_proj * screen_pos).xyz
	moved = last_origin != ray.origin
	ray.direction = (camera.inverse_view_proj * end_pos).xyz - ray.origin
	ray.direction = glsl.normalize(ray.direction)
}

scroll_callback :: proc "c" (
	window: glfw.WindowHandle,
	xoffset, yoffset: f64,
) {
	context = runtime.default_context()
	camera.scroll.x = f32(xoffset)
	camera.scroll.y = f32(yoffset)
}

init :: proc() {
	glfw.SetCursorPosCallback(window.handle, pos_callback)
	glfw.SetScrollCallback(window.handle, scroll_callback)
}

update :: proc() {
	camera.scroll = {0, 0}
	update_ray()
    previous_pos = pos
}

ray_intersect_plane :: proc(
	pos: glsl.vec3,
	normal: glsl.vec3,
) -> Maybe(glsl.vec3) {
	dot_product := glsl.dot(ray.direction, normal)

	if dot_product == 0 {
		return nil
	}

	t := glsl.dot(pos - ray.origin, normal) / dot_product
	if t < 0 {
		return nil
	}

	return ray.origin + t * ray.direction
}

ray_intersect_triangle :: proc(triangle: [3]glsl.vec3) -> Maybe(glsl.vec3) {
	EPSILON :: 0.000001

	edge1, edge2, h, s, q: glsl.vec3
	a, f, u, v: f32

	edge1.x = triangle[1].x - triangle[0].x
	edge1.y = triangle[1].y - triangle[0].y
	edge1.z = triangle[1].z - triangle[0].z

	edge2.x = triangle[2].x - triangle[0].x
	edge2.y = triangle[2].y - triangle[0].y
	edge2.z = triangle[2].z - triangle[0].z

	h = glsl.cross(ray.direction, edge2)
	a = glsl.dot(edge1, h)

	if a > -EPSILON && a < EPSILON {
		return nil
	}

	f = 1 / a
	s.x = ray.origin.x - triangle[0].x
	s.y = ray.origin.y - triangle[0].y
	s.z = ray.origin.z - triangle[0].z

	u = f * glsl.dot(s, h)
	if u < 0 || u > 1 {
		return nil
	}

	q = glsl.cross(s, edge1)
	v = f * glsl.dot(ray.direction, q)
	if v < 0 || u + v > 1 {
		return nil
	}

	t := f * glsl.dot(edge2, q)
	if t > EPSILON {
		return(
			glsl.vec3 {
				ray.origin.x + ray.direction.x * t,
				ray.origin.y + ray.direction.y * t,
				ray.origin.z + ray.direction.z * t,
			} \
		)
	}

	return nil
}

intersect_with_tile_triangle :: proc(
	side: tile.Tile_Triangle_Side,
	heights: [3]f32,
	pos: glsl.vec2,
	on_intersect: proc(_: glsl.vec3),
) -> bool {
	triangle: [3]glsl.vec3

	vertices := tile.tile_triangle_side_vertices_map[side]
	for vertex, i in vertices {
		triangle[i] = vertex.pos
		triangle[i].x += pos.x
		triangle[i].z += pos.y
		triangle[i].y += heights[i]
	}

	intersect, ok := ray_intersect_triangle(triangle).?
	if ok {
		on_intersect(intersect)
	}

	return ok
}

intersect_with_tile :: proc(
	x, z: f32,
	on_intersect: proc(_: glsl.vec3),
    floor: i32,
) -> bool {
	for side in tile.Tile_Triangle_Side {
		pos := glsl.vec2{math.floor(x), math.floor(z)}

		x := int(pos.x)
		z := int(pos.y)

		heights := tile.get_terrain_tile_triangle_heights(side, x, z, 1)
		for &h in heights {
			h += f32(floor) * constants.WALL_HEIGHT
		}

		if intersect_with_tile_triangle(
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

intersect_with_tiles_south_west :: proc(on_intersect: proc(_: glsl.vec3), floor: i32) {
	x := ray.origin.x + 0.5
	z := ray.origin.z + 0.5
	dx := ray.direction.x
	dz := ray.direction.z


	left_x := f32(camera.visible_chunks_start.x * constants.CHUNK_WIDTH)
	left_z := z + ((left_x - x) / dx) * dz

	right_z := f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH)
	right_x := x + ((right_z - z) / dz) * dx

	if right_x >= f32(camera.visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	   right_x <= f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH) {
		x = right_x
		z = right_z
	} else if left_z >=
		   f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   left_z <= f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = left_x
		z = left_z
	} else {
		return
	}

	for x <= f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH) &&
	    z <= f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH) {

		next_x := x + 1
		next_z := z + 1

		if intersect_with_tile(x, z, on_intersect, floor) {
			break
		}

		if (next_x <=
				   f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH) &&
			   intersect_with_tile(next_x, z, on_intersect, floor)) ||
		   next_z <=
				   f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH) &&
			   intersect_with_tile(x, next_z, on_intersect, floor) {
			break
		}

		x += 1
		z += 1
	}
}

intersect_with_tiles_south_east :: proc(on_intersect: proc(_: glsl.vec3), floor: i32) {
	x := ray.origin.x - 0.5
	z := ray.origin.z + 0.5
	dx := ray.direction.x
	dz := ray.direction.z

	left_z := f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH)
	left_x := x + ((left_z - z) / dz) * dx

	right_x := f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH - 1)
	right_z := z + ((right_x - x) / dx) * dz

	if left_x >= f32(camera.visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	   left_x < f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH) {
		x = left_x
		z = left_z
	} else if right_z >=
		   f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   right_z < f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = right_x
		z = right_z
	} else {
		return
	}

	for x >= f32(camera.visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	    z < f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH) {

		next_x := x - 1
		next_z := z + 1

		if intersect_with_tile(x, z, on_intersect, floor) {
			break
		}

		if (next_x >=
				   f32(
					   camera.visible_chunks_start.x * constants.CHUNK_WIDTH,
				   ) &&
			   intersect_with_tile(next_x, z, on_intersect, floor)) ||
		   (next_z <
					   f32(
						   camera.visible_chunks_end.y * constants.CHUNK_DEPTH,
					   ) &&
				   intersect_with_tile(x, next_z, on_intersect, floor)) {
			break
		}

		x -= 1
		z += 1
	}
}

intersect_with_tiles_north_west :: proc(on_intersect: proc(_: glsl.vec3), floor: i32) {
	x := ray.origin.x + 0.5
	z := ray.origin.z - 0.5
	dx := ray.direction.x
	dz := ray.direction.z

	left_z := f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH - 1)
	left_x := x + ((left_z - z) / dz) * dx

	right_x := f32(camera.visible_chunks_start.x * constants.CHUNK_WIDTH)
	right_z := z + ((right_x - x) / dx) * dz

	if left_x >= f32(camera.visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	   left_x < f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH) {
		x = left_x
		z = left_z
	} else if right_z >=
		   f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   right_z < f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = right_x
		z = right_z
	} else {
		return
	}

	for x < f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH) &&
	    z >= f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH) {

		next_x := x + 1
		next_z := z - 1

		if intersect_with_tile(x, z, on_intersect, floor) {
			break
		}

		if (next_x <
				   f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH) &&
			   intersect_with_tile(next_x, z, on_intersect, floor)) ||
		   (next_z >=
					   f32(
						   camera.visible_chunks_start.y *
						   constants.CHUNK_DEPTH,
					   ) &&
				   intersect_with_tile(x, next_z, on_intersect, floor)) {
			break
		}

		x += 1
		z -= 1
	}
}

intersect_with_tiles_north_east :: proc(
	on_intersect: proc(_: glsl.vec3),
    floor: i32,
) {
	x := ray.origin.x - 0.5
	z := ray.origin.z - 0.5
	dx := ray.direction.x
	dz := ray.direction.z

	right_z := f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH - 1)
	right_x := x + ((right_z - z) / dz) * dx

	left_x := f32(camera.visible_chunks_end.x * constants.CHUNK_WIDTH - 1)
	left_z := z + ((left_x - x) / dx) * dz

	if left_z >= f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH) &&
	   left_z < f32(camera.visible_chunks_end.y * constants.CHUNK_DEPTH) {
		x = left_x
		z = left_z
	} else if right_x >=
		   f32(camera.visible_chunks_start.x * constants.CHUNK_DEPTH) &&
	   right_x < f32(camera.visible_chunks_end.x * constants.CHUNK_DEPTH) {
		x = right_x
		z = right_z
	} else {
		return
	}

	for x >= f32(camera.visible_chunks_start.x * constants.CHUNK_WIDTH) &&
	    z >= f32(camera.visible_chunks_start.y * constants.CHUNK_DEPTH) {

		next_x := x - 1
		next_z := z - 1

		if intersect_with_tile(x, z, on_intersect, floor) {
			break
		}

		if (next_x >=
				   f32(
					   camera.visible_chunks_start.x * constants.CHUNK_WIDTH,
				   ) &&
			   intersect_with_tile(next_x, z, on_intersect, floor)) ||
		   (next_z >=
					   f32(
						   camera.visible_chunks_start.y *
						   constants.CHUNK_DEPTH,
					   ) &&
				   intersect_with_tile(x, next_z, on_intersect, floor)) {
			break
		}

		x -= 1
		z -= 1
	}
}

intersect_with_tiles :: proc(on_intersect: proc(_: glsl.vec3), floor: i32) {
	switch camera.rotation {
	case .South_West:
		intersect_with_tiles_south_west(on_intersect, floor)
	case .South_East:
		intersect_with_tiles_south_east(on_intersect, floor)
	case .North_West:
		intersect_with_tiles_north_west(on_intersect, floor)
	case .North_East:
		intersect_with_tiles_north_east(on_intersect, floor)
	}
}


on_tile_intersect :: proc(
	on_intersect: proc(_: glsl.vec3),
	previous_floor: i32,
	floor: i32,
) {
	if moved || previous_floor != floor {
		intersect_with_tiles(on_intersect, floor)
	}
}
