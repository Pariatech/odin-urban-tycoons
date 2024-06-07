package paint_tool

import "core:math/linalg/glsl"

import "../../wall"

Wall_Type :: enum {
	N_S,
	E_W,
	NW_SE,
	SW_NE,
}

flood_fill :: proc(
	type: Wall_Type,
	side: wall.Wall_Side,
	texture: wall.Wall_Texture,
) {
	previous_texture := get_found_wall_texture()

}

Next_Wall :: struct {
	position: glsl.ivec3,
	side:     wall.Wall_Side,
	type:     Wall_Type,
}

get_next_left_wall :: proc(
	current: Next_Wall,
	texture: wall.Wall_Texture,
) -> (
	Next_Wall,
	bool,
) {
	switch current.type {
	case .E_W:
		switch current.side {
		case .Inside:
			return get_next_left_east_west_wall(current, texture, .Inside)
		case .Outside:
			return get_next_left_east_west_outside_wall(current, texture)
		}
	case .N_S:
	case .NW_SE:
	case .SW_NE:
	}

	return {}, false
}

NEXT_LEFT_WALL_MAP :: [Wall_Type][wall.Wall_Side][]Next_Wall {
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
			{type = .E_W, position = {0, 0, 0}, side = .Inside},
			{type = .NW_SE, position = {0, 0, -1}, side = .Inside},
			{type = .N_S, position = {0, 0, -1}, side = .Inside},
			{type = .SW_NE, position = {-1, 0, -1}, side = .Inside},
			{type = .E_W, position = {-1, 0, 0}, side = .Outside},
			{type = .N_S, position = {0, 0, 0}, side = .Outside},
		},
	},
	.NW_SE = {.Inside = {}, .Outside = {}},
	.SW_NE = {.Inside = {}, .Outside = {}},
}

get_next_left_east_west_wall :: proc(
	current: Next_Wall,
	texture: wall.Wall_Texture,
	side: wall.Wall_Side,
) -> (
	Next_Wall,
	bool,
) {
	position := current.position + {1 - i32(side), 0, -i32(side)}
	if w, ok := wall.get_north_south_wall(position); ok {
		side: wall.Wall_Side = .Outside - side
		if w.textures[side] == texture {
			return {position = position, side = side, type = .N_S}, true
		}
		return {}, false
	}

	position = current.position + {1 - i32(side) * 2, 0, -i32(side)}
	if w, ok := wall.get_south_west_north_east_wall(
		current.position + {-1, 0, -1},
	); ok {
		side: wall.Wall_Side = .Outside - side
		if w.textures[side] == texture {
			return  {
					position = current.position + {-1, 0, -1},
					side = side,
					type = .SW_NE,
				},
				true
		}
	} else if w, ok := wall.get_east_west_wall(current.position + {-1, 0, 0});
	   ok {
		if w.textures[side] == texture {
			return  {
					position = current.position + {-1, 0, 0},
					side = side,
					type = .E_W,
				},
				true
		}
	} else if w, ok := wall.get_north_west_south_east_wall(
		current.position + {-1, 0, 0},
	); ok {
		if w.textures[side] == texture {
			return  {
					position = current.position + {-1, 0, 0},
					side = side,
					type = .NW_SE,
				},
				true
		}
	} else if w, ok := wall.get_north_south_wall(current.position); ok {
		if w.textures[side] == texture {
			return {position = current.position, side = side, type = .N_S},
				true
		}
	} else {
		return  {
				position = current.position,
				side = .Outside - side,
				type = .E_W,
			},
			true
	}

	return {}, false
}

get_next_left_east_west_outside_wall :: proc(
	current: Next_Wall,
	texture: wall.Wall_Texture,
) -> (
	Next_Wall,
	bool,
) {
	if w, ok := wall.get_north_south_wall(current.position + {0, 0, -1}); ok {
		if w.textures[.Inside] == texture {
			return  {
					position = current.position + {0, 0, -1},
					side = .Inside,
					type = .N_S,
				},
				true
		}
	} else if w, ok := wall.get_south_west_north_east_wall(
		current.position + {1, 0, -1},
	); ok {
		if w.textures[.Inside] == texture {
			return  {
					position = current.position + {1, 0, -1},
					side = .Inside,
					type = .SW_NE,
				},
				true
		}
	} else if w, ok := wall.get_east_west_wall(current.position + {1, 0, 0});
	   ok {
		if w.textures[.Outside] == texture {
			return  {
					position = current.position + {1, 0, 0},
					side = .Outside,
					type = .SW_NE,
				},
				true
		}
	} else if w, ok := wall.get_north_west_south_east_wall(
		current.position + {1, 0, 0},
	); ok {
		if w.textures[.Outside] == texture {
			return  {
					position = current.position + {1, 0, 0},
					side = .Outside,
					type = .NW_SE,
				},
				true
		}
	} else if w, ok := wall.get_north_south_wall(current.position); ok {
		if w.textures[.Outside] == texture {
			return {position = current.position, side = .Outside, type = .N_S},
				true
		}
	} else {
		return {position = current.position, side = .Inside, type = .E_W}, true
	}

	return {}, false
}
