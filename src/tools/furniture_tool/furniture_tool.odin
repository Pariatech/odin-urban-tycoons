package furniture_tool

import "core:log"
import "core:math"
import "core:math/linalg/glsl"

import "../../billboard"
import "../../constants"
import "../../cursor"
import "../../floor"
import "../../furniture"
import "../../keyboard"
import "../../mouse"
import "../../terrain"

state: State
previous_state: State
type: furniture.Type

previous_pos: glsl.vec3
pos: glsl.vec3

rotate_pos: glsl.vec3
original: Maybe(Original)

Original :: struct {
	pos:       glsl.vec3,
	furniture: furniture.Furniture,
}

orientation: furniture.Rotation = .North
cursor_pos: glsl.vec3

DEFAULT_ORIENTATION :: furniture.Rotation.North
ERROR_LIGHT :: glsl.vec3{1, 0.5, 0.5}

State :: enum {
	Idle,
	Rotating,
	Moving,
}

init :: proc() {
	cursor.intersect_with_tiles(on_intersect, floor.floor)

	floor.show_markers = true
}

deinit :: proc() {
	// remove_cursor(pos, orientation)
	state = .Idle
}

update :: proc() {
	previous_pos = pos
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	switch state {
	case .Idle:
		idle()
	case .Moving:
		move()
	case .Rotating:
		rotate()
	}
}

idle :: proc() {
	tile_pos := get_tile_pos(pos)
	if mouse.is_button_press(.Left) {
		if furn, ok := furniture.get(tile_pos); ok {
			original = Original {
				pos       = tile_pos,
				furniture = furn,
			}
			rotate_pos = pos
			furniture.remove(tile_pos)
			change_state(.Rotating)
		}
	}
}

add_back_original :: proc() {
	if original, ok := original.?; ok {
		furniture.add(
			original.pos,
			original.furniture.type,
			original.furniture.rotation,
		)
	}
	original = nil
}

rotate :: proc() {
	remove_cursor()

	dx := pos.x - rotate_pos.x
	dz := pos.z - rotate_pos.z

	if math.abs(dx) > math.abs(dz) {
		if dx == 0 {
		} else if dx > 0 {
			orientation = .East
		} else {
			orientation = .West
		}
	} else {
		if dz == 0 {
		} else if dz > 0 {
			orientation = .North
		} else {
			orientation = .South
		}
	}

	if keyboard.is_key_press(.Key_Escape) {
		add_back_original()

		change_state(.Idle)
		return
	}


	if mouse.is_button_release(.Left) {
		if previous_state == .Moving {
			tile_pos := get_tile_pos(rotate_pos)
			if furniture.can_place(tile_pos, type, orientation) {
				furniture.add(tile_pos, type, orientation)
				change_state(.Idle)
			} else {
				change_state(.Moving)
			}
		} else if previous_state == .Idle {
			if move_from_rotate() {
				change_state(.Moving)
			} else {
				tile_pos := get_tile_pos(rotate_pos)
				if furniture.can_place(tile_pos, type, orientation) {
					furniture.add(tile_pos, type, orientation)
					change_state(.Idle)
				}
			}
		}
		return
	}

	add_cursor()
}

move_from_rotate :: proc() -> bool {
    return glsl.length(pos - rotate_pos) <= 0.1
}

move :: proc() {
	remove_cursor()

	if keyboard.is_key_press(.Key_Escape) {
		add_back_original()

		change_state(.Idle)
		return
	}

	add_cursor()

	if mouse.is_button_press(.Left) {
		rotate_pos = pos
		change_state(.Rotating)
	}
}

change_state :: proc(new_state: State) {
	previous_state = state
	state = new_state

	// tile_pos := get_tile_pos(pos)
	//    furniture.remove(tile_pos)
}

remove_cursor :: proc() {
	previous_pos := previous_pos
	if state == .Rotating {
		previous_pos = rotate_pos
	}
	previous_tile_pos := get_tile_pos(previous_pos)

	cursor_pos := previous_pos
	if furniture.can_place(previous_tile_pos, type, orientation) {
		cursor_pos = previous_tile_pos
	}

	it := furniture.make_child_iterator(type, orientation)
	for child in furniture.next_child(&it) {
		translate := furniture.get_translate(orientation, child.x, child.z)
		billboard.billboard_1x1_remove(
			{pos = cursor_pos + translate, type = .Cursor},
		)
	}
}

add_cursor :: proc() {
	pos := pos
	if state == .Rotating {
		pos = rotate_pos
	}
	tile_pos := get_tile_pos(pos)

	cursor_pos := pos
	light: glsl.vec3 = {1, 1, 1}
	if furniture.can_place(tile_pos, type, orientation) {
		cursor_pos = tile_pos
	} else {
		light = {1, 0.5, 0.5}
	}

	it := furniture.make_child_iterator(type, orientation)
	for child in furniture.next_child(&it) {
		translate := furniture.get_translate(orientation, child.x, child.z)
		billboard.billboard_1x1_set(
			{pos = cursor_pos + translate, type = .Cursor},
			 {
				texture = child.texture,
				depth_map = child.texture,
				light = light,
			},
		)
	}
}

get_tile_pos :: proc(pos: glsl.vec3) -> glsl.vec3 {
	return(
		 {
			math.floor(pos.x + 0.5),
			floor.height_at(pos),
			math.floor(pos.z + 0.5),
		} \
	)
}

on_intersect :: proc(intersect: glsl.vec3) {
	pos = intersect
}

place_furniture :: proc(i: furniture.Type) {
	type = i
	state = .Idle
	orientation = DEFAULT_ORIENTATION
	original = nil

	change_state(.Moving)
}
