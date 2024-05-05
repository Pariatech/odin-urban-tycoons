package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"

import "constants"
import "keyboard"
import "camera"
import "mouse"
import "cursor"
import "terrain"
import "billboard"

wall_tool_billboard: billboard.Key
wall_tool_start_billboard: Maybe(billboard.Key)
wall_tool_position: glsl.ivec2
wall_tool_drag_start: glsl.ivec2
wall_tool_north_south_walls: map[glsl.ivec3]Wall
wall_tool_east_west_walls: map[glsl.ivec3]Wall
wall_tool_south_west_north_east_walls: map[glsl.ivec3]Wall
wall_tool_north_west_south_east_walls: map[glsl.ivec3]Wall

wall_tool_init :: proc() {
	wall_tool_billboard = {
		type = .Wall_Cursor,
	}
	billboard.billboard_1x1_set(
		wall_tool_billboard,
		{light = {1, 1, 1}, texture = .Wall_Cursor, depth_map = .Wall_Cursor},
	)
	cursor.intersect_with_tiles(wall_tool_on_tile_intersect, floor)
	wall_tool_move_cursor()
}

wall_tool_deinit :: proc() {
	billboard.billboard_1x1_remove(wall_tool_billboard)
}

wall_tool_on_tile_intersect :: proc(intersect: glsl.vec3) {
	wall_tool_position.x = i32(math.ceil(intersect.x))
	wall_tool_position.y = i32(math.ceil(intersect.z))
}

wall_tool_update_walls_line :: proc(
	south_west_north_east_fn: proc(_: glsl.ivec3),
	north_west_south_east_fn: proc(_: glsl.ivec3),
	east_west: proc(_: glsl.ivec3),
	north_south: proc(_: glsl.ivec3),
) {
	if wall_tool_is_diagonal() {
		wall_tool_diagonal_update(
			south_west_north_east_fn,
			north_west_south_east_fn,
		)
	} else {
		wall_tool_cardinal_update(east_west, north_south)
	}
}

wall_tool_update_walls_rectangle :: proc(
	east_west: proc(_: glsl.ivec3),
	north_south: proc(_: glsl.ivec3),
) {
	start_x := min(wall_tool_position.x, wall_tool_drag_start.x)
	end_x := max(wall_tool_position.x, wall_tool_drag_start.x)
	start_z := min(wall_tool_position.y, wall_tool_drag_start.y)
	end_z := max(wall_tool_position.y, wall_tool_drag_start.y)

	for z in start_z ..< end_z {
		north_south({start_x, i32(floor), z})
	}

	if start_x != end_x {
		for z in start_z ..< end_z {
			north_south({end_x, i32(floor), z})
		}
	}

	for x in start_x ..< end_x {
		east_west({x, i32(floor), start_z})
	}

	if start_z != end_z {
		for x in start_x ..< end_x {
			east_west({x, i32(floor), end_z})
		}
	}
}

wall_tool_is_diagonal :: proc() -> bool {
	l := max(
		abs(wall_tool_position.x - wall_tool_drag_start.x),
		abs(wall_tool_position.y - wall_tool_drag_start.y),
	)
	return(
		abs(wall_tool_position.y - wall_tool_drag_start.y) > l / 2 &&
		abs(wall_tool_position.x - wall_tool_drag_start.x) > l / 2 \
	)
}

wall_tool_diagonal_update :: proc(
	south_west_north_east_fn: proc(_: glsl.ivec3),
	north_west_south_east_fn: proc(_: glsl.ivec3),
) {
	if (wall_tool_position.x >= wall_tool_drag_start.x &&
		   wall_tool_position.y >= wall_tool_drag_start.y) ||
	   (wall_tool_position.x < wall_tool_drag_start.x &&
			   wall_tool_position.y < wall_tool_drag_start.y) {
		wall_tool_south_west_north_east_update(south_west_north_east_fn)
	} else {
		wall_tool_north_west_south_east_update(north_west_south_east_fn)
	}
}

