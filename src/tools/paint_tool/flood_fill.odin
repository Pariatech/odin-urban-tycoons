package paint_tool

import "core:log"
import "core:math/linalg/glsl"

import "../../wall"

NEXT_LEFT_WALL_MAP :: [wall.Wall_Axis][wall.Wall_Side][]Next_Wall {
	.E_W =  {
		.Inside =  {
			{type = .N_S, position = {1, 0, 0}, side = .Outside},
			{type = .SW_NE, position = {1, 0, 0}, side = .Outside},
			{type = .E_W, position = {1, 0, 0}, side = .Inside},
			{type = .NW_SE, position = {1, 0, -1}, side = .Inside},
			{type = .N_S, position = {1, 0, -1}, side = .Inside},
			{type = .E_W, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .N_S, position = {0, 0, -1}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, -1}, side = .Inside},
			{type = .E_W, position = {-1, 0, 0}, side = .Outside},
			{type = .NW_SE, position = {-1, 0, 0}, side = .Outside},
			{type = .N_S, position = {0, 0, 0}, side = .Outside},
			{type = .E_W, position = {0, 0, 0}, side = .Inside},
		},
	},
	.N_S =  {
		.Inside =  {
			{type = .E_W, position = {0, 0, 0}, side = .Inside},
			{type = .NW_SE, position = {0, 0, -1}, side = .Inside},
			{type = .N_S, position = {0, 0, -1}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, -1}, side = .Inside},
			{type = .E_W, position = {-1, 0, 0}, side = .Outside},
			{type = .N_S, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .E_W, position = {-1, 0, 1}, side = .Outside},
			{type = .NW_SE, position = {-1, 0, 1}, side = .Outside},
			{type = .N_S, position = {0, 0, 1}, side = .Outside},
			{type = .SW_NE, position = {0, 0, 1}, side = .Outside},
			{type = .E_W, position = {0, 0, 1}, side = .Inside},
			{type = .N_S, position = {0, 0, 0}, side = .Inside},
		},
	},
	.NW_SE =  {
		.Inside =  {
			{type = .SW_NE, position = {1, 0, 0}, side = .Outside},
			{type = .E_W, position = {1, 0, 0}, side = .Inside},
			{type = .NW_SE, position = {1, 0, -1}, side = .Inside},
			{type = .N_S, position = {1, 0, -1}, side = .Inside},
			{type = .SW_NE, position = {0, 0, -1}, side = .Inside},
			{type = .NW_SE, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .SW_NE, position = {-1, 0, 0}, side = .Inside},
			{type = .E_W, position = {-1, 0, 1}, side = .Outside},
			{type = .NW_SE, position = {-1, 0, 1}, side = .Outside},
			{type = .N_S, position = {0, 0, 1}, side = .Outside},
			{type = .SW_NE, position = {0, 0, 1}, side = .Outside},
			{type = .NW_SE, position = {0, 0, 0}, side = .Inside},
		},
	},
	.SW_NE =  {
		.Inside =  {
			{type = .NW_SE, position = {0, 0, -1}, side = .Inside},
			{type = .N_S, position = {0, 0, -1}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, -1}, side = .Inside},
			{type = .E_W, position = {-1, 0, 0}, side = .Outside},
			{type = .NW_SE, position = {-1, 0, 0}, side = .Outside},
			{type = .SW_NE, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .NW_SE, position = {0, 0, 1}, side = .Outside},
			{type = .N_S, position = {1, 0, 1}, side = .Outside},
			{type = .SW_NE, position = {1, 0, 1}, side = .Outside},
			{type = .E_W, position = {1, 0, 1}, side = .Inside},
			{type = .NW_SE, position = {1, 0, 0}, side = .Inside},
			{type = .SW_NE, position = {0, 0, 0}, side = .Inside},
		},
	},
}

