package main

import "core:fmt"
import m "core:math/linalg/glsl"
import gl "vendor:OpenGL"

WORLD_WIDTH :: 1024
WORLD_HEIGHT :: 4
WORLD_DEPTH :: 1024

sun := m.vec3{0, -1, 0}

house_x: i32 = 12
house_z: i32 = 12

init_world :: proc() {
	//
	// insert_north_south_wall(
	// 	{1, 0, 1},
	// 	{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_east_west_wall(
	// 	{3, 0, 1},
	// 	{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )

	// insert_north_south_wall(
	// 	{7, 0, 1},
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{7, 0, 1},
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_south_wall(
	// 	{11, 0, 1},
	// 	 {
	// 		type = .End_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{10, 0, 1},
	// 	 {
	// 		type = .End_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_south_wall(
	// 	{14, 0, 1},
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{13, 0, 2},
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_south_wall(
	// 	{16, 0, 1},
	// 	 {
	// 		type = .Right_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{16, 0, 2},
	// 	 {
	// 		type = .Right_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_south_wall(
	// 	{1, 0, 6},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_north_south_wall(
	// 	{1, 0, 7},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_east_west_wall(
	// 	{3, 0, 6},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_east_west_wall(
	// 	{4, 0, 6},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_north_south_wall(
	// 	{7, 0, 6},
	// 	 {
	// 		type = .Side_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_north_south_wall(
	// 	{7, 0, 7},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_east_west_wall(
	// 	{7, 0, 6},
	// 	 {
	// 		type = .Left_Corner_Side,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{8, 0, 6},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_north_south_wall(
	// 	{12, 0, 6},
	// 	 {
	// 		type = .Side_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_north_south_wall(
	// 	{12, 0, 7},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_east_west_wall(
	// 	{10, 0, 6},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_east_west_wall(
	// 	{11, 0, 6},
	// 	 {
	// 		type = .Side_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_south_wall(
	// 	{15, 0, 6},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_north_south_wall(
	// 	{15, 0, 7},
	// 	 {
	// 		type = .Left_Corner_Side,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{13, 0, 8},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_east_west_wall(
	// 	{14, 0, 8},
	// 	 {
	// 		type = .Side_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_south_wall(
	// 	{16, 0, 6},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_north_south_wall(
	// 	{16, 0, 7},
	// 	 {
	// 		type = .Right_Corner_Side,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{16, 0, 8},
	// 	 {
	// 		type = .Right_Corner_Side,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{17, 0, 8},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_north_south_wall(
	// 	{1, 0, 10},
	// 	 {
	// 		type = .Right_Corner_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_north_south_wall(
	// 	{2, 0, 10},
	// 	 {
	// 		type = .Left_Corner_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{1, 0, 10},
	// 	 {
	// 		type = .Left_Corner_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	// insert_east_west_wall(
	// 	{1, 0, 11},
	// 	 {
	// 		type = .Right_Corner_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_south_wall(
	// 	{5, 0, 10},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_north_south_wall(
	// 	{5, 0, 11},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_east_west_wall(
	// 	{4, 0, 11},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_east_west_wall(
	// 	{5, 0, 11},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_north_west_south_east_wall(
	// 	{1, 0, 13},
	// 	{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{1, 0, 15},
	// 	{type = .End_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	//
	// insert_north_west_south_east_wall(
	// 	{1, 0, 17},
	// 	 {
	// 		type = .End_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{2, 0, 17},
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_west_south_east_wall(
	// 	{6, 0, 17},
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{6, 0, 18},
	// 	 {
	// 		type = .Right_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	//
	// insert_north_west_south_east_wall(
	// 	{9, 0, 17},
	// 	 {
	// 		type = .Left_Corner_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{9, 0, 18},
	// 	 {
	// 		type = .Right_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{10, 0, 17},
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	//
	// insert_north_west_south_east_wall(
	// 	{13, 0, 17},
	// 	 {
	// 		type = .Right_Corner_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{12, 0, 17},
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{14, 0, 17},
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	//
	// insert_north_west_south_east_wall(
	// 	{17, 0, 17},
	// 	 {
	// 		type = .Right_Corner_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{16, 0, 17},
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{17, 0, 16},
	// 	 {
	// 		type = .End_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	//
	// insert_north_west_south_east_wall(
	// 	{20, 0, 17},
	// 	 {
	// 		type = .Right_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{19, 0, 17},
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	//
	// insert_north_west_south_east_wall(
	// 	{22, 0, 17},
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{22, 0, 16},
	// 	 {
	// 		type = .End_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_north_west_south_east_wall(
	// 	{1, 0, 20},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_east_west_wall(
	// 	{2, 0, 20},
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	//
	// insert_north_south_wall(
	// 	{1, 0, 23},
	// 	 {
	// 		type = .Right_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{1, 0, 24},
	// 	{type = .Side_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_north_south_wall(
	// 	{5, 0, 24},
	// 	 {
	// 		type = .End_Left_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Varg},
	// 	},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{4, 0, 23},
	// 	{type = .Side_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	//
	// insert_south_west_north_east_wall(
	// 	{6, 0, 23},
	// 	{type = .End_Side, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )
	// insert_south_west_north_east_wall(
	// 	{7, 0, 24},
	// 	{type = .Side_End, textures = {.Inside = .Brick, .Outside = .Varg}},
	// )


	// The house
	add_house_floor_walls(0, .Varg, .Varg)
	add_house_floor_walls(1, .Nyana, .Nyana)
	add_house_floor_triangles(2, .Wood)

	for x in 0 ..< WORLD_WIDTH {
		for z in 1 ..= 3 {
			insert_floor_tile(
				{i32(x), 0, i32(z)},
				{texture = .Asphalt, mask_texture = .Full_Mask},
			)
		}

		insert_floor_tile(
			{i32(x), 0, 4},
			{texture = .Asphalt_Horizontal_Line, mask_texture = .Full_Mask},
		)
		for z in 5 ..= 7 {
			insert_floor_tile(
				{i32(x), 0, i32(z)},
				{texture = .Asphalt, mask_texture = .Full_Mask},
			)
		}
	}

	for x in 1 ..= 7 {
		insert_floor_tile(
			{i32(x), 0, 4},
			{texture = .Asphalt, mask_texture = .Full_Mask},
		)
	}

	for z in 8 ..< WORLD_WIDTH {
		for x in 1 ..= 3 {
			insert_floor_tile(
				{i32(x), 0, i32(z)},
				{texture = .Asphalt, mask_texture = .Full_Mask},
			)
		}

		insert_floor_tile(
			{4, 0, i32(z)},
			{texture = .Asphalt_Vertical_Line, mask_texture = .Full_Mask},
		)
		for x in 5 ..= 7 {
			insert_floor_tile(
				{i32(x), 0, i32(z)},
				{texture = .Asphalt, mask_texture = .Full_Mask},
			)
		}
	}

	for x in 8 ..< WORLD_WIDTH {
		insert_floor_tile(
			{i32(x), 0, 8},
			{texture = .Sidewalk, mask_texture = .Full_Mask},
		)
	}

	for z in 9 ..< WORLD_WIDTH {
		insert_floor_tile(
			{8, 0, i32(z)},
			{texture = .Sidewalk, mask_texture = .Full_Mask},
		)
	}

	// insert_wall_window(.East_West, {3, 0, 3}, {texture = .Medium_Window_Wood})
	// insert_wall_door(.East_West, {2, 0, 2}, {model = .Wood})
	// insert_wall_door(.North_South, {2, 0, 2}, {model = .Wood})
	//
	// insert_table(
	// 	{4, 0, 4},
	// 	{model = .Six_Places, texture = .Table_6Places_Wood},
	// )
	// insert_chair({4, 0, 6}, {model = .Wood, orientation = .South})
	// insert_chair({4, 0, 3}, {model = .Wood, orientation = .North})
	//
	// insert_chair({3, 0, 5}, {model = .Wood, orientation = .East})
	// insert_chair({3, 0, 4}, {model = .Wood, orientation = .East})
	//
	// insert_chair({5, 0, 5}, {model = .Wood, orientation = .West})
	// insert_chair({5, 0, 4}, {model = .Wood, orientation = .West})

	// append_billboard(
	// 	 {
	// 		position = {0, 0, 0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_North_Wood,
	// 		depth_map = .Chair_North,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {0.1, 0.1, 0.2},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_North_Wood,
	// 		depth_map = .Chair_North,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {1.0, -0.1, 0.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_South_Wood,
	// 		depth_map = .Chair_South,
	// 	},
	// )

	// for x in 0 ..< 20 {
	// 	for z in 0 ..< 10 {
	// 		append_billboard(
	// 			 {
	// 				position = {f32(x), 0.0, f32(z)},
	// 				light = {1, 1, 1},
	// 				texture = .Chair_Wood_SW,
	// 				depth_map = .Chair_Wood_SW,
	// 			},
	// 		)
	// 	}
	// }
	//    fmt.println("finished adding chairs", len(billboard_system.nodes))

	// for x in 0 ..< 100 {
	// 	for z in 0 ..< 100 {
	// 		append_four_tiles_billboard(
	// 			 {
	// 				position = {f32(x * 2) + 0.5, 0.0, f32(z * 2) + 0.5},
	// 				light = {1, 1, 1},
	// 				texture = .Table_Wood_SW,
	// 				depth_map = .Table_Wood_SW,
	// 			},
	// 		)
	// 	}
	// }


	// append_billboard(
	// 	 {
	// 		position = {1.0, 0.0, 0.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_Wood_SW,
	// 		depth_map = .Chair_Wood_SW,
	//            rotation = 1,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {2.0, 0.0, 0.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_Wood_SW,
	// 		depth_map = .Chair_Wood_SW,
	//            rotation = 2,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {3.0, 0.0, 0.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_Wood_SW,
	// 		depth_map = .Chair_Wood_SW,
	//            rotation = 3,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {0.0, 0.0, 1.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_Wood_NE,
	// 		depth_map = .Chair_Wood_NE,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {1.0, 0.0, 1.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_Wood_NE,
	// 		depth_map = .Chair_Wood_NE,
	//            rotation = 1,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {2.0, 0.0, 1.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_Wood_NE,
	// 		depth_map = .Chair_Wood_NE,
	//            rotation = 2,
	// 	},
	// )
	//
	// append_billboard(
	// 	 {
	// 		position = {3.0, 0.0, 1.0},
	// 		light = {1, 1, 1},
	// 		texture = .Chair_Wood_NE,
	// 		depth_map = .Chair_Wood_NE,
	//            rotation = 3,
	// 	},
	// )
	//
	//
	// append_four_tiles_billboard(
	// 	 {
	// 		position = {0.5, 0.0, 3.5},
	// 		light = {1, 1, 1},
	// 		texture = .Table_Wood_SW,
	// 		depth_map = .Table_Wood_SW,
	//            rotation = 0,
	// 	},
	// )
	//
	// append_four_tiles_billboard(
	// 	 {
	// 		position = {3.5, 0.0, 3.5},
	// 		light = {1, 1, 1},
	// 		texture = .Table_8_Places_Wood_SW,
	// 		depth_map = .Table_8_Places_Wood_SW,
	//            rotation = 0,
	// 	},
	// )

	// append_billboard(
	// 	 {
	// 		position = {0.0, 0.0, 3.0},
	// 		light = {1, 1, 1},
	// 		texture = .Table_North_Wood,
	// 		depth_map = .Table_North_Wood,
	//            rotation = 0,
	// 	},
	// )
}

add_house_floor_triangles :: proc(floor: i32, texture: Texture) {
	tri := Tile_Triangle {
		texture      = texture,
		mask_texture = .Full_Mask,
	}

	insert_west_floor_tile_triangle({house_x + 4, floor, house_z}, tri)
	insert_north_floor_tile_triangle({house_x + 4, floor, house_z}, tri)

	insert_south_floor_tile_triangle({house_x, floor, house_z + 4}, tri)
	insert_east_floor_tile_triangle({house_x, floor, house_z + 4}, tri)

	insert_north_floor_tile_triangle({house_x, floor, house_z + 6}, tri)
	insert_east_floor_tile_triangle({house_x, floor, house_z + 6}, tri)

	insert_south_floor_tile_triangle({house_x + 4, floor, house_z + 10}, tri)
	insert_west_floor_tile_triangle({house_x + 4, floor, house_z + 10}, tri)

	for x in 0 ..< 4 {
		for z in 0 ..< 4 {
			insert_floor_tile({house_x + i32(x), floor, house_z + i32(z)}, tri)
		}
	}

	for x in 0 ..< 3 {
		for z in 0 ..< 3 {
			insert_floor_tile(
				{house_x + i32(x) + 1, floor, house_z + i32(z) + 4},
				tri,
			)
		}
	}

	for x in 0 ..< 4 {
		for z in 0 ..< 4 {
			insert_floor_tile(
				{house_x + i32(x), floor, house_z + i32(z) + 7},
				tri,
			)
		}
	}

	for z in 0 ..< 9 {
		insert_floor_tile({house_x + 4, floor, house_z + i32(z) + 1}, tri)
	}
}

add_house_floor_walls :: proc(
	floor: i32,
	inside_texture: Wall_Texture,
	outside_texture: Wall_Texture,
) {
	// The house's front wall
	insert_north_south_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z)},
			type = .Side_Right_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)
	for i in 0 ..< 2 {
		insert_north_south_wall(
			 {
				pos =  {
					f32(house_x),
					f32(floor * WALL_HEIGHT),
					f32(house_z + i32(i) + 1),
				},
				type = .Side_Side,
				textures = {.Inside = inside_texture, .Outside = outside_texture},
			},
		)
	}
	insert_north_south_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z + 3)},
			type = .Right_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	insert_south_west_north_east_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z + 4)},
			type = .Side_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	// door?
	mask := Wall_Mask_Texture.Window_Opening
	if floor == 0 do mask = .Door_Opening
	insert_north_south_wall(
		 {
			pos =  {
				f32(house_x + 1),
				f32(floor * WALL_HEIGHT),
				f32(house_z + 5),
			},
			type = .Left_Corner_Left_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
			mask = mask,
		},
	)
	if floor > 0 {
		append_billboard(
			 {
				position =  {
					f32(house_x + 1),
					f32(floor * WALL_HEIGHT),
					f32(house_z + 5),
				},
				light = {1, 1, 1},
				texture = .Window_Wood_SE,
				depth_map = .Window_Wood_SE,
			},
		)
	} else {
		append_billboard(
			 {
				position = {f32(house_x + 1), f32(floor), f32(house_z + 5)},
				light = {1, 1, 1},
				texture = .Door_Wood_SE,
				depth_map = .Door_Wood_SE,
			},
		)
	}

	insert_north_west_south_east_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z + 6)},
			type = .End_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	insert_north_south_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z + 7)},
			type = .Side_Right_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	for i in 0 ..< 2 {
		insert_north_south_wall(
			 {
				pos =  {
					f32(house_x),
					f32(floor * WALL_HEIGHT),
					f32(house_z + i32(i) + 8),
				},
				type = .Side_Side,
				textures = {.Inside = inside_texture, .Outside = outside_texture},
				mask = .Window_Opening,
			},
		)
		append_billboard(
			 {
				position =  {
					f32(house_x),
					f32(floor * WALL_HEIGHT),
					f32(house_z + i32(i) + 8),
				},
				light = {1, 1, 1},
				texture = .Window_Wood_SE,
				depth_map = .Window_Wood_SE,
			},
		)
	}

	insert_north_south_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z + 10)},
			type = .Right_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	// The house's right side wall
	insert_east_west_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z)},
			type = .Left_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	for i in 0 ..< 2 {
		insert_east_west_wall(
			 {
				pos =  {
					f32(house_x + i32(i) + 1),
					f32(floor * WALL_HEIGHT),
					f32(house_z),
				},
				type = .Side_Side,
				textures = {.Inside = inside_texture, .Outside = outside_texture},
				mask = .Window_Opening,
			},
		)

		append_billboard(
			 {
				position =  {
					f32(house_x + i32(i) + 1),
					f32(floor * WALL_HEIGHT),
					f32(house_z),
				},
				light = {1, 1, 1},
				texture = .Window_Wood_SW,
				depth_map = .Window_Wood_SW,
			},
		)
	}

	insert_east_west_wall(
		 {
			pos = {f32(house_x + 3), f32(floor * WALL_HEIGHT), f32(house_z)},
			type = .Side_Left_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	// The house's left side wall
	insert_east_west_wall(
		 {
			pos = {f32(house_x), f32(floor * WALL_HEIGHT), f32(house_z + 11)},
			type = .Right_Corner_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	for i in 0 ..< 2 {
		insert_east_west_wall(
			 {
				pos =  {
					f32(house_x + i32(i) + 1),
					f32(floor * WALL_HEIGHT),
					f32(house_z + 11),
				},
				type = .Side_Side,
				textures = {.Inside = outside_texture, .Outside = inside_texture},
				mask = .Window_Opening,
			},
		)

		append_billboard(
			 {
				position =  {
					f32(house_x + i32(i) + 1),
					f32(floor * WALL_HEIGHT),
					f32(house_z + 11),
				},
				light = {1, 1, 1},
				texture = .Window_Wood_SW,
				depth_map = .Window_Wood_SW,
			},
		)
	}
	insert_east_west_wall(
		 {
			pos =  {
				f32(house_x + 3),
				f32(floor * WALL_HEIGHT),
				f32(house_z + 11),
			},
			type = .Side_Right_Corner,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	// The house's back wall
	insert_south_west_north_east_wall(
		 {
			pos = {f32(house_x + 4), f32(floor * WALL_HEIGHT), f32(house_z)},
			type = .Side_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	insert_north_south_wall(
		 {
			pos =  {
				f32(house_x + 5),
				f32(floor * WALL_HEIGHT),
				f32(house_z + 1),
			},
			type = .Side_Left_Corner,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	for i in 0 ..< 7 {
		insert_north_south_wall(
			 {
				pos =  {
					f32(house_x + 5),
					f32(floor * WALL_HEIGHT),
					f32(house_z + i32(i) + 2),
				},
				type = .Side_Side,
				textures = {.Inside = outside_texture, .Outside = inside_texture},
			},
		)
	}

	insert_north_south_wall(
		 {
			pos =  {
				f32(house_x + 5),
				f32(floor * WALL_HEIGHT),
				f32(house_z + 9),
			},
			type = .Left_Corner_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	insert_north_west_south_east_wall(
		 {
			pos =  {
				f32(house_x + 4),
				f32(floor * WALL_HEIGHT),
				f32(house_z + 10),
			},
			type = .End_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)
}

draw_world :: proc() {
	// sort the draw components? 
	draw_terrain()
	draw_floor_tiles()

	uniform_object.view = camera_view
	uniform_object.proj = camera_proj

	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)
	gl.BufferSubData(
		gl.UNIFORM_BUFFER,
		0,
		size_of(Uniform_Object),
		&uniform_object,
	)

	gl.UseProgram(shader_program)

	start_wall_rendering()
	draw_walls()
	draw_diagonal_walls()
	finish_wall_rendering()


	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(world_vertices) * size_of(Vertex),
		raw_data(world_vertices),
		gl.STATIC_DRAW,
	)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	gl.BindVertexArray(vao)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, mask_array)

	gl.DrawElements(
		gl.TRIANGLES,
		i32(len(world_indices)),
		gl.UNSIGNED_INT,
		raw_data(world_indices),
	)
	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}
