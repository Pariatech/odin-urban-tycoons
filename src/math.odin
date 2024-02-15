package main

import m "core:math/linalg/glsl"

triangle_normal :: proc(p0, p1, p2: m.vec3) -> m.vec3 {
	a := p1 - p0
	b := p2 - p0
	return m.cross(a, b)
}

vec3_to_vec4 :: proc(v: m.vec3) -> (result: m.vec4) {
    result.xyz = v.xyz
	return
}

vec3_scalar_to_vec4 :: proc(v: m.vec3, scalar: f32) -> (result: m.vec4) {
    result.xyz = v.xyz
    result.w = scalar
	return
}

vec4 :: proc {
    vec3_to_vec4,
    vec3_scalar_to_vec4,
}

point_in_rhombus :: proc(
	point: m.vec2,
	center: m.vec2,
	top: m.vec2,
	right: m.vec2,
	bottom: m.vec2,
	left: m.vec2,
) -> bool {
	center_to_top := top - center
	center_to_right := right - center
	center_to_bottom := bottom - center
	center_to_left := left - center
	center_to_point := point - center

	return(
		m.dot(center_to_point, center_to_top) <=
			m.dot(center_to_top, center_to_top) &&
		m.dot(center_to_point, center_to_right) <=
			m.dot(center_to_right, center_to_right) &&
		m.dot(center_to_point, center_to_bottom) <=
			m.dot(center_to_bottom, center_to_bottom) &&
		m.dot(center_to_point, center_to_left) <=
			m.dot(center_to_left, center_to_left) \
	)
}

point_in_square :: proc(point: m.vec2, center: m.vec2, size: f32) -> bool {
	half_size := size / 2

	return(
		point.x >= center.x - half_size &&
		point.x <= center.x + half_size &&
		point.y >= center.y - half_size &&
		point.y <= center.y + half_size \
	)
}
