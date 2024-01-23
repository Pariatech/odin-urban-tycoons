package main

import m "core:math/linalg/glsl"

Diagonal_Wall_Axis :: enum {
	South_West_North_East,
	North_West_South_East,
}

Diagonal_Wall_Mask :: enum {
	Full,
	Side,
	Left_Extension,
	Right_Extension,
}

DIAGONAL_WALL_MASK_TEXTURE_MAP ::
	[Diagonal_Wall_Mask][Wall_Texture_Position]Texture {
		.Full = {.Base = .Full_Mask, .Top = .Full_Mask},
		.Side =  {
			.Base = .Diagonal_Wall_Base_Mask,
			.Top = .Diagonal_Wall_Top_Mask,
		},
		.Left_Extension =  {
			.Base = .Extended_Left_Diagonal_Wall_Base_Mask,
			.Top = .Extended_Left_Diagonal_Wall_Top_Mask,
		},
		.Right_Extension =  {
			.Base = .Extended_Right_Diagonal_Wall_Base_Mask,
			.Top = .Extended_Right_Diagonal_Wall_Top_Mask,
		},
	}

DIAGONAL_WALL_TOP_TEXTURE_MAP :: [Diagonal_Wall_Axis]Texture {
		.South_West_North_East = .Wall_Top_Diagonal_Cross,
		.North_West_South_East = .Wall_Top_Diagonal,
	}

DIAGONAL_WALL_MASK_MAP ::
	[Diagonal_Wall_Axis][Camera_Rotation][Wall_Type]Diagonal_Wall_Mask {
		.South_West_North_East =  {
			.South_West =  {
				.End_End = .Full,
				.Side_Side = .Full,
				.End_Side = .Full,
				.Side_End = .Full,
				.Left_Corner_End = .Full,
				.End_Left_Corner = .Full,
				.Right_Corner_End = .Full,
				.End_Right_Corner = .Full,
				.Left_Corner_Side = .Full,
				.Side_Left_Corner = .Full,
				.Right_Corner_Side = .Full,
				.Side_Right_Corner = .Full,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Full,
				.Right_Corner_Left_Corner = .Full,
			},
			.South_East =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Left_Extension,
				.End_Left_Corner = .Right_Extension,
				.Right_Corner_End = .Side,
				.End_Right_Corner = .Side,
				.Left_Corner_Side = .Left_Extension,
				.Side_Left_Corner = .Right_Extension,
				.Right_Corner_Side = .Side,
				.Side_Right_Corner = .Side,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Side,
				.Left_Corner_Right_Corner = .Left_Extension,
				.Right_Corner_Left_Corner = .Right_Extension,
			},
			.North_East =  {
				.End_End = .Full,
				.Side_Side = .Full,
				.End_Side = .Full,
				.Side_End = .Full,
				.Left_Corner_End = .Full,
				.End_Left_Corner = .Full,
				.Right_Corner_End = .Full,
				.End_Right_Corner = .Full,
				.Left_Corner_Side = .Full,
				.Side_Left_Corner = .Full,
				.Right_Corner_Side = .Full,
				.Side_Right_Corner = .Full,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Full,
				.Right_Corner_Left_Corner = .Full,
			},
			.North_West =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Side,
				.End_Left_Corner = .Side,
				.Right_Corner_End = .Right_Extension,
				.End_Right_Corner = .Left_Extension,
				.Left_Corner_Side = .Side,
				.Side_Left_Corner = .Side,
				.Right_Corner_Side = .Right_Extension,
				.Side_Right_Corner = .Left_Extension,
				.Left_Corner_Left_Corner = .Side,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Left_Extension,
				.Right_Corner_Left_Corner = .Right_Extension,
			},
		},
		.North_West_South_East =  {
			.South_West =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Left_Extension,
				.End_Left_Corner = .Right_Extension,
				.Right_Corner_End = .Side,
				.End_Right_Corner = .Side,
				.Left_Corner_Side = .Left_Extension,
				.Side_Left_Corner = .Right_Extension,
				.Right_Corner_Side = .Side,
				.Side_Right_Corner = .Side,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Side,
				.Left_Corner_Right_Corner = .Left_Extension,
				.Right_Corner_Left_Corner = .Right_Extension,
			},
			.South_East =  {
				.End_End = .Full,
				.Side_Side = .Full,
				.End_Side = .Full,
				.Side_End = .Full,
				.Left_Corner_End = .Full,
				.End_Left_Corner = .Full,
				.Right_Corner_End = .Full,
				.End_Right_Corner = .Full,
				.Left_Corner_Side = .Full,
				.Side_Left_Corner = .Full,
				.Right_Corner_Side = .Full,
				.Side_Right_Corner = .Full,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Full,
				.Right_Corner_Left_Corner = .Full,
			},
			.North_East =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Side,
				.End_Left_Corner = .Side,
				.Right_Corner_End = .Right_Extension,
				.End_Right_Corner = .Left_Extension,
				.Left_Corner_Side = .Side,
				.Side_Left_Corner = .Side,
				.Right_Corner_Side = .Right_Extension,
				.Side_Right_Corner = .Left_Extension,
				.Left_Corner_Left_Corner = .Side,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Left_Extension,
				.Right_Corner_Left_Corner = .Right_Extension,
			},
			.North_West =  {
				.End_End = .Full,
				.Side_Side = .Full,
				.End_Side = .Full,
				.Side_End = .Full,
				.Left_Corner_End = .Full,
				.End_Left_Corner = .Full,
				.Right_Corner_End = .Full,
				.End_Right_Corner = .Full,
				.Left_Corner_Side = .Full,
				.Side_Left_Corner = .Full,
				.Right_Corner_Side = .Full,
				.Side_Right_Corner = .Full,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Full,
				.Right_Corner_Left_Corner = .Full,
			},
		},
	}

