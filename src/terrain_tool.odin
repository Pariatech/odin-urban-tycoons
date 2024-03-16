package main

import "core:fmt"
import "core:math/linalg/glsl"

terrain_tool_billboard: int

terrain_tool_init :: proc() {
	terrain_tool_billboard = append_billboard(
		 {
			position = {0.0, 0.0, 0.0},
			light = {1, 1, 1},
			texture = .Shovel_SW,
			depth_map = .Shovel_SW,
			rotation = 0,
		},
	)
}

terrain_tool_tile_cursor :: proc(
	tri: Tile_Triangle,
	side: Tile_Triangle_Side,
	lights: [3]glsl.vec3,
	heights: [3]f32,
	pos: glsl.vec2,
	size: f32,
) {
    fmt.println("tri pos:", pos)
}

terrain_tool_update :: proc() {
	terrain_on_visible(terrain_tool_tile_cursor)
}
