package main

import m "core:math/linalg/glsl"
import "core:fmt"

Tile_Triangle_Side :: enum {
	South,
	East,
	North,
	West,
}

Tile_Triangle :: struct {
	texture:      Texture,
	mask_texture: Mask,
}

north_tile_triangles := map[m.ivec3]Tile_Triangle{}
east_tile_triangles := map[m.ivec3]Tile_Triangle{}
south_tile_triangles := map[m.ivec3]Tile_Triangle{}
west_tile_triangles := map[m.ivec3]Tile_Triangle{}

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
    size: f32,
) {
	index_offset := u32(len(world_vertices))

	vertices := tile_triangle_side_vertices_map[side]
	for vertex, i in vertices {
		vertex := vertex
        vertex.pos *= size
        vertex.pos.x += pos.x
        vertex.pos.z += pos.y
		vertex.pos.y += heights[i]
		vertex.light = lights[i]
        vertex.texcoords.z = f32(tri.texture)
        vertex.texcoords.w = f32(tri.mask_texture)
        vertex.texcoords.xy *= size
		append(&world_vertices, vertex)
	}

	append(
		&world_indices,
		index_offset + 0,
		index_offset + 1,
		index_offset + 2,
	)
}