wall_tool_south_west_north_east_update :: proc(fn: proc(_: glsl.ivec3)) {
	start_x := min(wall_tool_position.x, wall_tool_drag_start.x)
	end_x := max(wall_tool_position.x, wall_tool_drag_start.x)
	z := wall_tool_drag_start.y

	dz: i32 = 0
	if wall_tool_position.x < wall_tool_drag_start.x {
		dz = start_x - end_x
	}
	for x, i in start_x ..< end_x {
		fn({x, i32(floor), z + i32(i) + dz})
	}
}

wall_tool_north_west_south_east_update :: proc(fn: proc(_: glsl.ivec3)) {
	start_x := min(wall_tool_position.x, wall_tool_drag_start.x)
	end_x := max(wall_tool_position.x, wall_tool_drag_start.x)
	z := wall_tool_drag_start.y

	dz: i32 = -1
	if wall_tool_position.x < wall_tool_drag_start.x {
		dz = end_x - start_x - 1
	}

	for x, i in start_x ..< end_x {
		fn({x, i32(floor), z - i32(i) + dz})
	}
}

wall_tool_cardinal_update :: proc(
	east_west: proc(_: glsl.ivec3),
	north_south: proc(_: glsl.ivec3),
) {
	if abs(wall_tool_position.x - wall_tool_drag_start.x) <
	   abs(wall_tool_position.y - wall_tool_drag_start.y) {
		wall_tool_north_south_update(north_south)
	} else {
		wall_tool_east_west_update(east_west)
	}
}

wall_tool_east_west_update :: proc(fn: proc(_: glsl.ivec3)) {
	start_x := min(wall_tool_position.x, wall_tool_drag_start.x)
	end_x := max(wall_tool_position.x, wall_tool_drag_start.x)
	z := wall_tool_drag_start.y
	for x in start_x ..< end_x {
		fn({x, i32(floor), z})
	}
}

wall_tool_north_south_update :: proc(fn: proc(_: glsl.ivec3)) {
	start_z := min(wall_tool_position.y, wall_tool_drag_start.y)
	end_z := max(wall_tool_position.y, wall_tool_drag_start.y)
	x := wall_tool_drag_start.x
	for z in start_z ..< end_z {
		fn({x, i32(floor), z})
	}
}

wall_tool_update_south_west_north_east_neighbors :: proc(pos: glsl.ivec3) {
	wall_tool_update_south_west_north_east_wall(pos + {-1, 0, -1})
	wall_tool_update_south_west_north_east_wall(pos + {1, 0, 1})
	wall_tool_update_north_west_south_east_wall(pos + {0, 0, 1})
	wall_tool_update_north_west_south_east_wall(pos + {0, 0, -1})
	wall_tool_update_north_west_south_east_wall(pos + {-1, 0, 0})
	wall_tool_update_north_west_south_east_wall(pos + {1, 0, 0})
}

wall_tool_update_north_west_south_east_neighbors :: proc(pos: glsl.ivec3) {
	wall_tool_update_north_west_south_east_wall(pos + {-1, 0, 1})
	wall_tool_update_north_west_south_east_wall(pos + {1, 0, -1})
	wall_tool_update_south_west_north_east_wall(pos + {0, 0, 1})
	wall_tool_update_south_west_north_east_wall(pos + {0, 0, -1})
	wall_tool_update_south_west_north_east_wall(pos + {-1, 0, 0})
	wall_tool_update_south_west_north_east_wall(pos + {1, 0, 0})
}

wall_tool_update_east_west_neighbors :: proc(pos: glsl.ivec3) {
	wall_tool_update_east_west_wall(pos + {-1, 0, 0})
	wall_tool_update_east_west_wall(pos + {1, 0, 0})
	wall_tool_update_north_south_wall(pos + {0, 0, -1})
	wall_tool_update_north_south_wall(pos + {0, 0, 1})
	wall_tool_update_north_south_wall(pos + {1, 0, -1})
	wall_tool_update_north_south_wall(pos + {1, 0, 1})
}

