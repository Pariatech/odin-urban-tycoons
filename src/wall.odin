package main

import "core:fmt"
import m "core:math/linalg/glsl"

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
    Varg,
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

Wall :: struct {
	y:       f32,
	type:    Wall_Type,
	texture: Wall_Texture,
}

WALL_HEIGHT :: 3

WALL_TEXTURE_MAP :: [Wall_Texture][Wall_Texture_Position]Texture {
	.Brick = {.Base = .Brick_Wall_Side_Base, .Top = .Brick_Wall_Side_Top},
    .Varg = {.Base = .Varg_Wall_Side_Base, .Top = .Varg_Wall_Side_Top},
}

WALL_TRANSLATION_MAP :: [Wall_Axis][Camera_Rotation]m.vec3 {
	.North_South =  {
		.South_West = {0, 0, 0},
		.South_East = {-1, 0, 0},
		.North_East = {-1, 0, 0},
		.North_West = {0, 0, 0},
	},
	.East_West =  {
		.South_West = {0, 0, 0},
		.South_East = {0, 0, 0},
		.North_East = {0, 0, -1},
		.North_West = {0, 0, -1},
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
			.South_West = .End,
			.South_East = .Full,
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
			.North_East = .Full,
			.North_West = .End,
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
			.South_West = .Full,
			.South_East = .End,
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
			.North_East = .End,
			.North_West = .Full,
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
			.North_East = .Extended_Side,
			.North_West = .Side,
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
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
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

WALL_MIRROR_MAP :: [Wall_Axis][Camera_Rotation]Sprite_Mirror {
	.North_South =  {
		.South_West = .No,
		.South_East = .Yes,
		.North_East = .No,
		.North_West = .Yes,
	},
	.East_West =  {
		.South_West = .Yes,
		.South_East = .No,
		.North_East = .Yes,
		.North_West = .No,
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

draw_wall :: proc(wall: Wall, pos: m.ivec3, axis: Wall_Axis) {
	mirror_map := WALL_MIRROR_MAP
	texture_map := WALL_TEXTURE_MAP
	mask_map := WALL_MASK_MAP
	mask_texture_map := WALL_MASK_TEXTURE_MAP
	wall_translation_map := WALL_TRANSLATION_MAP

	texture := texture_map[wall.texture]
	mask := mask_map[wall.type][axis][camera_rotation]
	mask_texture := mask_texture_map[mask]
	translation := wall_translation_map[axis][camera_rotation]
	position := m.vec3{f32(pos.x), wall.y, f32(pos.z)} + translation

	sprite := Sprite {
		position = position,
		texture = texture[.Base],
		mask_texture = mask_texture[.Base],
		mirror = mirror_map[axis][camera_rotation],
		lights = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}, {1, 1, 1}},
	}


	draw_sprite(sprite)

	sprite.position.y += SPRITE_HEIGHT
	sprite.texture = texture[.Top]
	sprite.mask_texture = mask_texture[.Top]
	draw_sprite(sprite)

    sprite.texture = .Wall_Top
    sprite.position.y += WALL_HEIGHT - SPRITE_HEIGHT - 0.005
	draw_sprite(sprite)
}

draw_tile_walls :: proc(x, z, floor: i32) {
	north_south_key := m.ivec3{x, floor, z}
    #partial switch camera_rotation {
        case .South_East, .North_East:
            north_south_key.x += 1
    }
	if wall, ok := north_south_walls[north_south_key]; ok {
		draw_wall(wall, north_south_key, .North_South)
	}

	east_west_key := m.ivec3{x, floor, z}
    #partial switch camera_rotation {
        case .North_East, .North_West:
            east_west_key.z += 1
    }
	if wall, ok := east_west_walls[east_west_key]; ok {
		draw_wall(wall, east_west_key, .East_West)
	}
}

insert_north_south_wall :: proc(pos: m.ivec3, wall: Wall) {
	north_south_walls[pos] = wall
}

insert_east_west_wall :: proc(pos: m.ivec3, wall: Wall) {
	east_west_walls[pos] = wall
}
