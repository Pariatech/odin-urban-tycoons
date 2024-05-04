package main

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:math/rand"
import "vendor:glfw"

import "constants"

terrain_tool_cursor_pos: glsl.vec3
terrain_tool_billboard: Billboard_Key
terrain_tool_intersect: glsl.vec3
terrain_tool_position: glsl.ivec2
terrain_tool_tick_timer: f64
terrain_tool_drag_start: Maybe(glsl.ivec2)
terrain_tool_drag_end: Maybe(glsl.ivec2)
terrain_tool_drag_clip: bool
terrain_tool_brush_size: i32 = 1
terrain_tool_brush_strength: f32 = 0.1

TERRAIN_TOOL_TICK_SPEED :: 0.125
TERRAIN_TOOL_LOW :: 0
TERRAIN_TOOL_HIGH :: 6
TERRAIN_TOOL_BRUSH_MIN_STRENGTH :: 0.1
TERRAIN_TOOL_BRUSH_MAX_STRENGTH :: 1.1
TERRAIN_TOOL_MIN_SLOPE :: 0.1
TERRAIN_TOOL_MAX_SLOPE :: 1.0
TERRAIN_TOOL_RANDOM_RADIUS :: 3

terrain_tool_init :: proc() {
	cursor_intersect_with_tiles(terrain_tool_on_intersect)
	terrain_tool_cursor_pos = cursor_ray.origin

	position := terrain_tool_intersect
	position.x = math.ceil(position.x) - 0.5
	position.z = math.ceil(position.z) - 0.5
	position.y =
		terrain_heights[terrain_tool_position.x][terrain_tool_position.y]

	terrain_tool_billboard = {
		type = .Shovel_Cursor,
		pos  = position,
	}
	billboard_1x1_set(
		terrain_tool_billboard,
		{light = {1, 1, 1}, texture = .Shovel_1_SW, depth_map = .Shovel_1_SW},
	)

	terrain_tool_drag_start = nil
	terrain_tool_drag_end = nil
}

terrain_tool_on_intersect :: proc(intersect: glsl.vec3) {
	terrain_tool_intersect = intersect
}

terrain_tool_mark_array_dirty :: proc(start: glsl.ivec2, end: glsl.ivec2) {
	start := start
	end := end
	start.x /= constants.CHUNK_WIDTH
	end.x /= constants.CHUNK_WIDTH
	start.y /= constants.CHUNK_DEPTH
	end.y /= constants.CHUNK_DEPTH

	start.x = max(start.x, 0)
	start.y = max(start.y, 0)
	end.x = min(end.x, constants.WORLD_CHUNK_WIDTH - 1)
	end.y = min(end.y, constants.WORLD_CHUNK_DEPTH - 1)

	for i in start.x ..= end.x {
		for j in start.y ..= end.y {
			for floor in 0 ..< constants.CHUNK_HEIGHT {
				world_chunks[i][j].floors[floor].tiles.dirty = true
			}
		}
	}
}

terrain_tool_move_points :: proc(position: glsl.vec3) {
	if drag_start, ok := terrain_tool_drag_start.?; ok {
		start_x := min(drag_start.x, terrain_tool_position.x)
		start_z := min(drag_start.y, terrain_tool_position.y)
		end_x := max(drag_start.x, terrain_tool_position.x)
		end_z := max(drag_start.y, terrain_tool_position.y)

		if mouse_is_button_up(.Left) && mouse_is_button_up(.Right) {
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

			for x in start_x ..= end_x {
				for z in start_z ..= end_z {
					calculate_terrain_light(int(x), int(z))
				}
			}
			terrain_tool_drag_start = nil

			terrain_tool_mark_array_dirty(
				 {
					start_x - terrain_tool_brush_size,
					start_z - terrain_tool_brush_size,
				},
				 {
					end_x + terrain_tool_brush_size,
					end_z + terrain_tool_brush_size,
				},
			)
		} else if terrain_tool_drag_end != terrain_tool_position {
			terrain_tool_drag_end = terrain_tool_position
		}

		terrain_tool_mark_array_dirty({start_x, start_z}, {end_x, end_z})
	} else if mouse_is_button_down(.Left) || mouse_is_button_down(.Right) {
		terrain_tool_drag_clip = mouse_is_button_down(.Right)
		terrain_tool_drag_start = terrain_tool_position
	}
}

