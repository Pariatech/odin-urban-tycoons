package main

import "base:runtime"
import "core:log"
import "core:math/linalg/glsl"
import "core:os"
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
import "object"
import "game"

TITLE :: "My Window!"

delta_time: f64

ui_ctx: ui.Context

framebuffer_size_callback :: proc "c" (
	_: glfw.WindowHandle,
	width, height: i32,
) {
	context = runtime.default_context()

	// log.debug(glsl.ivec2{width, height})
	// log.debug(glfw.GetWindowSize(handle))

	renderer.framebuffer_resized = true
	// window.size.x = f32(width)
	// window.size.y = f32(height)
}

start :: proc() -> (ok: bool = false) {
    game_state: game.Game
    defer game.free_models(&game_state.models)

	when ODIN_DEBUG {
		context.logger = log.create_console_logger()
		defer log.destroy_console_logger(context.logger)
	} else {
		h, _ := os.open("logs", os.O_WRONLY + os.O_CREATE, os.S_IRUSR + os.S_IWUSR)
		context.logger = log.create_file_logger(h)

		defer log.destroy_file_logger(context.logger)
	}

	window.init(TITLE) or_return
	defer window.deinit()

	if window.handle == nil {
		log.fatal("GLFW has failed to load the window.")
		return
	}

	glfw.SetFramebufferSizeCallback(window.handle, framebuffer_size_callback)

	glfw.MakeContextCurrent(window.handle)
	when ODIN_DEBUG {
		glfw.SwapInterval(0)
	} else {
		glfw.SwapInterval(1)
	}

	if (!renderer.init()) do return
	defer renderer.deinit()

	wall.init_wall_renderer() or_return

	keyboard.init()
	defer keyboard.deinit()
	mouse.init()
	defer mouse.deinit()
	cursor.init()

	billboard.init_draw_contexts() or_return
	terrain.init_terrain()

	world.init()

    object.init() or_return

	ui.init(&ui_ctx) or_return
	defer ui.deinit(&ui_ctx)

	floor_tool.init()
	terrain_tool.init()

	tools.init()
	defer tools.deinit()

	wall.init_cutaways()

    game.load_models(&game_state.models) or_return

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
			log.debug("FPS:", frames)
			frames = 0
			time.stopwatch_reset(&fps_stopwatch)
			time.stopwatch_start(&fps_stopwatch)
		}

		glfw.PollEvents()

		// log.debug("Window:", glfw.GetWindowSize(window.handle))
		// log.debug("Frambuffer:", glfw.GetFramebufferSize(window.handle))

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

		wall.update_cutaways()
		tools.update(delta_time)

        object.draw()
		world.draw(&game_state)

		ui.draw(&ui_ctx)

		renderer.end_draw()


		should_close = bool(glfw.WindowShouldClose(window.handle))
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
