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
origin_pos: glsl.vec3
original: furniture.Furniture
orientation: furniture.Rotation = .North
cursor_pos: glsl.vec3

DEFAULT_ORIENTATION :: furniture.Rotation.North

State :: enum {
	Idle,
	Placing,
	Moving,
	Rotating,
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
	case .Placing:
		placing_furniture(previous_pos)
	case .Moving:
		moving_furniture(previous_pos)
	case .Rotating:
		rotating_furniture()
	}

	if keyboard.is_key_press(.Key_Escape) {
		if previous_state == .Placing && state == .Rotating {
			furniture.remove(get_tile_pos(origin_pos))
		} else if previous_state == .Idle && state == .Rotating {
			furniture.add(
				get_tile_pos(origin_pos),
				original.type,
				original.rotation,
				original.light,
			)
		}
		state = .Idle
	}
}

idle :: proc() {
	tile_pos := get_tile_pos(pos)
	if mouse.is_button_press(.Left) {
		if furn, ok := furniture.get(tile_pos); ok {
			// start_moving_furniture(furn)
		}
	}
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

placing_furniture :: proc(previous_pos: glsl.vec3) {
	tile_pos := get_tile_pos(pos)
	previous_tile_pos := get_tile_pos(previous_pos)

	if mouse.is_button_down(.Left) {
		previous_tile_pos = get_tile_pos(origin_pos)
	}

	if keyboard.is_key_press(.Key_Escape) {
		remove_cursor(orientation)
		return
	}

	if mouse.is_button_press(.Left) {
		origin_pos = pos
	}

	if mouse.is_button_release(.Left) {
		tile_pos := get_tile_pos(origin_pos)
		if furniture.can_place(tile_pos, type, orientation) {
			remove_cursor(orientation)
			furniture.add(tile_pos, type, orientation)
			return
		}
	}

	previous_orientation := orientation
	update_orientation()

	if previous_orientation == orientation && previous_pos == pos {
		return
	}

	remove_cursor(previous_orientation)

	if mouse.is_button_down(.Left) {
		tile_pos = get_tile_pos(origin_pos)
	}

	light := glsl.vec3{1, 1, 1}
	if !furniture.can_place(tile_pos, type, orientation) {
		if mouse.is_button_down(.Left) {
			tile_pos += {0, 0.1, 0}
		} else {
			tile_pos = pos + {0, 0.1, 0}
		}
		light = {1, 0.5, 0.5}
	}

	cursor_pos = tile_pos

	it := furniture.make_child_iterator(type, orientation)
	for child in furniture.next_child(&it) {
		translate := furniture.get_translate(orientation, child.x, child.z)
		billboard.billboard_1x1_set(
			{pos = tile_pos + translate, type = .Cursor},
			 {
				light = light,
				texture = child.texture,
				depth_map = child.texture,
			},
		)
	}
}

update_orientation :: proc() {
	if mouse.is_button_up(.Left) {
		return
	}

	dx := pos.x - origin_pos.x
	dz := pos.z - origin_pos.z

	// log.info(origin_pos, pos, dx, dz)
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
}

start_moving_furniture :: proc(furn: furniture.Furniture) {
	state = .Moving
	if parent, ok := furn.parent.?; ok {
		origin_pos = parent
	} else {
		origin_pos = pos
	}
	tile_pos := get_tile_pos(origin_pos)
	original = furn
}

moving_furniture :: proc(previous_pos: glsl.vec3) {
	tile_pos := get_tile_pos(pos)
	previous_tile_pos := get_tile_pos(previous_pos)

	if mouse.is_button_down(.Left) {
		previous_tile_pos = get_tile_pos(origin_pos)
	}

	if keyboard.is_key_press(.Key_Escape) {
		state = .Idle
	    tile_pos := get_tile_pos(origin_pos)
		furniture.add(tile_pos, original.type, original.rotation)
		return
	}

	if mouse.is_button_press(.Left) {
		origin_pos = pos
	}

	if mouse.is_button_release(.Left) {
		tile_pos := get_tile_pos(origin_pos)
		if furniture.can_place(tile_pos, type, orientation) {
			furniture.remove(tile_pos)
			furniture.add(tile_pos, type, orientation)
			return
		}
	}

	previous_orientation := orientation
	update_orientation()

	if previous_orientation == orientation && previous_pos == pos {
		return
	}

	remove_cursor(previous_orientation)

	if mouse.is_button_down(.Left) {
		tile_pos = get_tile_pos(origin_pos)
	}

	light := glsl.vec3{1, 1, 1}
	if !furniture.can_place(tile_pos, type, orientation) {
		if mouse.is_button_down(.Left) {
			tile_pos += {0, 0.1, 0}
		} else {
			tile_pos = pos + {0, 0.1, 0}
		}
		light = {1, 0.5, 0.5}
	}

	cursor_pos = tile_pos

	it := furniture.make_child_iterator(type, orientation)
	for child in furniture.next_child(&it) {
		translate := furniture.get_translate(orientation, child.x, child.z)
		billboard.billboard_1x1_set(
			{pos = tile_pos + translate, type = .Cursor},
			 {
				light = light,
				texture = child.texture,
				depth_map = child.texture,
			},
		)
	}
}

start_rotating_furniture :: proc(furn: furniture.Furniture) {
	state = .Rotating
	if parent, ok := furn.parent.?; ok {
		log.info(parent)
		origin_pos = parent
	} else {
		origin_pos = pos
	}
	tile_pos := get_tile_pos(origin_pos)
	original = furn
}

rotating_furniture :: proc() {
	tile_pos := get_tile_pos(origin_pos)

	if mouse.is_button_release(.Left) {
		state = .Idle

		furniture.remove(tile_pos)
		if furniture.can_place(tile_pos, type, orientation) {
			furniture.add(tile_pos, type, orientation)
			return
		}
		furniture.add(tile_pos, original.type, original.rotation)
		return
	}

	previous_orientation := orientation
	update_orientation()

	if previous_orientation != orientation {
		furniture.remove(tile_pos)
		furniture.add(tile_pos, type, orientation)
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
	// pos =  {
	// 	math.floor(intersect.x + 0.5),
	// 	intersect.y,
	// 	math.floor(intersect.z + 0.5),
	// }
	pos = intersect
	//
	// x := intersect.x - math.floor(intersect.x + 0.5)
	// z := intersect.z - math.floor(intersect.z + 0.5)
	//
	// if x >= z && x <= -z {
	// 	side = .South
	// } else if z >= -x && z <= x {
	// 	side = .East
	// } else if x >= -z && x <= z {
	// 	side = .North
	// } else {
	// 	side = .West
	// }
}

place_furniture :: proc(i: furniture.Type) {
	remove_cursor(orientation)

	type = i
	state = .Placing
}
