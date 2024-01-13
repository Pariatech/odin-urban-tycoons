package main

import "core:fmt"
import "core:runtime"
import gl "vendor:OpenGL"
import "vendor:glfw"

WIDTH :: 1600
HEIGHT :: 900
TITLE :: "My Window!"

window_handle: glfw.WindowHandle
framebuffer_resized: bool

framebuffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
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

	should_close := false
	for !should_close {
		glfw.PollEvents()


		if is_key_press(.Key_F) {
			fmt.println("F in the chat!")
		}

		begin_draw()

		uniform_object.view[0] = {1, 0, 0, 0}
		uniform_object.view[1] = {0, 1, 0, 0}
		uniform_object.view[2] = {0, 0, 1, 0}
		uniform_object.view[3] = {0, 0, 0, 1}

		uniform_object.proj[0] = {1, 0, 0, 0}
		uniform_object.proj[1] = {0, 1, 0, 0}
		uniform_object.proj[2] = {0, 0, 1, 0}
		uniform_object.proj[3] = {0, 0, 0, 1}

		// draw_triangle(
		// 	{pos = {-0.5, -0.5, 0.0}, light = {1.0, 1.0, 1.0}, texcoords = {0.0, 0.0, f32(Sprites.Grass), 0.0}},
		// 	{pos = {0.5, -0.5, 0.0}, light = {1.0, 1.0, 1.0}, texcoords = {1.0, 0.0, f32(Sprites.Grass), 0.0}},
		// 	{pos = {0.0, 0.5, 0.0}, light = {1.0, 1.0, 1.0}, texcoords = {0.5, 1.0, f32(Sprites.Grass), 0.0}},
		// )

        draw_quad(
			{pos = {-0.5, -0.5, 0.0}, light = {1.0, 1.0, 1.0}, texcoords = {0.0, 0.0, f32(Sprites.Grass), 0.0}},
			{pos = {0.5, -0.5, 0.0}, light = {1.0, 1.0, 1.0}, texcoords = {1.0, 0.0, f32(Sprites.Grass), 0.0}},
			{pos = {0.5, 0.5, 0.0}, light = {1.0, 1.0, 1.0}, texcoords = {1.0, 1.0, f32(Sprites.Grass), 0.0}},
			{pos = {-0.5, 0.5, 0.0}, light = {1.0, 1.0, 1.0}, texcoords = {0.0, 1.0, f32(Sprites.Grass), 0.0}},
        )

		end_draw()

		should_close = bool(glfw.WindowShouldClose(window_handle)) || is_key_down(.Key_Escape)

		update_keyboard()
	}
}
