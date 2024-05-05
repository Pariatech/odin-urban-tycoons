package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

import "constants"
import "camera"
import "tile"
import "billboard"

house_x: i32 = 12
house_z: i32 = 12

world_chunks: [constants.WORLD_CHUNK_WIDTH][constants.WORLD_CHUNK_DEPTH]Chunk

world_tiles_dirty: bool
world_previously_visible_chunks_start: glsl.ivec2
world_previously_visible_chunks_end: glsl.ivec2

world_get_chunk :: proc(pos: glsl.ivec2) -> ^Chunk {
	return &world_chunks[pos.x / constants.CHUNK_WIDTH][pos.y / constants.CHUNK_DEPTH]
}

world_set_tile :: proc(
	pos: glsl.ivec3,
	tile: [tile.Tile_Triangle_Side]Maybe(tile.Tile_Triangle),
) {
	chunk_set_tile(world_get_chunk(pos.xz), pos, tile)
}

world_get_tile :: proc(
	pos: glsl.ivec3,
) -> ^[tile.Tile_Triangle_Side]Maybe(tile.Tile_Triangle) {
	return chunk_get_tile(world_get_chunk(pos.xz), pos)
}

world_set_tile_mask_texture :: proc(pos: glsl.ivec3, mask_texture: tile.Mask) {
	chunk_set_tile_mask_texture(world_get_chunk(pos.xz), pos, mask_texture)
}

world_set_tile_triangle :: proc(
	pos: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
	tile_triangle: Maybe(tile.Tile_Triangle),
) {
	chunk_set_tile_triangle(world_get_chunk(pos.xz), pos, side, tile_triangle)
}

world_set_north_south_wall :: proc(pos: glsl.ivec3, wall: Wall) {
	chunk_set_north_south_wall(world_get_chunk(pos.xz), pos, wall)
}

world_get_north_south_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_north_south_wall(world_get_chunk(pos.xz), pos)
}

world_has_north_south_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_north_south_wall(world_get_chunk(pos.xz), pos) \
	)
}

world_remove_north_south_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_north_south_wall(world_get_chunk(pos.xz), pos)
}

world_set_east_west_wall :: proc(pos: glsl.ivec3, wall: Wall) {
	chunk_set_east_west_wall(world_get_chunk(pos.xz), pos, wall)
}

world_get_east_west_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_east_west_wall(world_get_chunk(pos.xz), pos)
}

world_has_east_west_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_east_west_wall(world_get_chunk(pos.xz), pos) \
	)
}

world_remove_east_west_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_east_west_wall(world_get_chunk(pos.xz), pos)
}

world_set_north_west_south_east_wall :: proc(pos: glsl.ivec3, wall: Wall) {
	chunk_set_north_west_south_east_wall(world_get_chunk(pos.xz), pos, wall)
}

world_has_north_west_south_east_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_north_west_south_east_wall(world_get_chunk(pos.xz), pos) \
	)
}

world_get_north_west_south_east_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_north_west_south_east_wall(world_get_chunk(pos.xz), pos)
}

world_remove_north_west_south_east_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_north_west_south_east_wall(world_get_chunk(pos.xz), pos)
}

world_set_south_west_north_east_wall :: proc(pos: glsl.ivec3, wall: Wall) {
	chunk_set_south_west_north_east_wall(world_get_chunk(pos.xz), pos, wall)
}

world_has_south_west_north_east_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_south_west_north_east_wall(world_get_chunk(pos.xz), pos) \
	)
}

world_get_south_west_north_east_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_south_west_north_east_wall(world_get_chunk(pos.xz), pos)
}

world_remove_south_west_north_east_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_south_west_north_east_wall(world_get_chunk(pos.xz), pos)
}

world_iterate_all_chunks :: proc() -> Chunk_Iterator {
	return {{0, 0}, {0, 0}, {constants.WORLD_CHUNK_WIDTH, constants.WORLD_CHUNK_DEPTH}}
}

