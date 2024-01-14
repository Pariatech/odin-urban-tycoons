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

draw_tile_triangle :: proc(side: Tile_Triangle_Side, pos: IVec3) {
	tri: Tile_Triangle
	if pos.y == 0 {
		tri = tile_triangles[side][pos.z * WORLD_WIDTH + pos.x]
	}

	verts_map := TILE_TRIANGLE_SIDE_VERTICES_MAP
	verts := verts_map[side]

	for i in 0 ..< len(verts) {
		verts[i].pos.x += f32(pos.x)
		verts[i].pos.z += f32(pos.z)
		// vertices[i].pos.y += half_tile.corners_y[i]
		// vertices[i].light = half_tile.corners_light[i]
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
