package main

import "core:fmt"
import "core:math/linalg"
import m "core:math/linalg/glsl"

Chair_Model :: enum {
	Wood,
}

Chair_Orientation :: enum {
	South,
	West,
	North,
	East,
}

Chair :: struct {
	orientation: Chair_Orientation,
	model:       Chair_Model,
}

chairs := map[m.ivec3]Chair{}

chair_north_vertices: [19]Vertex
chair_north_indices: [33]u32

chair_south_vertices: [23]Vertex
chair_south_indices: [39]u32

CHAIR_NORTH_PATH :: "resources/models/chair-north.glb"
CHAIR_SOUTH_PATH :: "resources/models/chair-south.glb"

load_chair_models :: proc() {
	load_model(CHAIR_NORTH_PATH, &chair_north_vertices, &chair_north_indices)
	load_model(CHAIR_SOUTH_PATH, &chair_south_vertices, &chair_south_indices)
}

CHAIR_TEXTURE_MAP :: [Chair_Model][Chair_Orientation]Billboard_Texture {
	.Wood =  {
		.South = .Chair_South_Wood,
		.West = .Chair_South_Wood,
		.North = .Chair_North_Wood,
		.East = .Chair_North_Wood,
	},
}

CHAIR_ROTATION_MAP :: [Camera_Rotation][Chair_Orientation]Chair_Orientation {
	.South_West =  {
		.South = .South,
		.West = .West,
		.North = .North,
		.East = .East,
	},
	.South_East =  {
		.South = .South,
		.West = .East,
		.North = .North,
		.East = .West,
	},
	.North_East =  {
		.South = .North,
		.West = .East,
		.North = .South,
		.East = .West,
	},
	.North_West =  {
		.South = .North,
		.West = .West,
		.North = .South,
		.East = .East,
	},
}

CHAIR_TRANSFORM_MAP :: [Camera_Rotation][Chair_Orientation]m.mat4 {
	.South_West =  {
		.South = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.West = {0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
		.North = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.East = {0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
	},
	.South_East =  {
		.South = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.West = {0, 0, -1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
		.North = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.East = {0, 0, -1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
	},
	.North_East =  {
		.South = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1},
		.West = {0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.North = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1},
		.East = {0, 0, -1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
	},
	.North_West =  {
		.South = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1},
		.West = {0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.North = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1},
		.East = {0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
	},
}

draw_chair_mesh :: proc(
	using chair: Chair,
	pos: m.ivec3,
	y: f32,
	vertices: ^[$T]Vertex,
	indices: ^[$Y]u32,
) {
	texture_map := CHAIR_TEXTURE_MAP
	texture := texture_map[model][orientation]
	position := m.vec3{f32(pos.x), y, f32(pos.z)}
	chair_transform_map := CHAIR_TRANSFORM_MAP

	transform := m.mat4Translate(position)
	transform *= chair_transform_map[camera_rotation][orientation]

	// append_draw_component(
	// 	 {
	// 		vertices = vertices[:],
	// 		indices = indices[:],
	// 		model = transform,
	// 		texture = texture,
	// 	},
	// )
}

draw_chair :: proc(chair: Chair, pos: m.ivec3, y: f32) {
	chair := chair
	rotation_map := CHAIR_ROTATION_MAP
	chair.orientation = rotation_map[camera_rotation][chair.orientation]
	switch chair.orientation {
	case .South, .West:
		draw_chair_mesh(
			chair,
			pos,
			y,
			&chair_south_vertices,
			&chair_south_indices,
		)
	case .North, .East:
		draw_chair_mesh(
			chair,
			pos,
			y,
			&chair_north_vertices,
			&chair_north_indices,
		)
	}
}

get_chair :: proc(pos: m.ivec3) -> Maybe(Chair) {
	return chairs[pos]
}

insert_chair :: proc(pos: m.ivec3, chair: Chair) {
	chairs[pos] = chair
	draw_chair(chair, pos, 0)
}

rotate_chair :: proc(pos: m.ivec3, chair: Chair) {
	draw_chair(chair, pos, 0)
}

rotate_chairs :: proc() {
	for pos, chair in chairs {
		fmt.println(pos)
		rotate_chair(pos, chair)
	}
}
