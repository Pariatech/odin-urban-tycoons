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
	left_border_width: f32 = BORDER_WIDTH,
	right_border_width: f32 = BORDER_WIDTH,
	top_border_width: f32 = BORDER_WIDTH,
	bottom_border_width: f32 = BORDER_WIDTH,
	body: proc(
		ctx: ^Context,
		pos: glsl.vec2,
		size: glsl.vec2,
	) = container_noop,
) {
	rect(
		ctx,
		 {
			x = pos.x,
			y = pos.y,
			w = size.x,
			h = size.y,
			color = color,
			left_border_width = left_border_width,
			right_border_width = right_border_width,
			top_border_width = top_border_width,
			bottom_border_width = bottom_border_width,
		},
	)
	body(ctx, pos, size)
	if cursor.pos.x >= pos.x &&
	   cursor.pos.x < pos.x + size.x &&
	   cursor.pos.y >= pos.y &&
	   cursor.pos.y < pos.y + size.y {
		mouse.capture_all()
	}
}