wall_tool_update_north_south_neighbors :: proc(pos: glsl.ivec3) {
	wall_tool_update_north_south_wall(pos + {0, 0, -1})
	wall_tool_update_north_south_wall(pos + {0, 0, 1})
	wall_tool_update_east_west_wall(pos + {-1, 0, 0})
	wall_tool_update_east_west_wall(pos + {1, 0, 0})
	wall_tool_update_east_west_wall(pos + {-1, 0, 1})
	wall_tool_update_east_west_wall(pos + {1, 0, 1})
}

wall_tool_update_south_west_north_east_wall_and_neighbors :: proc(
	pos: glsl.ivec3,
) {
	wall_tool_update_south_west_north_east_wall(pos)
	wall_tool_update_south_west_north_east_neighbors(pos)
}

wall_tool_update_north_west_south_east_wall_and_neighbors :: proc(
	pos: glsl.ivec3,
) {
	wall_tool_update_north_west_south_east_wall(pos)
	wall_tool_update_north_west_south_east_neighbors(pos)
}

wall_tool_update_east_west_wall_and_neighbors :: proc(pos: glsl.ivec3) {
	wall_tool_update_east_west_wall(pos)
	wall_tool_update_east_west_neighbors(pos)
}

wall_tool_update_north_south_wall_and_neighbors :: proc(pos: glsl.ivec3) {
	wall_tool_update_north_south_wall(pos)
	wall_tool_update_north_south_neighbors(pos)
}

wall_tool_undo_removing_south_west_north_east_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_south_west_north_east_walls[pos]; ok {
		world_set_south_west_north_east_wall(pos, wall)
		wall_tool_update_south_west_north_east_wall_and_neighbors(pos)
	}
}

wall_tool_undo_removing_north_west_south_east_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_north_west_south_east_walls[pos]; ok {
		world_set_north_west_south_east_wall(pos, wall)
		wall_tool_update_north_west_south_east_wall_and_neighbors(pos)
	}
}

wall_tool_undo_removing_east_west_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_east_west_walls[pos]; ok {
		world_set_east_west_wall(pos, wall)
		wall_tool_update_east_west_wall_and_neighbors(pos)
	}
}

wall_tool_undo_removing_north_south_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_north_south_walls[pos]; ok {
		world_set_north_south_wall(pos, wall)
		wall_tool_update_north_south_wall_and_neighbors(pos)
	}
}

wall_tool_remove_south_west_north_east_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_south_west_north_east_walls[pos]; ok {
		return
	}
	world_remove_south_west_north_east_wall(pos)
	wall_tool_update_south_west_north_east_neighbors(pos)
}

wall_tool_remove_north_west_south_east_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_north_west_south_east_walls[pos]; ok {
		return
	}
	world_remove_north_west_south_east_wall(pos)
	wall_tool_update_north_west_south_east_neighbors(pos)
}

wall_tool_remove_east_west_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_east_west_walls[pos]; ok {
		return
	}
	world_remove_east_west_wall(pos)
	wall_tool_update_east_west_neighbors(pos)
}

wall_tool_remove_north_south_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := wall_tool_north_south_walls[pos]; ok {
		return
	}
	world_remove_north_south_wall(pos)
	wall_tool_update_north_south_neighbors(pos)
}

