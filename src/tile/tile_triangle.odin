package tile

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"

import "../camera"
import "../constants"
import "../terrain"

Vertex :: struct {
	pos:       glsl.vec3,
	light:     glsl.vec3,
	texcoords: glsl.vec4,
	depth_map: f32,
}

Texture :: enum (u16) {
	Floor_Marker,
	Grass,
	Wood,
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

Key :: struct {
	x, z: int,
	side: Tile_Triangle_Side,
}

Chunk :: struct {
	triangles:     map[Key]Tile_Triangle,
	dirty:         bool,
	initialized:   bool,
	vao, vbo, ebo: u32,
	num_indices:   i32,
}

chunks: [constants.CHUNK_HEIGHT][constants.WORLD_CHUNK_WIDTH][constants.WORLD_CHUNK_DEPTH]Chunk
texture_array: u32
mask_array: u32
tile_triangle_side_vertices_map :=
	[Tile_Triangle_Side][3]Tile_Triangle_Vertex {
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
		.Dotted_Grid    = "resources/textures/masks/dotted-grid.png",
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

draw_tiles :: proc(floor: i32) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, mask_array)

	floor_slice := &chunks[floor]
	for x in camera.visible_chunks_start.x ..< camera.visible_chunks_end.x {
		for z in camera.visible_chunks_start.y ..< camera.visible_chunks_end.y {
			chunk_draw_tiles(&floor_slice[x][z], {i32(x), i32(floor), i32(z)})
		}
	}
}

chunk_draw_tiles :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	if !chunk.initialized {
		chunk.initialized = true
		chunk.dirty = true
		gl.GenVertexArrays(1, &chunk.vao)
		gl.BindVertexArray(chunk.vao)
		gl.GenBuffers(1, &chunk.vbo)
		gl.BindBuffer(gl.ARRAY_BUFFER, chunk.vbo)

		gl.GenBuffers(1, &chunk.ebo)

		gl.VertexAttribPointer(
			0,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Tile_Triangle_Vertex),
			offset_of(Tile_Triangle_Vertex, pos),
		)
		gl.EnableVertexAttribArray(0)

		gl.VertexAttribPointer(
			1,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Tile_Triangle_Vertex),
			offset_of(Tile_Triangle_Vertex, light),
		)
		gl.EnableVertexAttribArray(1)

		gl.VertexAttribPointer(
			2,
			4,
			gl.FLOAT,
			gl.FALSE,
			size_of(Tile_Triangle_Vertex),
			offset_of(Tile_Triangle_Vertex, texcoords),
		)
		gl.EnableVertexAttribArray(2)
	}

	gl.BindVertexArray(chunk.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, chunk.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, chunk.ebo)

	floor := pos.y
	if chunk.dirty {
		chunk.dirty = false
		vertices: [dynamic]Tile_Triangle_Vertex
		indices: [dynamic]u32
		defer delete(vertices)
		defer delete(indices)

		for index, tile_triangle in chunk.triangles {
			side := index.side
			pos := glsl.vec2{f32(index.x), f32(index.z)}

			x := int(index.x)
			z := int(index.z)
			lights := get_terrain_tile_triangle_lights(side, x, z, 1)

			heights := get_terrain_tile_triangle_heights(side, x, z, 1)

			for i in 0 ..< 3 {
				heights[i] += f32(floor * constants.WALL_HEIGHT)
			}

			draw_tile_triangle(
				tile_triangle,
				side,
				lights,
				heights,
				pos,
				1,
				&vertices,
				&indices,
			)
		}

		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(vertices) * size_of(Vertex),
			raw_data(vertices),
			gl.STATIC_DRAW,
		)

		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(indices) * size_of(u32),
			raw_data(indices),
			gl.STATIC_DRAW,
		)
		chunk.num_indices = i32(len(indices))
	}

	gl.DrawElements(gl.TRIANGLES, chunk.num_indices, gl.UNSIGNED_INT, nil)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
}

