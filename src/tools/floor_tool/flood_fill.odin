package floor_tool

import "core:fmt"
import "core:math/linalg/glsl"

import "../../constants"
import "../../floor"
import "../../tile"
import "../../wall"

Visited_Tile_Triangle :: struct {
	position: glsl.ivec2,
	side:     tile.Tile_Triangle_Side,
}

flood_fill :: proc(
	position: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
	texture: tile.Texture,
) {
	tile_triangle, ok := tile.get_tile_triangle(position, side)
	if !ok {return}
	original_texture := tile_triangle.texture
	if original_texture == texture {return}

	visited_queue: [dynamic]Visited_Tile_Triangle
    defer delete(visited_queue)

	visited := Visited_Tile_Triangle{position.xz, side}

	set_texture(visited, texture)

	append(&visited_queue, visited)

	for len(visited_queue) > 0 {
		visited = pop(&visited_queue)
		from := visited
		switch visited.side {
		case .South:
			next_visited := visited
			next_visited.side = .East
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .West
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .North
			next_visited.position -= {0, 1}
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		case .East:
			next_visited := visited
			next_visited.side = .North
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .South
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .West
			next_visited.position += {1, 0}
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		case .North:
			next_visited := visited
			next_visited.side = .East
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .West
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .South
			next_visited.position += {0, 1}
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		case .West:
			next_visited := visited
			next_visited.side = .South
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .North
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .East
			next_visited.position -= {1, 0}
			process_next_visited(
				from,
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		}
	}
}

process_next_visited :: proc(
	from: Visited_Tile_Triangle,
	to: Visited_Tile_Triangle,
	original_texture: tile.Texture,
	texture: tile.Texture,
	visited_queue: ^[dynamic]Visited_Tile_Triangle,
) {
	if can_texture(from, to, original_texture) {
		set_texture(to, texture)
		append(visited_queue, to)
	}
}

set_texture :: proc(
	using visited: Visited_Tile_Triangle,
	texture: tile.Texture,
) {
    mask_texture: tile.Mask = .Grid_Mask
    if texture == .Floor_Marker {
        mask_texture = .Full_Mask
    }
	tile.set_tile_triangle(
		{position.x, floor.floor, position.y},
		side,
		tile.Tile_Triangle{texture = texture, mask_texture = mask_texture},
	)
}

can_texture :: proc(
	from: Visited_Tile_Triangle,
	to: Visited_Tile_Triangle,
	texture: tile.Texture,
) -> bool {
	if to.position.x < 0 ||
	   to.position.y < 0 ||
	   to.position.x >= constants.WORLD_WIDTH ||
	   to.position.y >= constants.WORLD_DEPTH {
		return false
	}

	switch from.side {
	case .South:
		switch to.side {
		case .South:
		case .East:
			_, ok := wall.get_north_west_south_east_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		case .North:
			_, ok := wall.get_east_west_wall(
				{from.position.x, floor.floor, from.position.y},
			)
			if ok {
				return false
			}
		case .West:
			_, ok := wall.get_south_west_north_east_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		}
	case .East:
		switch to.side {
		case .South:
			_, ok := wall.get_north_west_south_east_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		case .East:
		case .North:
			_, ok := wall.get_south_west_north_east_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		case .West:
			_, ok := wall.get_north_south_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		}
	case .North:
		switch to.side {
		case .South:
			_, ok := wall.get_east_west_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		case .East:
			_, ok := wall.get_south_west_north_east_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		case .North:
		case .West:
			_, ok := wall.get_north_west_south_east_wall(
				{from.position.x, floor.floor, from.position.y},
			)
			if ok {
				return false
			}
		}
	case .West:
		switch to.side {
		case .South:
			_, ok := wall.get_south_west_north_east_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		case .East:
			_, ok := wall.get_north_south_wall(
				{from.position.x, floor.floor, from.position.y},
			)
			if ok {
				return false
			}
		case .North:
			_, ok := wall.get_north_west_south_east_wall(
				{to.position.x, floor.floor, to.position.y},
			)
			if ok {
				return false
			}
		case .West:
		}
	}

	tile_triangle, ok := tile.get_tile_triangle(
		{to.position.x, floor.floor, to.position.y},
		to.side,
	)

	return !ok || tile_triangle.texture == texture
}