world_iterate_visible_chunks :: proc() -> Chunk_Iterator {
	it := Chunk_Iterator{}

	switch camera.rotation {
	case .South_West:
		it.pos = camera.visible_chunks_end - {1, 1}
	case .South_East:
		it.pos.x = camera.visible_chunks_end.x - 1
		it.pos.y = camera.visible_chunks_start.y
	case .North_East:
		it.pos = camera.visible_chunks_start
	case .North_West:
		it.pos.x = camera.visible_chunks_start.x
		it.pos.y = camera.visible_chunks_end.y - 1
	}

	it.start = camera.visible_chunks_start
	it.end = camera.visible_chunks_end

	return it
}

world_draw_walls :: proc(floor: int) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_mask_array)

	chunks_it := world_iterate_visible_chunks()
	for chunk, chunk_pos in chunk_iterator_next(&chunks_it) {
		chunk_draw_walls(chunk, {chunk_pos.x, i32(floor), chunk_pos.z})
	}
}


world_draw_tiles :: proc(floor: int) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, mask_array)
	// gl.Disable(gl.BLEND)

	chunks_it := world_iterate_visible_chunks()
	for chunk, chunk_pos in chunk_iterator_next(&chunks_it) {
		chunk_draw_tiles(chunk, {chunk_pos.x, i32(floor), chunk_pos.z})
	}
	// gl.Enable(gl.BLEND)
}

world_update :: proc() {
	aabb := camera.get_aabb()
	world_previously_visible_chunks_start = camera.visible_chunks_start
	world_previously_visible_chunks_end = camera.visible_chunks_end
	camera.visible_chunks_start.x = max(aabb.x / constants.CHUNK_WIDTH - 1, 0)
	camera.visible_chunks_start.y = max(aabb.y / constants.CHUNK_DEPTH - 1, 0)
	camera.visible_chunks_end.x = min(
		(aabb.x + aabb.w) / constants.CHUNK_WIDTH + 1,
		constants.WORLD_CHUNK_WIDTH,
	)
	camera.visible_chunks_end.y = min(
		(aabb.y + aabb.h) / constants.CHUNK_DEPTH + 1,
		constants.WORLD_CHUNK_DEPTH,
	)
	world_tiles_dirty = false
}

init_world :: proc() {
	for x in 0 ..< constants.WORLD_CHUNK_WIDTH {
		for z in 0 ..< constants.WORLD_CHUNK_DEPTH {
			chunk_init(&world_chunks[x][z])
		}
	}

	// The house
	add_house_floor_walls(0, .Varg, .Varg)
	add_house_floor_walls(1, .Nyana, .Nyana)
	add_house_floor_triangles(2, .Wood)

	for x in 0 ..< constants.WORLD_WIDTH {
		for z in 1 ..= 3 {
			world_set_tile(
				{i32(x), 0, i32(z)},
				chunk_tile({texture = .Asphalt, mask_texture = .Full_Mask}),
			)
		}

		world_set_tile(
			{i32(x), 0, 4},
			chunk_tile(
				 {
					texture = .Asphalt_Horizontal_Line,
					mask_texture = .Full_Mask,
				},
			),
		)
		for z in 5 ..= 7 {
			world_set_tile(
				{i32(x), 0, i32(z)},
				chunk_tile({texture = .Asphalt, mask_texture = .Full_Mask}),
			)
		}
	}

	for x in 1 ..= 7 {
		world_set_tile(
			{i32(x), 0, 4},
			chunk_tile({texture = .Asphalt, mask_texture = .Full_Mask}),
		)
	}

	for z in 8 ..< constants.WORLD_WIDTH {
		for x in 1 ..= 3 {
			world_set_tile(
				{i32(x), 0, i32(z)},
				chunk_tile({texture = .Asphalt, mask_texture = .Full_Mask}),
			)
		}

		world_set_tile(
			{4, 0, i32(z)},
			chunk_tile(
				{texture = .Asphalt_Vertical_Line, mask_texture = .Full_Mask},
			),
		)
		for x in 5 ..= 7 {
			world_set_tile(
				{i32(x), 0, i32(z)},
				chunk_tile({texture = .Asphalt, mask_texture = .Full_Mask}),
			)
		}
	}

	for x in 8 ..< constants.WORLD_WIDTH {
		world_set_tile(
			{i32(x), 0, 8},
			chunk_tile({texture = .Sidewalk, mask_texture = .Full_Mask}),
		)
	}

	for z in 9 ..< constants.WORLD_WIDTH {
		world_set_tile(
			{8, 0, i32(z)},
			chunk_tile({texture = .Sidewalk, mask_texture = .Full_Mask}),
		)
	}
}