terrain_tool_smooth_brush :: proc() {
	if mouse_is_button_down(.Left) {
		terrain_tool_tick_timer += delta_time
	} else if mouse_is_button_release(.Left) && terrain_tool_tick_timer > 0 {
		terrain_tool_tick_timer = 0
	}

	if terrain_tool_tick_timer == delta_time ||
	   terrain_tool_tick_timer >= TERRAIN_TOOL_TICK_SPEED {

		start_x := max(
			terrain_tool_position.x - terrain_tool_brush_size + 1,
			0,
		)
		start_z := max(
			terrain_tool_position.y - terrain_tool_brush_size + 1,
			0,
		)
		end_x := min(
			terrain_tool_position.x + terrain_tool_brush_size - 1,
			constants.WORLD_WIDTH,
		)
		end_z := min(
			terrain_tool_position.y + terrain_tool_brush_size - 1,
			constants.WORLD_DEPTH,
		)

		for x in start_x ..= end_x {
			for z in start_z ..= end_z {
				start_x := max(x - 1, 0)
				start_z := max(z - 1, 0)
				end_x := min(x + 1, constants.WORLD_WIDTH)
				end_z := min(z + 1, constants.WORLD_DEPTH)
				points := f32((end_x - start_x + 1) * (end_z - start_z + 1))
				average: f32 = 0

				for x in start_x ..= end_x {
					for z in start_z ..= end_z {
						average += terrain_heights[x][z] / points
					}
				}

				movement := average - terrain_heights[x][z]
				terrain_heights[x][z] += movement * terrain_tool_brush_strength
			}
		}

		terrain_tool_calculate_lights()

		if terrain_tool_tick_timer >= TERRAIN_TOOL_TICK_SPEED {
			terrain_tool_tick_timer = math.max(
				0,
				terrain_tool_tick_timer - TERRAIN_TOOL_TICK_SPEED,
			)
		}

		terrain_tool_mark_array_dirty({start_x, start_z}, {end_x, end_z})
	}
}

terrain_tool_calculate_lights :: proc() {
	start_x := max(terrain_tool_position.x - terrain_tool_brush_size, 0)
	end_x := min(
		terrain_tool_position.x + terrain_tool_brush_size,
		constants.WORLD_WIDTH,
	)
	start_z := max(terrain_tool_position.y - terrain_tool_brush_size, 0)
	end_z := min(
		terrain_tool_position.y + terrain_tool_brush_size,
		constants.WORLD_DEPTH,
	)
	for x in start_x ..= end_x {
		for z in start_z ..= end_z {
			calculate_terrain_light(int(x), int(z))
		}
	}
}

terrain_tool_move_point :: proc() {
	movement: f32 = 0
	if mouse_is_button_down(.Left) {
		movement = terrain_tool_brush_strength
		terrain_tool_tick_timer += delta_time
	} else if mouse_is_button_down(.Right) {
		movement = -terrain_tool_brush_strength
		terrain_tool_tick_timer += delta_time
	} else if mouse_is_button_release(.Left) && terrain_tool_tick_timer > 0 {
		terrain_tool_tick_timer = 0
	}

	if terrain_tool_tick_timer == delta_time ||
	   terrain_tool_tick_timer >= TERRAIN_TOOL_TICK_SPEED {
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
			movement,
		)
		terrain_tool_calculate_lights()

		if terrain_tool_tick_timer >= TERRAIN_TOOL_TICK_SPEED {
			terrain_tool_tick_timer = math.max(
				0,
				terrain_tool_tick_timer - TERRAIN_TOOL_TICK_SPEED,
			)
		}

		terrain_tool_mark_array_dirty(
			 {
				terrain_tool_position.x - terrain_tool_brush_size,
				terrain_tool_position.y - terrain_tool_brush_size,
			},
			 {
				terrain_tool_position.x + terrain_tool_brush_size,
				terrain_tool_position.y + terrain_tool_brush_size,
			},
		)
	}
}

terrain_tool_move_point_height :: proc(x, z: int, movement: f32) {
	height := terrain_heights[x][z]
	height += movement

	height = clamp(height, TERRAIN_TOOL_LOW, TERRAIN_TOOL_HIGH)

	set_terrain_height(x, z, height)
}

