package main

import "core:fmt"
import "core:math/linalg/glsl"
import "core:runtime"
import "vendor:glfw"

cursor_scroll: glsl.vec2
cursor_pos: glsl.vec2
cursor_ray: Cursor_Ray

Cursor_Ray :: struct {
	origin:    glsl.vec3,
	direction: glsl.vec3,
}

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {
	context = runtime.default_context()

	cursor_pos.x = f32(xpos)
	cursor_pos.y = f32(ypos)

	// fmt.println(window_size)
	screen_pos: glsl.vec4
	screen_pos.x = cursor_pos.x / window_size.x
	screen_pos.y = cursor_pos.y / window_size.y

	screen_pos.x = screen_pos.x * 2 - 1
	screen_pos.y = (1 - screen_pos.y) * 2 - 1
	screen_pos.z = -1
	screen_pos.w = 1

	end_pos := screen_pos
	end_pos.z = 1

	cursor_ray.origin = (icamera_vp * screen_pos).xyz
	cursor_ray.direction = (icamera_vp * end_pos).xyz - cursor_ray.origin
	cursor_ray.direction = glsl.normalize(cursor_ray.direction)

	// fmt.println(cursor_pos)
	// fmt.println(screen_pos)
	// fmt.println(cursor_ray)
	// p1 := inverse(camera_vp) * glsl.vec4{screen_point.x, screen_point.y, -1, 1}
	// p2 := inverse(camera_vp) * glsl.vec4{screen_point.x, screen_point.y, 1, 1}
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
	glfw.SetCursorPosCallback(window_handle, cursor_pos_callback)
	glfw.SetScrollCallback(window_handle, scroll_callback)
}

update_cursor :: proc() {
	cursor_scroll = {0, 0}
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
        return glsl.vec3{
            cursor_ray.origin.x + cursor_ray.direction.x * t,
            cursor_ray.origin.y + cursor_ray.direction.y * t,
            cursor_ray.origin.z + cursor_ray.direction.z * t,
        }
    }

	return nil
}
