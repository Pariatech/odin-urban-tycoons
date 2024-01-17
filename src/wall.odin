package main

import "core:fmt"

Wall_Axis :: enum {
	North_South,
	East_West,
}

Wall_Type :: enum {
	End_End,
	Side_Side,
	End_Side,
	Side_End,
	Left_Corner_End,
	End_Left_Corner,
	Right_Corner_End,
	End_Right_Corner,
	Left_Corner_Side,
	Side_Left_Corner,
	Right_Corner_Side,
	Side_Right_Corner,
	Left_Corner_Left_Corner,
	Right_Corner_Right_Corner,
	Left_Corner_Right_Corner,
	Right_Corner_Left_Corner,
}

Wall_Texture :: enum {
	Brick,
}

Wall_Texture_Position :: enum {
	Base,
	Top,
}

Wall_Mask :: enum {
	Full,
	Extended_Side,
	Side,
	End,
}

Wall_Mirror :: enum {
	Yes,
	No,
}

Wall :: struct {
	type:    Wall_Type,
	texture: Wall_Texture,
}

WALL_TEXTURE_MAP :: [Wall_Texture][Wall_Texture_Position]Texture {
	.Brick = {.Base = .Brick_Wall_Side_Base, .Top = .Brick_Wall_Side_Top},
}

WALL_TRANSLATION_MAP :: [Wall_Axis][Camera_Rotation]Vec3 {
	.North_South =  {
		.South_West = {0, 0, 0},
		.South_East = {0, 0, -1},
		.North_East = {0, 0, -1},
		.North_West = {0, 0, 0},
	},
	.East_West =  {
		.South_West = {0, 0, 0},
		.South_East = {0, 0, 0},
		.North_East = {-1, 0, 0},
		.North_West = {-1, 0, 0},
	},
}

WALL_MASK_MAP :: [Wall_Type][Wall_Axis][Camera_Rotation]Wall_Mask {
	.End_End =  {
		.North_South =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
		.East_West =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.Side_Side =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.End_Side =  {
		.North_South =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .End,
			.North_West = .End,
		},
		.East_West =  {
			.South_West = .End,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .End,
		},
	},
	.Side_End =  {
		.North_South =  {
			.South_West = .End,
			.South_East = .End,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
		.East_West =  {
			.South_West = .Extended_Side,
			.South_East = .End,
			.North_East = .End,
			.North_West = .Extended_Side,
		},
	},
	.Left_Corner_End =  {
		.North_South =  {
			.South_West = .Full,
			.South_East = .End,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
		.East_West =  {
			.South_West = .Extended_Side,
			.South_East = .Full,
			.North_East = .End,
			.North_West = .Extended_Side,
		},
	},
	.End_Left_Corner =  {
		.North_South =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .End,
			.North_West = .Full,
		},
		.East_West =  {
			.South_West = .Full,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .End,
		},
	},
	.Right_Corner_End =  {
		.North_South =  {
			.South_West = .End,
			.South_East = .Full,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
		.East_West =  {
			.South_West = .Extended_Side,
			.South_East = .End,
			.North_East = .Full,
			.North_West = .Extended_Side,
		},
	},
	.End_Right_Corner =  {
		.North_South =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .Full,
			.North_West = .End,
		},
		.East_West =  {
			.South_West = .End,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .Full,
		},
	},
	.Left_Corner_Side =  {
		.North_South =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Side_Left_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
		.East_West =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Right_Corner_Side =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
	},
	.Side_Right_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
	},
	.Left_Corner_Left_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Right_Corner_Right_Corner =  {
		.North_South =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
	},
	.Left_Corner_Right_Corner =  {
		.North_South =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
	},
	.Right_Corner_Left_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
		.East_West =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
	},
}

WALL_MIRROR_MAP :: [Wall_Axis][Camera_Rotation]Wall_Mirror {
	.North_South =  {
		.South_West = .Yes,
		.South_East = .No,
		.North_East = .Yes,
		.North_West = .No,
	},
	.East_West =  {
		.South_West = .No,
		.South_East = .Yes,
		.North_East = .No,
		.North_West = .Yes,
	},
}

WALL_MASK_TEXTURE_MAP :: [Wall_Mask][Wall_Texture_Position]Texture {
	.Full = {.Base = .Full_Mask, .Top = .Full_Mask},
	.Extended_Side =  {
		.Base = .Extended_Side_Wall_Base_Mask,
		.Top = .Extended_Side_Wall_Top_Mask,
	},
	.Side = {.Base = .Side_Wall_Base_Mask, .Top = .Side_Wall_Top_Mask},
	.End = {.Base = .End_Wall_Base_Mask, .Top = .End_Wall_Top_Mask},
}

