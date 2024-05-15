package floor_tool

import "core:fmt"
import "core:math/linalg/glsl"

import "../../constants"
import "../../floor"
import "../../tile"

Visited_Tile_Triangle :: struct {
	position: glsl.ivec2,
	side:     tile.Tile_Triangle_Side,
}

flood_fill :: proc(
	position: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
	original_texture: tile.Texture,
	texture: tile.Texture,
) {
	fmt.println("original_texture", original_texture)
	visited_queue: [dynamic]Visited_Tile_Triangle

	visited := Visited_Tile_Triangle{position.xz, side}

	set_texture(visited, texture)

	append(&visited_queue, visited)

	for len(visited_queue) > 0 {
		visited := pop(&visited_queue)
		fmt.println(visited)
		switch visited.side {
		case .South:
			next_visited := visited
			next_visited.side = .East
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .West
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .North
			next_visited.position -= {0, 1}
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		case .East:
			next_visited := visited
			next_visited.side = .North
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .South
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .West
			next_visited.position += {1, 0}
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		case .North:
			next_visited := visited
			next_visited.side = .East
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .West
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .South
			next_visited.position += {0, 1}
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		case .West:
			next_visited := visited
			next_visited.side = .South
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .North
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
			next_visited.side = .East
			next_visited.position -= {1, 0}
			process_next_visited(
				next_visited,
				original_texture,
				texture,
				&visited_queue,
			)
		}
	}
}

process_next_visited :: proc(
	visited: Visited_Tile_Triangle,
	original_texture: tile.Texture,
	texture: tile.Texture,
	visited_queue: ^[dynamic]Visited_Tile_Triangle,
) {
	if can_texture(visited, original_texture) {
		set_texture(visited, texture)
		append(visited_queue, visited)
	}
}

set_texture :: proc(
	using visited: Visited_Tile_Triangle,
	texture: tile.Texture,
) {
	fmt.println("set_texture", visited, texture)
	tile.set_tile_triangle(
		{position.x, floor.floor, position.y},
		side,
		tile.Tile_Triangle{texture = texture, mask_texture = .Grid_Mask},
	)
}

can_texture :: proc(
	using visited: Visited_Tile_Triangle,
	texture: tile.Texture,
) -> bool {
	if position.x < 0 ||
	   position.y < 0 ||
	   position.x >= constants.WORLD_WIDTH ||
	   position.y >= constants.WORLD_DEPTH {
		return false
	}

	tile_triangle, ok := tile.get_tile_triangle(
		{position.x, floor.floor, position.y},
		side,
	)

	fmt.println("can_texture", visited, tile_triangle.texture)

	return !ok || tile_triangle.texture == texture
}
