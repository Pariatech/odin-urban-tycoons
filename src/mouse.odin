package main

import "core:runtime"
import "vendor:glfw"

import "window"

Mouse_Button_State :: enum {
	Up,
	Press,
	Repeat,
	Release,
	Down,
}

Mouse_Button :: enum {
	Left,
	Right,
	Middle,
	Four,
	Five,
	Six,
	Seven,
	Eight,
}

mouse_buttons: [Mouse_Button]Mouse_Button_State

mouse_on_button :: proc "c" (
	window: glfw.WindowHandle,
	button: i32,
	action: i32,
	mods: i32,
) {
	context = runtime.default_context()
	switch action {
	case glfw.RELEASE:
		mouse_buttons[Mouse_Button(button)] = .Release
	case glfw.PRESS:
		mouse_buttons[Mouse_Button(button)] = .Press
	case glfw.REPEAT:
		mouse_buttons[Mouse_Button(button)] = .Repeat
	}
}

mouse_init :: proc() {
	glfw.SetMouseButtonCallback(window.handle, mouse_on_button)
}

mouse_update :: proc() {
	for &state in mouse_buttons {
		switch state {
		case .Press, .Repeat, .Down:
			state = .Down
		case .Release, .Up:
			state = .Up
		}
	}
}

mouse_is_button_press :: proc(button: Mouse_Button) -> bool {
	return mouse_buttons[button] == .Press
}

mouse_is_button_down :: proc(button: Mouse_Button) -> bool {
	return(
		mouse_buttons[button] == .Press ||
		mouse_buttons[button] == .Down ||
		mouse_buttons[button] == .Repeat \
	)
}

mouse_is_button_release :: proc(button: Mouse_Button) -> bool {
	return mouse_buttons[button] == .Release
}

mouse_is_button_up :: proc(button: Mouse_Button) -> bool {
	return mouse_buttons[button] == .Release || mouse_buttons[button] == .Up
}
