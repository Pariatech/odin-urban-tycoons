package furniture_tool

import "core:math"
import "core:math/linalg/glsl"

import "../../cursor"
import "../../floor"
import "../../furniture"
import "../../terrain"

state: State
type: furniture.Type
pos: glsl.vec3

State :: enum {
	Idle,
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

	switch state {
	case .Idle:
		return
	case .Moving:
		move_furniture(previous_pos)
	case .Rotating:
		rotating_furniture()
	}
}

move_furniture :: proc(previous_pos: glsl.vec3) {
	if pos == previous_pos {
		return
	}

	// previous_pos := glsl.vec3 {
	// 	math.floor(previous_pos.x + 0.5),
	// 	terrain.get_tile_height(
	// 		int(previous_pos.x + 0.5),
	// 		int(previous_pos.z + 0.5),
	// 	),
	// 	math.floor(previous_pos.z + 0.5),
	// }
	furniture.remove(previous_pos)

	new_pos := glsl.vec3 {
		math.floor(pos.x + 0.5),
		terrain.get_tile_height(int(pos.x + 0.5), int(pos.z + 0.5)),
		math.floor(pos.z + 0.5),
	}

    if furniture.has(new_pos) {
        pos.y += 0.1
	    furniture.add(pos, type, .South, {1, 0.5, 0.5})
    } else {
	    furniture.add(new_pos, type, .South)
        pos = new_pos
    }
}

rotating_furniture :: proc() {

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