terrain_tool_adjust_points :: proc(x, z, w, h: int, movement: f32) {
	for i in 1 ..< int(terrain_tool_brush_size) {
		start_x := max(x - i, 0) + 1
		end_x := max(x + i, 0)
		start_z := max(z - i, 0)
		end_z := max(z + i, 0)

		if x - i >= 0 {
			for z in start_z ..= end_z {
				terrain_tool_move_point_height(
					x - i,
					z,
					movement *
					f32(terrain_tool_brush_size - i32(i)) /
					f32(terrain_tool_brush_size),
				)
			}
		}

		if x + w + i < constants.WORLD_WIDTH {
			for z in start_z ..= end_z {
				terrain_tool_move_point_height(
					x + w + i,
					z,
					movement *
					f32(terrain_tool_brush_size - i32(i)) /
					f32(terrain_tool_brush_size),
				)
			}
		}

		if z - i >= 0 {
			for x in start_x ..< end_x {
				terrain_tool_move_point_height(
					x,
					z - i,
					movement *
					f32(terrain_tool_brush_size - i32(i)) /
					f32(terrain_tool_brush_size),
				)
			}
		}

		if z + h + i < constants.WORLD_DEPTH {
			for x in start_x ..< end_x {
				terrain_tool_move_point_height(
					x,
					z + h + i,
					movement *
					f32(terrain_tool_brush_size - i32(i)) /
					f32(terrain_tool_brush_size),
				)
			}
		}
	}
}

terrain_tool_deinit :: proc() {
	if drag_start, ok := terrain_tool_drag_start.?; ok {
		start_x := min(drag_start.x, terrain_tool_position.x)
		start_z := min(drag_start.y, terrain_tool_position.y)
		end_x := max(drag_start.x, terrain_tool_position.x)
		end_z := max(drag_start.y, terrain_tool_position.y)

		for x in start_x ..< end_x {
			for z in start_z ..< end_z {
				world_set_tile_mask_texture({x, 0, z}, .Grid_Mask)
			}
		}

		terrain_tool_mark_array_dirty(
			 {
				start_x - terrain_tool_brush_size,
				start_z - terrain_tool_brush_size,
			},
			{end_x + terrain_tool_brush_size, end_z + terrain_tool_brush_size},
		)
	} else {
		start_x := max(terrain_tool_position.x - terrain_tool_brush_size, 0)
		start_z := max(terrain_tool_position.y - terrain_tool_brush_size, 0)
		end_x := min(
			terrain_tool_position.x + terrain_tool_brush_size,
			constants.WORLD_WIDTH,
		)
		end_z := min(
			terrain_tool_position.y + terrain_tool_brush_size,
			constants.WORLD_DEPTH,
		)
		for x in start_x ..< end_x {
			for z in start_z ..< end_z {
				world_set_tile_mask_texture({x, 0, z}, .Grid_Mask)
			}
		}
		terrain_tool_mark_array_dirty(
			 {
				terrain_tool_position.x - terrain_tool_brush_size,
				terrain_tool_position.y - terrain_tool_brush_size,
			},
			 {
				terrain_tool_position.x + terrain_tool_brush_size,
				terrain_tool_position.y + terrain_tool_brush_size,
			},
		)
	}
	billboard_1x1_remove(terrain_tool_billboard)

}