DIAGONAL_WALL_TOP_MASK_MAP ::
	[Diagonal_Wall_Axis][Camera_Rotation][Wall_Type]Texture {
		.South_West_North_East =  {
			.South_West =  {
				.End_End = .Full_Mask,
				.Side_Side = .Full_Mask,
				.End_Side = .Full_Mask,
				.Side_End = .Full_Mask,
				.Left_Corner_End = .Full_Mask,
				.End_Left_Corner = .Full_Mask,
				.Right_Corner_End = .Full_Mask,
				.End_Right_Corner = .Full_Mask,
				.Left_Corner_Side = .Full_Mask,
				.Side_Left_Corner = .Full_Mask,
				.Right_Corner_Side = .Full_Mask,
				.Side_Right_Corner = .Full_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
			.South_East =  {
				.End_End = .Diagonal_Wall_Top_Mask,
				.Side_Side = .Diagonal_Wall_Top_Mask,
				.End_Side = .Diagonal_Wall_Top_Mask,
				.Side_End = .Diagonal_Wall_Top_Mask,
				.Left_Corner_End = .Extended_Left_Diagonal_Wall_Top_Mask,
				.End_Left_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Right_Corner_End = .Extended_Left_Diagonal_Wall_Top_Mask,
				.End_Right_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Left_Corner_Side = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Side_Left_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Right_Corner_Side = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Side_Right_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
			.North_East =  {
				.End_End = .Full_Mask,
				.Side_Side = .Full_Mask,
				.End_Side = .Full_Mask,
				.Side_End = .Full_Mask,
				.Left_Corner_End = .Full_Mask,
				.End_Left_Corner = .Full_Mask,
				.Right_Corner_End = .Full_Mask,
				.End_Right_Corner = .Full_Mask,
				.Left_Corner_Side = .Full_Mask,
				.Side_Left_Corner = .Full_Mask,
				.Right_Corner_Side = .Full_Mask,
				.Side_Right_Corner = .Full_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
			.North_West =  {
				.End_End = .Diagonal_Wall_Top_Mask,
				.Side_Side = .Diagonal_Wall_Top_Mask,
				.End_Side = .Diagonal_Wall_Top_Mask,
				.Side_End = .Diagonal_Wall_Top_Mask,
				.Left_Corner_End = .Extended_Right_Diagonal_Wall_Top_Mask,
				.End_Left_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Right_Corner_End = .Extended_Right_Diagonal_Wall_Top_Mask,
				.End_Right_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Left_Corner_Side = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Side_Left_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Right_Corner_Side = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Side_Right_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
		},
		.North_West_South_East =  {
			.South_West =  {
				.End_End = .Diagonal_Wall_Top_Mask,
				.Side_Side = .Diagonal_Wall_Top_Mask,
				.End_Side = .Diagonal_Wall_Top_Mask,
				.Side_End = .Diagonal_Wall_Top_Mask,
				.Left_Corner_End = .Extended_Left_Diagonal_Wall_Top_Mask,
				.End_Left_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Right_Corner_End = .Extended_Left_Diagonal_Wall_Top_Mask,
				.End_Right_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Left_Corner_Side = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Side_Left_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Right_Corner_Side = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Side_Right_Corner = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
			.South_East =  {
				.End_End = .Full_Mask,
				.Side_Side = .Full_Mask,
				.End_Side = .Full_Mask,
				.Side_End = .Full_Mask,
				.Left_Corner_End = .Full_Mask,
				.End_Left_Corner = .Full_Mask,
				.Right_Corner_End = .Full_Mask,
				.End_Right_Corner = .Full_Mask,
				.Left_Corner_Side = .Full_Mask,
				.Side_Left_Corner = .Full_Mask,
				.Right_Corner_Side = .Full_Mask,
				.Side_Right_Corner = .Full_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
			.North_East =  {
				.End_End = .Diagonal_Wall_Top_Mask,
				.Side_Side = .Diagonal_Wall_Top_Mask,
				.End_Side = .Diagonal_Wall_Top_Mask,
				.Side_End = .Diagonal_Wall_Top_Mask,
				.Left_Corner_End = .Extended_Right_Diagonal_Wall_Top_Mask,
				.End_Left_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Right_Corner_End = .Extended_Right_Diagonal_Wall_Top_Mask,
				.End_Right_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Left_Corner_Side = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Side_Left_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Right_Corner_Side = .Extended_Right_Diagonal_Wall_Top_Mask,
				.Side_Right_Corner = .Extended_Left_Diagonal_Wall_Top_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
			.North_West =  {
				.End_End = .Full_Mask,
				.Side_Side = .Full_Mask,
				.End_Side = .Full_Mask,
				.Side_End = .Full_Mask,
				.Left_Corner_End = .Full_Mask,
				.End_Left_Corner = .Full_Mask,
				.Right_Corner_End = .Full_Mask,
				.End_Right_Corner = .Full_Mask,
				.Left_Corner_Side = .Full_Mask,
				.Side_Left_Corner = .Full_Mask,
				.Right_Corner_Side = .Full_Mask,
				.Side_Right_Corner = .Full_Mask,
				.Left_Corner_Left_Corner = .Full_Mask,
				.Right_Corner_Right_Corner = .Full_Mask,
				.Left_Corner_Right_Corner = .Full_Mask,
				.Right_Corner_Left_Corner = .Full_Mask,
			},
		},
	}

DIAGONAL_WALL_ROTATION_MAP ::
	[Diagonal_Wall_Axis][Camera_Rotation]Diagonal_Wall_Axis {
		.South_West_North_East =  {
			.South_West = .South_West_North_East,
			.South_East = .North_West_South_East,
			.North_East = .South_West_North_East,
			.North_West = .North_West_South_East,
		},
		.North_West_South_East =  {
			.South_West = .North_West_South_East,
			.South_East = .South_West_North_East,
			.North_East = .North_West_South_East,
			.North_West = .South_West_North_East,
		},
	}

DIAGONAL_WALL_TEXTURE_MAP ::
	[Diagonal_Wall_Axis][Texture][Wall_Texture_Position]Texture {
		.South_West_North_East =  #partial {
			.Brick =  {
				.Base = .Brick_Wall_Cross_Diagonal_Base,
				.Top = .Brick_Wall_Cross_Diagonal_Top,
			},
			.Varg =  {
				.Base = .Varg_Wall_Cross_Diagonal_Base,
				.Top = .Varg_Wall_Cross_Diagonal_Top,
			},
			.Nyana =  {
				.Base = .Nyana_Wall_Cross_Diagonal_Base,
				.Top = .Nyana_Wall_Cross_Diagonal_Top,
			},
		},
		.North_West_South_East = #partial {
			.Brick =  {
				.Base = .Brick_Wall_Diagonal_Base,
				.Top = .Brick_Wall_Diagonal_Top,
			},
			.Varg =  {
				.Base = .Varg_Wall_Diagonal_Base,
				.Top = .Varg_Wall_Diagonal_Top,
			},
			.Nyana =  {
				.Base = .Nyana_Wall_Diagonal_Base,
				.Top = .Nyana_Wall_Diagonal_Top,
			},
		},
	}

DIAGONAL_WALL_DRAW_MAP ::
	[Diagonal_Wall_Axis][Wall_Type][Camera_Rotation]bool {
		.South_West_North_East =  {
			.End_End =  {
				.South_West = true,
				.South_East = true,
				.North_East = true,
				.North_West = true,
			},
			.Side_Side =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.End_Side =  {
				.South_West = true,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Side_End =  {
				.South_West = false,
				.South_East = true,
				.North_East = true,
				.North_West = true,
			},
			.Left_Corner_End =  {
				.South_West = false,
				.South_East = true,
				.North_East = true,
				.North_West = true,
			},
			.End_Left_Corner =  {
				.South_West = true,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Right_Corner_End =  {
				.South_West = false,
				.South_East = true,
				.North_East = true,
				.North_West = true,
			},
			.End_Right_Corner =  {
				.South_West = true,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Left_Corner_Side =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Side_Left_Corner =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Right_Corner_Side =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Side_Right_Corner =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Left_Corner_Left_Corner =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Right_Corner_Right_Corner =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Left_Corner_Right_Corner =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
			.Right_Corner_Left_Corner =  {
				.South_West = false,
				.South_East = true,
				.North_East = false,
				.North_West = true,
			},
		},
		.North_West_South_East =  {
			.End_End =  {
				.South_West = true,
				.South_East = true,
				.North_East = true,
				.North_West = true,
			},
			.Side_Side =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.End_Side =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = true,
			},
			.Side_End =  {
				.South_West = true,
				.South_East = true,
				.North_East = true,
				.North_West = false,
			},
			.Left_Corner_End =  {
				.South_West = true,
				.South_East = true,
				.North_East = true,
				.North_West = false,
			},
			.End_Left_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = true,
			},
			.Right_Corner_End =  {
				.South_West = true,
				.South_East = true,
				.North_East = true,
				.North_West = false,
			},
			.End_Right_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = true,
			},
			.Left_Corner_Side =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.Side_Left_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.Right_Corner_Side =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.Side_Right_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.Left_Corner_Left_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.Right_Corner_Right_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.Left_Corner_Right_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
			.Right_Corner_Left_Corner =  {
				.South_West = true,
				.South_East = false,
				.North_East = true,
				.North_West = false,
			},
		},
	}

DIAGONAL_WALL_SIDE_MAP :: [Diagonal_Wall_Axis][Camera_Rotation]Wall_Side {
		.South_West_North_East =  {
			.South_West = .Outside,
			.South_East = .Inside,
			.North_East = .Inside,
			.North_West = .Outside,
		},
		.North_West_South_East =  {
			.South_West = .Outside,
			.South_East = .Outside,
			.North_East = .Inside,
			.North_West = .Inside,
		},
	}

draw_diagonal_wall :: proc(
	wall: Wall,
	pos: m.ivec3,
	axis: Diagonal_Wall_Axis,
    y: f32
) {
	mask_texture_map := DIAGONAL_WALL_MASK_TEXTURE_MAP
	mask_map := DIAGONAL_WALL_MASK_MAP
	rotation_map := DIAGONAL_WALL_ROTATION_MAP
	texture_map := DIAGONAL_WALL_TEXTURE_MAP
	draw_map := DIAGONAL_WALL_DRAW_MAP
	top_texture_map := DIAGONAL_WALL_TOP_TEXTURE_MAP
	top_mask_map := DIAGONAL_WALL_TOP_MASK_MAP
	side_map := DIAGONAL_WALL_SIDE_MAP

	side := side_map[axis][camera_rotation]
	rotation := rotation_map[axis][camera_rotation]
	texture := texture_map[rotation][wall.textures[side]]
	mask := mask_map[axis][camera_rotation][wall.type]
	mask_texture := mask_texture_map[mask]
	draw := draw_map[axis][wall.type][camera_rotation]
	position := m.vec3{f32(pos.x), y, f32(pos.z)}

	sprite := Sprite {
			position = position,
			texture = texture[.Base],
			mask_texture = mask_texture[.Base],
			mirror = .No,
			lights = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1}},
		}


	if (draw) {
		draw_sprite(sprite)

		sprite.position.y += SPRITE_HEIGHT
		sprite.texture = texture[.Top]
		sprite.mask_texture = mask_texture[.Top]
		draw_sprite(sprite)
	}

	sprite.texture = top_texture_map[rotation]
	sprite.mask_texture = top_mask_map[axis][camera_rotation][wall.type]
	sprite.position.y = y + WALL_HEIGHT
	draw_sprite(sprite)
}

draw_tile_diagonal_walls :: proc(x, z, floor: i32, y: f32) {
	pos := m.ivec3{x, floor, z}
	if wall, ok := north_west_south_east_walls[pos]; ok {
		draw_diagonal_wall(wall, pos, .North_West_South_East, y)
	} else if wall, ok := south_west_north_east_walls[pos]; ok {
		draw_diagonal_wall(wall, pos, .South_West_North_East, y)
	}
}

insert_north_west_south_east_wall :: proc(pos: m.ivec3, wall: Wall) {
	north_west_south_east_walls[pos] = wall
}

insert_south_west_north_east_wall :: proc(pos: m.ivec3, wall: Wall) {
	south_west_north_east_walls[pos] = wall
}
