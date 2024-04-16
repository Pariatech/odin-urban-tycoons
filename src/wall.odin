package main

import "core:fmt"
import "core:math/linalg"
import glsl "core:math/linalg/glsl"
import gl "vendor:OpenGL"

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

Wall_Top_Mesh :: enum {
	Full,
	Side,
}

Wall_Side :: enum {
	Inside,
	Outside,
}

Wall :: struct {
	type:     Wall_Type,
	textures: [Wall_Side]Wall_Texture,
	mask:     Wall_Mask_Texture,
}


Wall_Vertex :: struct {
	pos:       glsl.vec3,
	light:     glsl.vec3,
	texcoords: glsl.vec4,
}

Wall_Index :: u32

WALL_HEIGHT :: 3
WALL_TOP_OFFSET :: 0.0001
WALL_TEXTURE_HEIGHT :: 384
WALL_TEXTURE_WIDTH :: 128

wall_full_vertices := []Wall_Vertex {
	{pos = {-0.5, 0.0, -0.5}, light = {1, 1, 1}, texcoords = {0, 1, 0, 0}},
	 {
		pos = {0.615, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {1.115, 1, 0, 0},
	},
	 {
		pos = {0.615, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {1.115, 0, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 0, 0, 0},
	},
	{pos = {-0.5, 0, -0.385}, light = {1, 1, 1}, texcoords = {0.115, 1, 0, 0}},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {0.115, 0, 0, 0},
	},
}
wall_full_indices := []u32{0, 1, 2, 0, 2, 3, 0, 3, 5, 0, 5, 4}

wall_extended_side_vertices := []Wall_Vertex {
	{pos = {-0.5, 0.0, -0.5}, light = {1, 1, 1}, texcoords = {0, 1, 0, 0}},
	 {
		pos = {0.615, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {1.115, 1, 0, 0},
	},
	 {
		pos = {0.615, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {1.115, 0, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 0, 0, 0},
	},
}
wall_extended_side_indices := []u32{0, 1, 2, 0, 2, 3}

wall_side_vertices := []Wall_Vertex {
	{pos = {-0.5, 0.0, -0.5}, light = {1, 1, 1}, texcoords = {0, 1, 0, 0}},
	{pos = {0.5, 0.0, -0.5}, light = {1, 1, 1}, texcoords = {1, 1, 0, 0}},
	 {
		pos = {0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {1, 0, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 0, 0, 0},
	},
}
wall_side_indices := []u32{0, 1, 2, 0, 2, 3}

wall_end_vertices := []Wall_Vertex {
	{pos = {-0.5, 0.0, -0.5}, light = {1, 1, 1}, texcoords = {0, 1, 0, 0}},
	{pos = {0.5, 0.0, -0.5}, light = {1, 1, 1}, texcoords = {1, 1, 0, 0}},
	 {
		pos = {0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {1, 0, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 0, 0, 0},
	},
	{pos = {-0.5, 0, -0.385}, light = {1, 1, 1}, texcoords = {0.115, 1, 0, 0}},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {0.115, 0, 0, 0},
	},
}
wall_end_indices := []u32{0, 1, 2, 0, 2, 3, 0, 3, 5, 0, 5, 4}


wall_full_top_vertices := []Wall_Vertex {
	 {
		pos = {-0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 0.115, 0, 0},
	},
	 {
		pos = {0.615, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {1, 0.115, 0, 0},
	},
	 {
		pos = {0.615, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {1, 0, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {0, 0, 0, 0},
	},
}
wall_top_vertices := []Wall_Vertex {
	 {
		pos = {-0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 0.115, 0, 0},
	},
	 {
		pos = {0.5, WALL_HEIGHT, -0.5},
		light = {1, 1, 1},
		texcoords = {1, 0.115, 0, 0},
	},
	 {
		pos = {0.5, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {1, 0, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {0, 0, 0, 0},
	},
}
wall_top_indices := []u32{0, 1, 2, 0, 2, 3}

WALL_SIDE_MAP :: [Wall_Axis][Camera_Rotation]Wall_Side {
	.North_South =  {
		.South_West = .Outside,
		.South_East = .Inside,
		.North_East = .Inside,
		.North_West = .Outside,
	},
	.East_West =  {
		.South_West = .Outside,
		.South_East = .Outside,
		.North_East = .Inside,
		.North_West = .Inside,
	},
}

WALL_TRANSFORM_MAP :: [Wall_Axis][Camera_Rotation]glsl.mat4 {
	.North_South =  {
		.South_West = {0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.South_East = {0, 0, -1, -1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.North_East = {0, 0, -1, -1, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
		.North_West = {0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
	},
	.East_West =  {
		.South_West = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.South_East = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.North_East = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 1},
		.North_West = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 1},
	},
}


WALL_TOP_MESH_MAP :: [Wall_Type][Wall_Axis][Camera_Rotation]Wall_Mask {
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
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Side,
		},
	},
	.Side_End =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Full,
		},
		.East_West =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
	},
	.Left_Corner_End =  {
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
	.End_Left_Corner =  {
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
	.Right_Corner_End =  {
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
	.End_Right_Corner =  {
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
	.Left_Corner_Side =  {
		.North_South =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
	},
	.Side_Left_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
		.East_West =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
	},
	.Right_Corner_Side =  {
		.North_South =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Side_Right_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Left_Corner_Left_Corner =  {
		.North_South =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.Right_Corner_Right_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Left_Corner_Right_Corner =  {
		.North_South =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
		.East_West =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Full,
		},
	},
	.Right_Corner_Left_Corner =  {
		.North_South =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Full,
		},
		.East_West =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
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
			.South_West = .Side,
			.South_East = .Extended_Side,
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
			.South_West = .Extended_Side,
			.South_East = .Side,
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
			.North_East = .Side,
			.North_West = .Extended_Side,
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

wall_texture_array: u32
wall_mask_array: u32

load_wall_mask_array :: proc() -> (ok: bool) {
	gl.ActiveTexture(gl.TEXTURE1)
	gl.GenTextures(1, &wall_mask_array)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_mask_array)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

	return load_texture_2D_array(
		wall_mask_paths,
		WALL_TEXTURE_WIDTH,
		WALL_TEXTURE_HEIGHT,
	)
}

load_wall_texture_array :: proc() -> (ok: bool = true) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.GenTextures(1, &wall_texture_array)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_texture_array)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MIN_FILTER,
		gl.LINEAR_MIPMAP_LINEAR,
	)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	max_anisotropy: f32
	gl.GetFloatv(gl.MAX_TEXTURE_MAX_ANISOTROPY, &max_anisotropy)
	gl.TexParameterf(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MAX_ANISOTROPY,
		max_anisotropy,
	)

	return load_texture_2D_array(
		wall_texture_paths,
		WALL_TEXTURE_WIDTH,
		WALL_TEXTURE_HEIGHT,
	)
}

init_wall_renderer :: proc() -> (ok: bool) {
	load_wall_texture_array() or_return
	load_wall_mask_array() or_return

	return true
}

draw_wall_mesh :: proc(
	vertices: []Wall_Vertex,
	indices: []Wall_Index,
	model: glsl.mat4,
	texture: Wall_Texture,
	mask: Wall_Mask_Texture,
	vertex_buffer: ^[dynamic]Wall_Vertex,
	index_buffer: ^[dynamic]Wall_Index,
) {
	index_offset := u32(len(vertex_buffer))
	for i in 0 ..< len(vertices) {
		vertex := vertices[i]
		vertex.texcoords.z = f32(texture)
		vertex.texcoords.w = f32(mask)
		vertex.pos = linalg.mul(model, vec4(vertex.pos, 1)).xyz

		append(vertex_buffer, vertex)
	}

	for idx in indices {
		append(index_buffer, idx + index_offset)
	}
}

draw_wall :: proc(
	pos: glsl.ivec3,
	wall: Wall,
	axis: Wall_Axis,
	vertex_buffer: ^[dynamic]Wall_Vertex,
	index_buffer: ^[dynamic]Wall_Index,
) {
	mask_map := WALL_MASK_MAP
	side_map := WALL_SIDE_MAP
	transform_map := WALL_TRANSFORM_MAP
	top_mesh_map := WALL_TOP_MESH_MAP

	side := side_map[axis][camera_rotation]
	texture := wall.textures[side]
	mask := mask_map[wall.type][axis][camera_rotation]
	top_mesh := top_mesh_map[wall.type][axis][camera_rotation]

	position := glsl.vec3 {
		f32(pos.x),
		f32(pos.y) * WALL_HEIGHT + terrain_heights[pos.x][pos.z],
		f32(pos.z),
	}
	transform := glsl.mat4Translate(position)
	transform *= transform_map[axis][camera_rotation]

	vertices: []Wall_Vertex
	indices: []Wall_Index

	switch mask {
	case .Full:
		vertices = wall_full_vertices
		indices = wall_full_indices
	case .Extended_Side:
		vertices = wall_extended_side_vertices
		indices = wall_extended_side_indices
	case .Side:
		vertices = wall_side_vertices
		indices = wall_side_indices
	case .End:
		vertices = wall_end_vertices
		indices = wall_end_indices
	}
	draw_wall_mesh(
		vertices,
		indices,
		transform,
		texture,
		wall.mask,
		vertex_buffer,
		index_buffer,
	)

	top_vertices := wall_full_top_vertices
	if top_mesh == .Side do top_vertices = wall_top_vertices
	transform *= glsl.mat4Translate({0, WALL_TOP_OFFSET * f32(axis), 0})

	draw_wall_mesh(
		top_vertices,
		wall_top_indices,
		transform,
		.Wall_Top,
		.Full_Mask,
		vertex_buffer,
		index_buffer,
	)
}
