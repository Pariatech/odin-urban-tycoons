package main

import "vendor:glfw"
import "core:runtime"

Mouse_Button_State :: enum {
	Press,
	Repeat,
	Release,
	Down,
	Up,
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

mouse_buttons: [Mouse_Button]Mouse_Button_State;

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
    glfw.SetMouseButtonCallback(window_handle, mouse_on_button)
	key_map = make(map[Key_Value]Key_State)
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
