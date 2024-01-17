package main

WORLD_WIDTH :: 64
WORLD_HEIGHT :: 64
WORLD_DEPTH :: 32

sun := Vec3{0, -1, 0}
north_south_walls := make(map[IVec3]Wall)
east_west_walls := make(map[IVec3]Wall)

draw_world :: proc() {
	// for y in 0 ..< WORLD_HEIGHT {
	for x in 0 ..< WORLD_WIDTH {
		x := x
		#partial switch camera_rotation {
		case .South_West, .South_East:
			x = WORLD_WIDTH - x - 1
		}
		for z in 0 ..< WORLD_DEPTH {
			z := z
			#partial switch camera_rotation {
			case .South_West, .North_West:
				z = WORLD_DEPTH - z - 1
			}
			// draw_half_tiles_at({f32(x), f32(y), f32(z)})
			for side in Tile_Triangle_Side {
				draw_terrain_tile_triangle(side, x, z)
			}

			draw_tile_walls(x, z, 0)
		}
	}
	// }
}

init_world :: proc() {
	for x in 0 ..< WORLD_WIDTH {
		for z in 0 ..< WORLD_DEPTH {
			for side in Tile_Triangle_Side {
				set_terrain_tile_triangle(side, x, z, .Grass, .Full_Mask)
			}
			// add_half_tile(
			// 	 {
			// 		position = {f32(x), 0, f32(z)},
			// 		corner = .South_West,
			// 		corners_y = {0, 0, 0},
			// 		corners_light = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}},
			// 		texture = .Grass,
			// 		mask_texture = .Full_Mask,
			// 	},
			// )
			// add_half_tile(
			// 	 {
			// 		position = {f32(x), 0, f32(z)},
			// 		corner = .North_East,
			// 		corners_y = {0, 0, 0},
			// 		corners_light = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}},
			// 		texture = .Grass,
			// 		mask_texture = .Full_Mask,
			// 	},
			// )
		}
	}

	insert_north_south_wall({1, 0, 1}, {type = .End_End, texture = .Brick})
}
