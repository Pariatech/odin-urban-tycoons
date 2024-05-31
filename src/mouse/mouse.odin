package mouse

import "core:math/linalg/glsl"
import "core:runtime"

import "vendor:glfw"

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

@(private)
buttons: [Button]Button_State

@(private)
buttons_captured: [Button]bool

@(private)
scroll: glsl.vec2

get_scroll :: proc() -> glsl.vec2 {
    return scroll
}

vertical_scroll :: proc() -> f32 {
    return scroll.y
}

capture_vertical_scroll :: proc() {
    scroll.y = 0
}

scroll_callback :: proc "c" (
	window: glfw.WindowHandle,
	xoffset, yoffset: f64,
) {
	context = runtime.default_context()
	scroll.x = f32(xoffset)
	scroll.y = f32(yoffset)
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
	return buttons[button] == .Release || buttons[button] == .Up
}

capture :: proc(button: Button) {
	buttons_captured[button] = true
}
