package main

import "core:fmt"
import "core:runtime"
import "core:time"
import gl "vendor:OpenGL"
import "vendor:glfw"

WIDTH :: 1600
HEIGHT :: 900
TITLE :: "My Window!"

window_handle: glfw.WindowHandle
framebuffer_resized: bool

framebuffer_size_callback :: proc "c" (
	window: glfw.WindowHandle,
	width, height: i32,
) {
	context = runtime.default_context()

	fmt.println("Window resized")
	framebuffer_resized = true
}

main :: proc() {
	fmt.println("Hellope!")

	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load.")
		return
	}

	window_handle = glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)

	defer glfw.DestroyWindow(window_handle)
	defer glfw.Terminate()

	if window_handle == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	glfw.SetFramebufferSizeCallback(window_handle, framebuffer_size_callback)

	glfw.MakeContextCurrent(window_handle)
	glfw.SwapInterval(0)

	if (!init_renderer()) do return
	defer deinit_renderer()
	init_keyboard()
    init_cursor()

    load_wall_door_models()
    load_wall_window_mesh()
    load_table_models()
    load_chair_models()
    init_terrain()
	init_world()

	should_close := false
	current_time_ns := time.now()
	previous_time_ns := time.now()
    fps_stopwatch: time.Stopwatch
    time.stopwatch_start(&fps_stopwatch)
	delta_time: f64
	frames: i64 = 0
	for !should_close {
		previous_time_ns = current_time_ns
		current_time_ns = time.now()
		diff := time.diff(previous_time_ns, current_time_ns)
		delta_time = time.duration_seconds(diff)
		if time.stopwatch_duration(fps_stopwatch) >= time.Second {
			fmt.println("FPS:", frames)
			frames = 0
            time.stopwatch_reset(&fps_stopwatch)
            time.stopwatch_start(&fps_stopwatch)
		}

		glfw.PollEvents()

		begin_draw()

		update_camera(delta_time)

		draw_world()

		end_draw()

		should_close =
			bool(glfw.WindowShouldClose(window_handle)) ||
			is_key_down(.Key_Escape)

		update_keyboard()
        update_cursor()

		frames += 1
	}
}
