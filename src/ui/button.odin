package ui

import "../cursor"
import "../mouse"
import "core:math/linalg/glsl"

Button :: struct {}

button :: proc(
	ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
	txt: string,
	color: glsl.vec4,
	txt_size: f32 = 32,
) -> (
	clicked: bool = false,
) {
	rect(ctx, {x = pos.x, y = pos.y, w = size.x, h = size.y, color = color})
	text(
		ctx,
		{pos.x + size.x / 2, pos.y + size.y / 2},
		txt,
		ah = .CENTER,
		av = .MIDDLE,
		clip_start = pos,
		clip_end = pos + size,
		size = txt_size,
	)

	if mouse.is_button_press(.Left) {
		if cursor.pos.x >= pos.x &&
		   cursor.pos.x < pos.x + size.x &&
		   cursor.pos.y >= pos.y &&
		   cursor.pos.y < pos.y + size.y {
            mouse.capture(.Left)

			return true
		}
	}

	return
}

icon_button :: proc(
	ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
	texture_array: u32,
	texture: int,
	color: glsl.vec4 = ROYAL_BLUE,
) -> (
	clicked: bool = false,
) {
	icon(
		ctx,
		 {
			pos = pos,
			size = size,
			color = color,
			texture_array = texture_array,
			texture = texture,
		},
	)

	if mouse.is_button_press(.Left) {
		if cursor.pos.x >= pos.x &&
		   cursor.pos.x < pos.x + size.x &&
		   cursor.pos.y >= pos.y &&
		   cursor.pos.y < pos.y + size.y {
            mouse.capture(.Left)

			return true
		}
	}

	return
}
