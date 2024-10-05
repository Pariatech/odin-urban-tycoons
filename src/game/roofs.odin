package game

import "core:log"
import "core:math"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../camera"
import c "../constants"
import "../renderer"

Roof_Id :: int

Roof_Key :: struct {
	chunk_pos: glsl.ivec2,
	index:     int,
}

Roof_Type :: enum {
	Half_Hip,
	Half_Gable,
}

Roof_Orientation :: enum {}

Roof :: struct {
	id:           Roof_Id,
	start:        glsl.vec2,
	end:          glsl.vec2,
	slope:        f32,
	light:        glsl.vec3,
	type:         Roof_Type,
	top_texture:  string,
	side_texture: string,
	orientation:  Roof_Orientation,
}

Roof_Chunk :: struct {
	roofs:        [dynamic]Roof,
	dirty:        bool,
	roofs_inside: [dynamic]Roof_Id,
}

Roof_Chunks :: [c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Roof_Chunk

Roof_Uniform_Object :: struct {
	mvp:   glsl.mat4,
	light: glsl.vec3,
}

Roof_Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec3,
	color:     glsl.vec3,
}

Roof_Index :: u32

Roofs_Context :: struct {
	chunks:        Roof_Chunks,
	keys:          map[Roof_Id]Roof_Key,
	next_id:       Roof_Id,
	ubo:           u32,
	shader:        Shader,
	vao, vbo, ebo: u32,
	texture_array: u32,
}

ROOF_SHADER :: Shader {
	vertex   = "resources/shaders/roof.vert",
	fragment = "resources/shaders/roof.frag",
}

init_roofs :: proc(
	game: ^Game_Context = cast(^Game_Context)context.user_ptr,
) -> bool {
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	game.roofs.shader = ROOF_SHADER
	init_shader(&game.roofs.shader) or_return

	// set_shader_uniform(&game.roofs.shader, "texture_sampler", i32(0))

	gl.GenBuffers(1, &game.roofs.ubo)

	gl.GenVertexArrays(1, &game.roofs.vao)
	gl.BindVertexArray(game.roofs.vao)
	gl.GenBuffers(1, &game.roofs.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, game.roofs.vbo)

	gl.GenBuffers(1, &game.roofs.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, game.roofs.ebo)

	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Roof_Vertex),
		offset_of(Roof_Vertex, pos),
	)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(
		1,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Roof_Vertex),
		offset_of(Roof_Vertex, texcoords),
	)
	gl.EnableVertexAttribArray(1)

	gl.VertexAttribPointer(
		2,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Roof_Vertex),
		offset_of(Roof_Vertex, color),
	)
	gl.EnableVertexAttribArray(2)

	gl.ActiveTexture(gl.TEXTURE0)
	gl.GenTextures(1, &game.roofs.texture_array)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, game.roofs.texture_array)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MIN_FILTER,
		gl.LINEAR_MIPMAP_LINEAR,
	)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	max_anisotropy: f32
	gl.GetFloatv(gl.MAX_TEXTURE_MAX_ANISOTROPY, &max_anisotropy)
	gl.TexParameterf(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MAX_ANISOTROPY,
		max_anisotropy,
	)

	log.info(game.roofs.texture_array)
	renderer.load_texture_2D_array(ROOF_TEXTURES, 128, 128) or_return
	set_shader_uniform(&game.roofs.shader, "texture_sampler", i32(0))

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.UseProgram(0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, 0)

	return true
}

deinit_roofs :: proc(
	game: ^Game_Context = cast(^Game_Context)context.user_ptr,
) {
	delete(game.roofs.keys)
	for &row in game.roofs.chunks {
		for chunk in row {
			delete(chunk.roofs)
			delete(chunk.roofs_inside)
		}
	}
}