WALL_WIDTH :: 1.115
SPRITE_HEIGHT :: 1.9312
WALL_START :: 0.0575
WALL_END :: 1.0575

WALL_VERTEX_POSITION_MAP :: [Camera_Rotation][4]Vec3 {
	.South_West =  {
		{-WALL_END, 0.0, WALL_START},
		{-WALL_END, SPRITE_HEIGHT, WALL_START},
		{WALL_START, SPRITE_HEIGHT, -WALL_END},
		{WALL_START, 0.0, -WALL_END},
	},
	.South_East =  {
		{WALL_START, 0.0, WALL_END},
		{WALL_START, SPRITE_HEIGHT, WALL_END},
		{-WALL_END, SPRITE_HEIGHT, -WALL_START},
		{-WALL_END, 0.0, -WALL_START},
	},
	.North_East =  {
		{WALL_END, 0.0, -WALL_START},
		{WALL_END, SPRITE_HEIGHT, -WALL_START},
		{-WALL_START, SPRITE_HEIGHT, WALL_END},
		{-WALL_START, 0.0, WALL_END},
	},
	.North_West =  {
		{-WALL_START, 0.0, -WALL_END},
		{-WALL_START, SPRITE_HEIGHT, -WALL_END},
		{WALL_END, SPRITE_HEIGHT, WALL_START},
		{WALL_END, 0.0, WALL_START},
	},
}

WALL_VERTEX_TEXCOORDS_MAP :: [Wall_Mirror][4]Vec4 {
	.Yes = {{0, 1, 0, 0}, {0, 0, 0, 0}, {1, 0, 0, 0}, {1, 1, 0, 0}},
	.No = {{1, 1, 0, 0}, {1, 0, 0, 0}, {0, 0, 0, 0}, {0, 1, 0, 0}},
}

draw_wall :: proc(wall: Wall, pos: IVec3, axis: Wall_Axis) {
	position_map := WALL_VERTEX_POSITION_MAP
	texcoords_map := WALL_VERTEX_TEXCOORDS_MAP
	mirror_map := WALL_MIRROR_MAP
	texture_map := WALL_TEXTURE_MAP
	mask_map := WALL_MASK_MAP
	mask_texture_map := WALL_MASK_TEXTURE_MAP
	positions := position_map[camera_rotation]
	texcoords := texcoords_map[mirror_map[axis][camera_rotation]]
	texture := texture_map[wall.texture]
	mask := mask_map[wall.type][axis][camera_rotation]
	mask_texture := mask_texture_map[mask]
	light := Vec3{1, 1, 1}
	vertices: [4]Vertex

	for i in 0 ..< len(vertices) {
		texcoords[i].z = f32(texture[.Base])
		texcoords[i].w = f32(mask_texture[.Base])
	    positions[i] += Vec3{f32(pos.x), 0, f32(pos.z)}
		vertices[i] = {
			pos       = positions[i],
			light     = light,
			texcoords = texcoords[i],
		}
	}

    fmt.println(vertices)
	draw_quad(vertices[0], vertices[1], vertices[2], vertices[3])

	for i in 0 ..< len(vertices) {
		texcoords[i].z = f32(texture[.Top])
		texcoords[i].w = f32(mask_texture[.Top])
		positions[i] += Vec3{0, SPRITE_HEIGHT, 0}
		vertices[i] = {
			pos       = positions[i],
			light     = light,
			texcoords = texcoords[i],
		}
	}

	draw_quad(vertices[0], vertices[1], vertices[2], vertices[3])
}

draw_tile_walls :: proc(x, z, floor: int) {
	north_south_key := IVec3{x, floor, z}
	if wall, ok := north_south_walls[north_south_key]; ok {
		draw_wall(wall, north_south_key, .North_South)
	}

	east_west_key := IVec3{x, floor, z}
	if wall, ok := east_west_walls[east_west_key]; ok {
		draw_wall(wall, east_west_key, .East_West)
	}
}

insert_north_south_wall :: proc(pos: IVec3, wall: Wall) {
	north_south_walls[pos] = wall
}

insert_east_west_wall :: proc(pos: IVec3, wall: Wall) {
	east_west_walls[pos] = wall
}
