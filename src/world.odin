package main

WORLD_WIDTH :: 32
WORLD_HEIGHT :: 32
WORLD_DEPTH :: 32

draw_world :: proc() {
	for y in 0 ..< WORLD_HEIGHT {
		for x in 0 ..< WORLD_WIDTH {
			for z in 0 ..< WORLD_DEPTH {
				draw_half_tiles_at({f32(x), f32(y), f32(z)})
			}
		}
	}
}

init_world :: proc() {
	for x in 0 ..< WORLD_WIDTH {
		for z in 0 ..< WORLD_DEPTH {
			add_half_tile(
				 {
					position = {f32(x), 0, f32(z)},
					corner = .South_West,
					corners_y = {0, 0, 0},
					corners_light = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}},
					texture = .Grass,
					mask_texture = .Full_Mask,
				},
			)
			add_half_tile(
				 {
					position = {f32(x), 0, f32(z)},
					corner = .North_East,
					corners_y = {0, 0, 0},
					corners_light = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}},
					texture = .Grass,
					mask_texture = .Full_Mask,
				},
			)
		}
	}
}