draw_roofs :: proc(game: ^Game_Context = cast(^Game_Context)context.user_ptr) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, game.roofs.texture_array)
	defer gl.BindTexture(gl.TEXTURE_2D_ARRAY, 0)

	gl.BindVertexArray(game.roofs.vao)

	gl.BindBuffer(gl.ARRAY_BUFFER, game.roofs.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, game.roofs.ebo)

	bind_shader(&game.roofs.shader)

	gl.BindBuffer(gl.UNIFORM_BUFFER, game.roofs.ubo)
	set_shader_unifrom_block_binding(
		&game.roofs.shader,
		"UniformBufferObject",
		2,
	)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, game.roofs.ubo)

	uniform_object := Roof_Uniform_Object {
		mvp = camera.view_proj,
		light = {1, 1, 1},
	}

	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Roof_Uniform_Object),
		&uniform_object,
		gl.STATIC_DRAW,
	)

	roof_ids: [dynamic]Roof_Id
	defer delete(roof_ids)
	for x in camera.visible_chunks_start.x ..< camera.visible_chunks_end.x {
		for z in camera.visible_chunks_start.y ..< camera.visible_chunks_end.y {
			chunk := &game.roofs.chunks[x][z]
			for roof_inside_id in chunk.roofs_inside {
				existing := false

				for roof_id in roof_ids {
					if roof_inside_id == roof_id {
						existing = true
						break
					}
				}

				if !existing {
					append(&roof_ids, roof_inside_id)
				}
			}
		}
	}

	vertices: [dynamic]Roof_Vertex
	defer delete(vertices)
	indices: [dynamic]Roof_Index
	defer delete(indices)
	for roof_id in roof_ids {
		draw_roof(&game.roofs, roof_id, &vertices, &indices)
	}

	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Roof_Vertex),
		raw_data(vertices),
		gl.STATIC_DRAW,
	)

	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(Roof_Index),
		raw_data(indices),
		gl.STATIC_DRAW,
	)

	gl.DrawElements(gl.TRIANGLES, i32(len(indices)), gl.UNSIGNED_INT, nil)
}

add_roof :: proc(
	roof: Roof,
	game: ^Game_Context = cast(^Game_Context)context.user_ptr,
) -> Roof_Id {
	x := i32(roof.start.x + 0.5)
	z := i32(roof.start.y + 0.5)
	chunk_x := x / c.CHUNK_WIDTH
	chunk_z := z / c.CHUNK_DEPTH
	chunk := &game.roofs.chunks[chunk_x][chunk_z]
	id := game.roofs.next_id
	game.roofs.next_id += 1
	game.roofs.keys[id] = {
		chunk_pos = {chunk_x, chunk_z},
		index = len(chunk.roofs),
	}
	append(&chunk.roofs, roof)
	append(&chunk.roofs_inside, id)

	return id
}

@(private = "file")
draw_roof :: proc(
	ctx: ^Roofs_Context,
	id: Roof_Id,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
) {
	key := ctx.keys[id]
	roof := &ctx.chunks[key.chunk_pos.x][key.chunk_pos.y].roofs[key.index]
	size := glsl.abs(roof.end - roof.start) + {1, 1}
	rotation: glsl.mat4
	face_lights := [4]glsl.vec3 {
		{1, 1, 1},
		{0.8, 0.8, 0.8},
		{0.6, 0.6, 0.6},
		{0.4, 0.4, 0.4},
	}
	if roof.start.x <= roof.end.x && roof.start.y <= roof.end.y {
		if size.y >= size.x {
			rotation = glsl.identity(glsl.mat4)
		} else {
			rotation = glsl.mat4Rotate({0, 1, 0}, 0.5 * math.PI)
			face_lights = [4]glsl.vec3 {
				{0.4, 0.4, 0.4},
				{1, 1, 1},
				{0.8, 0.8, 0.8},
				{0.6, 0.6, 0.6},
			}
		}
	} else if roof.start.x <= roof.end.x {
		if size.y >= size.x {
			rotation = glsl.mat4Rotate({0, 1, 0}, 1 * math.PI)
			face_lights = [4]glsl.vec3 {
				{0.6, 0.6, 0.6},
				{0.4, 0.4, 0.4},
				{1, 1, 1},
				{0.8, 0.8, 0.8},
			}
		} else {
			rotation = glsl.mat4Rotate({0, 1, 0}, 0.5 * math.PI)
			face_lights = [4]glsl.vec3 {
				{0.4, 0.4, 0.4},
				{1, 1, 1},
				{0.8, 0.8, 0.8},
				{0.6, 0.6, 0.6},
			}
		}
	} else if roof.start.y <= roof.end.y {
		if size.y >= size.x {
			rotation = glsl.identity(glsl.mat4)
		} else {
			rotation = glsl.mat4Rotate({0, 1, 0}, 1.5 * math.PI)
			face_lights = [4]glsl.vec3 {
				{0.8, 0.8, 0.8},
				{0.6, 0.6, 0.6},
				{0.4, 0.4, 0.4},
				{1, 1, 1},
			}
		}
	} else {
		if size.y >= size.x {
			rotation = glsl.mat4Rotate({0, 1, 0}, 1.0 * math.PI)
			face_lights = [4]glsl.vec3 {
				{0.6, 0.6, 0.6},
				{0.4, 0.4, 0.4},
				{1, 1, 1},
				{0.8, 0.8, 0.8},
			}
		} else {
			rotation = glsl.mat4Rotate({0, 1, 0}, 1.5 * math.PI)
			face_lights = [4]glsl.vec3 {
				{0.8, 0.8, 0.8},
				{0.6, 0.6, 0.6},
				{0.4, 0.4, 0.4},
				{1, 1, 1},
			}
		}
	}
	switch roof.type {
	case .Half_Hip:
		draw_half_hip_roof(
			roof,
			vertices,
			indices,
			size,
			rotation,
			face_lights,
		)
	case .Half_Gable:
	}
}

