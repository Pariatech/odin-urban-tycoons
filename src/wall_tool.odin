package main

import "core:math"
import "core:math/linalg/glsl"

wall_tool_billboard: Billboard_Key
wall_tool_position: glsl.ivec2

wall_tool_init :: proc() {
	wall_tool_billboard = { type = .Wall_Cursor }
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

wall_tool_update :: proc() {
	cursor_on_tile_intersect(wall_tool_on_tile_intersect)
}
