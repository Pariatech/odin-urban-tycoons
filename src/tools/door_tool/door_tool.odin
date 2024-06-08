package door_tool

import "core:log"
import "core:math"
import "core:math/linalg/glsl"

import "../../billboard"
import "../../cursor"
import "../../floor"
import "../../terrain"
import "../../tile"
import "../../wall"
import "../../mouse"

door_billboard: Maybe(billboard.Key)
position: glsl.vec3
side: tile.Tile_Triangle_Side

bound_wall: Maybe(glsl.ivec3)
bound_wall_axis: wall.Wall_Axis

init :: proc() {
	cursor.intersect_with_tiles(on_intersect, floor.floor)
}

deinit :: proc() {
	if key, ok := door_billboard.?; ok {
		billboard.billboard_1x1_remove(key)
		door_billboard = nil
	}
}

update :: proc() {
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	if key, ok := &door_billboard.?; ok {
		revert_bound_wall()
		if !bind_to_wall(key) {
			billboard.billboard_1x1_set_texture(key^, .Door_Wood_SW)
			billboard.billboard_1x1_move(key, position)
			billboard.billboard_1x1_set_light(key^, {1, .5, .5})
	        bound_wall = nil
		} else if mouse.is_button_press(.Left) {
		    door_billboard = nil
	        bound_wall = nil
        }
	} else {
		new_key := billboard.Key {
			pos  = position,
			type = .Door,
		}

		billboard.billboard_1x1_set(
			new_key,
			 {
				light = {1, 0.5, 0.5},
				texture = .Door_Wood_SW,
				depth_map = .Door_Wood_SW,
			},
		)

		door_billboard = new_key
	}
}

on_intersect :: proc(intersect: glsl.vec3) {
	position = intersect

	x := intersect.x - math.floor(intersect.x + 0.5)
	z := intersect.z - math.floor(intersect.z + 0.5)

	if x >= z && x <= -z {
		side = .South
	} else if z >= -x && z <= x {
		side = .East
	} else if x >= -z && x <= z {
		side = .North
	} else {
		side = .West
	}
}

revert_bound_wall :: proc() {
	if pos, ok := bound_wall.?; ok {
		w, _ := wall.get_wall(pos, bound_wall_axis)
		w.mask = .Full_Mask
		wall.set_wall(pos, bound_wall_axis, w)
	}
}

bind_to_wall :: proc(key: ^billboard.Key) -> bool {
	pos := glsl.ivec3 {
		i32(position.x + 0.5),
		floor.floor,
		i32(position.z + 0.5),
	}
	switch side {
	case .South:
		if w, ok := wall.get_east_west_wall(pos); ok {
			fpos := glsl.vec3 {
				f32(pos.x),
				terrain.get_tile_height(int(pos.x), int(pos.z)),
				f32(pos.z),
			}
			if (bound_wall == nil && billboard.has_billboard_1x1({pos = fpos, type = .Door})) ||
			   billboard.has_billboard_1x1({pos = fpos, type = .Window}) {
				return false
			}

			bound_wall = pos
			bound_wall_axis = .E_W

			billboard.billboard_1x1_move(key, fpos)
			billboard.billboard_1x1_set_texture(key^, .Door_Wood_SW)
			billboard.billboard_1x1_set_light(key^, {1, 1, 1})

			w := w
			w.mask = .Door_Opening
			wall.set_east_west_wall(pos, w)

			return true
		}
	case .East:
		pos += {1, 0, 0}
		if w, ok := wall.get_north_south_wall(pos); ok {
			fpos := glsl.vec3 {
				f32(pos.x),
				terrain.get_tile_height(int(pos.x), int(pos.z)),
				f32(pos.z),
			}
			if (bound_wall == nil && billboard.has_billboard_1x1({pos = fpos, type = .Door})) ||
			   billboard.has_billboard_1x1({pos = fpos, type = .Window}) {
				return false
			}

			bound_wall = pos
			bound_wall_axis = .N_S

			billboard.billboard_1x1_move(key, fpos)
			billboard.billboard_1x1_set_texture(key^, .Door_Wood_SE)
			billboard.billboard_1x1_set_light(key^, {1, 1, 1})

			w := w
			w.mask = .Door_Opening
			wall.set_north_south_wall(pos, w)

			return true
		}
	case .North:
		pos += {0, 0, 1}
		if w, ok := wall.get_east_west_wall(pos); ok {
			fpos := glsl.vec3 {
				f32(pos.x),
				terrain.get_tile_height(int(pos.x), int(pos.z)),
				f32(pos.z),
			}
			if (bound_wall == nil && billboard.has_billboard_1x1({pos = fpos, type = .Door})) ||
			   billboard.has_billboard_1x1({pos = fpos, type = .Window}) {
				return false
			}

			bound_wall = pos
			bound_wall_axis = .E_W

			billboard.billboard_1x1_move(key, fpos)
			billboard.billboard_1x1_set_texture(key^, .Door_Wood_SW)
			billboard.billboard_1x1_set_light(key^, {1, 1, 1})

			w := w
			w.mask = .Door_Opening
			wall.set_east_west_wall(pos, w)

			return true
		}
	case .West:
		if w, ok := wall.get_north_south_wall(pos); ok {
			fpos := glsl.vec3 {
				f32(pos.x),
				terrain.get_tile_height(int(pos.x), int(pos.z)),
				f32(pos.z),
			}
			if (bound_wall == nil && billboard.has_billboard_1x1({pos = fpos, type = .Door})) ||
			   billboard.has_billboard_1x1({pos = fpos, type = .Window}) {
				return false
			}

			bound_wall = pos
			bound_wall_axis = .N_S

			billboard.billboard_1x1_move(key, fpos)
			billboard.billboard_1x1_set_texture(key^, .Door_Wood_SE)
			billboard.billboard_1x1_set_light(key^, {1, 1, 1})

			w := w
			w.mask = .Door_Opening
			wall.set_north_south_wall(pos, w)

			return true
		}
	}

	return false
}
