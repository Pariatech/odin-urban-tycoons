package camera

import "core:log"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "vendor:glfw"

import "../keyboard"
import "../mouse"
import "../utils"
import "../window"

SPEED :: 8.0
ZOOM_SPEED :: 0.05
ZOOM_MAX :: 2
ZOOM_MIN :: 0.5

ANGLE :: f64(math.RAD_PER_DEG * 30)

zoom: f64 = 1
position: glsl.dvec3
rotation: Rotation
distance := f64(40)
translate := glsl.dvec3 {
	-distance,
	math.sqrt(math.pow(distance, 2) * 2) * math.tan(ANGLE),
	-distance,
}
view: glsl.mat4
proj: glsl.mat4
dview: glsl.dmat4
dproj: glsl.dmat4

view_proj: glsl.mat4
inverse_view_proj: glsl.mat4
dview_proj: glsl.dmat4
dinverse_view_proj: glsl.dmat4
left: f64
right: f64
top: f64
bottom: f64

visible_chunks_start: glsl.ivec2
visible_chunks_end: glsl.ivec2

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

rotate_counter_clockwise :: proc() {
	translate *= glsl.dvec3{-1, 1, 1}
	translate.zx = translate.xz
	rotation = Rotation((int(rotation) + 3) % 4)
}

rotate_clockwise :: proc() {
	translate *= glsl.dvec3{1, 1, -1}
	translate.zx = translate.xz
	rotation = Rotation((int(rotation) + 1) % 4)
}

update :: proc(delta_time: f64) {
	zoom -= mouse.get_scroll().y * ZOOM_SPEED
	zoom = math.clamp(zoom, ZOOM_MIN, ZOOM_MAX)
	// fixed_zoom := math.pow(2, math.round(math.log2(zoom)))

	width, height := glfw.GetWindowSize(window.handle)

	movement := glsl.dvec3 {
		SPEED * delta_time * (zoom + 1),
		0,
		SPEED * delta_time * (zoom + 1),
	}

	movement *= translate / distance

	if keyboard.is_key_down(.Key_W) {
		position += glsl.dvec3{-movement.x, 0, -movement.z}
	} else if keyboard.is_key_down(.Key_S) {
		position += glsl.dvec3{movement.x, 0, movement.z}
	}

	if keyboard.is_key_down(.Key_A) {
		position += glsl.dvec3{movement.z, 0, -movement.x}
	} else if keyboard.is_key_down(.Key_D) {
		position += glsl.dvec3{-movement.z, 0, movement.x}
	}

	// position.x = math.floor(position.x * 512) / 512
	// position.y = math.floor(position.y * 512) / 512
	// position.z = math.floor(position.z * 512) / 512
	// log.info(position)

	dview = glsl.dmat4LookAt(position + translate, position, {0, 1, 0})
	aspect_ratio := f64(height) / f64(width)
	scale := f64(width) / (math.pow(f64(2.8284), 5) / zoom)
	scale *= f64(window.scale.y)

	left = scale
	right = -scale
	bottom = -aspect_ratio * scale
	top = aspect_ratio * scale

	dproj = glsl.dmat4Ortho3d(left, right, bottom, top, 0.1, 120.0)

	dview_proj = dproj * dview
	dinverse_view_proj = linalg.inverse(dview_proj)

    view = linalg.matrix_cast(dview, f32)
    proj = linalg.matrix_cast(dproj, f32)
    view_proj = linalg.matrix_cast(dview_proj, f32)
    inverse_view_proj = linalg.matrix_cast(dinverse_view_proj, f32)
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
	dcamera := position + translate
	camera := glsl.vec3{f32(dcamera.x), f32(dcamera.y), f32(dcamera.z)}

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

Visible_Chunk_Iterator :: struct {
	pos:  glsl.ivec2,
	next: proc(it: ^Visible_Chunk_Iterator) -> (glsl.ivec2, bool),
}

next_visible_chunk_south_west :: proc(
	it: ^Visible_Chunk_Iterator,
) -> (
	glsl.ivec2,
	bool,
) {
	if it.pos.x < visible_chunks_start.x {
		it.pos.x = visible_chunks_end.x - 1
		it.pos.y -= 1
	}

	if it.pos.y < visible_chunks_start.y {
		return {}, false
	}

	pos := it.pos
	it.pos.x -= 1
	return pos, true
}

next_visible_chunk_south_east :: proc(
	it: ^Visible_Chunk_Iterator,
) -> (
	glsl.ivec2,
	bool,
) {
	if it.pos.x >= visible_chunks_end.x {
		it.pos.x = visible_chunks_start.x
		it.pos.y -= 1
	}

	if it.pos.y < visible_chunks_start.y {
		return {}, false
	}

	pos := it.pos
	it.pos.x += 1
	if pos.y == 8 {
		log.fatal("Eille le Y est pas bon!")
	}
	return pos, true
}

next_visible_chunk_north_east :: proc(
	it: ^Visible_Chunk_Iterator,
) -> (
	glsl.ivec2,
	bool,
) {
	if it.pos.x >= visible_chunks_end.x {
		it.pos.x = visible_chunks_start.x
		it.pos.y += 1
	}

	if it.pos.y >= visible_chunks_end.y {
		return {}, false
	}

	pos := it.pos
	it.pos.x += 1
	return pos, true
}

next_visible_chunk_north_west :: proc(
	it: ^Visible_Chunk_Iterator,
) -> (
	glsl.ivec2,
	bool,
) {
	if it.pos.x < visible_chunks_start.x {
		it.pos.x = visible_chunks_end.x - 1
		it.pos.y += 1
	}

	if it.pos.y >= visible_chunks_end.y {
		return {}, false
	}

	pos := it.pos
	it.pos.x -= 1
	return pos, true
}

make_visible_chunk_iterator :: proc() -> Visible_Chunk_Iterator {
	it: Visible_Chunk_Iterator
	switch rotation {
	case .South_West:
		it.pos = visible_chunks_end - {1, 1}
		it.next = next_visible_chunk_south_west
	case .South_East:
		it.pos.x = visible_chunks_start.x
		it.pos.y = visible_chunks_end.y - 1
		it.next = next_visible_chunk_south_east
	case .North_East:
		it.pos = visible_chunks_start
		it.next = next_visible_chunk_north_east
	case .North_West:
		it.pos.x = visible_chunks_end.x - 1
		it.pos.y = visible_chunks_start.y
		it.next = next_visible_chunk_north_west
	}
	return it
}
