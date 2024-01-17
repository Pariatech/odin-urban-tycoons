package main

import m "core:math/linalg/glsl"

triangle_normal :: proc(p0, p1, p2: m.vec3) -> m.vec3 {
	a := p1 - p0
	b := p2 - p0
	return m.cross(a, b)
}