@(private = "file")
ROOF_TEXTURES :: [?]cstring{"resources/textures/roofs/RoofingTiles002.png"}

@(private = "file")
HALF_PYRAMID_ROOF_VERTICES :: [?]Roof_Vertex {
	{pos = {-0.5, 0, -0.5}, texcoords = {0, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 0, -0.5}, texcoords = {1, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 1, 0}, texcoords = {1, 0, 0}, color = {1, 1, 1}},
	{pos = {-0.5, 0, 0.5}, texcoords = {2, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 0, 0.5}, texcoords = {1, 1, 0}, color = {1, 1, 1}},
}

@(private = "file")
HALF_PYRAMID_ROOF_INDICES :: [?]Roof_Index{0, 1, 2, 2, 3, 0, 3, 2, 4}

@(private = "file")
HALF_HIP_SIDE_ROOF_VERTICES :: [?]Roof_Vertex {
	{pos = {-0.5, 0, -0.5}, texcoords = {0, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 0, -0.5}, texcoords = {1, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 1, -0.5 + 0.33}, texcoords = {1, 0, 0}, color = {1, 1, 1}},
	{pos = {-0.5, 0, -0.5 + 0.33}, texcoords = {1, 1, 0}, color = {1, 1, 1}},
	{pos = {-0.5, 0, -0.5 + 0.66}, texcoords = {2, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 1, -0.5 + 0.66}, texcoords = {2, 0, 0}, color = {1, 1, 1}},
	{pos = {-0.5, 0, 0.5}, texcoords = {3, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 0, 0.5}, texcoords = {2, 1, 0}, color = {1, 1, 1}},
}

@(private = "file")
HALF_HIP_SIDE_ROOF_INDICES :: [?]Roof_Index {
	0,
	1,
	2,
	2,
	3,
	0,
	4,
	3,
	2,
	5,
	4,
	2,
	6,
	4,
	5,
	7,
	6,
	5,
}

@(private = "file")
HALF_HIP_SIDE_SOUTH_INDICES :: [?]int{2, 3}
@(private = "file")
HALF_HIP_SIDE_NORTH_INDICES :: [?]int{4, 5}

@(private = "file")
draw_half_pyramid_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	roof_vertices := HALF_PYRAMID_ROOF_VERTICES
	roof_indices := HALF_PYRAMID_ROOF_INDICES

	index_offset := u32(len(vertices))

	for &vertex in roof_vertices {
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * rotation).xyz
		vertex.pos.y *= min(size.x, size.y)
		vertex.pos.x *= size.x
		vertex.pos.z *= size.y
		// vertex.texcoords.x = vertex.pos.x + vertex.pos.z
		// vertex.texcoords.y = vertex.pos.y
		vertex.pos.xz += roof.start + (roof.end - roof.start) / 2
		append(vertices, vertex)
	}

	for index in roof_indices {
		append(indices, index + index_offset)
	}
}

