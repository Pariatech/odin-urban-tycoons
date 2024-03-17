package main

import "core:fmt"
import "core:math/linalg/glsl"
import "core:math"

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
    // fmt.println("tri pos:", pos)
    triangle : [3]glsl.vec3

	vertices := tile_triangle_side_vertices_map[side]
	for vertex, i in vertices {
        triangle[i] = vertex.pos
        triangle[i] *= size
        triangle[i].x += pos.x
        triangle[i].z += pos.y
		triangle[i].y += heights[i]
	}

    intersect, ok := cursor_ray_intersect_triangle(triangle).?
    if ok {
        position := intersect
        position.x = math.ceil(position.x) - 0.5
        position.z = math.ceil(position.z) - 0.5
        position.y = terrain_heights[int(position.x + 0.5)][int(position.z + 0.5)]
        move_billboard(terrain_tool_billboard, position)
        // billboard_system.instances[terrain_tool_billboard].position = position
    }
}

terrain_tool_update :: proc() {
	tile_on_visible(0, terrain_tool_tile_cursor)
}