wall_tool_update_east_west_wall :: proc(pos: glsl.ivec3) {
	if pos.x < 0 || pos.z < 0 || pos.x >= constants.WORLD_WIDTH || pos.z >= constants.WORLD_DEPTH {
		return
	}

	wall, ok := world_get_east_west_wall(pos)
	if !ok {
		return
	}

	left_type_part := Wall_Type_Part.End
	if world_has_east_west_wall(pos + {-1, 0, 0}) {
		left_type_part = .Side
	} else {
		has_left := world_has_north_south_wall(pos + {0, 0, 0})
		// || world_has_north_west_south_east_wall(pos + {-1, 0, 0})
		has_right := world_has_north_south_wall(pos + {0, 0, -1})
		// || world_has_south_west_north_east_wall(pos + {-1, 0, -1})
		if has_left && has_right {
			left_type_part = .Side
		} else if has_left {
			left_type_part = .Left_Corner
		} else if has_right {
			left_type_part = .Right_Corner
		}
	}
	right_type_part := Wall_Type_Part.End
	if world_has_east_west_wall(pos + {1, 0, 0}) {
		right_type_part = .Side
	} else {
		has_left := world_has_north_south_wall(pos + {1, 0, 0})
		has_right := world_has_north_south_wall(pos + {1, 0, -1})

		if has_left && has_right {
			right_type_part = .Side
		} else if has_left {
			right_type_part = .Left_Corner
		} else if has_right {
			right_type_part = .Right_Corner
		}
	}

	type_map := WALL_SIDE_TYPE_MAP
	type := type_map[left_type_part][right_type_part]
	world_set_east_west_wall(pos, {type = type, textures = wall.textures})
}

wall_tool_update_north_south_wall :: proc(pos: glsl.ivec3) {
	if pos.x < 0 || pos.z < 0 || pos.x >= constants.WORLD_WIDTH || pos.z >= constants.WORLD_DEPTH {
		return
	}

	wall, ok := world_get_north_south_wall(pos)
	if !ok {
		return
	}

	left_type_part := Wall_Type_Part.End
	if world_has_north_south_wall(pos + {0, 0, 1}) {
		left_type_part = .Side
	} else {
		has_left := world_has_east_west_wall(pos + {-1, 0, 1})
		has_right := world_has_east_west_wall(pos + {0, 0, 1})
		if has_left && has_right {
			left_type_part = .Side
		} else if has_left {
			left_type_part = .Left_Corner
		} else if has_right {
			left_type_part = .Right_Corner
		}
	}
	right_type_part := Wall_Type_Part.End
	if world_has_north_south_wall(pos + {0, 0, -1}) {
		right_type_part = .Side
	} else {
		has_left := world_has_east_west_wall(pos + {-1, 0, 0})
		has_right := world_has_east_west_wall(pos + {0, 0, 0})

		if has_left && has_right {
			right_type_part = .Side
		} else if has_left {
			right_type_part = .Left_Corner
		} else if has_right {
			right_type_part = .Right_Corner
		}
	}

	type_map := WALL_SIDE_TYPE_MAP
	type := type_map[left_type_part][right_type_part]
	world_set_north_south_wall(pos, {type = type, textures = wall.textures})
}

wall_tool_update_north_west_south_east_wall :: proc(pos: glsl.ivec3) {
	if pos.x < 0 || pos.z < 0 || pos.x >= constants.WORLD_WIDTH || pos.z >= constants.WORLD_DEPTH {
		return
	}

	wall, ok := world_get_north_west_south_east_wall(pos)
	if !ok {
		return
	}

	left_type_part := Wall_Type_Part.End
	if world_has_north_west_south_east_wall(pos + {-1, 0, 1}) {
		left_type_part = .Side
	} else {
		has_left := world_has_south_west_north_east_wall(pos + {0, 0, 1})
		has_right := world_has_south_west_north_east_wall(pos + {-1, 0, 0})
		if has_left && has_right {
			left_type_part = .Side
		} else if has_left {
			left_type_part = .Left_Corner
		} else if has_right {
			left_type_part = .Right_Corner
		}
	}
	right_type_part := Wall_Type_Part.End
	if world_has_north_west_south_east_wall(pos + {1, 0, -1}) {
		right_type_part = .Side
	} else {
		has_left := world_has_south_west_north_east_wall(pos + {1, 0, 0})
		has_right := world_has_south_west_north_east_wall(pos + {0, 0, -1})
		if has_left && has_right {
			right_type_part = .Side
		} else if has_left {
			right_type_part = .Left_Corner
		} else if has_right {
			right_type_part = .Right_Corner
		}
	}

	type_map := WALL_SIDE_TYPE_MAP
	type := type_map[left_type_part][right_type_part]
	world_set_north_west_south_east_wall(
		pos,
		{type = type, textures = wall.textures},
	)
}

