package main

import "core:fmt"
import "core:math/linalg"
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
	pos:      m.vec3,
	type:     Wall_Type,
	textures: [Wall_Side]Texture,
	mask:     Texture,
}

WALL_HEIGHT :: 3
WALL_TOP_OFFSET :: 0.0001

wall_full_vertices := []Vertex {
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

wall_extended_side_vertices := []Vertex {
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

wall_side_vertices := []Vertex {
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

wall_end_vertices := []Vertex {
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


wall_full_top_vertices := []Vertex {
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
wall_top_vertices := []Vertex {
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

WALL_TRANSFORM_MAP :: [Wall_Axis][Camera_Rotation]m.mat4 {
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

north_south_walls := [dynamic]Wall{}
east_west_walls := [dynamic]Wall{}
north_south_walls_quadtree := Quadtree(int) {
	size = WORLD_WIDTH,
}
east_west_walls_quadtree := Quadtree(int) {
	size = WORLD_WIDTH,
}

draw_wall_mesh :: proc(
	vertices: []Vertex,
	indices: []u32,
	model: m.mat4,
	texture: Texture,
	mask: Texture,
) {
	index_offset := u32(len(world_vertices))
	for i in 0 ..< len(vertices) {
		vertex := vertices[i]
		vertex.texcoords.z = f32(texture)
		vertex.texcoords.w = f32(mask)
		vertex.pos = linalg.mul(model, vec4(vertex.pos, 1)).xyz

		append(&world_vertices, vertex)
	}

	for idx in indices {
		append(&world_indices, idx + index_offset)
	}
}

draw_wall :: proc(wall: Wall, axis: Wall_Axis) {
	mask_map := WALL_MASK_MAP
	side_map := WALL_SIDE_MAP
	transform_map := WALL_TRANSFORM_MAP
	top_mesh_map := WALL_TOP_MESH_MAP

	side := side_map[axis][camera_rotation]
	texture := wall.textures[side]
	mask := mask_map[wall.type][axis][camera_rotation]
	top_mesh := top_mesh_map[wall.type][axis][camera_rotation]

	position := wall.pos
	transform := m.mat4Translate(position)
	transform *= transform_map[axis][camera_rotation]

	vertices: []Vertex
	indices: []u32

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
	draw_wall_mesh(vertices, indices, transform, texture, wall.mask)

	top_vertices := wall_full_top_vertices
	if top_mesh == .Side do top_vertices = wall_top_vertices
	transform *= m.mat4Translate({0, WALL_TOP_OFFSET * f32(axis), 0})

	// draw_wall_mesh(
	// 	top_vertices,
	// 	wall_top_indices,
	// 	transform,
	// 	.Wall_Top,
	// 	.Full_Mask,
	// )
}

draw_walls :: proc() {
	aabb := get_camera_aabb()
	north_south_walls_indices := quadtree_search(
		&north_south_walls_quadtree,
		aabb,
	)
	defer delete(north_south_walls_indices)
	for index in north_south_walls_indices {
		draw_wall(north_south_walls[index], .North_South)
	}

	east_west_walls_indices := quadtree_search(
		&east_west_walls_quadtree,
		aabb,
	)
	defer delete(east_west_walls_indices)
	for index in east_west_walls_indices {
		draw_wall(east_west_walls[index], .East_West)
	}
}

insert_north_south_wall :: proc(wall: Wall) {
	index := len(north_south_walls)
	append(&north_south_walls, wall)
	quadtree_append(
		&north_south_walls_quadtree,
		{i32(wall.pos.x), i32(wall.pos.z)},
		index,
	)
}

insert_east_west_wall :: proc(wall: Wall) {
	index := len(east_west_walls)
	append(&east_west_walls, wall)
	quadtree_append(
		&east_west_walls_quadtree,
		{i32(wall.pos.x), i32(wall.pos.z)},
		index,
	)
}
