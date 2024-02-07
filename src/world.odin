package main

import m "core:math/linalg/glsl"

WORLD_WIDTH :: 64
WORLD_HEIGHT :: 4
WORLD_DEPTH :: 64

sun := m.vec3{0, -1, 0}

house_x: i32 = 32
house_z: i32 = 32

init_world :: proc() {
	for x in 0 ..< WORLD_WIDTH {
		for z in 0 ..< WORLD_DEPTH {
			for side in Tile_Triangle_Side {
				set_terrain_tile_triangle(side, x, z, .Grass, .Grid_Mask)
			}
		}
	}
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
	add_house_floor_walls(0, .Varg)
	add_house_floor_walls(1, .Nyana)
	add_house_floor_triangles(2, .Wood)

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

	append_billboard(
		 {
			position = {0.0, 0.0, 0.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_SW,
			depth_map = .Chair_Wood_SW,
		},
	)

	append_billboard(
		 {
			position = {1.0, 0.0, 0.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_SW,
			depth_map = .Chair_Wood_SW,
            rotation = 1,
		},
	)

	append_billboard(
		 {
			position = {2.0, 0.0, 0.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_SW,
			depth_map = .Chair_Wood_SW,
            rotation = 2,
		},
	)

	append_billboard(
		 {
			position = {3.0, 0.0, 0.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_SW,
			depth_map = .Chair_Wood_SW,
            rotation = 3,
		},
	)

	append_billboard(
		 {
			position = {0.0, 0.0, 1.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_NE,
			depth_map = .Chair_Wood_NE,
		},
	)

	append_billboard(
		 {
			position = {1.0, 0.0, 1.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_NE,
			depth_map = .Chair_Wood_NE,
            rotation = 1,
		},
	)

	append_billboard(
		 {
			position = {2.0, 0.0, 1.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_NE,
			depth_map = .Chair_Wood_NE,
            rotation = 2,
		},
	)

	append_billboard(
		 {
			position = {3.0, 0.0, 1.0},
			light = {1, 1, 1},
			texture = .Chair_Wood_NE,
			depth_map = .Chair_Wood_NE,
            rotation = 3,
		},
	)


	append_four_tiles_billboard(
		 {
			position = {0.5, 0.0, 3.5},
			light = {1, 1, 1},
			texture = .Table_Wood_SW,
			depth_map = .Table_Wood_SW,
            rotation = 0,
		},
	)

	append_four_tiles_billboard(
		 {
			position = {3.5, 0.0, 3.5},
			light = {1, 1, 1},
			texture = .Table_8_Places_Wood_SW,
			depth_map = .Table_8_Places_Wood_SW,
            rotation = 0,
		},
	)

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

add_house_floor_walls :: proc(floor: i32, inside_texture: Texture) {
	// The house's front wall
	insert_north_south_wall(
		{house_x, floor, house_z},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)
	for i in 0 ..< 2 {
		insert_north_south_wall(
			{house_x, floor, house_z + i32(i) + 1},
			 {
				type = .Side_Side,
				textures = {.Inside = inside_texture, .Outside = .Brick},
			},
		)
	}
	insert_north_south_wall(
		{house_x, floor, house_z + 3},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)

	insert_south_west_north_east_wall(
		{house_x, floor, house_z + 4},
		 {
			type = .Side_Side,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)

	// door?
	mask := Texture.Window_Opening
	if floor == 0 do mask = .Door_Opening
	insert_north_south_wall(
		{house_x + 1, floor, house_z + 5},
		 {
			type = .Left_Corner_Left_Corner,
			textures = {.Inside = inside_texture, .Outside = .Brick},
			mask = mask,
		},
	)
	if floor > 0 {
		insert_wall_window(
			.North_South,
			{house_x + 1, floor, house_z + 5},
			{texture = .Medium_Window_Wood},
		)
	} else {
		insert_wall_door(
			.North_South,
			{house_x + 1, floor, house_z + 5},
			{model = .Wood},
		)
	}

	insert_north_west_south_east_wall(
		{house_x, floor, house_z + 6},
		 {
			type = .End_Side,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)

	insert_north_south_wall(
		{house_x, floor, house_z + 7},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)

	for i in 0 ..< 2 {
		insert_north_south_wall(
			{house_x, floor, house_z + i32(i) + 8},
			 {
				type = .Side_Side,
				textures = {.Inside = inside_texture, .Outside = .Brick},
				mask = .Window_Opening,
			},
		)
		insert_wall_window(
			.North_South,
			{house_x, floor, house_z + i32(i) + 8},
			{texture = .Medium_Window_Wood},
		)
	}

	insert_north_south_wall(
		{house_x, floor, house_z + 10},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)

	// The house's right side wall
	insert_east_west_wall(
		{house_x, floor, house_z},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)

	for i in 0 ..< 2 {
		insert_east_west_wall(
			{house_x + i32(i) + 1, floor, house_z},
			 {
				type = .Side_Side,
				textures = {.Inside = inside_texture, .Outside = .Brick},
				mask = .Window_Opening,
			},
		)

		insert_wall_window(
			.East_West,
			{house_x + i32(i) + 1, floor, house_z},
			{texture = .Medium_Window_Wood},
		)
	}

	insert_east_west_wall(
		{house_x + 3, floor, house_z},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = inside_texture, .Outside = .Brick},
		},
	)

	// The house's left side wall
	insert_east_west_wall(
		{house_x, floor, house_z + 11},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = .Brick, .Outside = inside_texture},
		},
	)

	for i in 0 ..< 2 {
		insert_east_west_wall(
			{house_x + i32(i) + 1, floor, house_z + 11},
			 {
				type = .Side_Side,
				textures = {.Inside = .Brick, .Outside = inside_texture},
				mask = .Window_Opening,
			},
		)

		insert_wall_window(
			.East_West,
			{house_x + i32(i) + 1, floor, house_z + 11},
			{texture = .Medium_Window_Wood},
		)
	}
	insert_east_west_wall(
		{house_x + 3, floor, house_z + 11},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = .Brick, .Outside = inside_texture},
		},
	)

	// The house's back wall
	insert_south_west_north_east_wall(
		{house_x + 4, floor, house_z},
		 {
			type = .Side_Side,
			textures = {.Inside = .Brick, .Outside = inside_texture},
		},
	)

	insert_north_south_wall(
		{house_x + 5, floor, house_z + 1},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = .Brick, .Outside = inside_texture},
		},
	)

	for i in 0 ..< 7 {
		insert_north_south_wall(
			{house_x + 5, floor, house_z + i32(i) + 2},
			 {
				type = .Side_Side,
				textures = {.Inside = .Brick, .Outside = inside_texture},
			},
		)
	}

	insert_north_south_wall(
		{house_x + 5, floor, house_z + 9},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = .Brick, .Outside = inside_texture},
		},
	)

	insert_north_west_south_east_wall(
		{house_x + 4, floor, house_z + 10},
		 {
			type = .End_Side,
			textures = {.Inside = .Brick, .Outside = inside_texture},
		},
	)
}

rotate_world :: proc() {
	clear_draw_components()
	rotate_chairs()
	rotate_tables()
	rotate_doors()
	rotate_windows()
	rotate_walls()
	rotate_diagonal_walls()
}

draw_world :: proc() {
	// sort the draw components? 
	draw_terrain()
	for draw_component in draw_components {
		draw(draw_component)
	}
}