wall_tool_update_south_west_north_east_wall :: proc(pos: glsl.ivec3) {
	if pos.x < 0 || pos.z < 0 || pos.x >= constants.WORLD_WIDTH || pos.z >= constants.WORLD_DEPTH {
		return
	}

	wall, ok := world_get_south_west_north_east_wall(pos)
	if !ok {
		return
	}

	left_type_part := Wall_Type_Part.End
	if world_has_south_west_north_east_wall(pos + {-1, 0, -1}) {
		left_type_part = .Side
	} else {
		has_left := world_has_north_west_south_east_wall(pos + {-1, 0, 0})
		has_right := world_has_north_west_south_east_wall(pos + {0, 0, -1})
		if has_left && has_right {
			left_type_part = .Side
		} else if has_left {
			left_type_part = .Left_Corner
		} else if has_right {
			left_type_part = .Right_Corner
		}
	}
	right_type_part := Wall_Type_Part.End
	if world_has_south_west_north_east_wall(pos + {1, 0, 1}) {
		right_type_part = .Side
	} else {
		has_left := world_has_north_west_south_east_wall(pos + {0, 0, 1})
		has_right := world_has_north_west_south_east_wall(pos + {1, 0, 0})
		if has_left && has_right {
			right_type_part = .Side
		} else if has_left {
			right_type_part = .Left_Corner
		} else if has_right {
			right_type_part = .Right_Corner
		}
	}

	type_map := WALL_SIDE_TYPE_MAP
	type := type_map[left_type_part][right_type_part]
	world_set_south_west_north_east_wall(
		pos,
		{type = type, textures = wall.textures},
	)
}

wall_tool_set_south_west_north_east_wall_frame :: proc(pos: glsl.ivec3) {
	wall_tool_set_south_west_north_east_wall(pos, .Frame)
}

wall_tool_set_south_west_north_east_wall_drywall :: proc(pos: glsl.ivec3) {
	wall_tool_set_south_west_north_east_wall(pos, .Brick)
}

wall_tool_set_south_west_north_east_wall :: proc(
	pos: glsl.ivec3,
	texture: Wall_Texture,
) {
	if wall, ok := world_get_south_west_north_east_wall(pos); ok {
		wall_tool_south_west_north_east_walls[pos] = wall
		return
	}

	world_set_south_west_north_east_wall(
		pos,
		 {
			type = .Side_Side,
			textures = {.Inside = texture, .Outside = texture},
		},
	)
	wall_tool_update_south_west_north_east_wall_and_neighbors(pos)
}

wall_tool_set_north_west_south_east_wall_frame :: proc(pos: glsl.ivec3) {
	wall_tool_set_north_west_south_east_wall(pos, .Frame)
}

wall_tool_set_north_west_south_east_wall_drywall :: proc(pos: glsl.ivec3) {
	wall_tool_set_north_west_south_east_wall(pos, .Brick)
}

wall_tool_set_north_west_south_east_wall :: proc(
	pos: glsl.ivec3,
	texture: Wall_Texture,
) {
	if wall, ok := world_get_north_west_south_east_wall(pos); ok {
		wall_tool_north_west_south_east_walls[pos] = wall
		return
	}
	world_set_north_west_south_east_wall(
		pos,
		 {
			type = .Side_Side,
			textures = {.Inside = texture, .Outside = texture},
		},
	)

	wall_tool_update_north_west_south_east_wall_and_neighbors(pos)
}

wall_tool_set_east_west_wall_frame :: proc(pos: glsl.ivec3) {
	wall_tool_set_east_west_wall(pos, .Frame)
}

wall_tool_set_east_west_wall_drywall :: proc(pos: glsl.ivec3) {
	wall_tool_set_east_west_wall(pos, .Brick)
}

