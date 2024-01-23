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
