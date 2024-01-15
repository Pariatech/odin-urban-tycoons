package main


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
	Right_Corner_RightCorner,
	Left_Corner_Right_Corner,
	Right_Corner_Left_Corner,
}

Wall_Sprite :: enum {
	Brick,
}

Wall_Sprite_Position :: enum {
	Base,
	Top,
}

WALL_SPRITE_MAP :: [Wall_Sprite][Wall_Sprite_Position]Sprite {
	.Brick = {.Base = .Brick_Wall_Side_Base, .Top = .Brick_Wall_Side_Top},
}

Wall_Mask :: enum {
	Full,
	Extended_Side,
	Side,
	End,
}

WALL_TRANSLATION_MAP :: [Wall_Axis][Camera_Rotiation]Vec3 {
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

Wall_Mirror :: enum {
	Yes,
	No,
}

WALL_MIRROR_MAP :: [Wall_Axis][Camera_Rotiation]Wall_Mirror {
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

WALL_MASK_SPRITE_MAP :: [Wall_Mask][Wall_Sprite_Position]Sprite {
	.Full = {.Base = .Full_Mask, .Top = .Full_Mask},
	.Extended_Side =  {
		.Base = .Extended_Side_Wall_Base_Mask,
		.Top = .Extended_Side_Wall_Top_Mask,
	},
	.Side = {.Base = .Side_Wall_Base_Mask, .Top = .Side_Wall_Top_Mask},
	.End = {.Base = .End_Wall_Base_Mask, .Top = .End_Wall_Top_Mask},
}

Wall :: struct {
	type:   Wall_Type,
	sprite: Wall_Sprite,
}

WALL_VERTICES :: [Wall_Mirror][4]Vertex{
    }

draw_wall :: proc(pos: IVec3, axis: Wall_Axis) {
	// draw_quad()
}
