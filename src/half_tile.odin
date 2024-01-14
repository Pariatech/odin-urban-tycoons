package main

half_tiles: #soa[dynamic]Half_Tile
half_tile_octree: Octree_Node

Half_Tile_Corner :: enum {
	South_West,
	South_East,
	North_East,
	North_West,
}

Half_Tile :: struct {
	position:      Vec3,
	corner:        Half_Tile_Corner,
	corners_y:     Vec3,
	corners_light: [3]Vec3,
	texture:       Sprites,
	mask_texture:  Sprites,
}

HALF_TILE_CORNER_VERTICES_MAP :: [Half_Tile_Corner][3]Vertex {
	.South_West =  {
		 {
			pos = {0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {-0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {-0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 1.0, 0.0, 0.0},
		},
	},
	.South_East =  {
		 {
			pos = {-0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {-0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 1.0, 0.0, 0.0},
		},
	},
	.North_East =  {
		 {
			pos = {-0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 0.0, 0.0, 0.0},
		},
	},
	.North_West =  {
		 {
			pos = {0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {-0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 0.0, 0.0, 0.0},
		},
	},
}

draw_half_tile :: proc(half_tile: Half_Tile) {
	vertices_map := HALF_TILE_CORNER_VERTICES_MAP
	vertices := vertices_map[half_tile.corner]

	for i in 0 ..< 3 {
		vertices[i].pos += half_tile.position
		vertices[i].pos.y += half_tile.corners_y[i]
		vertices[i].light = half_tile.corners_light[i]
		vertices[i].texcoords.z = f32(half_tile.texture)
		vertices[i].texcoords.w = f32(half_tile.mask_texture)
	}

	v0 := vertices[0]
	v1 := vertices[1]
	v2 := vertices[2]

	draw_triangle(v0, v1, v2)
}

add_half_tile :: proc(half_tile: Half_Tile) {
	insert_in_octree(
		&half_tile_octree,
		{position = half_tile.position, index = len(half_tiles)},
		{WORLD_WIDTH / 2, WORLD_HEIGHT / 2, WORLD_DEPTH / 2},
		WORLD_WIDTH,
	)
	append_soa(&half_tiles, half_tile)
}

get_half_tiles_at :: proc(
	position: Vec3,
) -> (
	t0: Maybe(Half_Tile) = nil,
	t1: Maybe(Half_Tile) = nil,
) {
	// for ht in half_tiles {
	// 	if ht.position == position {
	// 		if t0 == nil {
	// 			t0 = ht
	// 		} else if t1 == nil {
	// 			t1 = ht
	// 		} else {
	// 			return
	// 		}
	// 	}
	// }

    index, ok := get_in_octree(
		&half_tile_octree,
		position,
		{WORLD_WIDTH / 2, WORLD_HEIGHT / 2, WORLD_DEPTH / 2},
		WORLD_WIDTH,
	).?
    if ok {
        t0 = half_tiles[index]
    }
    return;
}

draw_half_tiles_at :: proc(position: Vec3) {
	t0, t1 := get_half_tiles_at(position)

	if (t0 == nil && t1 == nil) do return

	half_tile, ok := t0.?

	if (ok) {
		draw_half_tile(half_tile)
	}

	half_tile, ok = t1.?

	if (ok) {
		draw_half_tile(half_tile)
	}
}
