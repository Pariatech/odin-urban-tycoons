package main

import m "core:math/linalg/glsl"
import "vendor:glfw"
import "core:fmt"
import "core:runtime"

cursor_pos_callback :: proc "c" (window: glfw.WindowHandle, xpos, ypos: f64) {

}

cursor_scroll: m.vec2

scroll_callback :: proc "c" (
	window: glfw.WindowHandle,
	xoffset, yoffset: f64,
) {
	context = runtime.default_context()
	cursor_scroll.x = f32(xoffset)
	cursor_scroll.y = f32(yoffset)
    fmt.println(cursor_scroll)
}

init_cursor :: proc() {
	glfw.SetCursorPosCallback(window_handle, cursor_pos_callback)
	glfw.SetScrollCallback(window_handle, scroll_callback)
}

update_cursor :: proc() {
    cursor_scroll = {0, 0}
}
