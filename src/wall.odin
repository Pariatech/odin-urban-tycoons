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
	type:     Wall_Type,
	textures: [Wall_Side]Texture,
    mask: Texture,
}

WALL_HEIGHT :: 3
WALL_TOP_OFFSET :: 0.0001

WALL_FULL_VERTICES :: [?]Vertex {
	 {
		pos = {-0.5, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 1, 0, 0},
	},
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
	 {
		pos = {-0.5, 0, -0.385},
		light = {1, 1, 1},
		texcoords = {0.115, 1, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {0.115, 0, 0, 0},
	},
}
WALL_FULL_INDICES :: [?]u32{0, 1, 2, 0, 2, 3, 0, 3, 5, 0, 5, 4}

WALL_EXTENDED_SIDE_VERTICES :: [?]Vertex {
	 {
		pos = {-0.5, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 1, 0, 0},
	},
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
WALL_EXTENDED_SIDE_INDICES :: [?]u32{0, 1, 2, 0, 2, 3}

WALL_SIDE_VERTICES :: [?]Vertex {
	 {
		pos = {-0.5, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 1, 0, 0},
	},
	 {
		pos = {0.5, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {1, 1, 0, 0},
	},
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
WALL_SIDE_INDICES :: [?]u32{0, 1, 2, 0, 2, 3}

WALL_END_VERTICES :: [?]Vertex {
	 {
		pos = {-0.5, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {0, 1, 0, 0},
	},
	 {
		pos = {0.5, 0.0, -0.5},
		light = {1, 1, 1},
		texcoords = {1, 1, 0, 0},
	},
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
	 {
		pos = {-0.5, 0, -0.385},
		light = {1, 1, 1},
		texcoords = {0.115, 1, 0, 0},
	},
	 {
		pos = {-0.5, WALL_HEIGHT, -0.385},
		light = {1, 1, 1},
		texcoords = {0.115, 0, 0, 0},
	},
}
WALL_END_INDICES :: [?]u32{0, 1, 2, 0, 2, 3, 0, 3, 5, 0, 5, 4}


WALL_FULL_TOP_VERTICES :: [?]Vertex {
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
WALL_TOP_VERTICES :: [?]Vertex {
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
WALL_TOP_INDICES :: [?]u32{0, 1, 2, 0, 2, 3}

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

draw_wall :: proc(
	wall: Wall,
	pos: m.ivec3,
	axis: Wall_Axis,
	y: f32,
	draw_top: bool = false,
) {
	mask_map := WALL_MASK_MAP
	side_map := WALL_SIDE_MAP
	transform_map := WALL_TRANSFORM_MAP
    top_mesh_map := WALL_TOP_MESH_MAP

	side := side_map[axis][camera_rotation]
	texture := wall.textures[side]
	mask := mask_map[wall.type][axis][camera_rotation]
    top_mesh := top_mesh_map[wall.type][axis][camera_rotation]

	position := m.vec3{f32(pos.x), y, f32(pos.z)}
	transform := transform_map[axis][camera_rotation]

	switch mask {
	case .Full:
		vertices := WALL_FULL_VERTICES
		indices := WALL_FULL_INDICES
		for i in 0 ..< len(vertices) {
			vertices[i].texcoords.z = f32(texture)
            vertices[i].texcoords.w = f32(wall.mask)
			vertices[i].pos =
				linalg.mul(transform, vec4(vertices[i].pos, 1)).xyz
			vertices[i].pos += position
		}
		draw_mesh(vertices[:], indices[:])
	case .Extended_Side:
		vertices := WALL_EXTENDED_SIDE_VERTICES
		indices := WALL_EXTENDED_SIDE_INDICES
		for i in 0 ..< len(vertices) {
			vertices[i].texcoords.z = f32(texture)
            vertices[i].texcoords.w = f32(wall.mask)
			vertices[i].pos =
				linalg.mul(transform, vec4(vertices[i].pos, 1)).xyz
			vertices[i].pos += position
		}
		draw_mesh(vertices[:], indices[:])
	case .Side:
		vertices := WALL_SIDE_VERTICES
		indices := WALL_SIDE_INDICES
		for i in 0 ..< len(vertices) {
			vertices[i].texcoords.z = f32(texture)
            vertices[i].texcoords.w = f32(wall.mask)
			vertices[i].pos =
				linalg.mul(transform, vec4(vertices[i].pos, 1)).xyz
			vertices[i].pos += position
		}
		draw_mesh(vertices[:], indices[:])
	case .End:
		vertices := WALL_END_VERTICES
		indices := WALL_END_INDICES
		for i in 0 ..< len(vertices) {
			vertices[i].texcoords.z = f32(texture)
            vertices[i].texcoords.w = f32(wall.mask)
			vertices[i].pos =
				linalg.mul(transform, vec4(vertices[i].pos, 1)).xyz
			vertices[i].pos += position
		}
		draw_mesh(vertices[:], indices[:])
	}

	top_vertices := WALL_FULL_TOP_VERTICES
    if top_mesh == .Side do top_vertices = WALL_TOP_VERTICES
	top_indices := WALL_TOP_INDICES
	for i in 0 ..< len(top_vertices) {
		top_vertices[i].texcoords.z = f32(Texture.Wall_Top)
		top_vertices[i].pos =
			linalg.mul(transform, vec4(top_vertices[i].pos, 1)).xyz
		top_vertices[i].pos += position
        top_vertices[i].pos.y += WALL_TOP_OFFSET * f32(axis)
	}
	draw_mesh(top_vertices[:], top_indices[:])
}

draw_tile_walls :: proc(x, z, floor: i32, y: f32) {
	north_south_key := m.ivec3{x, floor, z}
	#partial switch camera_rotation {
	case .South_East, .North_East:
		north_south_key.x += 1
	}
	if wall, ok := north_south_walls[north_south_key]; ok {
		draw_top := !(north_south_key + {0, 1, 0} in north_south_walls)
		draw_wall(wall, north_south_key, .North_South, y, draw_top)
	}

	east_west_key := m.ivec3{x, floor, z}
	#partial switch camera_rotation {
	case .North_East, .North_West:
		east_west_key.z += 1
	}
	if wall, ok := east_west_walls[east_west_key]; ok {
		draw_top := !(east_west_key + {0, 1, 0} in east_west_walls)
		draw_wall(wall, east_west_key, .East_West, y, draw_top)
	}
}

insert_north_south_wall :: proc(pos: m.ivec3, wall: Wall) {
	north_south_walls[pos] = wall
}

insert_east_west_wall :: proc(pos: m.ivec3, wall: Wall) {
	east_west_walls[pos] = wall
}