@(private = "file")
draw_half_hip_side_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	roof_vertices := HALF_HIP_SIDE_ROOF_VERTICES
	roof_indices := HALF_HIP_SIDE_ROOF_INDICES

	north_indices := HALF_HIP_SIDE_NORTH_INDICES
	south_indices := HALF_HIP_SIDE_SOUTH_INDICES
	ratio := min(size.x, size.y) / max(size.x, size.y)
	for idx in north_indices {
		roof_vertices[idx].pos.z = 0.5 - ratio
	}

	for idx in south_indices {
		roof_vertices[idx].pos.z = -0.5 + ratio
	}

	index_offset := u32(len(vertices))

	for &vertex in roof_vertices {
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * rotation).xyz
		vertex.pos.y *= min(size.x, size.y)
		vertex.pos.x *= size.x
		vertex.pos.z *= size.y
		// vertex.texcoords.x = vertex.pos.x + vertex.pos.z
		// vertex.texcoords.y = vertex.pos.y
		vertex.pos.xz += roof.start + (roof.end - roof.start) / 2
		append(vertices, vertex)
	}

	for index in roof_indices {
		append(indices, index + index_offset)
	}
}

@(private = "file")
HALF_HIP_END_ROOF_SOUTH_FACE_VERTICES :: [?]Roof_Vertex {
	{pos = {-0.5, 0, -0.5}, texcoords = {0, 1, 0}, color = {1, 1, 1}},
	{pos = {0, 0, -0.5}, texcoords = {0.5, 1, 0}, color = {1, 1, 1}},
	{pos = {0, 1, 0}, texcoords = {0.5, 0, 0}, color = {1, 1, 1}},
	{pos = {0.5, 0, -0.5}, texcoords = {1, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 1, 0}, texcoords = {1, 0, 0}, color = {1, 1, 1}},
}

@(private = "file")
HALF_HIP_END_ROOF_NORTH_FACE_VERTICES :: [?]Roof_Vertex {
	{pos = {-0.5, 0, 0.5}, texcoords = {0, 1, 0}, color = {0.6, 0.6, 0.6}},
	{pos = {0, 1, 0}, texcoords = {0.5, 0, 0}, color = {0.6, 0.6, 0.6}},
	{pos = {0, 0, 0.5}, texcoords = {0.5, 1, 0}, color = {0.6, 0.6, 0.6}},
	{pos = {0.5, 1, 0}, texcoords = {1, 0, 0}, color = {0.6, 0.6, 0.6}},
	{pos = {0.5, 0, 0.5}, texcoords = {1, 1, 0}, color = {0.6, 0.6, 0.6}},
}

@(private = "file")
HALF_HIP_END_ROOF_WEST_FACE_VERTICES :: [?]Roof_Vertex {
	{pos = {-0.5, 0, -0.5}, texcoords = {0, 1, 0}, color = {0.8, 0.8, 0.8}},
	{pos = {-0.5, 0, 0.5}, texcoords = {1, 1, 0}, color = {0.8, 0.8, 0.8}},
	{pos = {0, 1, 0}, texcoords = {0.5, 0, 0}, color = {0.8, 0.8, 0.8}},
}

@(private = "file")
HALF_HIP_END_ROOF_SOUTH_FACE_INDICES :: [?]Roof_Index {
	0,
	1,
	2,
	2,
	1,
	3,
	2,
	3,
	4,
}

@(private = "file")
HALF_HIP_END_ROOF_NORTH_FACE_INDICES :: [?]Roof_Index {
	0,
	1,
	2,
	2,
	1,
	3,
	2,
	3,
	4,
}

@(private = "file")
HALF_HIP_END_ROOF_WEST_FACE_INDICES :: [?]Roof_Index{0, 2, 1}

@(private = "file")
HALF_HIP_END_ROOF_SOUTH_FACE_MIDDLE_INDICES :: [?]Roof_Index{1, 2}

