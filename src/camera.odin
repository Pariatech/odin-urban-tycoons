package main

import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "vendor:glfw"

CAMERA_SPEED :: 8.0
CAMERA_ZOOM_SPEED :: 0.05
CAMERA_ZOOM_MAX :: 2
CAMERA_ZOOM_MIN :: 1

CAMERA_ANGLE :: (math.RAD_PER_DEG * 30)

camera_zoom: f32 = 1
camera_position: glsl.vec3
camera_rotation: Camera_Rotation
camera_distance := f32(30)
camera_translate := glsl.vec3 {
	-camera_distance,
	math.sqrt(math.pow(camera_distance, 2) * 2) * math.tan_f32(CAMERA_ANGLE),
	-camera_distance,
}
camera_view: glsl.mat4
camera_proj: glsl.mat4

camera_vp: glsl.mat4
icamera_vp: glsl.mat4
camera_left: f32
camera_right: f32
camera_top: f32
camera_bottom: f32

Camera_Rotation :: enum {
	South_West,
	South_East,
	North_East,
	North_West,
}

Camera_Rotated :: enum {
    Clockwise,
    Counter_Clockwise,
}

update_camera :: proc(delta_time: f64) {
	camera_zoom -= cursor_scroll.y * CAMERA_ZOOM_SPEED
	camera_zoom = math.clamp(camera_zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX)

	width, height := glfw.GetWindowSize(window_handle)
	// camera_distance = width 

	camera_movement := glsl.vec3 {
		f32(CAMERA_SPEED * delta_time) * (camera_zoom + 1),
		0,
		f32(CAMERA_SPEED * delta_time) * (camera_zoom + 1),
	}

	if is_key_press(.Key_Q) {
		camera_translate *= glsl.vec3{-1, 1, 1}
		camera_translate.zx = camera_translate.xz
		camera_rotation = Camera_Rotation((int(camera_rotation) + 3) % 4)
        world_update_after_rotation(.Counter_Clockwise)
	} else if is_key_press(.Key_E) {
		camera_translate *= glsl.vec3{1, 1, -1}
		camera_translate.zx = camera_translate.xz
		camera_rotation = Camera_Rotation((int(camera_rotation) + 1) % 4)
        world_update_after_rotation(.Clockwise)
	}

	camera_movement *= camera_translate / camera_distance

	if is_key_down(.Key_W) {
		camera_position += glsl.vec3{-camera_movement.x, 0, -camera_movement.z}
	} else if is_key_down(.Key_S) {
		camera_position += glsl.vec3{camera_movement.x, 0, camera_movement.z}
	}

	if is_key_down(.Key_A) {
		camera_position += glsl.vec3{camera_movement.z, 0, -camera_movement.x}
	} else if is_key_down(.Key_D) {
		camera_position += glsl.vec3{-camera_movement.z, 0, camera_movement.x}
	}

	camera_view = glsl.mat4LookAt(
		camera_position + camera_translate,
		camera_position,
		{0, 1, 0},
	)
	aspect_ratio := f32(height) / f32(width)
	// scale := f32(width) / (128 / camera_zoom) / 1.4142
	// scale := f32(width) / (128 / camera_zoom)
	scale := f32(width) / (176.775 / camera_zoom)
	// scale := f32(width) / (128 / camera_zoom)

	camera_left = scale
	camera_right = -scale
	camera_bottom = -aspect_ratio * scale
	camera_top = aspect_ratio * scale

	camera_proj = glsl.mat4Ortho3d(
		camera_left,
		camera_right,
	 	camera_bottom,
		camera_top,
		0.1,
		100.0,
	)

	camera_vp = camera_proj * camera_view
    icamera_vp = linalg.inverse(camera_vp)
}

get_view_corner :: proc(screen_point: glsl.vec2) -> glsl.vec2 {
	p1 :=
		linalg.inverse(camera_vp) *
		glsl.vec4{screen_point.x, screen_point.y, -1, 1}
	p2 :=
		linalg.inverse(camera_vp) *
		glsl.vec4{screen_point.x, screen_point.y, 1, 1}
	t := -p1.y / (p2.y - p1.y)
	return glsl.vec2{p1.x + t * (p2.x - p1.x), p1.z + t * (p2.z - p1.z)}
}

get_camera_aabb :: proc() -> Rectangle {
	bottom_left := get_view_corner({-1, -1})
	top_left := get_view_corner({-1, 1})
	bottom_right := get_view_corner({1, -1})
	top_right := get_view_corner({1, 1})
	camera := camera_position + camera_translate

	aabb: Rectangle
	switch camera_rotation {
	case .South_West:
		// camera.x = math.min(camera.x, bottom_left.x)
		// camera.z = math.min(camera.z, bottom_right.y)
		camera.x = bottom_left.x
		camera.z = bottom_right.y
		width := top_right.x - camera.x
		height := top_left.y - camera.z

		aabb = Rectangle {
				x = i32(camera.x),
				y = i32(camera.z),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .South_East:
		// camera.x = math.max(camera.x, bottom_right.x)
		// camera.z = math.min(camera.z, bottom_left.y)
		camera.x = bottom_right.x
		camera.z = bottom_left.y
		width := camera.x - top_left.x
		height := top_right.y - camera.z

		aabb = Rectangle {
				x = i32(top_left.x),
				y = i32(camera.z),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .North_East:
		// camera.x = math.max(camera.x, bottom_left.x)
		// camera.z = math.max(camera.z, bottom_right.y)
		camera.x = bottom_left.x
		camera.z = bottom_right.y
		width := camera.x - top_right.x
		height := camera.z - top_left.y

		aabb = Rectangle {
				x = i32(top_right.x),
				y = i32(top_left.y),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .North_West:
		// camera.x = math.min(camera.x, bottom_right.x)
		// camera.z = math.max(camera.z, bottom_left.y)
		camera.x = bottom_right.x
		camera.z = bottom_left.y
		width := top_left.x - camera.x
		height := camera.z - top_right.y

		aabb = Rectangle {
				x = i32(camera.x),
				y = i32(top_right.y),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	}

	return aabb
}
