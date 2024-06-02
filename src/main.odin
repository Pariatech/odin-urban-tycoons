package main

import "core:fmt"
import "core:log"
import "core:math/linalg/glsl"
import "base:runtime"
import "core:time"
import "vendor:glfw"

import "billboard"
import "camera"
import "cursor"
import "floor"
import "keyboard"
import "mouse"
import "renderer"
import "terrain"
import "tools"
import "tools/floor_tool"
import "tools/terrain_tool"
import "ui"
import "wall"
import "window"
import "world"

TITLE :: "My Window!"

delta_time: f64

ui_ctx: ui.Context

framebuffer_size_callback :: proc "c" (
	_: glfw.WindowHandle,
	width, height: i32,
) {
	context = runtime.default_context()

	renderer.framebuffer_resized = true
	window.size.x = f32(width)
	window.size.y = f32(height)
}

start :: proc() -> (ok: bool = false) {
	context.logger = log.create_console_logger()

	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load.")
		return
	}

	glfw.WindowHint(glfw.SAMPLES, 4)
	window.handle = glfw.CreateWindow(
		window.WIDTH,
		window.HEIGHT,
		TITLE,
		nil,
		nil,
	)

	defer glfw.DestroyWindow(window.handle)
	defer glfw.Terminate()

	if window.handle == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	glfw.SetFramebufferSizeCallback(window.handle, framebuffer_size_callback)

	glfw.MakeContextCurrent(window.handle)
	when ODIN_DEBUG {
		glfw.SwapInterval(0)
	}

	if (!renderer.init()) do return
	defer renderer.deinit()

	wall.init_wall_renderer() or_return

	keyboard.init()
	mouse.init()
	cursor.init()

	billboard.init_draw_contexts() or_return
	terrain.init_terrain()
	world.init()

	ui.init(&ui_ctx) or_return

	floor_tool.init()
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


		renderer.begin_draw()

		floor.update()
		ui.update(&ui_ctx)

		if keyboard.is_key_press(.Key_Q) {
			camera.rotate_counter_clockwise()
			world.update_after_rotation(.Counter_Clockwise)
		} else if keyboard.is_key_press(.Key_E) {
			camera.rotate_clockwise()
			world.update_after_rotation(.Clockwise)
		}
		camera.update(delta_time)

		world.update()

		tools.update(delta_time)

		world.draw()

		ui.draw(&ui_ctx)

		renderer.end_draw()


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