add_house_floor_triangles :: proc(floor: i32, texture: tile.Texture) {
	tri := tile.Tile_Triangle {
		texture      = texture,
		mask_texture = .Full_Mask,
	}

	world_set_tile_triangle({house_x + 4, floor, house_z}, .West, tri)
	world_set_tile_triangle({house_x + 4, floor, house_z}, .North, tri)

	world_set_tile_triangle({house_x, floor, house_z + 4}, .South, tri)
	world_set_tile_triangle({house_x, floor, house_z + 4}, .East, tri)

	world_set_tile_triangle({house_x, floor, house_z + 6}, .North, tri)
	world_set_tile_triangle({house_x, floor, house_z + 6}, .East, tri)

	world_set_tile_triangle({house_x + 4, floor, house_z + 10}, .South, tri)
	world_set_tile_triangle({house_x + 4, floor, house_z + 10}, .West, tri)

	for x in 0 ..< 4 {
		for z in 0 ..< 4 {
			world_set_tile(
				{house_x + i32(x), floor, house_z + i32(z)},
				chunk_tile(tri),
			)
		}
	}

	for x in 0 ..< 3 {
		for z in 0 ..< 3 {
			world_set_tile(
				{house_x + i32(x) + 1, floor, house_z + i32(z) + 4},
				chunk_tile(tri),
			)
		}
	}

	for x in 0 ..< 4 {
		for z in 0 ..< 4 {
			world_set_tile(
				{house_x + i32(x), floor, house_z + i32(z) + 7},
				chunk_tile(tri),
			)
		}
	}

	for z in 0 ..< 9 {
		world_set_tile(
			{house_x + 4, floor, house_z + i32(z) + 1},
			chunk_tile(tri),
		)
	}
}

