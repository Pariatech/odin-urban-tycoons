package wall

import "core:fmt"
import "core:math/linalg"
import glsl "core:math/linalg/glsl"

import "../camera"
import "../constants"
import "../models"
import "../terrain"

Diagonal_Wall_Mask :: enum {
	Full,
	Side,
	Left_Extension,
	Right_Extension,
	Cross,
}

DIAGONAL_WALL_TOP_CROSS_OFFSET :: -0.0002
DIAGONAL_WALL_TOP_OFFSET :: 0.0003

DIAGONAL_WALL_MASK_MODEL_NAME_MAP :: [Wall_Type]string {
	.Start          = "Diagonal_Wall.Up.Start.Outside",
	.End            = "Diagonal_Wall.Up.End.Outside",
	.Extended_Left  = "Diagonal_Wall.Up.Extended_Left.Outside",
	.Extended_Right = "Diagonal_Wall.Up.Extended_Right.Outside",
	.Full           = "Diagonal_Wall.Up.Full.Outside",
	.Side           = "Diagonal_Wall.Up.Side.Outside",
	.Extended_Start = "Wall.Up.Extended_Start.Outside",
	.Extended_End   = "Wall.Up.Extended_End.Outside",
	.Extended       = "Wall.Up.Extended.Outside",
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
	rotation_map := DIAGONAL_WALL_ROTATION_MAP
	transform_map := DIAGONAL_WALL_TRANSFORM_MAP

	rotation := rotation_map[axis][camera.rotation]
	// texture := wall.textures[side]
	position := glsl.vec3 {
		f32(pos.x),
		f32(pos.y) * constants.WALL_HEIGHT +
		terrain.terrain_heights[pos.x][pos.z],
		f32(pos.z),
	}
	transform := glsl.mat4Translate(position)
	transform *= transform_map[camera.rotation]

	light := glsl.vec3{0.95, 0.95, 0.95}

	model_name_map := DIAGONAL_WALL_MASK_MODEL_NAME_MAP
	model_name := model_name_map[wall.type]
	model := models.models[model_name]
	wall_vertices := model.vertices[:]
	wall_indices := model.indices[:]

	// wall_vertices := diagonal_wall_vertices[wall.state][mask][:]
	//       wall_indices := diagonal_wall_indices[wall.state][mask][:]

	// draw_wall_mesh(
	// 	wall_vertices,
	// 	wall_indices,
	// 	transform,
	// 	texture,
	// 	wall.mask,
	// 	light,
	// 	vertex_buffer,
	// 	index_buffer,
	// )

	// top_vertices := diagonal_wall_top_vertices[wall.state][top_mask][:]
	// top_indices := diagonal_wall_top_indices[wall.state][top_mask][:]
	//
	// transform *= glsl.mat4Translate(
	// 	{0, constants.WALL_TOP_OFFSET * f32(axis), 0},
	// )
	//
	// draw_wall_mesh(
	// 	top_vertices,
	// 	top_indices,
	// 	transform,
	// 	.Wall_Top,
	// 	wall.mask,
	//        light,
	// 	vertex_buffer,
	// 	index_buffer,
	// )
}
