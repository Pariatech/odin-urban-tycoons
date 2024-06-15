package wall

import "core:fmt"
import "core:math/linalg"
import glsl "core:math/linalg/glsl"

import "../camera"
import "../constants"
import "../terrain"

Diagonal_Wall_Mask :: enum {
	Full,
	Side,
	Left_Extension,
	Right_Extension,
	Cross,
}

DIAGONAL_WALL_TOP_CROSS_OFFSET :: 0.0002
DIAGONAL_WALL_TOP_OFFSET :: 0.0003

diagonal_wall_vertices := [State][Diagonal_Wall_Mask][dynamic]Wall_Vertex{}
diagonal_wall_indices := [State][Diagonal_Wall_Mask][dynamic]Wall_Index{}

diagonal_wall_top_vertices := [State][Diagonal_Wall_Mask][dynamic]Wall_Vertex{}
diagonal_wall_top_indices := [State][Diagonal_Wall_Mask][dynamic]Wall_Index{}

DIAGONAL_WALL_MASK_MAP ::
	#partial [Wall_Axis][camera.Rotation][Wall_Type]Diagonal_Wall_Mask {
		.SW_NE =  {
			.South_West =  {
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
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
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
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
		.NW_SE =  {
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
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
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
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
			},
		},
	}

DIAGONAL_WALL_TOP_MASK_MAP ::
	#partial [Wall_Axis][camera.Rotation][Wall_Type]Diagonal_Wall_Mask {
		.SW_NE =  {
			.South_West =  {
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
			},
			.South_East =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Left_Extension,
				.End_Left_Corner = .Right_Extension,
				.Right_Corner_End = .Left_Extension,
				.End_Right_Corner = .Right_Extension,
				.Left_Corner_Side = .Left_Extension,
				.Side_Left_Corner = .Right_Extension,
				.Right_Corner_Side = .Left_Extension,
				.Side_Right_Corner = .Right_Extension,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Side,
				.Left_Corner_Right_Corner = .Left_Extension,
				.Right_Corner_Left_Corner = .Right_Extension,
			},
			.North_East =  {
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
			},
			.North_West =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Right_Extension,
				.End_Left_Corner = .Left_Extension,
				.Right_Corner_End = .Right_Extension,
				.End_Right_Corner = .Left_Extension,
				.Left_Corner_Side = .Right_Extension,
				.Side_Left_Corner = .Left_Extension,
				.Right_Corner_Side = .Right_Extension,
				.Side_Right_Corner = .Left_Extension,
				.Left_Corner_Left_Corner = .Side,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Left_Extension,
				.Right_Corner_Left_Corner = .Right_Extension,
			},
		},
		.NW_SE =  {
			.South_West =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Left_Extension,
				.End_Left_Corner = .Right_Extension,
				.Right_Corner_End = .Left_Extension,
				.End_Right_Corner = .Right_Extension,
				.Left_Corner_Side = .Left_Extension,
				.Side_Left_Corner = .Right_Extension,
				.Right_Corner_Side = .Left_Extension,
				.Side_Right_Corner = .Right_Extension,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Full,
				.Right_Corner_Left_Corner = .Full,
			},
			.South_East =  {
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
			},
			.North_East =  {
				.End_End = .Side,
				.Side_Side = .Side,
				.End_Side = .Side,
				.Side_End = .Side,
				.Left_Corner_End = .Right_Extension,
				.End_Left_Corner = .Left_Extension,
				.Right_Corner_End = .Right_Extension,
				.End_Right_Corner = .Left_Extension,
				.Left_Corner_Side = .Right_Extension,
				.Side_Left_Corner = .Left_Extension,
				.Right_Corner_Side = .Right_Extension,
				.Side_Right_Corner = .Left_Extension,
				.Left_Corner_Left_Corner = .Full,
				.Right_Corner_Right_Corner = .Full,
				.Left_Corner_Right_Corner = .Full,
				.Right_Corner_Left_Corner = .Full,
			},
			.North_West =  {
				.End_End = .Cross,
				.Side_Side = .Cross,
				.End_Side = .Cross,
				.Side_End = .Cross,
				.Left_Corner_End = .Cross,
				.End_Left_Corner = .Cross,
				.Right_Corner_End = .Cross,
				.End_Right_Corner = .Cross,
				.Left_Corner_Side = .Cross,
				.Side_Left_Corner = .Cross,
				.Right_Corner_Side = .Cross,
				.Side_Right_Corner = .Cross,
				.Left_Corner_Left_Corner = .Cross,
				.Right_Corner_Right_Corner = .Cross,
				.Left_Corner_Right_Corner = .Cross,
				.Right_Corner_Left_Corner = .Cross,
			},
		},
	}

DIAGONAL_WALL_ROTATION_MAP :: #partial [Wall_Axis][camera.Rotation]Wall_Axis {
		.SW_NE =  {
			.South_West = .SW_NE,
			.South_East = .NW_SE,
			.North_East = .SW_NE,
			.North_West = .NW_SE,
		},
		.NW_SE =  {
			.South_West = .NW_SE,
			.South_East = .SW_NE,
			.North_East = .NW_SE,
			.North_West = .SW_NE,
		},
	}

DIAGONAL_WALL_DRAW_MAP ::
	#partial [Wall_Axis][Wall_Type][camera.Rotation]bool {
		.SW_NE =  {
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
		.NW_SE =  {
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


DIAGONAL_WALL_TRANSFORM_MAP :: [camera.Rotation]glsl.mat4 {
		.South_West = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.South_East = {0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.North_East = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1},
		.North_West = {0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
	}


draw_diagonal_wall :: proc(
	pos: glsl.ivec3,
	wall: Wall,
	axis: Wall_Axis,
	vertex_buffer: ^[dynamic]Wall_Vertex,
	index_buffer: ^[dynamic]Wall_Index,
) {
	mask_map := DIAGONAL_WALL_MASK_MAP
	rotation_map := DIAGONAL_WALL_ROTATION_MAP
	draw_map := DIAGONAL_WALL_DRAW_MAP
	top_mask_map := DIAGONAL_WALL_TOP_MASK_MAP
	side_map := WALL_SIDE_MAP
	transform_map := DIAGONAL_WALL_TRANSFORM_MAP

	side := side_map[axis][camera.rotation]
	rotation := rotation_map[axis][camera.rotation]
	texture := wall.textures[side]
	mask := mask_map[axis][camera.rotation][wall.type]
	top_mask := top_mask_map[axis][camera.rotation][wall.type]
	draw := draw_map[axis][wall.type][camera.rotation]
	position := glsl.vec3 {
		f32(pos.x),
		f32(pos.y) * constants.WALL_HEIGHT +
		terrain.terrain_heights[pos.x][pos.z],
		f32(pos.z),
	}
	transform := glsl.mat4Translate(position)
	transform *= transform_map[camera.rotation]

	if draw {
		wall_vertices := diagonal_wall_vertices[wall.state][mask][:]
        wall_indices := diagonal_wall_indices[wall.state][mask][:]

		draw_wall_mesh(
			wall_vertices,
			wall_indices,
			transform,
			texture,
			wall.mask,
			vertex_buffer,
			index_buffer,
		)
	}

	top_vertices := diagonal_wall_top_vertices[wall.state][top_mask][:]
	top_indices := diagonal_wall_top_indices[wall.state][top_mask][:]

	draw_wall_mesh(
		top_vertices,
		top_indices,
		transform,
		.Wall_Top,
		wall.mask,
		vertex_buffer,
		index_buffer,
	)
}
