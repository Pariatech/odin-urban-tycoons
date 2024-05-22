package window

import "core:math/linalg/glsl"
import "vendor:glfw"

WIDTH :: 1280
HEIGHT :: 720

handle: glfw.WindowHandle
size := glsl.vec2{WIDTH, HEIGHT}
