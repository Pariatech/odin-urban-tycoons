package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"

wall_tool_billboard: Billboard_Key
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
	billboard_1x1_set(
		wall_tool_billboard,
		{light = {1, 1, 1}, texture = .Wall_Cursor, depth_map = .Wall_Cursor},
	)
	cursor_intersect_with_tiles(wall_tool_on_tile_intersect)
}

wall_tool_deinit :: proc() {
	billboard_1x1_remove(wall_tool_billboard)
}

wall_tool_on_tile_intersect :: proc(intersect: glsl.vec3) {
	wall_tool_position.x = i32(math.ceil(intersect.x))
	wall_tool_position.y = i32(math.ceil(intersect.z))
	position := intersect
	position.x = math.ceil(position.x)
	position.z = math.ceil(position.z)
	position.y = terrain_heights[wall_tool_position.x][wall_tool_position.y]
	billboard_1x1_move(&wall_tool_billboard, position)
}

wall_tool_diagonal_update :: proc(
	south_west_north_east_fn: proc(_: glsl.ivec3),
	north_west_south_east_fn: proc(_: glsl.ivec3),
) -> bool {
	l := max(
		abs(wall_tool_position.x - wall_tool_drag_start.x),
		abs(wall_tool_position.y - wall_tool_drag_start.y),
	)
	if abs(wall_tool_position.y - wall_tool_drag_start.y) <= l / 2 ||
	   abs(wall_tool_position.x - wall_tool_drag_start.x) <= l / 2 {
		return false
	}

	start_x := min(wall_tool_position.x, wall_tool_drag_start.x)
	end_x := max(wall_tool_position.x, wall_tool_drag_start.x)
	floor: i32 = 0
	z := wall_tool_drag_start.y

	if (wall_tool_position.x >= wall_tool_drag_start.x &&
		   wall_tool_position.y >= wall_tool_drag_start.y) ||
	   (wall_tool_position.x < wall_tool_drag_start.x &&
			   wall_tool_position.y < wall_tool_drag_start.y) {

		dz: i32 = 0
		if wall_tool_position.x < wall_tool_drag_start.x {
			dz = start_x - end_x
		}
		for x, i in start_x ..< end_x {
			south_west_north_east_fn({x, floor, z + i32(i) + dz})
		}
	} else {
		dz: i32 = -1
		if wall_tool_position.x < wall_tool_drag_start.x {
			dz = end_x - start_x - 1
		}

		for x, i in start_x ..< end_x {
			north_west_south_east_fn({x, floor, z - i32(i) + dz})
		}
	}

	fmt.println("south west north east")

	return true
}

wall_tool_north_west_south_east_update :: proc(
	fn: proc(_: glsl.ivec3),
) -> bool {

	l := max(
		abs(wall_tool_position.x - wall_tool_drag_start.x),
		abs(wall_tool_position.y - wall_tool_drag_start.y),
	)
	if abs(wall_tool_position.y - wall_tool_drag_start.y) <= l / 2 ||
	   abs(wall_tool_position.x - wall_tool_drag_start.x) <= l / 2 {
		return false
	}

	// if abs(
	// 	   wall_tool_drag_start.y -
	// 	   (wall_tool_position.x - wall_tool_drag_start.x) / 2 -
	// 	   wall_tool_position.y,
	//    ) >=
	//    abs(wall_tool_position.y - wall_tool_drag_start.y) {
	// 	return false
	// }

	start_x := min(wall_tool_position.x, wall_tool_drag_start.x)
	end_x := max(wall_tool_position.x, wall_tool_drag_start.x)
	floor: i32 = 0
	z := wall_tool_drag_start.y
	dz: i32 = -1
	if wall_tool_position.x < wall_tool_drag_start.x {
		dz = end_x - start_x - 1
	}
	for x, i in start_x ..< end_x {
		fn({x, floor, z - i32(i) + dz})
	}

	fmt.println("north west south east")

	return true
}

wall_tool_east_west_update :: proc(fn: proc(_: glsl.ivec3)) -> bool {
	if abs(wall_tool_position.x - wall_tool_drag_start.x) <
	   abs(wall_tool_position.y - wall_tool_drag_start.y) {
		return false
	}

	start_x := min(wall_tool_position.x, wall_tool_drag_start.x)
	end_x := max(wall_tool_position.x, wall_tool_drag_start.x)
	z := wall_tool_drag_start.y
	floor: i32 = 0
	for x in start_x ..< end_x {
		fn({x, floor, z})
	}

	fmt.println("east west")

	return true
}

wall_tool_north_south_update :: proc(fn: proc(_: glsl.ivec3)) -> bool {
	start_z := min(wall_tool_position.y, wall_tool_drag_start.y)
	end_z := max(wall_tool_position.y, wall_tool_drag_start.y)
	x := wall_tool_drag_start.x
	floor: i32 = 0
	for z in start_z ..< end_z {
		fn({x, floor, z})
	}

	fmt.println("north south")

	return true
}

wall_tool_update :: proc() {
	if mouse_is_button_down(.Left) {
		_ =
			wall_tool_diagonal_update(
				world_remove_south_west_north_east_wall,
				world_remove_north_west_south_east_wall,
			) ||
			wall_tool_east_west_update(world_remove_east_west_wall) ||
			wall_tool_north_south_update(world_remove_north_south_wall)
	}

	cursor_on_tile_intersect(wall_tool_on_tile_intersect)

	if mouse_is_button_press(.Left) {
		wall_tool_drag_start = wall_tool_position
	} else if mouse_is_button_down(.Left) {
		_ = wall_tool_diagonal_update(proc(pos: glsl.ivec3) {
				world_set_south_west_north_east_wall(
					pos,
					 {
						type = .Side_Side,
						textures = {.Inside = .Brick, .Outside = .Brick},
					},
				)
			}, proc(pos: glsl.ivec3) {
				world_set_north_west_south_east_wall(
					pos,
					 {
						type = .Side_Side,
						textures = {.Inside = .Brick, .Outside = .Brick},
					},
				)
			}) || wall_tool_east_west_update(proc(pos: glsl.ivec3) {
					world_set_east_west_wall(
						pos,
						 {
							type = .Side_Side,
							textures = {.Inside = .Brick, .Outside = .Brick},
						},
					)
				}) || wall_tool_north_south_update(proc(pos: glsl.ivec3) {
					world_set_north_south_wall(
						pos,
						 {
							type = .Side_Side,
							textures = {.Inside = .Brick, .Outside = .Brick},
						},
					)
				})
	} else {
	}
}
