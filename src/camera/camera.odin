package camera

import "core:math"
import "core:log"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "vendor:glfw"

import "../keyboard"
import "../utils"
import "../window"
import "../mouse"

SPEED :: 8.0
ZOOM_SPEED :: 0.05
ZOOM_MAX :: 2
ZOOM_MIN :: 0.5

ANGLE :: (math.RAD_PER_DEG * 30)

zoom: f32 = 1
position: glsl.vec3
rotation: Rotation
distance := f32(20)
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
	translate *= glsl.vec3{-1, 1, 1}
	translate.zx = translate.xz
	rotation = Rotation((int(rotation) + 3) % 4)
}

rotate_clockwise :: proc() {
	translate *= glsl.vec3{1, 1, -1}
	translate.zx = translate.xz
	rotation = Rotation((int(rotation) + 1) % 4)
}

update :: proc(delta_time: f64) {
	zoom -= mouse.get_scroll().y * ZOOM_SPEED
	zoom = math.clamp(zoom, ZOOM_MIN, ZOOM_MAX)
    fixed_zoom := math.pow(2, math.round(math.log2(zoom)))

	width, height := glfw.GetWindowSize(window.handle)

	movement := glsl.vec3 {
		f32(SPEED * delta_time) * (fixed_zoom + 1),
		0,
		f32(SPEED * delta_time) * (fixed_zoom + 1),
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

    // position.x = math.floor(position.x * 512) / 512
    // position.y = math.floor(position.y * 512) / 512
    // position.z = math.floor(position.z * 512) / 512
    // log.info(position)

	view = glsl.mat4LookAt(position + translate, position, {0, 1, 0})
	aspect_ratio := f32(height) / f32(width)
	scale := f32(width) / (math.pow(f32(2.8284), 5) / fixed_zoom)
    scale *= window.scale.y

	left = scale
	right = -scale
	bottom = -aspect_ratio * scale
	top = aspect_ratio * scale

	proj = glsl.mat4Ortho3d(left, right, bottom, top, 0.1, 100.0)

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