add_house_floor_walls :: proc(
	floor: i32,
	inside_texture: Wall_Texture,
	outside_texture: Wall_Texture,
) {
	// The house's front wall
	world_set_north_south_wall(
		{house_x, floor, house_z},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)
	for i in 0 ..< 2 {
		world_set_north_south_wall(
			{house_x, floor, house_z + i32(i) + 1},
			 {
				type = .Side_Side,
				textures =  {
					.Inside = inside_texture,
					.Outside = outside_texture,
				},
			},
		)
	}
	world_set_north_south_wall(
		{house_x, floor, house_z + 3},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	world_set_south_west_north_east_wall(
		{house_x, floor, house_z + 4},
		 {
			type = .Side_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	// door?
	mask := Wall_Mask_Texture.Window_Opening
	if floor == 0 do mask = .Door_Opening
	world_set_north_south_wall(
		{house_x + 1, floor, house_z + 5},
		 {
			type = .Left_Corner_Left_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
			mask = mask,
		},
	)
	if floor > 0 {
		billboard.billboard_1x1_set(
			 {
				type = .Window,
				pos =  {
					f32(house_x + 1),
					f32(floor * constants.WALL_HEIGHT),
					f32(house_z + 5),
				},
			},
			 {
				light = {1, 1, 1},
				texture = .Window_Wood_SE,
				depth_map = .Window_Wood_SE,
			},
		)
	} else {
		billboard.billboard_1x1_set(
			 {
				type = .Door,
				pos = {f32(house_x + 1), f32(floor), f32(house_z + 5)},
			},
			 {
				light = {1, 1, 1},
				texture = .Door_Wood_SE,
				depth_map = .Door_Wood_SE,
			},
		)
	}

	world_set_north_west_south_east_wall(
		{house_x, floor, house_z + 6},
		 {
			type = .End_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	world_set_north_south_wall(
		{house_x, floor, house_z + 7},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	for i in 0 ..< 2 {
		world_set_north_south_wall(
			{house_x, floor, house_z + i32(i) + 8},
			 {
				type = .Side_Side,
				textures =  {
					.Inside = inside_texture,
					.Outside = outside_texture,
				},
				mask = .Window_Opening,
			},
		)
		billboard.billboard_1x1_set(
			 {
				type = .Window,
				pos =  {
					f32(house_x),
					f32(floor * constants.WALL_HEIGHT),
					f32(house_z + i32(i) + 8),
				},
			},
			 {
				light = {1, 1, 1},
				texture = .Window_Wood_SE,
				depth_map = .Window_Wood_SE,
			},
		)
	}

	world_set_north_south_wall(
		{house_x, floor, house_z + 10},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	// The house's right side wall
	world_set_east_west_wall(
		{house_x, floor, house_z},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	for i in 0 ..< 2 {
		world_set_east_west_wall(
			{house_x + i32(i) + 1, floor, house_z},
			 {
				type = .Side_Side,
				textures =  {
					.Inside = inside_texture,
					.Outside = outside_texture,
				},
				mask = .Window_Opening,
			},
		)

		billboard.billboard_1x1_set(
			 {
				type = .Window,
				pos =  {
					f32(house_x + i32(i) + 1),
					f32(floor * constants.WALL_HEIGHT),
					f32(house_z),
				},
			},
			 {
				light = {1, 1, 1},
				texture = .Window_Wood_SW,
				depth_map = .Window_Wood_SW,
			},
		)
	}

	world_set_east_west_wall(
		{house_x + 3, floor, house_z},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = inside_texture, .Outside = outside_texture},
		},
	)

	// The house's left side wall
	world_set_east_west_wall(
		{house_x, floor, house_z + 11},
		 {
			type = .Right_Corner_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	for i in 0 ..< 2 {
		world_set_east_west_wall(
			{house_x + i32(i) + 1, floor, house_z + 11},
			 {
				type = .Side_Side,
				textures =  {
					.Inside = outside_texture,
					.Outside = inside_texture,
				},
				mask = .Window_Opening,
			},
		)

		billboard.billboard_1x1_set(
			 {
				type = .Window,
				pos =  {
					f32(house_x + i32(i) + 1),
					f32(floor * constants.WALL_HEIGHT),
					f32(house_z + 11),
				},
			},
			 {
				light = {1, 1, 1},
				texture = .Window_Wood_SW,
				depth_map = .Window_Wood_SW,
			},
		)
	}
	world_set_east_west_wall(
		{house_x + 3, floor, house_z + 11},
		 {
			type = .Side_Right_Corner,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	// The house's back wall
	world_set_south_west_north_east_wall(
		{house_x + 4, floor, house_z},
		 {
			type = .Side_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	world_set_north_south_wall(
		{house_x + 5, floor, house_z + 1},
		 {
			type = .Side_Left_Corner,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	for i in 0 ..< 7 {
		world_set_north_south_wall(
			{house_x + 5, floor, house_z + i32(i) + 2},
			 {
				type = .Side_Side,
				textures =  {
					.Inside = outside_texture,
					.Outside = inside_texture,
				},
			},
		)
	}

	world_set_north_south_wall(
		{house_x + 5, floor, house_z + 9},
		 {
			type = .Left_Corner_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)

	world_set_north_west_south_east_wall(
		{house_x + 4, floor, house_z + 10},
		 {
			type = .End_Side,
			textures = {.Inside = outside_texture, .Outside = inside_texture},
		},
	)
}

draw_world :: proc() {
	uniform_object.view = camera.view
	uniform_object.proj = camera.proj

	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)
	gl.BufferSubData(
		gl.UNIFORM_BUFFER,
		0,
		size_of(Uniform_Object),
		&uniform_object,
	)


	for floor in 0 ..< constants.CHUNK_HEIGHT {
	    gl.UseProgram(shader_program)
		world_draw_tiles(floor)
		world_draw_walls(floor)
		billboard.draw_billboards(floor)
	}
}

world_update_after_rotation :: proc(rotated: camera.Rotated) {
	wall_tool_move_cursor()
    billboard.update_after_rotation()
	switch rotated {
	case .Counter_Clockwise:
        billboard.update_after_counter_clockwise_rotation()
	case .Clockwise:
        billboard.update_after_clockwise_rotation()
	}
	for row in &world_chunks {
		for chunk in &row {
			for floor in 0 ..< constants.CHUNK_HEIGHT {
				chunk.floors[floor].walls.dirty = true
			}
		}
	}
}