terrain_tool_update :: proc() {
	if drag_start, ok := terrain_tool_drag_start.?; ok {
		start_x := min(drag_start.x, terrain_tool_position.x)
		start_z := min(drag_start.y, terrain_tool_position.y)
		end_x := max(drag_start.x, terrain_tool_position.x)
		end_z := max(drag_start.y, terrain_tool_position.y)

		for x in start_x ..< end_x {
			for z in start_z ..< end_z {
				world_set_tile_mask_texture({x, 0, z}, .Grid_Mask)
			}
		}
	} else {
		start_x := max(terrain_tool_position.x - terrain_tool_brush_size, 0)
		end_x := min(
			terrain_tool_position.x + terrain_tool_brush_size,
			constants.WORLD_WIDTH,
		)
		start_z := max(terrain_tool_position.y - terrain_tool_brush_size, 0)
		end_z := min(
			terrain_tool_position.y + terrain_tool_brush_size,
			constants.WORLD_DEPTH,
		)
		for x in start_x ..< end_x {
			for z in start_z ..< end_z {
				world_set_tile_mask_texture({x, 0, z}, .Grid_Mask)
			}
		}
	}

	if is_key_press(.Key_Equal) {
		if is_key_down(.Key_Left_Shift) {
			terrain_tool_brush_strength += TERRAIN_TOOL_BRUSH_MIN_STRENGTH
			terrain_tool_brush_strength = min(
				terrain_tool_brush_strength,
				TERRAIN_TOOL_BRUSH_MAX_STRENGTH,
			)

			t := int(terrain_tool_brush_strength * 10 - 1)
			billboard_1x1_set_texture(
				terrain_tool_billboard,
				Billboard_Texture_1x1(
					int(Billboard_Texture_1x1.Shovel_1_SW) + t,
				),
			)
		} else {
			terrain_tool_brush_size += 1
			terrain_tool_brush_size = min(terrain_tool_brush_size, 10)
		}
		terrain_tool_mark_array_dirty(
			 {
				terrain_tool_position.x - terrain_tool_brush_size,
				terrain_tool_position.y - terrain_tool_brush_size,
			},
			 {
				terrain_tool_position.x + terrain_tool_brush_size,
				terrain_tool_position.y + terrain_tool_brush_size,
			},
		)
	} else if is_key_press(.Key_Minus) {
		if is_key_down(.Key_Left_Shift) {
			terrain_tool_brush_strength -= TERRAIN_TOOL_BRUSH_MIN_STRENGTH
			terrain_tool_brush_strength = max(
				terrain_tool_brush_strength,
				TERRAIN_TOOL_BRUSH_MIN_STRENGTH,
			)

			t := int(terrain_tool_brush_strength * 10 - 1)
			billboard_1x1_set_texture(
				terrain_tool_billboard,
				Billboard_Texture_1x1(
					int(Billboard_Texture_1x1.Shovel_1_SW) + t,
				),
			)
		} else {
			terrain_tool_brush_size -= 1
			terrain_tool_brush_size = max(terrain_tool_brush_size, 1)
		}
		terrain_tool_mark_array_dirty(
			 {
				terrain_tool_position.x - terrain_tool_brush_size - 1,
				terrain_tool_position.y - terrain_tool_brush_size - 1,
			},
			 {
				terrain_tool_position.x + terrain_tool_brush_size + 1,
				terrain_tool_position.y + terrain_tool_brush_size + 1,
			},
		)
	}

	cursor_on_tile_intersect(terrain_tool_on_intersect)

	position := terrain_tool_intersect
	position.x = math.ceil(position.x) - 0.5
	position.z = math.ceil(position.z) - 0.5
	previous_tool_position := terrain_tool_position
	terrain_tool_position.x = i32(position.x + 0.5)
	terrain_tool_position.y = i32(position.z + 0.5)

	if terrain_tool_position != previous_tool_position {
		terrain_tool_mark_array_dirty(
			 {
				terrain_tool_position.x - terrain_tool_brush_size,
				terrain_tool_position.y - terrain_tool_brush_size,
			},
			 {
				terrain_tool_position.x + terrain_tool_brush_size,
				terrain_tool_position.y + terrain_tool_brush_size,
			},
		)
		terrain_tool_mark_array_dirty(
			 {
				previous_tool_position.x - terrain_tool_brush_size,
				previous_tool_position.y - terrain_tool_brush_size,
			},
			 {
				previous_tool_position.x + terrain_tool_brush_size,
				previous_tool_position.y + terrain_tool_brush_size,
			},
		)
	}

	position.y =
		terrain_heights[terrain_tool_position.x][terrain_tool_position.y]
	billboard_1x1_move(&terrain_tool_billboard, position)
	shift_down := is_key_down(.Key_Left_Shift)

	if shift_down || terrain_tool_drag_start != nil {
		terrain_tool_move_points(position)
	} else if is_key_down(.Key_Left_Control) {
		terrain_tool_smooth_brush()
	} else {
		terrain_tool_move_point()
	}

	if drag_start, ok := terrain_tool_drag_start.?; ok {
		start_x := min(drag_start.x, terrain_tool_position.x)
		start_z := min(drag_start.y, terrain_tool_position.y)
		end_x := max(drag_start.x, terrain_tool_position.x)
		end_z := max(drag_start.y, terrain_tool_position.y)

		for x in start_x ..< end_x {
			for z in start_z ..< end_z {
				world_set_tile_mask_texture({x, 0, z}, .Leveling_Brush)
			}
		}
	} else {
		start_x := max(terrain_tool_position.x - terrain_tool_brush_size, 0)
		end_x := min(
			terrain_tool_position.x + terrain_tool_brush_size,
			constants.WORLD_WIDTH,
		)
		start_z := max(terrain_tool_position.y - terrain_tool_brush_size, 0)
		end_z := min(
			terrain_tool_position.y + terrain_tool_brush_size,
			constants.WORLD_DEPTH,
		)
		for x in start_x ..< end_x {
			for z in start_z ..< end_z {
				world_set_tile_mask_texture({x, 0, z}, .Dotted_Grid)
			}
		}
	}
}
