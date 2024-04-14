package main

import "core:math/linalg/glsl"

wall_tool_billboard: glsl.vec3

wall_tool_init :: proc() {
	billboard_1x1_set(
		wall_tool_billboard,
		{light = {1, 1, 1}, texture = .Wall_Cursor, depth_map = .Wall_Cursor},
	)
}

wall_tool_deinit :: proc() {
    billboard_1x1_remove(wall_tool_billboard)
}

wall_tool_update :: proc() {

}
