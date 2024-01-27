package main

import "core:math/linalg"
import m "core:math/linalg/glsl"

Wall_Window :: struct {
	texture: Texture,
}

MEDIUM_WINDOW_VERTICES :: [?]Vertex {
	// 2/1
	 {
		pos = {0.385, 2.3, -0.525},
		light = {1, 1, 1},
		texcoords = {0.452941, 0, 0, 0},
	},
	// 4/2
	 {
		pos = {0.385, 0.6, -0.36},
		light = {1, 1, 1},
		texcoords = {0.55, 1, 0, 0},
	},
	// 1/3
	 {
		pos = {0.385, 0.6, -0.525},
		light = {1, 1, 1},
		texcoords = {0.452941, 1, 0, 0},
	},

	// 3/4
	 {
		pos = {0.385, 2.3, -0.36},
		light = {1, 1, 1},
		texcoords = {0.647059, 0.452941, 0, 0},
	},
	// 6/5
	 {
		pos = {-0.385, 2.3, -0.525},
		light = {1, 1, 1},
		texcoords = {0.55, 0, 0, 0},
	},
	// 5/6
	 {
		pos = {-0.385, 2.3, -0.36},
		light = {1, 1, 1},
		texcoords = {0.647059, 0, 0, 0},
	},

	// 7/7
	{pos = {-0.385, 0.6, -0.525}, light = {1, 1, 1}, texcoords = {0, 1, 0, 0}},

	// 3/8
	 {
		pos = {0.385, 2.3, -0.36},
		light = {1, 1, 1},
		texcoords = {0.55, 0, 0, 0},
	},

	// 2/9
	 {
		pos = {0.385, 2.3, -0.525},
		light = {1, 1, 1},
		texcoords = {0.55, 0.452941, 0, 0},
	},

	// 6/10
	{pos = {-0.385, 2.3, -0.525}, light = {1, 1, 1}, texcoords = {0, 0, 0, 0}},
}

WALL_WINDOW_INDICES :: [?]u32 {
	0, 1, 2,
	3, 4, 5,
	6, 0, 2,
	0, 7, 1,
	3, 8, 4,
	6, 9, 0,
}

draw_wall_window :: proc(
	using wall_window: Wall_Window,
	pos: m.ivec3,
	axis: Wall_Axis,
	y: f32,
) {
	transform_map := WALL_TRANSFORM_MAP
	position := m.vec3{f32(pos.x), y, f32(pos.z)}
	transform := transform_map[axis][camera_rotation]

	vertices := MEDIUM_WINDOW_VERTICES
	indices := WALL_WINDOW_INDICES
	for i in 0 ..< len(vertices) {
		vertices[i].texcoords.z = f32(texture)
		vertices[i].texcoords.y = 1 - vertices[i].texcoords.y
		vertices[i].pos.x *= -1
		vertices[i].pos = linalg.mul(transform, vec4(vertices[i].pos, 1)).xyz
		vertices[i].pos += position
	}
	draw_mesh(vertices[:], indices[:])
}

draw_tile_wall_windows :: proc(pos: m.ivec3, y: f32) {
	north_south_key := pos
	#partial switch camera_rotation {
	case .South_East, .North_East:
		north_south_key.x += 1
	}
	if north_south_key.x < WORLD_WIDTH {
		if wall_window, ok := get_wall_window(.North_South, north_south_key).?;
		   ok {
			draw_wall_window(wall_window, north_south_key, .North_South, y)
		}
	}

	east_west_key := pos
	#partial switch camera_rotation {
	case .North_East, .North_West:
		east_west_key.z += 1
	}
	if east_west_key.z < WORLD_DEPTH {
		if wall_window, ok := get_wall_window(.East_West, east_west_key).?;
		   ok {
			draw_wall_window(wall_window, east_west_key, .East_West, y)
		}
	}
}

get_wall_window :: proc(axis: Wall_Axis, pos: m.ivec3) -> Maybe(Wall_Window) {
	switch axis {
	case .North_South:
		return north_south_wall_windows[pos.x][pos.z][pos.y]
	case .East_West:
		return east_west_wall_windows[pos.x][pos.z][pos.y]
	}

	return nil
}

insert_wall_window :: proc(
	axis: Wall_Axis,
	pos: m.ivec3,
	wall_window: Wall_Window,
) {
	switch axis {
	case .North_South:
		north_south_wall_windows[pos.x][pos.z][pos.y] = wall_window
	case .East_West:
		east_west_wall_windows[pos.x][pos.z][pos.y] = wall_window
	}
}
