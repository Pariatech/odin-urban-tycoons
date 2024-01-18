package main

import "vendor:glfw"
import m "core:math/linalg/glsl"

CAMERA_SPEED :: 3.0

zoom: f32 = 1.0
camera_position: m.vec3
camera_rotation: Camera_Rotation
camera_distance := f32(10)
camera_translate := m.vec3{-camera_distance, camera_distance, -camera_distance}

Camera_Rotation :: enum {
	South_West,
	South_East,
	North_East,
	North_West,
}

update_camera :: proc(delta_time: f64) {
	camera_movement := m.vec3 {
		f32(CAMERA_SPEED * delta_time),
		0,
		f32(CAMERA_SPEED * delta_time),
	}

	if is_key_press(.Key_Q) {
		camera_translate *= m.vec3{-1, 1, 1}
		camera_translate.zx = camera_translate.xz
        camera_rotation = Camera_Rotation((int(camera_rotation) + 3) % 4)
	} else if is_key_press(.Key_E) {
		camera_translate *= m.vec3{1, 1, -1}
		camera_translate.zx = camera_translate.xz
        camera_rotation = Camera_Rotation((int(camera_rotation) + 1) % 4)
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

	uniform_object.view = m.mat4LookAt(
		camera_position + camera_translate,
		camera_position,
		{0, 1, 0},
	)
	width, height := glfw.GetWindowSize(window_handle)
	aspect_ratio := f32(height) / f32(width)
	scale := f32(width) / TEXTURE_SIZE
	uniform_object.proj = m.mat4Ortho3d(
		1 / zoom * scale,
		-1 / zoom * scale,
		-aspect_ratio / zoom * scale,
		aspect_ratio / zoom * scale,
		0.1,
		100.0,
	)
}
