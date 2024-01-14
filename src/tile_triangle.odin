package main

Tile_Triangle_Side :: enum {
	South,
	East,
	North,
	West,
}

Tile_Triangle :: struct {
	// position:     Vec3,
	// corner:        Half_Tile_Corner,
	// corners_y:     Vec3,
	// corners_light: [3]Vec3,
	texture:      Sprite,
	mask_texture: Sprite,
}

TILE_TRIANGLE_SIDE_VERTICES_MAP :: [Tile_Triangle_Side][3]Vertex {
	.South =  {
		 {
			pos = {-0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {0.0, 0.0, 0.0},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.5, 0.5, 0.0, 0.0},
		},
	},
	.East =  {
		 {
			pos = {0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {0.0, 0.0, 0.0},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.5, 0.5, 0.0, 0.0},
		},
	},
	.North =  {
		 {
			pos = {0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {1.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {-0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {0.0, 0.0, 0.0},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.5, 0.5, 0.0, 0.0},
		},
	},
	.West =  {
		 {
			pos = {-0.5, 0.0, 0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 1.0, 0.0, 0.0},
		},
		 {
			pos = {-0.5, 0.0, -0.5},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.0, 0.0, 0.0, 0.0},
		},
		 {
			pos = {0.0, 0.0, 0.0},
			light = {1.0, 1.0, 1.0},
			texcoords = {0.5, 0.5, 0.0, 0.0},
		},
	},
}

tile_triangles: [Tile_Triangle_Side][dynamic]Tile_Triangle

get_tile_triangle_lights :: proc(
	side: Tile_Triangle_Side,
	pos: IVec3,
) -> (
	lights: [3]Vec3,
) {
	lights = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}}
	if pos.y != 0 do return

	tile_lights := [4]Vec3 {
		terrain_lights[pos.x][pos.z],
		terrain_lights[pos.x + 1][pos.z],
		terrain_lights[pos.x + 1][pos.z + 1],
		terrain_lights[pos.x][pos.z + 1],
	}

    lights[2] = {0, 0, 0}
    for light in tile_lights {
        lights[2] += light
    }
    lights[2] /= 4
	switch side {
	case .South:
        lights[0] = tile_lights[0]
        lights[1] = tile_lights[1]
    case .East:
        lights[0] = tile_lights[1]
        lights[1] = tile_lights[2]
    case .North:
        lights[0] = tile_lights[2]
        lights[1] = tile_lights[3]
    case .West:
        lights[0] = tile_lights[3]
        lights[1] = tile_lights[0]
	}

	return
}

get_tile_triangle_heights :: proc(
	side: Tile_Triangle_Side,
	pos: IVec3,
) -> (
	heights: [3]f32,
) {
	heights = {0,0,0}
	if pos.y != 0 do return

	tile_heights := [4]f32 {
		terrain_heights[pos.x][pos.z],
		terrain_heights[pos.x + 1][pos.z],
		terrain_heights[pos.x + 1][pos.z + 1],
		terrain_heights[pos.x][pos.z + 1],
	}

    heights[2] = 0
    for height in tile_heights {
        heights[2] += height
    }
    heights[2] /= 4
	switch side {
	case .South:
        heights[0] = tile_heights[0]
        heights[1] = tile_heights[1]
    case .East:
        heights[0] = tile_heights[1]
        heights[1] = tile_heights[2]
    case .North:
        heights[0] = tile_heights[2]
        heights[1] = tile_heights[3]
    case .West:
        heights[0] = tile_heights[3]
        heights[1] = tile_heights[0]
	}

	return
}

draw_tile_triangle :: proc(side: Tile_Triangle_Side, pos: IVec3) {
	tri: Tile_Triangle
	if pos.y == 0 {
		tri = tile_triangles[side][pos.x * WORLD_DEPTH + pos.z]
	}

	verts_map := TILE_TRIANGLE_SIDE_VERTICES_MAP
	verts := verts_map[side]

	lights := get_tile_triangle_lights(side, pos)
    heights := get_tile_triangle_heights(side, pos)

	for i in 0 ..< len(verts) {
		verts[i].pos.x += f32(pos.x)
		verts[i].pos.z += f32(pos.z)
		verts[i].pos.y = heights[i]
		verts[i].light = lights[i]
		verts[i].texcoords.z = f32(tri.texture)
		verts[i].texcoords.w = f32(tri.mask_texture)
	}

	v0 := verts[0]
	v1 := verts[1]
	v2 := verts[2]

	draw_triangle(v0, v1, v2)
}

append_tile_triangle :: proc(
	side: Tile_Triangle_Side,
	pos: IVec3,
	texture: Sprite,
	mask: Sprite,
) {
	append(
		&tile_triangles[side],
		Tile_Triangle{texture = texture, mask_texture = mask},
	)
}
