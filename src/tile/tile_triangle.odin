package tile

import "core:fmt"
import "core:math/linalg/glsl"

Texture :: enum (u16) {
	Floor_Marker,
	Wood,
	Grass,
	Gravel,
	Asphalt,
	Asphalt_Vertical_Line,
	Asphalt_Horizontal_Line,
	Concrete,
	Sidewalk,
}

Mask :: enum (u16) {
	Full_Mask,
	Grid_Mask,
	Leveling_Brush,
    Dotted_Grid,
}

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

Tile_Triangle_Vertex :: struct {
	pos:       glsl.vec3,
	light:     glsl.vec3,
	texcoords: glsl.vec4,
}

north_tile_triangles := map[glsl.ivec3]Tile_Triangle{}
east_tile_triangles := map[glsl.ivec3]Tile_Triangle{}
south_tile_triangles := map[glsl.ivec3]Tile_Triangle{}
west_tile_triangles := map[glsl.ivec3]Tile_Triangle{}

tile_triangle_side_vertices_map := [Tile_Triangle_Side][3]Tile_Triangle_Vertex {
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

TEXTURE_PATHS :: [Texture]cstring {
	.Floor_Marker            = "resources/textures/floors/floor-marker.png",
	.Wood                    = "resources/textures/floors/wood.png",
	.Grass                   = "resources/textures/tiles/lawn.png",
	.Gravel                  = "resources/textures/tiles/gravel.png",
	.Asphalt                 = "resources/textures/tiles/asphalt.png",
	.Asphalt_Vertical_Line   = "resources/textures/tiles/asphalt-vertical-line.png",
	.Asphalt_Horizontal_Line = "resources/textures/tiles/asphalt-horizontal-line.png",
	.Concrete                = "resources/textures/tiles/concrete.png",
	.Sidewalk                = "resources/textures/tiles/sidewalk.png",
}

MASK_PATHS :: [Mask]cstring {
	.Full_Mask      = "resources/textures/masks/full.png",
	.Grid_Mask      = "resources/textures/masks/grid.png",
	.Leveling_Brush = "resources/textures/masks/leveling-brush.png",
	.Dotted_Grid      = "resources/textures/masks/dotted-grid.png",
}

draw_tile_triangle :: proc(
	tri: Tile_Triangle,
	side: Tile_Triangle_Side,
	lights: [3]glsl.vec3,
	heights: [3]f32,
	pos: glsl.vec2,
	size: f32,
	vertices_buffer: ^[dynamic]Tile_Triangle_Vertex,
	indices: ^[dynamic]u32,
) {
	index_offset := u32(len(vertices_buffer))

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
		append(vertices_buffer, vertex)
	}

	append(indices, index_offset + 0, index_offset + 1, index_offset + 2)
}
