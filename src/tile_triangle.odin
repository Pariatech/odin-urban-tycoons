package main

Tile_Triangle_Side :: enum {
	South,
	East,
	North,
	West,
}

Tile_Triangle :: struct {
	texture:      Texture,
	mask_texture: Texture,
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
