package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "vendor:glfw"

terrain_tool_billboard: int
terrain_tool_position: glsl.ivec2
terrain_tool_tick_timer: f64
terrain_tool_drag_start: Maybe(glsl.ivec2)
terrain_tool_drag_end: Maybe(glsl.ivec2)
terrain_tool_drag_start_billboard: int
terrain_tool_slope: f32 = 0.5

TERRAIN_TOOL_TICK_SPEED :: 0.125
TERRAIN_TOOL_MOVEMENT :: 0.1
TERRAIN_TOOL_LOW :: 0
TERRAIN_TOOL_HIGH :: 6
TERRAIN_TOOL_MIN_SLOPE :: 0.1
TERRAIN_TOOL_MAX_SLOPE :: 1.0

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

terrain_tool_clear_masks :: proc(drag_start: glsl.ivec2) {
	if previous_end, ok := terrain_tool_drag_end.?; ok {
		start_x := min(drag_start.x, previous_end.x)
		start_z := min(drag_start.y, previous_end.y)
		previous_end_x := max(drag_start.x, previous_end.x)
		previous_end_z := max(drag_start.y, previous_end.y)

		for x in start_x ..< previous_end_x {
			for z in start_z ..< previous_end_z {
				tile_update_tile({x, 0, z}, nil, .Grid_Mask)
			}
		}
	}
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
		previous_tool_position := terrain_tool_position
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
		shift_down := is_key_down(.Key_Left_Shift)

		if shift_down {
			if drag_start, ok := terrain_tool_drag_start.?; ok {
				start_x := min(drag_start.x, terrain_tool_position.x)
				start_z := min(drag_start.y, terrain_tool_position.y)
				end_x := max(drag_start.x, terrain_tool_position.x)
				end_z := max(drag_start.y, terrain_tool_position.y)

				if left_mouse_button == glfw.RELEASE {
					height := terrain_heights[drag_start.x][drag_start.y]
					for x in start_x ..= end_x {
						for z in start_z ..= end_z {
							set_terrain_height(int(x), int(z), height)
						}
					}

					// terrain_tool_adjust_points(
					// 	int(start_x - 1),
					// 	int(start_z - 1),
					// 	int(end_x - start_x + 2),
					// 	int(end_z - start_z + 2),
					// )
					terrain_tool_adjust_points_v2(
						int(start_x),
						int(start_z),
						int(end_x - start_x),
						int(end_z - start_z),
					)

					for x in start_x ..= end_x {
						for z in start_z ..= end_z {
							calculate_terrain_light(int(x), int(z))
						}
					}
					terrain_tool_drag_start = nil
					remove_billboard(terrain_tool_drag_start_billboard)

					terrain_tool_clear_masks(drag_start)
				} else if terrain_tool_drag_end != terrain_tool_position {
					terrain_tool_clear_masks(drag_start)

					terrain_tool_drag_end = terrain_tool_position
					for x in start_x ..< end_x {
						for z in start_z ..< end_z {
							tile_update_tile({x, 0, z}, nil, .Leveling_Brush)
						}
					}
				}
			} else if left_mouse_button == glfw.PRESS {
				terrain_tool_drag_start = terrain_tool_position
				terrain_tool_drag_start_billboard = append_billboard(
					 {
						position = position,
						light = {1, 1, 1},
						texture = .Shovel_SW,
						depth_map = .Shovel_SW,
						rotation = 0,
					},
				)
			}
		} else {
			terrain_tool_move_point(left_mouse_button, right_mouse_button)
		}
	}

	return ok
}

terrain_tool_move_point :: proc(left_mouse_button, right_mouse_button: i32) {
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
		terrain_tool_move_point_height(
			int(terrain_tool_position.x),
			int(terrain_tool_position.y),
			movement,
		)
		// terrain_tool_adjust_points(
		// 	int(terrain_tool_position.x - 1),
		// 	int(terrain_tool_position.y - 1),
		// 	2,
		// 	2,
		// )
		terrain_tool_adjust_points_v2(
			int(terrain_tool_position.x),
			int(terrain_tool_position.y),
			0,
			0,
		)

		if terrain_tool_tick_timer >= TERRAIN_TOOL_TICK_SPEED {
			terrain_tool_tick_timer = math.max(
				0,
				terrain_tool_tick_timer - TERRAIN_TOOL_TICK_SPEED,
			)
		}
	}
}

terrain_tool_move_point_height :: proc(x, z: int, movement: f32) {
	height := terrain_heights[x][z]
	height += movement

	height = clamp(height, TERRAIN_TOOL_LOW, TERRAIN_TOOL_HIGH)

	set_terrain_height(x, z, height)
}

terrain_tool_slope_points :: proc(x, z, rx, rz: int) -> bool {
	ref_height := terrain_heights[rx][rz]
	point_height := terrain_heights[x][z]

	if ref_height - point_height > terrain_tool_slope {
		terrain_tool_move_point_height(
			x,
			z,
			ref_height - point_height - terrain_tool_slope,
		)
		return true
	}

	if point_height - ref_height > terrain_tool_slope {
		terrain_tool_move_point_height(
			x,
			z,
			ref_height - point_height + terrain_tool_slope,
		)
		return true
	}

	return false
}

terrain_tool_adjust_side_points :: proc(x, z, w, h: int) {
	for x in x ..= x + w {
		for i in 1 ..= z {
			if !terrain_tool_slope_points(x, z - i, x, z - i + 1) {
				break
			}
		}
		for i in 1 ..= WORLD_DEPTH - z - h {
			if !terrain_tool_slope_points(x, z + h + i, x, z + h + i - 1) {
				break
			}
		}
	}

	for z in z ..= z + h {
		for i in 1 ..= x {
			if !terrain_tool_slope_points(x - i, z, x - i + 1, z) {
				break
			}
		}
		for i in 1 ..= WORLD_WIDTH - x - w {
			if !terrain_tool_slope_points(x + w + i, z, x + w + i - 1, z) {
				break
			}
		}
	}
}