wall_tool_set_east_west_wall :: proc(pos: glsl.ivec3, texture: Wall_Texture) {
	if wall, ok := world_get_east_west_wall(pos); ok {
		wall_tool_east_west_walls[pos] = wall
		return
	}
	world_set_east_west_wall(
		pos,
		 {
			type = .Side_Side,
			textures = {.Inside = texture, .Outside = texture},
		},
	)
	wall_tool_update_east_west_wall_and_neighbors(pos)
}

wall_tool_set_north_south_wall_frame :: proc(pos: glsl.ivec3) {
	wall_tool_set_north_south_wall(pos, .Frame)
}

wall_tool_set_north_south_wall_drywall :: proc(pos: glsl.ivec3) {
	wall_tool_set_north_south_wall(pos, .Brick)
}

wall_tool_set_north_south_wall :: proc(
	pos: glsl.ivec3,
	texture: Wall_Texture,
) {
	if wall, ok := world_get_north_south_wall(pos); ok {
		wall_tool_north_south_walls[pos] = wall
		return
	}
	world_set_north_south_wall(
		pos,
		 {
			type = .Side_Side,
			textures = {.Inside = texture, .Outside = texture},
		},
	)
	wall_tool_update_north_south_wall_and_neighbors(pos)
}

wall_tool_removing_south_west_north_east_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := world_get_south_west_north_east_wall(pos); ok {
		wall_tool_south_west_north_east_walls[pos] = wall
		world_remove_south_west_north_east_wall(pos)
		wall_tool_update_south_west_north_east_wall_and_neighbors(pos)
	}
}

wall_tool_removing_north_west_south_east_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := world_get_north_west_south_east_wall(pos); ok {
		wall_tool_north_west_south_east_walls[pos] = wall
		world_remove_north_west_south_east_wall(pos)
		wall_tool_update_north_west_south_east_wall_and_neighbors(pos)
	}
}

wall_tool_removing_east_west_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := world_get_east_west_wall(pos); ok {
		wall_tool_east_west_walls[pos] = wall
		world_remove_east_west_wall(pos)
		wall_tool_update_east_west_wall_and_neighbors(pos)
	}
}

wall_tool_removing_north_south_wall :: proc(pos: glsl.ivec3) {
	if wall, ok := world_get_north_south_wall(pos); ok {
		wall_tool_north_south_walls[pos] = wall
		world_remove_north_south_wall(pos)
		wall_tool_update_north_south_wall_and_neighbors(pos)
	}
}

wall_tool_removing_line :: proc() {
	if mouse.is_button_down(.Left) || mouse.is_button_release(.Left) {
		wall_tool_update_walls_line(
			wall_tool_undo_removing_south_west_north_east_wall,
			wall_tool_undo_removing_north_west_south_east_wall,
			wall_tool_undo_removing_east_west_wall,
			wall_tool_undo_removing_north_south_wall,
		)
	}

	previous_tool_position := wall_tool_position
	cursor.on_tile_intersect(wall_tool_on_tile_intersect, previous_floor, floor)

	if previous_tool_position != wall_tool_position ||
	   previous_floor != floor {
		wall_tool_move_cursor()
	}

	if mouse.is_button_press(.Left) {
		wall_tool_drag_start = wall_tool_position
		clear(&wall_tool_south_west_north_east_walls)
		clear(&wall_tool_north_west_south_east_walls)
		clear(&wall_tool_east_west_walls)
		clear(&wall_tool_north_south_walls)
	} else if mouse.is_button_down(.Left) {
		wall_tool_update_drag_start_billboard({1, 0, 0})
		wall_tool_update_walls_line(
			wall_tool_removing_south_west_north_east_wall,
			wall_tool_removing_north_west_south_east_wall,
			wall_tool_removing_east_west_wall,
			wall_tool_removing_north_south_wall,
		)
	} else if mouse.is_button_release(.Left) {
		wall_tool_update_walls_line(
			wall_tool_removing_south_west_north_east_wall,
			wall_tool_removing_north_west_south_east_wall,
			wall_tool_removing_east_west_wall,
			wall_tool_removing_north_south_wall,
		)
	} else {
		wall_tool_remove_drag_start_billboard()
		wall_tool_drag_start = wall_tool_position
	}

}

