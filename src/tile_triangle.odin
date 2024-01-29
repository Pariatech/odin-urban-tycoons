package main

import m "core:math/linalg/glsl"

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

north_tile_triangles := map[m.ivec3]Tile_Triangle{}
east_tile_triangles := map[m.ivec3]Tile_Triangle{}
south_tile_triangles := map[m.ivec3]Tile_Triangle{}
west_tile_triangles := map[m.ivec3]Tile_Triangle{}

Tile_Triangle_Vertices_Key :: struct {
	side:    Tile_Triangle_Side,
	heights: [3]f32,
	lights: [3]m.vec3,
}

tile_triangle_vertices := map[Tile_Triangle_Vertices_Key][]Vertex{}
tile_triangle_indices := []u32{0, 1, 2}

tile_triangle_side_vertices_map := [Tile_Triangle_Side][3]Vertex {
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

draw_tile_triangle :: proc(
	tri: Tile_Triangle,
	side: Tile_Triangle_Side,
	lights: [3]m.vec3,
	heights: [3]f32,
	pos: m.vec2,
) {
	transform := m.mat4Translate({pos.x, 0, pos.y})
    key := Tile_Triangle_Vertices_Key{side = side, heights = heights, lights = lights}
	vertices, ok := tile_triangle_vertices[key]
	if !ok {
		new_vertices := new_clone(tile_triangle_side_vertices_map[side])
		for i in 0 ..< len(new_vertices) {
			new_vertices[i].pos.y += heights[i]
			new_vertices[i].light = lights[i]
		}
        vertices = new_vertices[:]
        tile_triangle_vertices[key] = vertices
	}

	append_draw_component(
		 {
			vertices = vertices,
			indices = tile_triangle_indices,
			model = transform,
			texture = tri.texture,
			mask = tri.mask_texture,
		},
	)
}
