package ui

import "core:log"
import "core:math/linalg/glsl"

import "../camera"
import "../cursor"
import "../mouse"
import "../window"

HELP_TEXT :: `---- Camera ----
W,A,S,D:      Move camera
Q,E:          Rotate camera
Mouse Scroll: Zoom

---- Land Tool [T] ----
Only work on grass tiles

Left Click:              Raise land
Right Click:             Lower land
+:                       Increase brush size
-:                       Reduce brush size
Shift +:                 Increase brush strength
Shift -:                 Reduce brush strength
Ctrl Click:              Smooth land
Shift Click & Drag:      Level land
Ctrl Shift Click & Drag: Flatten land

---- Wall Tool [G] ----
Left Click & Drag:              Place Wall
Shift Left Click & Drag:        Place Wall Rectangle
Ctrl Left Click & Drag:         Remove Wall
Ctrl Shift Left Click & Drag:   Remove Wall Rectangle

---- Floor Tool [F] ----
Left Click & Drag:          Place
Ctrl Left Click & Drag:     Remove
Shift Left Click:           Fill Place
Ctrl Shift Left Click:      Fill Remove

---- Triangle Floor Tool [Ctrl F] ----
Left Click: Place
`

HELP_WINDOW_WIDTH :: 526
HELP_WINDOW_BODY_WIDTH :: 500
HELP_WINDOW_BODY_HEIGHT :: 400
HELP_WINDOW_PADDING :: 10
HELP_WINDOW_SCROLL_BAR_WIDTH :: 26

Help_Window :: struct {
	opened:              bool,
	scroll_bar_percent:  f32,
	scroll_bar_offset:   f32,
	scroll_bar_dragging: bool,
}

help_window_header :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	using help_window_ctx
	text(
		ctx,
		{pos.x + HELP_WINDOW_WIDTH / 2, pos.y + 5},
		"Help",
		.CENTER,
		.TOP,
		16,
	)

	if button(
		   ctx,
		   {pos.x + HELP_WINDOW_WIDTH - 26, pos.y},
		   {26, 26},
		   "x",
		   {0.255, 0.412, 0.882, 1},
		   txt_size = 32,
	   ) {
		opened = false
	}
}

help_window_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	using help_window_ctx

	min, max := text_bounds(
		ctx,
		pos + HELP_WINDOW_PADDING,
		HELP_TEXT,
		ah = .LEFT,
		av = .TOP,
		size = 18,
	)

	scroll_bar_percent = 400 / (max.y - min.y)
	if cursor.pos.x >= pos.x &&
	   cursor.pos.x < pos.x + size.x + HELP_WINDOW_SCROLL_BAR_WIDTH &&
	   cursor.pos.y >= pos.y &&
	   cursor.pos.y < pos.y + size.y {
		scroll_bar_offset -= (mouse.vertical_scroll() / scroll_bar_percent) * 4
		scroll_bar_offset = clamp(
			scroll_bar_offset,
			0,
			size.y * (1 - scroll_bar_percent),
		)
		mouse.capture_vertical_scroll()
	}

	text(
		ctx,
		 {
			pos.x + HELP_WINDOW_PADDING,
			pos.y + HELP_WINDOW_PADDING - scroll_bar_offset,
		},
		HELP_TEXT,
		ah = .LEFT,
		av = .TOP,
		size = 18,
		clip_start = pos + HELP_WINDOW_PADDING,
		clip_end =  {
			pos.x + HELP_WINDOW_WIDTH - HELP_WINDOW_PADDING,
			pos.y + HELP_WINDOW_BODY_HEIGHT - HELP_WINDOW_PADDING,
		},
	)

	scroll_bar(
		ctx,
		{pos.x + HELP_WINDOW_BODY_WIDTH, 25},
		{HELP_WINDOW_SCROLL_BAR_WIDTH, 400},
		scroll_bar_percent,
		&scroll_bar_offset,
		&scroll_bar_dragging,
	)
}

help_window :: proc(using ctx: ^Context) {
	using help_window_ctx
	x := window.size.x - HELP_WINDOW_WIDTH
	container(
		ctx,
		pos = {x, 0},
		size = {HELP_WINDOW_WIDTH, 26},
		color = {0.0, 0.251, 0.502, 1},
		body = help_window_header,
	)

	container(
		ctx,
		pos = {x, 25},
		size = {HELP_WINDOW_BODY_WIDTH, 400},
		body = help_window_body,
	)
}