@(private = "file")
HALF_HIP_END_ROOF_NORTH_FACE_MIDDLE_INDICES :: [?]Roof_Index{1, 2}

@(private = "file")
HALF_HIP_END_ROOF_WEST_FACE_MIDDLE_INDICES :: [?]Roof_Index{2}

@(private = "file")
draw_half_hip_end_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	south_face_roof_vertices := HALF_HIP_END_ROOF_SOUTH_FACE_VERTICES
	south_face_roof_indices := HALF_HIP_END_ROOF_SOUTH_FACE_INDICES
	south_face_midle_indices := HALF_HIP_END_ROOF_SOUTH_FACE_MIDDLE_INDICES

	north_face_roof_vertices := HALF_HIP_END_ROOF_NORTH_FACE_VERTICES
	north_face_roof_indices := HALF_HIP_END_ROOF_NORTH_FACE_INDICES
	north_face_midle_indices := HALF_HIP_END_ROOF_NORTH_FACE_MIDDLE_INDICES

	west_face_roof_vertices := HALF_HIP_END_ROOF_WEST_FACE_VERTICES
	west_face_roof_indices := HALF_HIP_END_ROOF_WEST_FACE_INDICES
	west_face_midle_indices := HALF_HIP_END_ROOF_WEST_FACE_MIDDLE_INDICES

	max_size := max(size.x, size.y)
	min_size := min(size.x, size.y)
	middle_x := (max_size - min_size) / min_size / 2

	// log.info(middle_x)
	for idx in south_face_midle_indices {
		south_face_roof_vertices[idx].pos.x = middle_x
		south_face_roof_vertices[idx].texcoords.x = middle_x + 0.5
	}
	for idx in north_face_midle_indices {
		north_face_roof_vertices[idx].pos.x = middle_x
		north_face_roof_vertices[idx].texcoords.x = middle_x + 0.5
	}
	for idx in west_face_midle_indices {
		west_face_roof_vertices[idx].pos.x = middle_x
	}

	height := max(size.x, size.y) / 2

	index_offset := u32(len(vertices))
	for &vertex in south_face_roof_vertices {
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * rotation).xyz
		vertex.pos.y *= height
		vertex.pos.x *= size.x
		vertex.pos.z *= size.y
		vertex.texcoords.x *= min_size
		vertex.texcoords.y *= height
		vertex.pos.xz += roof.start + (roof.end - roof.start) / 2
        vertex.color = face_lights[0]
		append(vertices, vertex)
	}

	for index in south_face_roof_indices {
		append(indices, index + index_offset)
	}

	index_offset = u32(len(vertices))
	for &vertex in north_face_roof_vertices {
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * rotation).xyz
		vertex.pos.y *= height
		vertex.pos.x *= size.x
		vertex.pos.z *= size.y
		vertex.texcoords.x *= min_size
		vertex.texcoords.y *= height
		vertex.pos.xz += roof.start + (roof.end - roof.start) / 2
        vertex.color = face_lights[2]
		append(vertices, vertex)
	}

	for index in north_face_roof_indices {
		append(indices, index + index_offset)
	}

	index_offset = u32(len(vertices))
	for &vertex in west_face_roof_vertices {
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * rotation).xyz
		vertex.pos.y *= height
		vertex.pos.x *= size.x
		vertex.pos.z *= size.y
		vertex.texcoords.x *= max_size
		vertex.texcoords.y *= height
		vertex.pos.xz += roof.start + (roof.end - roof.start) / 2
        vertex.color = face_lights[1]
		append(vertices, vertex)
	}

	for index in west_face_roof_indices {
		append(indices, index + index_offset)
	}
}

@(private = "file")
draw_half_hip_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	ratio := max(size.x, size.y) / min(size.x, size.y)
	if ratio > 2 {
		draw_half_hip_side_roof(
			roof,
			vertices,
			indices,
			size,
			rotation,
			face_lights,
		)
	} else if ratio == 2 {
		draw_half_pyramid_roof(
			roof,
			vertices,
			indices,
			size,
			rotation,
			face_lights,
		)
	} else {
		draw_half_hip_end_roof(
			roof,
			vertices,
			indices,
			size,
			rotation,
			face_lights,
		)
	}
}
