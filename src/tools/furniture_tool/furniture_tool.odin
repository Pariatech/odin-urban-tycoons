package furniture_tool

import "core:math"
import "core:math/linalg/glsl"

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

	furniture.remove(previous_pos)

	tile_pos := tile_pos(pos)
	if furniture.has(tile_pos) {
		pos.y += 0.1
		furniture.add(pos, type, .South, {1, 0.5, 0.5})
	} else {
		furniture.add(tile_pos, type, .South)
		if mouse.is_button_press(.Left) {
			previous_state = state
			state = .Rotating
			origin_pos = pos
		} else {
			pos = tile_pos
		}
	}
}

move_furniture :: proc(previous_pos: glsl.vec3) {
	if pos == previous_pos {
		return
	}
}

rotating_furniture :: proc() {
	if mouse.is_button_release(.Left) {
		if previous_state == .Placing {
			pos.y += 0.1
			furniture.add(pos, type, .South, {1, 0.5, 0.5})
			state = .Placing
		} else {
			state = .Idle
		}
		return
	}

	dx := pos.x - origin_pos.x
	dz := pos.z - origin_pos.z

	tile_pos := tile_pos(origin_pos)

	if math.abs(dx) > math.abs(dz) {
		if dx > 0 {
			furniture.add(tile_pos, type, .East)
		} else {
			furniture.add(tile_pos, type, .West)
		}
	} else {
		if dz > 0 {
			furniture.add(tile_pos, type, .North)
		} else {
			furniture.add(tile_pos, type, .South)
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
