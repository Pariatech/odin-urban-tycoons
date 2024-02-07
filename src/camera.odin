package main

import "core:math"
import m "core:math/linalg/glsl"
import "vendor:glfw"

CAMERA_SPEED :: 4.0
CAMERA_ZOOM_SPEED :: 0.05
CAMERA_ZOOM_MAX :: 2
CAMERA_ZOOM_MIN :: 0

camera_zoom: f32 = 0
camera_position: m.vec3
camera_rotation: Camera_Rotation
camera_distance := f32(20)
camera_translate := m.vec3{-camera_distance, camera_distance, -camera_distance}
camera_view: m.mat4
camera_proj: m.mat4

camera_vp: m.mat4
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

update_camera :: proc(delta_time: f64) {
	zoom_scale := math.pow(2, camera_zoom)
	camera_movement := m.vec3 {
		f32(CAMERA_SPEED * delta_time) * (camera_zoom + 1),
		0,
		f32(CAMERA_SPEED * delta_time) * (camera_zoom + 1),
	}

	if is_key_press(.Key_Q) {
		camera_translate *= m.vec3{-1, 1, 1}
		camera_translate.zx = camera_translate.xz
		camera_rotation = Camera_Rotation((int(camera_rotation) + 3) % 4)
        rotate_world()
	} else if is_key_press(.Key_E) {
		camera_translate *= m.vec3{1, 1, -1}
		camera_translate.zx = camera_translate.xz
		camera_rotation = Camera_Rotation((int(camera_rotation) + 1) % 4)
        rotate_world()
	}

	camera_movement *= camera_translate / camera_distance

	if is_key_down(.Key_W) {
		camera_position += m.vec3{-camera_movement.x, 0, -camera_movement.z}
	} else if is_key_down(.Key_S) {
		camera_position += m.vec3{camera_movement.x, 0, camera_movement.z}
	}

	if is_key_down(.Key_A) {
		camera_position += m.vec3{camera_movement.z, 0, -camera_movement.x}
	} else if is_key_down(.Key_D) {
		camera_position += m.vec3{-camera_movement.z, 0, camera_movement.x}
	}

	camera_zoom -= cursor_scroll.y * CAMERA_ZOOM_SPEED
	camera_zoom = math.clamp(camera_zoom, CAMERA_ZOOM_MIN, CAMERA_ZOOM_MAX)

	camera_view = m.mat4LookAt(
		camera_position + camera_translate,
		camera_position,
		{0, 1, 0},
	)
	width, height := glfw.GetWindowSize(window_handle)
	aspect_ratio := f32(height) / f32(width)
	scale := f32(width) / TEXTURE_SIZE
	zoom := 1 / zoom_scale

    camera_left = 1 / zoom * scale
    camera_right = -1 / zoom * scale
    camera_bottom = -aspect_ratio / zoom * scale
    camera_top = aspect_ratio / zoom * scale

	camera_proj = m.mat4Ortho3d(
		camera_left,
		camera_right,
		camera_bottom,
		camera_top,
		0.1,
		100.0,
	)

    camera_vp = camera_proj * camera_view 
}
