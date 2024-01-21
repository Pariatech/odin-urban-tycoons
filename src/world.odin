package main

import m "core:math/linalg/glsl"

WORLD_WIDTH :: 64
WORLD_HEIGHT :: 4
WORLD_DEPTH :: 64

sun := m.vec3{0, -1, 0}
north_south_walls := map[m.ivec3]Wall{}
east_west_walls := map[m.ivec3]Wall{}
north_west_south_east_walls := map[m.ivec3]Wall{}
south_west_north_east_walls := map[m.ivec3]Wall{}
north_floor_tile_triangles := map[m.ivec3]Tile_Triangle{}
east_floor_tile_triangles := map[m.ivec3]Tile_Triangle{}
south_floor_tile_triangles := map[m.ivec3]Tile_Triangle{}
west_floor_tile_triangles := map[m.ivec3]Tile_Triangle{}

house_x: i32 = 32
house_z: i32 = 32

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

			y := get_tile_height(x, z)
			draw_tile_diagonal_walls(i32(x), i32(z), 0, y)
			draw_tile_walls(i32(x), i32(z), 0, y)

			for floor in 1 ..< WORLD_HEIGHT {
				floor_y := y + f32(floor * WALL_HEIGHT)
				draw_tile_floor_trianges({i32(x), i32(floor), i32(z)}, floor_y)
				draw_tile_diagonal_walls(i32(x), i32(z), i32(floor), floor_y)
				draw_tile_walls(i32(x), i32(z), i32(floor), floor_y)
			}
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

	insert_north_south_wall(
		{1, 0, 1},
		{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_east_west_wall(
		{3, 0, 1},
		{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_north_south_wall(
		{7, 0, 1},
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{7, 0, 1},
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_south_wall(
		{11, 0, 1},
		 {
			type = .End_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{10, 0, 1},
		 {
			type = .End_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_south_wall(
		{14, 0, 1},
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{13, 0, 2},
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_south_wall(
		{16, 0, 1},
		 {
			type = .Right_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{16, 0, 2},
		 {
			type = .Right_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_south_wall(
		{1, 0, 6},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_north_south_wall(
		{1, 0, 7},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_east_west_wall(
		{3, 0, 6},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_east_west_wall(
		{4, 0, 6},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_north_south_wall(
		{7, 0, 6},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_north_south_wall(
		{7, 0, 7},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_east_west_wall(
		{7, 0, 6},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{8, 0, 6},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_north_south_wall(
		{12, 0, 6},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_north_south_wall(
		{12, 0, 7},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_east_west_wall(
		{10, 0, 6},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_east_west_wall(
		{11, 0, 6},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_south_wall(
		{15, 0, 6},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_north_south_wall(
		{15, 0, 7},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{13, 0, 8},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_east_west_wall(
		{14, 0, 8},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_south_wall(
		{16, 0, 6},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_north_south_wall(
		{16, 0, 7},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{16, 0, 8},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{17, 0, 8},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_north_south_wall(
		{1, 0, 10},
		 {
			type = .Right_Corner_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_north_south_wall(
		{2, 0, 10},
		 {
			type = .Left_Corner_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{1, 0, 10},
		 {
			type = .Left_Corner_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)
	insert_east_west_wall(
		{1, 0, 11},
		 {
			type = .Right_Corner_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_south_wall(
		{5, 0, 10},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_north_south_wall(
		{5, 0, 11},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_east_west_wall(
		{4, 0, 11},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
	insert_east_west_wall(
		{5, 0, 11},
		{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_north_west_south_east_wall(
		{1, 0, 13},
		{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_south_west_north_east_wall(
		{1, 0, 15},
		{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	)


	insert_north_west_south_east_wall(
		{1, 0, 17},
		 {
			type = .End_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{2, 0, 17},
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_west_south_east_wall(
		{6, 0, 17},
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{6, 0, 18},
		 {
			type = .Right_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)


	insert_north_west_south_east_wall(
		{9, 0, 17},
		 {
			type = .Left_Corner_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{9, 0, 18},
		 {
			type = .Right_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{10, 0, 17},
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)


	insert_north_west_south_east_wall(
		{13, 0, 17},
		 {
			type = .Right_Corner_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{12, 0, 17},
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{14, 0, 17},
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)


	insert_north_west_south_east_wall(
		{17, 0, 17},
		 {
			type = .Right_Corner_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{16, 0, 17},
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{17, 0, 16},
		 {
			type = .End_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)


	insert_north_west_south_east_wall(
		{20, 0, 17},
		 {
			type = .Right_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{19, 0, 17},
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)


	insert_north_west_south_east_wall(
		{22, 0, 17},
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_south_west_north_east_wall(
		{22, 0, 16},
		 {
			type = .End_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_west_south_east_wall(
		{1, 0, 20},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_east_west_wall(
		{2, 0, 20},
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)


	// The house
    draw_house_floor(0)
    draw_house_floor(1)
}

draw_house_floor :: proc(floor: i32) {
	// The house's front wall
	insert_north_south_wall(
		{house_x, floor, house_z},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = .Varg, .Outside = .Brick},
		},
	)
	for i in 0 ..< 2 {
		insert_north_south_wall(
			{house_x, floor, house_z + i32(i) + 1},
			 {
				type = .Side_Side,
				textures = {.Inside = .Varg, .Outside = .Brick},
			},
		)
	}
	insert_north_south_wall(
		{house_x, floor, house_z + 3},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = .Varg, .Outside = .Brick},
		},
	)

	insert_south_west_north_east_wall(
		{house_x, floor, house_z + 4},
		{type = .Side_Side, textures = {.Inside = .Varg, .Outside = .Brick}},
	)

	insert_north_south_wall(
		{house_x + 1, floor, house_z + 5},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = .Varg, .Outside = .Brick},
		},
	)

	insert_north_west_south_east_wall(
		{house_x, floor, house_z + 6},
		{type = .End_Side, textures = {.Inside = .Varg, .Outside = .Brick}},
	)

	insert_north_south_wall(
		{house_x, floor, house_z + 7},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = .Varg, .Outside = .Brick},
		},
	)

	for i in 0 ..< 2 {
		insert_north_south_wall(
			{house_x, floor, house_z + i32(i) + 8},
			 {
				type = .Side_Side,
				textures = {.Inside = .Varg, .Outside = .Brick},
			},
		)
	}

	insert_north_south_wall(
		{house_x, floor, house_z + 10},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = .Varg, .Outside = .Brick},
		},
	)

	// The house's right side wall
	insert_east_west_wall(
		{house_x, floor, house_z},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = .Varg, .Outside = .Brick},
		},
	)

	for i in 0 ..< 2 {
		insert_east_west_wall(
			{house_x + i32(i) + 1, floor, house_z},
			 {
				type = .Side_Side,
				textures = {.Inside = .Varg, .Outside = .Brick},
			},
		)
	}

	insert_east_west_wall(
		{house_x + 3, floor, house_z},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = .Varg, .Outside = .Brick},
		},
	)

	// The house's left side wall
	insert_east_west_wall(
		{house_x, floor, house_z + 11},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	for i in 0 ..< 2 {
		insert_east_west_wall(
			{house_x + i32(i) + 1, floor, house_z + 11},
			 {
				type = .Side_Side,
				textures = {.Inside = .Brick, .Outside = .Varg},
			},
		)
	}
	insert_east_west_wall(
		{house_x + 3, floor, house_z + 11},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	// The house's back wall
	insert_south_west_north_east_wall(
		{house_x + 4, floor, house_z},
		{type = .Side_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)

	insert_north_south_wall(
		{house_x + 5, floor, house_z + 1},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	for i in 0 ..< 7 {
		insert_north_south_wall(
			{house_x + 5, floor, house_z + i32(i) + 2},
			 {
				type = .Side_Side,
				textures = {.Inside = .Brick, .Outside = .Varg},
			},
		)
	}

	insert_north_south_wall(
		{house_x + 5, floor, house_z + 9},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = .Brick, .Outside = .Varg},
		},
	)

	insert_north_west_south_east_wall(
		{house_x + 4, floor, house_z + 10},
		{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	)
}
