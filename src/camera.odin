package main

import "vendor:glfw"

zoom: f32 = 8.0

look_at :: proc(eye, target, up: Vec3) -> Mat4 {
	f := normalize(target - eye)
	r := normalize(cross(up, f))
	u := cross(f, r)

	view := Mat4{}

	view[0] = {r.x, u.x, -f.x, 0}
	view[1] = {r.y, u.y, -f.y, 0}
	view[2] = {r.z, u.z, -f.z, 0}
	view[3] = {-dot(r, eye), -dot(u, eye), dot(f, eye), 1}

	return view
}

ortho :: proc(left, right, bottom, top, near, far: f32) -> Mat4 {
	proj := Mat4{}

	proj[0] = {2 / (right - left), 0, 0, -(right + left) / (right - left)}
	proj[1] = {0, 2 / (top - bottom), 0, -(top + bottom) / (top - bottom)}
	proj[2] = {0, 0, -2 / (far - near), -(far + near) / (far - near)}
	proj[3] = {0, 0, 0, 1}

	return proj
}

update_camera :: proc() {
	uniform_object.view = look_at({-3, 3, -3}, {0, 0, 0}, {0, 1, 0})
	width, height := glfw.GetWindowSize(window_handle)
	aspect_ratio := f32(height) / f32(width)
	scale := f32(width) / TEXTURE_SIZE
	uniform_object.proj = ortho(
		-1 / zoom * scale,
		1 / zoom * scale,
		-aspect_ratio / zoom * scale,
		aspect_ratio / zoom * scale,
		0.1,
		100.0,
	)
}
