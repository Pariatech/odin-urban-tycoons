package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "vendor:glfw"

terrain_tool_billboard: int
terrain_tool_position: glsl.ivec2
terrain_tool_tick_timer: f64

TERRAIN_TOOL_TICK_SPEED :: 0.25
TERRAIN_TOOL_MOVEMENT :: 0.1
TERRAIN_TOOL_LOW :: 0
TERRAIN_TOOL_HIGH :: 6

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
) -> bool {
	triangle: [3]glsl.vec3

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
		terrain_tool_position.x = i32(position.x + 0.5)
		terrain_tool_position.y = i32(position.z + 0.5)
		position.y =
			terrain_heights[terrain_tool_position.x][terrain_tool_position.y]
		move_billboard(terrain_tool_billboard, position)

		left_mouse_button := glfw.GetMouseButton(
			window_handle,
			glfw.MOUSE_BUTTON_LEFT,
		)
		right_mouse_button := glfw.GetMouseButton(
			window_handle,
			glfw.MOUSE_BUTTON_RIGHT,
		)
		movement: f32 = 0
		if left_mouse_button == glfw.PRESS {
			movement = TERRAIN_TOOL_MOVEMENT
			terrain_tool_tick_timer += delta_time
		} else if right_mouse_button == glfw.PRESS {
			movement = -TERRAIN_TOOL_MOVEMENT
			terrain_tool_tick_timer += delta_time
		} else if left_mouse_button == glfw.RELEASE &&
		   terrain_tool_tick_timer > 0 {
			terrain_tool_tick_timer = 0
		}

		if terrain_tool_tick_timer == delta_time ||
		   terrain_tool_tick_timer >= TERRAIN_TOOL_TICK_SPEED {
			height :=
				terrain_heights[terrain_tool_position.x][terrain_tool_position.y]
			height += movement

			height = clamp(height, TERRAIN_TOOL_LOW, TERRAIN_TOOL_HIGH)

			set_terrain_height(
				int(terrain_tool_position.x),
				int(terrain_tool_position.y),
				height,
			)

			if terrain_tool_tick_timer >= TERRAIN_TOOL_TICK_SPEED {
				terrain_tool_tick_timer = math.max(
					0,
					terrain_tool_tick_timer - TERRAIN_TOOL_TICK_SPEED,
				)
			}
		}
	}

	return ok
}

terrain_tool_update :: proc() {
	tile_on_visible(0, terrain_tool_tile_cursor)
}