wall_tool_adding_line :: proc() {
	if mouse.is_button_down(.Left) || mouse.is_button_release(.Left) {
		wall_tool_update_walls_line(
			wall_tool_remove_south_west_north_east_wall,
			wall_tool_remove_north_west_south_east_wall,
			wall_tool_remove_east_west_wall,
			wall_tool_remove_north_south_wall,
		)
	}

	previous_tool_position := wall_tool_position
	cursor.on_tile_intersect(wall_tool_on_tile_intersect, previous_floor, floor)

	if previous_tool_position != wall_tool_position {
		wall_tool_move_cursor()
	}

	if mouse.is_button_press(.Left) {
		wall_tool_drag_start = wall_tool_position
		clear(&wall_tool_south_west_north_east_walls)
		clear(&wall_tool_north_west_south_east_walls)
		clear(&wall_tool_east_west_walls)
		clear(&wall_tool_north_south_walls)
	} else if mouse.is_button_down(.Left) {
		wall_tool_update_drag_start_billboard({1, 1, 1})
		wall_tool_update_walls_line(
			wall_tool_set_south_west_north_east_wall_frame,
			wall_tool_set_north_west_south_east_wall_frame,
			wall_tool_set_east_west_wall_frame,
			wall_tool_set_north_south_wall_frame,
		)
	} else if mouse.is_button_release(.Left) {
		wall_tool_update_walls_line(
			wall_tool_set_south_west_north_east_wall_drywall,
			wall_tool_set_north_west_south_east_wall_drywall,
			wall_tool_set_east_west_wall_drywall,
			wall_tool_set_north_south_wall_drywall,
		)
	} else {
		wall_tool_remove_drag_start_billboard()
		wall_tool_drag_start = wall_tool_position
	}
}

wall_tool_update_line :: proc() {
	if keyboard.is_key_down(.Key_Left_Control) {
		wall_tool_removing_line()
	} else {
		wall_tool_adding_line()
	}
}

wall_tool_adding_rectangle :: proc() {
	if mouse.is_button_down(.Left) || mouse.is_button_release(.Left) {
		wall_tool_update_walls_rectangle(
			wall_tool_remove_east_west_wall,
			wall_tool_remove_north_south_wall,
		)
	}

	previous_tool_position := wall_tool_position
	cursor.on_tile_intersect(wall_tool_on_tile_intersect, previous_floor, floor)

	if previous_tool_position != wall_tool_position {
		wall_tool_move_cursor()
	}

	if mouse.is_button_press(.Left) {
		wall_tool_drag_start = wall_tool_position
		clear(&wall_tool_south_west_north_east_walls)
		clear(&wall_tool_north_west_south_east_walls)
		clear(&wall_tool_east_west_walls)
		clear(&wall_tool_north_south_walls)
	} else if mouse.is_button_down(.Left) {
		wall_tool_update_drag_start_billboard({1, 1, 1})
		wall_tool_update_walls_rectangle(
			wall_tool_set_east_west_wall_frame,
			wall_tool_set_north_south_wall_frame,
		)
	} else if mouse.is_button_release(.Left) {
		wall_tool_update_walls_rectangle(
			wall_tool_set_east_west_wall_drywall,
			wall_tool_set_north_south_wall_drywall,
		)
	} else {
		wall_tool_remove_drag_start_billboard()
		wall_tool_drag_start = wall_tool_position
	}
}

