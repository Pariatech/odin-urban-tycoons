package paint_tool

import "core:math/linalg/glsl"

import "../../wall"

Wall_Type :: enum {
	North_South,
	East_West,
	North_West_South_East,
	South_West_North_East,
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
	case .East_West:
		switch current.side {
		case .Inside:
			return get_next_left_east_west_wall(current, texture, .Inside)
		case .Outside:
			return get_next_left_east_west_outside_wall(current, texture)
		}
	case .North_South:
	case .North_West_South_East:
	case .South_West_North_East:
	}

	return {}, false
}

NEXT_LEFT_WALL_MAP :: [Wall_Type][wall.Wall_Side][]Next_Wall {
	.East_West =  {
		.Inside =  {
			{type = .North_South, position = {1, 0, 0}, side = .Outside},
			 {
				type = .South_West_North_East,
				position = {1, 0, 0},
				side = .Outside,
			},
			{type = .East_West, position = {1, 0, 0}, side = .Inside},
			 {
				type = .North_West_South_East,
				position = {1, 0, -1},
				side = .Inside,
			},
			{type = .North_South, position = {1, 0, -1}, side = .Inside},
			{type = .East_West, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .North_South, position = {0, 0, -1}, side = .Inside},
			 {
				type = .South_West_North_East,
				position = {-1, 0, -1},
				side = .Inside,
			},
			{type = .East_West, position = {-1, 0, 0}, side = .Outside},
			 {
				type = .North_West_South_East,
				position = {-1, 0, 0},
				side = .Outside,
			},
			{type = .North_South, position = {0, 0, 0}, side = .Outside},
			{type = .East_West, position = {0, 0, 0}, side = .Inside},
		},
	},
	.North_South =  {
		.Inside =  {
			{type = .East_West, position = {0, 0, 0}, side = .Inside},
			 {
				type = .North_West_South_East,
				position = {0, 0, -1},
				side = .Inside,
			},
			{type = .North_South, position = {0, 0, -1}, side = .Inside},
			 {
				type = .South_West_North_East,
				position = {-1, 0, -1},
				side = .Inside,
			},
			{type = .East_West, position = {-1, 0, 0}, side = .Outside},
			{type = .North_South, position = {0, 0, 0}, side = .Outside},
		},
		.Outside =  {
			{type = .East_West, position = {0, 0, 0}, side = .Inside},
			 {
				type = .North_West_South_East,
				position = {0, 0, -1},
				side = .Inside,
			},
			{type = .North_South, position = {0, 0, -1}, side = .Inside},
			 {
				type = .South_West_North_East,
				position = {-1, 0, -1},
				side = .Inside,
			},
			{type = .East_West, position = {-1, 0, 0}, side = .Outside},
			{type = .North_South, position = {0, 0, 0}, side = .Outside},
		},
	},
	.North_West_South_East = {.Inside = {}, .Outside = {}},
	.South_West_North_East = {.Inside = {}, .Outside = {}},
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
			return {position = position, side = side, type = .North_South},
				true
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
					type = .South_West_North_East,
				},
				true
		}
	} else if w, ok := wall.get_east_west_wall(current.position + {-1, 0, 0});
	   ok {
		if w.textures[side] == texture {
			return  {
					position = current.position + {-1, 0, 0},
					side = side,
					type = .East_West,
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
					type = .North_West_South_East,
				},
				true
		}
	} else if w, ok := wall.get_north_south_wall(current.position); ok {
		if w.textures[side] == texture {
			return  {
					position = current.position,
					side = side,
					type = .North_South,
				},
				true
		}
	} else {
		return  {
				position = current.position,
				side = .Outside - side,
				type = .East_West,
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
					type = .North_South,
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
					type = .South_West_North_East,
				},
				true
		}
	} else if w, ok := wall.get_east_west_wall(current.position + {1, 0, 0});
	   ok {
		if w.textures[.Outside] == texture {
			return  {
					position = current.position + {1, 0, 0},
					side = .Outside,
					type = .South_West_North_East,
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
					type = .North_West_South_East,
				},
				true
		}
	} else if w, ok := wall.get_north_south_wall(current.position); ok {
		if w.textures[.Outside] == texture {
			return  {
					position = current.position,
					side = .Outside,
					type = .North_South,
				},
				true
		}
	} else {
		return  {
				position = current.position,
				side = .Inside,
				type = .East_West,
			},
			true
	}

	return {}, false
}
