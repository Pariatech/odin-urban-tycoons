package window

import "core:log"
import "core:math/linalg/glsl"

import "vendor:glfw"

WIDTH :: 1280
HEIGHT :: 720

handle: glfw.WindowHandle
size := glsl.vec2{WIDTH, HEIGHT}
scale: glsl.vec2

init :: proc(title: cstring) -> (ok: bool = true) {
	if !bool(glfw.Init()) {
		log.fatal("GLFW has failed to load.")
		return false
	}

	glfw.WindowHint(glfw.SAMPLES, 4)
	handle = glfw.CreateWindow(WIDTH, HEIGHT, title, nil, nil)

	scale.x, scale.y = glfw.GetWindowContentScale(handle)
	dpi: glsl.vec2
	dpi.x, dpi.y = glfw.GetMonitorContentScale(glfw.GetPrimaryMonitor())
	log.debug("Window scale:", scale)
	log.debug("Screen scale:", dpi)

    // glfw.GetFramebufferSize()

	return
}

deinit :: proc() {
	defer glfw.DestroyWindow(handle)
	defer glfw.Terminate()
}