NEXT_RIGHT_WALL_MAP :: [wall.Wall_Axis][wall.Wall_Side][]Next_Wall {
	.E_W =  {
		.Inside =  {
			{type = .N_S, position = {-1, 0, 0}, side = .Inside},
			{type = .NW_SE, position = {-1, 0, 0}, side = .Inside},
			{type = .E_W, position = {-1, 0, 0}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, -1}, side = .Outside},
			{type = .N_S, position = {0, 0, -1}, side = .Outside},
			{type = .E_W, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .N_S, position = {1, 0, -1}, side = .Outside},
			{type = .NW_SE, position = {1, 0, -1}, side = .Outside},
			{type = .E_W, position = {1, 0, 0}, side = .Outside},
			{type = .SW_NE, position = {1, 0, 0}, side = .Inside},
			{type = .N_S, position = {1, 0, 0}, side = .Inside},
			{type = .E_W, position = {0, 0, 0}, side = .Inside},
		},
	},
	.N_S =  {
		.Inside =  {
			{type = .E_W, position = {0, 0, 1}, side = .Outside},
			{type = .SW_NE, position = {0, 0, 1}, side = .Inside},
			{type = .N_S, position = {0, 0, 1}, side = .Inside},
			{type = .NW_SE, position = {-1, 0, 1}, side = .Inside},
			{type = .E_W, position = {-1, 0, 1}, side = .Inside},
			{type = .N_S, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .E_W, position = {-1, 0, 0}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, -1}, side = .Outside},
			{type = .N_S, position = {0, 0, -1}, side = .Outside},
			{type = .NW_SE, position = {0, 0, -1}, side = .Outside},
			{type = .E_W, position = {0, 0, 0}, side = .Outside},
			{type = .N_S, position = {0, 0, 0}, side = .Inside},
		},
	},
	.NW_SE =  {
		.Inside =  {
			{type = .SW_NE, position = {0, 0, 1}, side = .Inside},
			{type = .N_S, position = {0, 0, 1}, side = .Inside},
			{type = .NW_SE, position = {-1, 0, 1}, side = .Inside},
			{type = .E_W, position = {-1, 0, 1}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, 0}, side = .Outside},
			{type = .NW_SE, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .SW_NE, position = {0, 0, -1}, side = .Outside},
			{type = .N_S, position = {1, 0, -1}, side = .Outside},
			{type = .NW_SE, position = {1, 0, -1}, side = .Outside},
			{type = .E_W, position = {1, 0, 0}, side = .Outside},
			{type = .SW_NE, position = {1, 0, 0}, side = .Inside},
			{type = .NW_SE, position = {0, 0, 0}, side = .Inside},
		},
	},
	.SW_NE =  {
		.Inside =  {
			{type = .NW_SE, position = {1, 0, 0}, side = .Outside},
			{type = .E_W, position = {1, 0, 1}, side = .Outside},
			{type = .SW_NE, position = {1, 0, 1}, side = .Inside},
			{type = .N_S, position = {1, 0, 1}, side = .Inside},
			{type = .NW_SE, position = {0, 0, 1}, side = .Inside},
			{type = .SW_NE, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .NW_SE, position = {-1, 0, 0}, side = .Inside},
			{type = .E_W, position = {-1, 0, 0}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, -1}, side = .Outside},
			{type = .N_S, position = {0, 0, -1}, side = .Outside},
			{type = .NW_SE, position = {0, 0, -1}, side = .Outside},
			{type = .SW_NE, position = {0, 0, 0}, side = .Inside},
		},
	},
}

Next_Wall :: struct {
	position: glsl.ivec3,
	side:     wall.Wall_Side,
	type:     wall.Wall_Axis,
	wall:     wall.Wall,
}

flood_fill :: proc(
	position: glsl.ivec3,
	type: wall.Wall_Axis,
	side: wall.Wall_Side,
	previous_texture: wall.Wall_Texture,
	texture: wall.Wall_Texture,
) {
	next_wall, ok := get_next_left_wall(
		{position = position, side = side, type = type},
		previous_texture,
	)
	for ok {
		paint_next_wall(next_wall, texture)
		next_wall, ok = get_next_left_wall(next_wall, previous_texture)
	}

	next_wall, ok = get_next_right_wall(
		{position = position, side = side, type = type},
		previous_texture,
	)
	for ok {
		paint_next_wall(next_wall, texture)
		next_wall, ok = get_next_right_wall(next_wall, previous_texture)
	}
}

paint_next_wall :: proc(next_wall: Next_Wall, texture: wall.Wall_Texture) {
	w := next_wall.wall
	w.textures[next_wall.side] = texture
	set_wall_by_type(next_wall.position, next_wall.type, w)
}

set_wall_by_type :: proc(position: glsl.ivec3, type: wall.Wall_Axis, w: wall.Wall) {
	switch type {
	case .E_W:
		wall.set_east_west_wall(position, w)
	case .N_S:
		wall.set_north_south_wall(position, w)
	case .NW_SE:
		wall.set_north_west_south_east_wall(position, w)
	case .SW_NE:
		wall.set_south_west_north_east_wall(position, w)
	}
}

get_wall_by_type :: proc(
	position: glsl.ivec3,
	type: wall.Wall_Axis,
) -> (
	wall.Wall,
	bool,
) {
	switch type {
	case .E_W:
		return wall.get_east_west_wall(position)
	case .N_S:
		return wall.get_north_south_wall(position)
	case .NW_SE:
		return wall.get_north_west_south_east_wall(position)
	case .SW_NE:
		return wall.get_south_west_north_east_wall(position)
	}

	return {}, false
}

get_next_left_wall :: proc(
	current: Next_Wall,
	texture: wall.Wall_Texture,
) -> (
	Next_Wall,
	bool,
) {
	return get_next_wall(current, texture, NEXT_LEFT_WALL_MAP)
}

get_next_right_wall :: proc(
	current: Next_Wall,
	texture: wall.Wall_Texture,
) -> (
	Next_Wall,
	bool,
) {
	return get_next_wall(current, texture, NEXT_RIGHT_WALL_MAP)
}

get_next_wall :: proc(
	current: Next_Wall,
	texture: wall.Wall_Texture,
	next_wall_map: [wall.Wall_Axis][wall.Wall_Side][]Next_Wall,
) -> (
	Next_Wall,
	bool,
) {
	next_wall_list := next_wall_map[current.type][current.side]

	for next_wall in next_wall_list {
		w, ok := get_wall_by_type(
			current.position + next_wall.position,
			next_wall.type,
		)

		if !ok {
			continue
		}

		if w.textures[next_wall.side] == texture {
			next_wall := next_wall
			next_wall.position += current.position
			next_wall.wall = w
			return next_wall, true
		}

		return {}, false
	}

	return {}, false
}
