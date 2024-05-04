package mouse

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

buttons: [Button]Button_State

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
}

update :: proc() {
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
	return buttons[button] == .Press
}

is_button_down :: proc(button: Button) -> bool {
	return(
		buttons[button] == .Press ||
		buttons[button] == .Down ||
		buttons[button] == .Repeat \
	)
}

is_button_release :: proc(button: Button) -> bool {
	return buttons[button] == .Release
}

is_button_up :: proc(button: Button) -> bool {
	return buttons[button] == .Release || buttons[button] == .Up
}
