package main

import "core:fmt"
import "core:math/linalg/glsl"
import "core:runtime"
import "core:time"
import "vendor:glfw"

import "window"
import "keyboard"
import "mouse"
import "camera"
import "cursor"
import "terrain"
import "billboard"
import "wall"
import "floor"
import "tools/terrain_tool"
import "tools"

TITLE :: "My Window!"

framebuffer_resized: bool
delta_time: f64

framebuffer_size_callback :: proc "c" (
	_: glfw.WindowHandle,
	width, height: i32,
) {
	context = runtime.default_context()

	framebuffer_resized = true
	window.size.x = f32(width)
	window.size.y = f32(height)
}

start :: proc() -> (ok: bool = false) {
	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load.")
		return
	}

	glfw.WindowHint(glfw.SAMPLES, 4)
	window.handle = glfw.CreateWindow(window.WIDTH, window.HEIGHT, TITLE, nil, nil)

	defer glfw.DestroyWindow(window.handle)
	defer glfw.Terminate()

	if window.handle == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	glfw.SetFramebufferSizeCallback(window.handle, framebuffer_size_callback)

	glfw.MakeContextCurrent(window.handle)
	glfw.SwapInterval(0)

	if (!init_renderer()) do return
	defer deinit_renderer()

	wall.init_wall_renderer() or_return

	keyboard.init()
    mouse.init()
	cursor.init()

	billboard.init_draw_contexts() or_return
	terrain.init_terrain()
	init_world()

    gui_init() or_return

	terrain_tool.init()

	should_close := false
	current_time_ns := time.now()
	previous_time_ns := time.now()
	fps_stopwatch: time.Stopwatch
	time.stopwatch_start(&fps_stopwatch)
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
		camera.update(delta_time, world_update_after_rotation)
        world_update()
        floor.update()

        tools.update(delta_time)

		draw_world()

        gui_draw()

		end_draw()


		should_close =
			bool(glfw.WindowShouldClose(window.handle)) ||
			keyboard.is_key_down(.Key_Escape)

		keyboard.update()
        mouse.update()
		cursor.update()

		frames += 1
	}

	return true
}

main :: proc() {
	start()
}
