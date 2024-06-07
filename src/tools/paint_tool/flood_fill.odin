package paint_tool

import "core:log"
import "core:math/linalg/glsl"

import "../../wall"

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

Wall_Type :: enum {
	N_S,
	E_W,
	NW_SE,
	SW_NE,
}

Next_Wall :: struct {
	position: glsl.ivec3,
	side:     wall.Wall_Side,
	type:     Wall_Type,
	wall:     wall.Wall,
}

flood_fill :: proc(
	position: glsl.ivec3,
	type: Wall_Type,
	side: wall.Wall_Side,
	previous_texture: wall.Wall_Texture,
	texture: wall.Wall_Texture,
) {
	log.info(Next_Wall{position = position, side = side, type = type})
	next_wall, ok := get_next_left_wall(
		{position = position, side = side, type = type},
		previous_texture,
	)
	log.info("next_wall:", next_wall, "ok:", ok)
	for ok {
		log.info("next_wall:", next_wall)
		paint_next_wall(next_wall, texture)
		next_wall, ok = get_next_left_wall(next_wall, previous_texture)
	}
}

paint_next_wall :: proc(next_wall: Next_Wall, texture: wall.Wall_Texture) {
	w := next_wall.wall
	w.textures[next_wall.side] = texture
	set_wall_by_type(next_wall.position, next_wall.type, w)
}

set_wall_by_type :: proc(position: glsl.ivec3, type: Wall_Type, w: wall.Wall) {
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
	type: Wall_Type,
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
	next_left_wall_map := NEXT_LEFT_WALL_MAP

	next_wall_list := next_left_wall_map[current.type][current.side]

	for next_wall in next_wall_list {
        log.info(next_wall)
		w, ok := get_wall_by_type(
			current.position + next_wall.position,
			next_wall.type,
		)
        log.info(w)
        log.info(texture)

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
