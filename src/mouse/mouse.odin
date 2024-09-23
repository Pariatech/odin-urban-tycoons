package mouse

import "base:runtime"
import "core:math/linalg/glsl"

import "vendor:glfw"
import stbi "vendor:stb/image"

import "../window"

Button_State :: enum {
	Up,
	Press,
	Repeat,
	Release,
	Down,
}

Button :: enum {
	Left,
	Right,
	Middle,
	Four,
	Five,
	Six,
	Seven,
	Eight,
}

Cursor :: enum {
	Arrow,
	Hand,
	Hand_Closed,
    Rotate,
    Cross, 
}

@(private)
buttons: [Button]Button_State

@(private)
buttons_captured: [Button]bool

@(private)
scroll: glsl.dvec2

@(private)
cursors: [Cursor]glfw.CursorHandle

CURSOR_PATHS :: [Cursor]cstring {
	.Arrow = "resources/cursors/arrow.png",
	.Hand  = "resources/cursors/hand.png",
	.Hand_Closed  = "resources/cursors/hand-closed.png",
	.Rotate  = "resources/cursors/rotate.png",
	.Cross  = "resources/cursors/cross.png",
}

CURSOR_HOTSPOTS :: [Cursor]glsl.ivec2 {
	.Arrow = {1, 1},
	.Hand  = {24, 24},
	.Hand_Closed  = {24, 24},
	.Rotate  = {24, 24},
	.Cross  = {24, 24},
}

get_scroll :: proc() -> glsl.dvec2 {
	return scroll
}

vertical_scroll :: proc() -> f64 {
	return scroll.y
}

capture_vertical_scroll :: proc() {
	scroll.y = 0
}

capture_scroll :: proc() {
	scroll = {}
}

scroll_callback :: proc "c" (
	window: glfw.WindowHandle,
	xoffset, yoffset: f64,
) {
	context = runtime.default_context()
	scroll.x = xoffset
	scroll.y = yoffset
}

on_button :: proc "c" (
	window: glfw.WindowHandle,
	button: i32,
	action: i32,
	mods: i32,
) {
	context = runtime.default_context()
	switch action {
	case glfw.RELEASE:
		buttons[Button(button)] = .Release
	case glfw.PRESS:
		buttons[Button(button)] = .Press
	case glfw.REPEAT:
		buttons[Button(button)] = .Repeat
	}
}

init :: proc() {
	glfw.SetMouseButtonCallback(window.handle, on_button)
	glfw.SetScrollCallback(window.handle, scroll_callback)

	cursor_paths := CURSOR_PATHS
    cursor_hotspots := CURSOR_HOTSPOTS
	for path, i in cursor_paths {
		width, height, channels: i32
		pixels := stbi.load(path, &width, &height, &channels, 4)
		defer stbi.image_free(pixels)

		image := glfw.Image {
			width  = width,
			height = height,
			pixels = pixels,
		}

        hotspot := cursor_hotspots[i]

		cursors[i] = glfw.CreateCursor(&image, hotspot.x, hotspot.y)
	}
	glfw.SetCursor(window.handle, cursors[.Arrow])
}

deinit :: proc() {
	for cursor, i in cursors {
		glfw.DestroyCursor(cursor)
	}
}

set_cursor :: proc(cursor: Cursor) {
	glfw.SetCursor(window.handle, cursors[cursor])
}

update :: proc() {
	scroll = {0, 0}

	for &capture in buttons_captured {
		capture = false
	}

	for &state in buttons {
		switch state {
		case .Press, .Repeat, .Down:
			state = .Down
		case .Release, .Up:
			state = .Up
		}
	}
}

is_button_press :: proc(button: Button) -> bool {
	return !buttons_captured[button] && buttons[button] == .Press
}

is_button_down :: proc(button: Button) -> bool {
	return(
		!buttons_captured[button] &&
		(buttons[button] == .Press ||
				buttons[button] == .Down ||
				buttons[button] == .Repeat) \
	)
}

is_button_release :: proc(button: Button) -> bool {
	return !buttons_captured[button] && buttons[button] == .Release
}

is_button_up :: proc(button: Button) -> bool {
	return buttons[button] == .Up
}


capture :: proc(button: Button) {
	buttons_captured[button] = true
	// buttons[button] = .Up
}

capture_all :: proc() {
	for &capture in buttons_captured {
		capture = true
	}

	capture_scroll()
}
