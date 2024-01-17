package main

import m "core:math/linalg/glsl"

WORLD_WIDTH :: 64
WORLD_HEIGHT :: 64
WORLD_DEPTH :: 32

sun := m.vec3{0, -1, 0}
north_south_walls := make(map[m.ivec3]Wall)
east_west_walls := make(map[m.ivec3]Wall)

draw_world :: proc() {
	// for y in 0 ..< WORLD_HEIGHT {
	for x in 0 ..< WORLD_WIDTH {
		x := x
		#partial switch camera_rotation {
		case .South_West, .North_West:
			x = WORLD_WIDTH - x - 1
		}
		for z in 0 ..< WORLD_DEPTH {
			z := z
			#partial switch camera_rotation {
			case .South_West, .South_East:
				z = WORLD_DEPTH - z - 1
			}
			for side in Tile_Triangle_Side {
				draw_terrain_tile_triangle(side, x, z)
			}

			draw_tile_walls(i32(x), i32(z), 0)
		}
	}
	// }
}

init_world :: proc() {
	for x in 0 ..< WORLD_WIDTH {
		for z in 0 ..< WORLD_DEPTH {
			for side in Tile_Triangle_Side {
				set_terrain_tile_triangle(side, x, z, .Grass, .Grid_Mask)
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

	insert_east_west_wall({3, 0, 1}, {type = .End_End, texture = .Brick})

    insert_north_south_wall({7, 0, 1}, {type = .End_Right_Corner, texture = .Varg})
    insert_east_west_wall({7, 0, 1}, {type = .Left_Corner_End, texture = .Brick})

    insert_north_south_wall({11, 0, 1}, {type = .End_Left_Corner, texture = .Varg})
    insert_east_west_wall({10, 0, 1}, {type = .End_Left_Corner, texture = .Brick})

    insert_north_south_wall({14, 0, 1}, {type = .Left_Corner_End, texture = .Varg})
    insert_east_west_wall({13, 0, 2}, {type = .End_Right_Corner, texture = .Brick})

    insert_north_south_wall({16, 0, 1}, {type = .Right_Corner_End, texture = .Varg})
    insert_east_west_wall({16, 0, 2}, {type = .Right_Corner_End, texture = .Brick})

    insert_north_south_wall({1, 0, 6}, {type = .Side_End, texture = .Varg})
    insert_north_south_wall({1, 0, 7}, {type = .End_Side, texture = .Brick})

	insert_east_west_wall({3, 0, 6}, {type = .End_Side, texture = .Varg})
	insert_east_west_wall({4, 0, 6}, {type = .Side_End, texture = .Brick})

    insert_north_south_wall({8, 0, 6}, {type = .Side_Left_Corner, texture = .Brick})
    insert_north_south_wall({8, 0, 7}, {type = .End_Side, texture = .Brick})
	insert_east_west_wall({6, 0, 6}, {type = .End_Side, texture = .Varg})
	insert_east_west_wall({7, 0, 6}, {type = .Side_Right_Corner, texture = .Varg})
}