terrain_tool_adjust_corner_points :: proc(x, z, w, h: int) {
	i := x - 1
	j := z - 1
	for i >= 0 && j >= 0 {
		if !terrain_tool_slope_points(i, j, i + 1, j + 1) {
			break
		}
		for k := j - 1; k >= 0; k -= 1 {
			if !terrain_tool_slope_points(i, k, i, k + 1) {
				break
			}
		}
		for k := i - 1; k >= 0; k -= 1 {
			if !terrain_tool_slope_points(k, j, k + 1, j) {
				break
			}
		}
		i -= 1
		j -= 1
	}

	i = x - 1
	j = z + h + 1
	for i >= 0 && j <= WORLD_DEPTH {
		if !terrain_tool_slope_points(i, j, i + 1, j - 1) {
			break
		}
		for k in j + 1 ..= WORLD_DEPTH {
			if !terrain_tool_slope_points(i, k, i, k - 1) {
				break
			}
		}
		for k := i - 1; k >= 0; k -= 1 {
			if !terrain_tool_slope_points(k, j, k + 1, j) {
				break
			}
		}
		i -= 1
		j += 1
	}

	i = x + w + 1
	j = z - 1
	for i <= WORLD_WIDTH && j >= 0 {
		if !terrain_tool_slope_points(i, j, i - 1, j + 1) {
			break
		}
		for k := j - 1; k >= 0; k -= 1 {
			if !terrain_tool_slope_points(i, k, i, k + 1) {
				break
			}
		}
		for k in i + 1 ..= WORLD_WIDTH {
			if !terrain_tool_slope_points(k, j, k - 1, j) {
				break
			}
		}
		i += 1
		j -= 1
	}

	i = x + w + 1
	j = z + h + 1
	for i <= WORLD_WIDTH && j <= WORLD_DEPTH {
		if !terrain_tool_slope_points(i, j, i - 1, j - 1) {
			break
		}
		for k in j + 1 ..= WORLD_DEPTH {
			if !terrain_tool_slope_points(i, k, i, k - 1) {
				break
			}
		}
		for k in i + 1 ..= WORLD_WIDTH {
			if !terrain_tool_slope_points(k, j, k - 1, j) {
				break
			}
		}
		i += 1
		j += 1
	}
}

terrain_tool_adjust_points_v2 :: proc(x, z, w, h: int) {
    terrain_tool_adjust_side_points(x, z, w, h)
    if !is_key_down(.Key_Left_Control) {
        terrain_tool_adjust_corner_points(x, z, w, h)
    }
}

terrain_tool_adjust_points :: proc(x, z, w, h: int) {
	x := x
	z := z
	w := w
	h := h

	cont := true
	for cont {
		cont = false
		right := x + w
		top := z + h
		start_z := max(z, 0)
		end_z := min(z + h, WORLD_DEPTH)
		start_x := max(x + 1, 0)
		end_x := min(x + w - 1, WORLD_WIDTH)
		if x >= 0 {
			if z == start_z {
				if terrain_tool_slope_points(x, start_z, x + 1, start_z + 1) {
					cont = true
				}
				start_z += 1
			}

			if end_z == z + h {
				if terrain_tool_slope_points(x, end_z, x + 1, end_z - 1) {
					cont = true
				}
				end_z -= 1
			}

			for z in start_z ..= end_z {
				if terrain_tool_slope_points(x, z, x + 1, z) {
					cont = true
				}
			}
		}

		start_z = max(z, 0)
		end_z = min(z + h, WORLD_DEPTH)
		if right <= WORLD_WIDTH {
			if z == start_z {
				if terrain_tool_slope_points(
					   right,
					   start_z,
					   right - 1,
					   start_z + 1,
				   ) {
					cont = true
				}
				start_z += 1
			}

			if end_z == z + h {
				if terrain_tool_slope_points(
					   right,
					   end_z,
					   right - 1,
					   end_z - 1,
				   ) {
					cont = true
				}
				end_z -= 1
			}

			for z in start_z ..= end_z {
				if terrain_tool_slope_points(right, z, right - 1, z) {
					cont = true
				}
			}
		}

		if z >= 0 {
			for x in start_x ..= end_x {
				if terrain_tool_slope_points(x, z, x, z + 1) {
					cont = true
				}
			}
		}

		if top <= WORLD_DEPTH {
			for x in start_x ..= end_x {
				if terrain_tool_slope_points(x, top, x, top - 1) {
					cont = true
				}
			}
		}

		if cont {
			x -= 1
			z -= 1
			w += 2
			h += 2
		}
	}

	start_z := max(z, 0)
	end_z := min(z + h, WORLD_DEPTH)
	start_x := max(x, 0)
	end_x := min(x + w, WORLD_WIDTH)
	for x in start_x ..= end_x {
		for z in start_z ..= end_z {
			calculate_terrain_light(int(x), int(z))
		}
	}
}

terrain_tool_update :: proc() {
	if is_key_press(.Key_Equal) {
		terrain_tool_slope += TERRAIN_TOOL_MIN_SLOPE
		terrain_tool_slope = min(terrain_tool_slope, TERRAIN_TOOL_MAX_SLOPE)
	} else if is_key_press(.Key_Minus) {
		terrain_tool_slope -= TERRAIN_TOOL_MIN_SLOPE
		terrain_tool_slope = max(terrain_tool_slope, TERRAIN_TOOL_MIN_SLOPE)
	}

	tile_on_visible(0, terrain_tool_tile_cursor)
}
