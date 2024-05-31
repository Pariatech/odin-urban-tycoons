package ui

import "core:math/linalg/glsl"

import "../cursor"
import "../mouse"

Container :: struct {
	pos:  glsl.vec2,
	size: glsl.vec2,
}

container_noop :: proc(ctx: ^Context, pos: glsl.vec2, size: glsl.vec2) {}

container :: proc(
	using ctx: ^Context,
	pos: glsl.vec2 = {},
	size: glsl.vec2 = {},
	color: glsl.vec4 = ROYAL_BLUE,
	body: proc(
		ctx: ^Context,
		pos: glsl.vec2,
		size: glsl.vec2,
	) = container_noop,
) {
	rect(ctx, {x = pos.x, y = pos.y, w = size.x, h = size.y, color = color})
	body(ctx, pos, size)
	if cursor.pos.x >= pos.x &&
	   cursor.pos.x < pos.x + size.x &&
	   cursor.pos.y >= pos.y &&
	   cursor.pos.y < pos.y + size.y {
		mouse.capture_all()
	}
}
