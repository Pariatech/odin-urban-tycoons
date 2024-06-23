package furniture_tool

import "core:math"
import "core:math/linalg/glsl"
import "core:log"

import "../../billboard"
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

DEFAULT_ORIENTATION :: furniture.Rotation.North

State :: enum {
	Idle,
	Placing,
	Moving,
	Rotating,
}

init :: proc() {
	cursor.intersect_with_tiles(on_intersect, floor.floor)
}

deinit :: proc() {

}

update :: proc() {
	previous_pos := pos
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	if keyboard.is_key_press(.Key_Escape) {
		if state == .Placing {
			furniture.remove(previous_pos)
		} else if previous_state == .Placing && state == .Rotating {
			furniture.remove(tile_pos(origin_pos))
		} else if previous_state == .Idle && state == .Rotating {
			furniture.add(
				tile_pos(origin_pos),
				original.type,
				original.rotation,
				original.light,
			)
		}
		state = .Idle
	}

	switch state {
	case .Idle:
		idle()
	case .Placing:
		placing_furniture(previous_pos)
	case .Moving:
		move_furniture(previous_pos)
	case .Rotating:
		rotating_furniture()
	}
}

idle :: proc() {
	tile_pos := tile_pos(pos)
	if mouse.is_button_press(.Left) {
		if furn, ok := furniture.get(tile_pos); ok {
			previous_state = state
			state = .Rotating
			origin_pos = pos
			original = furn
		}
	}
}

placing_furniture :: proc(previous_pos: glsl.vec3) {
	if pos == previous_pos {
		return
	}

	previous_tile_pos := tile_pos(previous_pos)
	tile_pos := tile_pos(pos)

	it := furniture.make_child_iterator(type, orientation)
	for child in furniture.next_child(&it) {
		translate := furniture.get_translate(orientation, child.x, child.z)
        log.info(previous_tile_pos + translate)
		billboard.billboard_1x1_remove(
			{pos = previous_tile_pos + translate, type = .Cursor},
		)
	}

    update_orientation()

	it = furniture.make_child_iterator(type, orientation)
	for child in furniture.next_child(&it) {
		translate := furniture.get_translate(orientation, child.x, child.z)
		billboard.billboard_1x1_set(
			{pos = tile_pos + translate, type = .Cursor},
			 {
				light = {1, 1, 1},
				texture = child.texture,
				depth_map = child.texture,
			},
		)
	}

	// furniture.remove(previous_pos)

	// if furniture.can_place(tile_pos, type, DEFAULT_ORIENTATION) {
	// 	furniture.add(tile_pos, type, DEFAULT_ORIENTATION)
	// 	if mouse.is_button_press(.Left) {
	// 		previous_state = state
	// 		state = .Rotating
	// 		origin_pos = pos
	// 	} else {
	// 		pos = tile_pos
	// 	}
	//
	// } else {
	// 	pos.y += 0.1
	// 	furniture.add(pos, type, DEFAULT_ORIENTATION, {1, 0.5, 0.5})
	// }
}

move_furniture :: proc(previous_pos: glsl.vec3) {
	if pos == previous_pos {
		return
	}
}

update_orientation :: proc() {
	if mouse.is_button_up(.Left) {
		return
	}

	if mouse.is_button_press(.Left) {
		origin_pos = pos
		return
	}

	dx := pos.x - origin_pos.x
	dz := pos.z - origin_pos.z

	if math.abs(dx) > math.abs(dz) {
		if dx >= 0 {
			orientation = .East
		} else {
			orientation = .West
		}
	} else {
		if dz >= 0 {
			orientation = .North
		} else {
			orientation = .South
		}
	}
}

rotating_furniture :: proc() {
	if mouse.is_button_release(.Left) {
		if previous_state == .Placing {
			pos.y += 0.1
			furniture.add(pos, type, DEFAULT_ORIENTATION, {1, 0.5, 0.5})
			state = .Placing
		} else {
			state = .Idle
		}
		return
	}

	dx := pos.x - origin_pos.x
	dz := pos.z - origin_pos.z

	tile_pos := tile_pos(origin_pos)

	furniture.remove(pos)
	if math.abs(dx) > math.abs(dz) {
		if dx >= 0 {
			if furniture.can_place(tile_pos, type, .East) {
				furniture.add(tile_pos, type, .East)
			} else {
				furniture.add(tile_pos, type, .East, {1, 0.5, 0.5})
			}
		} else {
			if furniture.can_place(tile_pos, type, .West) {
				furniture.add(tile_pos, type, .West)
			} else {
				furniture.add(tile_pos, type, .West, {1, 0.5, 0.5})
			}
		}
	} else {
		if dz >= 0 {
			if furniture.can_place(tile_pos, type, .North) {
				furniture.add(tile_pos, type, .North)
			} else {
				furniture.add(tile_pos, type, .North, {1, 0.5, 0.5})
			}
		} else {
			if furniture.can_place(tile_pos, type, .South) {
				furniture.add(tile_pos, type, .South)
			} else {
				furniture.add(tile_pos, type, .South, {1, 0.5, 0.5})
			}
		}
	}
}

tile_pos :: proc(pos: glsl.vec3) -> glsl.vec3 {
	return(
		 {
			math.floor(pos.x + 0.5),
			terrain.get_tile_height(int(pos.x + 0.5), int(pos.z + 0.5)),
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
