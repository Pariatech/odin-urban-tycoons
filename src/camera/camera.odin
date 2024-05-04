package camera

import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "vendor:glfw"

import "../window"
import "../keyboard"
import "../utils"

SPEED :: 8.0
ZOOM_SPEED :: 0.05
ZOOM_MAX :: 2
ZOOM_MIN :: 1

ANGLE :: (math.RAD_PER_DEG * 30)

zoom: f32 = 1
position: glsl.vec3
rotation: Rotation
distance := f32(30)
translate := glsl.vec3 {
	-distance,
	math.sqrt(math.pow(distance, 2) * 2) * math.tan_f32(ANGLE),
	-distance,
}
view: glsl.mat4
proj: glsl.mat4

view_proj: glsl.mat4
inverse_view_proj: glsl.mat4
left: f32
right: f32
top: f32
bottom: f32

scroll: glsl.vec2

Rotation :: enum {
	South_West,
	South_East,
	North_East,
	North_West,
}

Rotated :: enum {
    Clockwise,
    Counter_Clockwise,
}

update :: proc(delta_time: f64, on_rotated: proc(Rotated)) {
	zoom -= scroll.y * ZOOM_SPEED
	zoom = math.clamp(zoom, ZOOM_MIN, ZOOM_MAX)

	width, height := glfw.GetWindowSize(window.handle)

	movement := glsl.vec3 {
		f32(SPEED * delta_time) * (zoom + 1),
		0,
		f32(SPEED * delta_time) * (zoom + 1),
	}

	if keyboard.is_key_press(.Key_Q) {
		translate *= glsl.vec3{-1, 1, 1}
		translate.zx = translate.xz
		rotation = Rotation((int(rotation) + 3) % 4)
        on_rotated(.Counter_Clockwise)
	} else if keyboard.is_key_press(.Key_E) {
		translate *= glsl.vec3{1, 1, -1}
		translate.zx = translate.xz
		rotation = Rotation((int(rotation) + 1) % 4)
        on_rotated(.Clockwise)
	}

	movement *= translate / distance

	if keyboard.is_key_down(.Key_W) {
		position += glsl.vec3{-movement.x, 0, -movement.z}
	} else if keyboard.is_key_down(.Key_S) {
		position += glsl.vec3{movement.x, 0, movement.z}
	}

	if keyboard.is_key_down(.Key_A) {
		position += glsl.vec3{movement.z, 0, -movement.x}
	} else if keyboard.is_key_down(.Key_D) {
		position += glsl.vec3{-movement.z, 0, movement.x}
	}

	view = glsl.mat4LookAt(
		position + translate,
		position,
		{0, 1, 0},
	)
	aspect_ratio := f32(height) / f32(width)
	scale := f32(width) / (176.775 / zoom)

	left = scale
	right = -scale
	bottom = -aspect_ratio * scale
	top = aspect_ratio * scale

	proj = glsl.mat4Ortho3d(
		left,
		right,
	 	bottom,
		top,
		0.1,
		100.0,
	)

	view_proj = proj * view
    inverse_view_proj = linalg.inverse(view_proj)
}

get_view_corner :: proc(screen_point: glsl.vec2) -> glsl.vec2 {
	p1 :=
		linalg.inverse(view_proj) *
		glsl.vec4{screen_point.x, screen_point.y, -1, 1}
	p2 :=
		linalg.inverse(view_proj) *
		glsl.vec4{screen_point.x, screen_point.y, 1, 1}
	t := -p1.y / (p2.y - p1.y)
	return glsl.vec2{p1.x + t * (p2.x - p1.x), p1.z + t * (p2.z - p1.z)}
}

get_aabb :: proc() -> utils.Rectangle {
	bottom_left := get_view_corner({-1, -1})
	top_left := get_view_corner({-1, 1})
	bottom_right := get_view_corner({1, -1})
	top_right := get_view_corner({1, 1})
	camera := position + translate

	aabb: utils.Rectangle
	switch rotation {
	case .South_West:
		camera.x = bottom_left.x
		camera.z = bottom_right.y
		width := top_right.x - camera.x
		height := top_left.y - camera.z

		aabb = utils.Rectangle {
				x = i32(camera.x),
				y = i32(camera.z),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .South_East:
		camera.x = bottom_right.x
		camera.z = bottom_left.y
		width := camera.x - top_left.x
		height := top_right.y - camera.z

		aabb = utils.Rectangle {
				x = i32(top_left.x),
				y = i32(camera.z),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .North_East:
		camera.x = bottom_left.x
		camera.z = bottom_right.y
		width := camera.x - top_right.x
		height := camera.z - top_left.y

		aabb = utils.Rectangle {
				x = i32(top_right.x),
				y = i32(top_left.y),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .North_West:
		camera.x = bottom_right.x
		camera.z = bottom_left.y
		width := top_left.x - camera.x
		height := camera.z - top_right.y

		aabb = utils.Rectangle {
				x = i32(camera.x),
				y = i32(top_right.y),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	}

	return aabb
}
