package window

import "core:math/linalg/glsl"
import "vendor:glfw"

WIDTH :: 1920
HEIGHT :: 1080

handle: glfw.WindowHandle
size := glsl.vec2{WIDTH, HEIGHT}
