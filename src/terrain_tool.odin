package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:math/rand"
import "vendor:glfw"

terrain_tool_billboard: int
terrain_tool_position: glsl.ivec2
terrain_tool_tick_timer: f64
terrain_tool_drag_start: Maybe(glsl.ivec2)
terrain_tool_drag_end: Maybe(glsl.ivec2)
terrain_tool_drag_start_billboard: int
terrain_tool_drag_clip: bool
terrain_tool_slope: f32 = 0.5

terrain_tool_point: Maybe(glsl.vec3)
terrain_tool_point_height: f32

TERRAIN_TOOL_TICK_SPEED :: 0.125
TERRAIN_TOOL_MOVEMENT :: 0.1
TERRAIN_TOOL_LOW :: 0
TERRAIN_TOOL_HIGH :: 6
TERRAIN_TOOL_MIN_SLOPE :: 0.1
TERRAIN_TOOL_MAX_SLOPE :: 1.0
TERRAIN_TOOL_RANDOM_RADIUS :: 3

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

	left_mouse_button := glfw.GetMouseButton(
		window_handle,
		glfw.MOUSE_BUTTON_LEFT,
	)

	if point, ok := terrain_tool_point.?; ok {
		if intersect, ok := cursor_ray_intersect_plane(
			   glsl.vec3{point.x, 0, point.z},
			   glsl.normalize(glsl.vec3{-1, 0, -1}),
		   ).?; ok {
			fmt.println("intersect:", intersect)
            dy := intersect.y - point.y
            fmt.println("dy:", dy)
			terrain_tool_set_point_height(
				int(terrain_tool_position.x),
				int(terrain_tool_position.y),
				terrain_tool_point_height + dy,
			)
			position := glsl.vec3 {
				f32(terrain_tool_position.x) - 0.5,
				terrain_heights[terrain_tool_position.x][terrain_tool_position.y],
				f32(terrain_tool_position.y) - 0.5,
			}
			move_billboard(terrain_tool_billboard, position)

			if mouse_is_button_press(.Left) {
				terrain_tool_point = nil
			}
		}
		return true
	} else {
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

			right_mouse_button := glfw.GetMouseButton(
				window_handle,
				glfw.MOUSE_BUTTON_RIGHT,
			)
			shift_down := is_key_down(.Key_Left_Shift)

			if shift_down || terrain_tool_drag_start != nil {
				terrain_tool_move_points(
					left_mouse_button,
					right_mouse_button,
					position,
				)
			} else {
				// terrain_tool_move_point(left_mouse_button, right_mouse_button)
				if mouse_is_button_press(.Left) {
					terrain_tool_point = intersect
                    terrain_tool_point_height = position.y
				}
			}
		}

		return ok
	}
}

terrain_tool_move_points :: proc(
	left_mouse_button, right_mouse_button: i32,
	position: glsl.vec3,
) {
	if drag_start, ok := terrain_tool_drag_start.?; ok {
		start_x := min(drag_start.x, terrain_tool_position.x)
		start_z := min(drag_start.y, terrain_tool_position.y)
		end_x := max(drag_start.x, terrain_tool_position.x)
		end_z := max(drag_start.y, terrain_tool_position.y)

		if left_mouse_button == glfw.RELEASE &&
		   right_mouse_button == glfw.RELEASE {
			if is_key_down(.Key_Left_Control) {
				terrain_tool_adjust_inward_points(
					int(start_x),
					int(start_z),
					int(end_x - start_x),
					int(end_z - start_z),
				)
			} else {
				height := terrain_heights[drag_start.x][drag_start.y]
				for x in start_x ..= end_x {
					for z in start_z ..= end_z {
						if terrain_tool_drag_clip {
							point_height := terrain_heights[x][z]
							if point_height > height {
								set_terrain_height(int(x), int(z), height)
							}
						} else {
							set_terrain_height(int(x), int(z), height)
						}
					}
				}

				terrain_tool_adjust_points(
					int(start_x),
					int(start_z),
					int(end_x - start_x),
					int(end_z - start_z),
				)
			}

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
	} else if left_mouse_button == glfw.PRESS ||
	   right_mouse_button == glfw.PRESS {
		terrain_tool_drag_clip = right_mouse_button == glfw.PRESS
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
		if is_key_down(.Key_Left_Control) {
			for _ in 0 ..< 10 {
				o := rand.float32() * 2 * math.PI
				r := rand.float32() * TERRAIN_TOOL_RANDOM_RADIUS
				x := int(f32(terrain_tool_position.x) + r * math.cos(o) + 0.5)
				y := int(f32(terrain_tool_position.y) + r * math.sin(o) + 0.5)

				if x >= 0 && y >= 0 && x <= WORLD_WIDTH && y <= WORLD_DEPTH {
					terrain_tool_move_point_height(x, y, movement)
					terrain_tool_adjust_points(x, y, 0, 0)
				}
			}

			for i in 0 ..= 2 * TERRAIN_TOOL_RANDOM_RADIUS {
				for j in 0 ..= 2 * TERRAIN_TOOL_RANDOM_RADIUS {
					x :=
						int(terrain_tool_position.x) -
						TERRAIN_TOOL_RANDOM_RADIUS +
						i
					z :=
						int(terrain_tool_position.y) -
						TERRAIN_TOOL_RANDOM_RADIUS +
						j
					if x <= WORLD_WIDTH &&
					   z <= WORLD_DEPTH &&
					   x >= 0 &&
					   z >= 0 {
						calculate_terrain_light(x, z)
					}
				}
			}
		} else {
			terrain_tool_move_point_height(
				int(terrain_tool_position.x),
				int(terrain_tool_position.y),
				movement,
			)
			terrain_tool_adjust_points(
				int(terrain_tool_position.x),
				int(terrain_tool_position.y),
				0,
				0,
			)
		}

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

terrain_tool_set_point_height :: proc(x, z: int, height: f32) {
	height := clamp(height, TERRAIN_TOOL_LOW, TERRAIN_TOOL_HIGH)
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

terrain_tool_adjust_points :: proc(x, z, w, h: int) {
	terrain_tool_adjust_side_points(x, z, w, h)
	terrain_tool_adjust_corner_points(x, z, w, h)
}

terrain_tool_adjust_inward_points :: proc(x, z, w, h: int) {
	for i in x ..= x + w {
		for j in z + 1 ..< z + h {
			if !terrain_tool_slope_points(i, j, i, j - 1) {
				break
			}
		}
		for j := z + h - 1; j > z; j -= 1 {
			if !terrain_tool_slope_points(i, j, i, j + 1) {
				break
			}
		}
	}

	for j in z ..= z + h {
		for i in x + 1 ..< x + w {
			if !terrain_tool_slope_points(i, j, i - 1, j) {
				break
			}
		}
		for i := x + w - 1; i > x; i -= 1 {
			if !terrain_tool_slope_points(i, j, i + 1, j) {
				break
			}
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