get_terrain_tile_triangle_lights :: proc(
	side: Tile_Triangle_Side,
	x, z, w: int,
) -> (
	lights: [3]glsl.vec3,
) {
	lights = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}}

	tile_lights := [4]glsl.vec3 {
		terrain.terrain_lights[x][z],
		terrain.terrain_lights[x + w][z],
		terrain.terrain_lights[x + w][z + w],
		terrain.terrain_lights[x][z + w],
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

get_terrain_tile_triangle_heights :: proc(
	side: Tile_Triangle_Side,
	x, z, w: int,
) -> (
	heights: [3]f32,
) {
	heights = {0, 0, 0}

	tile_heights := [4]f32 {
		terrain.terrain_heights[x][z],
		terrain.terrain_heights[x + w][z],
		terrain.terrain_heights[x + w][z + w],
		terrain.terrain_heights[x][z + w],
	}

	heights[2] = 0
	lowest := min(
		tile_heights[0],
		tile_heights[1],
		tile_heights[2],
		tile_heights[3],
	)
	highest := max(
		tile_heights[0],
		tile_heights[1],
		tile_heights[2],
		tile_heights[3],
	)
	heights[2] = (lowest + highest) / 2

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

tile :: proc(
	tile_triangle: Maybe(Tile_Triangle),
) -> [Tile_Triangle_Side]Maybe(Tile_Triangle) {
	return(
		 {
			.West = tile_triangle,
			.South = tile_triangle,
			.East = tile_triangle,
			.North = tile_triangle,
		} \
	)
}

chunk_init :: proc() {
	for cx in 0 ..< constants.WORLD_CHUNK_WIDTH {
		for cz in 0 ..< constants.WORLD_CHUNK_DEPTH {
			chunk := &chunks[0][cx][cz]
			for x in 0 ..< constants.CHUNK_WIDTH {
				for z in 0 ..< constants.CHUNK_DEPTH {
					for side in Tile_Triangle_Side {
						chunk.triangles[{x = cx * constants.CHUNK_WIDTH + x, z = cz * constants.CHUNK_DEPTH + z, side = side}] =
							Tile_Triangle {
								texture      = .Grass,
								mask_texture = .Grid_Mask,
							}
					}
				}
			}
		}
	}
}

get_chunk :: proc(pos: glsl.ivec3) -> ^Chunk {
	x := pos.x / constants.CHUNK_WIDTH
	z := pos.z / constants.CHUNK_DEPTH
	return &chunks[pos.y][x][z]
}

get_tile_triangle :: proc(
	pos: glsl.ivec3,
	side: Tile_Triangle_Side,
) -> (
	Tile_Triangle,
	bool,
) {
	chunk := get_chunk(pos)
	return chunk.triangles[{x = int(pos.x), z = int(pos.z), side = side}]
}

set_tile_triangle :: proc(
	pos: glsl.ivec3,
	side: Tile_Triangle_Side,
	tile_triangle: Maybe(Tile_Triangle),
) {
	key := Key {
			x    = int(pos.x),
			z    = int(pos.z),
			side = side,
		}
	chunk := get_chunk(pos)
	if tile_triangle != nil {
		chunk.triangles[key] = tile_triangle.?
	} else {
		delete_key(&chunk.triangles, key)
	}
	chunk.dirty = true
}

get_tile :: proc(pos: glsl.ivec3) -> [Tile_Triangle_Side]Maybe(Tile_Triangle) {
	chunk := get_chunk(pos)
	result := [Tile_Triangle_Side]Maybe(Tile_Triangle){}

	for side in Tile_Triangle_Side {
		key := Key {
				x    = int(pos.x),
				z    = int(pos.z),
				side = side,
			}
		tri, ok := chunk.triangles[key]
		if ok {
			result[side] = tri
		}
	}

	return result
}

set_tile :: proc(
	pos: glsl.ivec3,
	tile: [Tile_Triangle_Side]Maybe(Tile_Triangle),
) {
	chunk := get_chunk(pos)
	for tri, side in tile {
		set_tile_triangle(pos, side, tri)
	}
}

set_tile_mask_texture :: proc(pos: glsl.ivec3, mask_texture: Mask) {
	chunk := get_chunk(pos)
	for side in Tile_Triangle_Side {
		tri, ok := get_tile_triangle(pos, side)
		if ok {
			tri.mask_texture = mask_texture
			set_tile_triangle(pos, side, tri)
		}
	}
}

set_tile_texture :: proc(pos: glsl.ivec3, texture: Texture) {
	chunk := get_chunk(pos)
	for side in Tile_Triangle_Side {
		tri, ok := get_tile_triangle(pos, side)
		if ok {
			tri.texture = texture
			set_tile_triangle(pos, side, tri)
		}
	}
}
