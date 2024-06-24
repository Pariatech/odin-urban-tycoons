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

pos: glsl.vec3
origin_pos: Maybe(glsl.vec3)
origin_orientation: furniture.Rotation

original: furniture.Furniture
orientation: furniture.Rotation = .North
cursor_pos: glsl.vec3

DEFAULT_ORIENTATION :: furniture.Rotation.North

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
	remove_cursor(orientation)
	state = .Idle
}

update :: proc() {
	previous_pos := pos
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	switch state {
	case .Idle:
		idle()
	case .Moving:
		move(previous_pos)
	case .Rotating:
		rotate()
	}
}

idle :: proc() {
	tile_pos := get_tile_pos(pos)
	if mouse.is_button_press(.Left) {
		if furn, ok := furniture.get(tile_pos); ok {
			origin_orientation = furn.rotation
			origin_pos = pos
			change_state(.Rotating)
		}
	}
}

rotate :: proc() {
	if origin_pos, ok := origin_pos.?; ok {
		tile_pos := get_tile_pos(origin_pos)
		furniture.remove(tile_pos)

		dx := pos.x - origin_pos.x
		dz := pos.z - origin_pos.z

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
			furniture.add(tile_pos, type, origin_orientation)

			change_state(.Idle)
			return
		}

		furniture.add(tile_pos, type, orientation)

		if mouse.is_button_release(.Left) {
            log.info(previous_state)
			if previous_state == .Moving {
				change_state(.Idle)
			} else if previous_state == .Idle {
				if pos == origin_pos {
					change_state(.Moving)
				} else {
					change_state(.Idle)
				}
			}
		}
	}

}

move :: proc(previous_pos: glsl.vec3) {
	previous_tile_pos := get_tile_pos(previous_pos)
	furniture.remove(previous_tile_pos)

	if keyboard.is_key_press(.Key_Escape) {
		if pos, ok := origin_pos.?; ok {
			tile_pos := get_tile_pos(pos)
			furniture.add(tile_pos, type, orientation)
		}

		change_state(.Idle)
		return
	}

	tile_pos := get_tile_pos(pos)
	furniture.add(tile_pos, type, orientation)

	if mouse.is_button_press(.Left) {
		origin_pos = pos
		origin_orientation = orientation
		change_state(.Rotating)
	}
}

change_state :: proc(new_state: State) {
	previous_state = state
	state = new_state
}

remove_cursor :: proc(orientation: furniture.Rotation) {
	it := furniture.make_child_iterator(type, orientation)
	for child in furniture.next_child(&it) {
		translate := furniture.get_translate(orientation, child.x, child.z)
		billboard.billboard_1x1_remove(
			{pos = cursor_pos + translate, type = .Cursor},
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
	state = .Moving
    previous_state = .Idle
	orientation = DEFAULT_ORIENTATION
	origin_pos = nil
}