wall_tool_removing_rectangle :: proc() {
	if mouse.is_button_down(.Left) || mouse.is_button_release(.Left) {
		wall_tool_update_walls_rectangle(
			wall_tool_undo_removing_east_west_wall,
			wall_tool_undo_removing_north_south_wall,
		)
	}

	previous_tool_position := wall_tool_position
	cursor.on_tile_intersect(wall_tool_on_tile_intersect, previous_floor, floor)

	if previous_tool_position != wall_tool_position {
		wall_tool_move_cursor()
	}

	if mouse.is_button_press(.Left) {
		wall_tool_drag_start = wall_tool_position
		clear(&wall_tool_south_west_north_east_walls)
		clear(&wall_tool_north_west_south_east_walls)
		clear(&wall_tool_east_west_walls)
		clear(&wall_tool_north_south_walls)
	} else if mouse.is_button_down(.Left) {
		wall_tool_update_drag_start_billboard({1, 0, 0})
		wall_tool_update_walls_rectangle(
			wall_tool_removing_east_west_wall,
			wall_tool_removing_north_south_wall,
		)
	} else if mouse.is_button_release(.Left) {
		wall_tool_update_walls_rectangle(
			wall_tool_removing_east_west_wall,
			wall_tool_removing_north_south_wall,
		)
	} else {
		wall_tool_remove_drag_start_billboard()
		wall_tool_drag_start = wall_tool_position
	}
}

wall_tool_update_rectangle :: proc() {
	if keyboard.is_key_down(.Key_Left_Control) {
		wall_tool_removing_rectangle()
	} else {
		wall_tool_adding_rectangle()
	}
}

wall_tool_update :: proc() {
	if keyboard.is_key_release(.Key_Left_Control) {
		billboard.billboard_1x1_set(
			wall_tool_billboard,
			 {
				light = {1, 1, 1},
				texture = .Wall_Cursor,
				depth_map = .Wall_Cursor,
			},
		)
	} else if keyboard.is_key_press(.Key_Left_Control) {
		billboard.billboard_1x1_set(
			wall_tool_billboard,
			 {
				light = {1, 0, 0},
				texture = .Wall_Cursor,
				depth_map = .Wall_Cursor,
			},
		)
	}

	if keyboard.is_key_down(.Key_Left_Shift) {
		wall_tool_update_rectangle()
	} else {
		wall_tool_update_line()
	}
}

wall_tool_update_drag_start_billboard :: proc(light: glsl.vec3) {
	if wall_tool_start_billboard == nil &&
	   wall_tool_drag_start != wall_tool_position {
		wall_tool_start_billboard = billboard.Key {
			pos =  {
				f32(wall_tool_drag_start.x),
				terrain.terrain_heights[wall_tool_drag_start.x][wall_tool_drag_start.y] +
				f32(floor) * constants.WALL_HEIGHT,
				f32(wall_tool_drag_start.y),
			},
			type = .Wall_Cursor,
		}
		billboard.billboard_1x1_set(
			wall_tool_start_billboard.?,
			{light = light, texture = .Wall_Cursor, depth_map = .Wall_Cursor},
		)
	} else if wall_tool_start_billboard != nil &&
	   wall_tool_drag_start == wall_tool_position {
		wall_tool_start_billboard = nil
	}
}

wall_tool_remove_drag_start_billboard :: proc() {
	if wall_tool_start_billboard != nil &&
	   wall_tool_drag_start != wall_tool_position {
		billboard.billboard_1x1_remove(wall_tool_start_billboard.?)
		wall_tool_start_billboard = nil
	}
}

wall_tool_move_cursor :: proc() {
	position: glsl.vec3
	position.y = terrain.terrain_heights[wall_tool_position.x][wall_tool_position.y]
	position.y += f32(floor) * constants.WALL_HEIGHT

	switch camera.rotation {
	case .South_West:
		position.x = f32(wall_tool_position.x)
		position.z = f32(wall_tool_position.y)
	case .South_East:
		position.x = f32(wall_tool_position.x - 1)
		position.z = f32(wall_tool_position.y)
	case .North_East:
		position.x = f32(wall_tool_position.x - 1)
		position.z = f32(wall_tool_position.y - 1)
	case .North_West:
		position.x = f32(wall_tool_position.x)
		position.z = f32(wall_tool_position.y - 1)
	}

	billboard.billboard_1x1_move(&wall_tool_billboard, position)
}
