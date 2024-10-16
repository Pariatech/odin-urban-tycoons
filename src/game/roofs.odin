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
	Hip,
	Gable,
}

Roof_Orientation :: enum {}

Roof :: struct {
	id:           Roof_Id,
	offset:       f32,
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

ROOF_TEXTURES :: [?]cstring {
	"resources/textures/roofs/Eave.png",
	"resources/textures/roofs/RoofingTiles002.png",
	"resources/textures/roofs/Dark Capping.png",
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
	size := glsl.abs(roof.end - roof.start)
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
			// face_lights = [4]glsl.vec3 {
			// 	{0.4, 0.4, 0.4},
			// 	{1, 1, 1},
			// 	{0.8, 0.8, 0.8},
			// 	{0.6, 0.6, 0.6},
			// }
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
			// rotation = glsl.mat4Rotate({0, 1, 0}, 0.5 * math.PI)
			rotation = glsl.identity(glsl.mat4)
			// face_lights = [4]glsl.vec3 {
			// 	{0.6, 0.6, 0.6},
			// 	{0.4, 0.4, 0.4},
			// 	{1, 1, 1},
			// 	{0.8, 0.8, 0.8},
			// }
		} else {
			rotation = glsl.mat4Rotate({0, 1, 0}, 1.5 * math.PI)
			face_lights = [4]glsl.vec3 {
				{0.8, 0.8, 0.8},
				{0.6, 0.6, 0.6},
				{0.4, 0.4, 0.4},
				{1, 1, 1},
			}
		}
	} else if roof.start.y <= roof.end.y {
		if size.y >= size.x {
			// rotation = glsl.identity(glsl.mat4)
			rotation = glsl.mat4Rotate({0, 1, 0}, 1.0 * math.PI)
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
		draw_half_gable_roof(
			roof,
			vertices,
			indices,
			size,
			rotation,
			face_lights,
		)
	case .Hip:
		draw_hip_roof(roof, vertices, indices, size, rotation, face_lights)
	case .Gable:
		draw_gable_roof(roof, vertices, indices, size, rotation, face_lights)
	}
}

@(private = "file")
draw_half_pyramid_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	center := roof.start + (roof.end - roof.start) / 2
	min_size := min(size.x, size.y)
	max_size := max(size.x, size.y)
	pos_offset := glsl.vec4{min_size / 2, 0, 0, 1} * rotation
	pos := center + pos_offset.xz

	face_rotation := rotation
	draw_roof_triangle(
		{pos.x, roof.offset, pos.y},
		{min_size, min_size, max_size / 2},
		false,
		face_rotation,
		1,
		face_lights[0],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{min_size, max_size},
		face_rotation,
		face_lights[0],
		vertices,
		indices,
	)

	face_rotation = rotation * glsl.mat4Rotate({0, 1, 0}, -1.0 * math.PI)
	draw_roof_triangle(
		{pos.x, roof.offset, pos.y},
		{min_size, min_size, max_size / 2},
		true,
		face_rotation,
		1,
		face_lights[2],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{min_size, max_size},
		face_rotation,
		face_lights[2],
		vertices,
		indices,
	)

	face_rotation = rotation * glsl.mat4Rotate({0, 1, 0}, -0.5 * math.PI)
	draw_roof_pyramid_face(
		{pos.x, roof.offset, pos.y},
		{max_size / 2, min_size, min_size},
		face_rotation,
		1,
		face_lights[1],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{max_size, min_size},
		face_rotation,
		face_lights[1],
		vertices,
		indices,
	)
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
	center := roof.start + (roof.end - roof.start) / 2
	min_size := min(size.x, size.y)
	max_size := max(size.x, size.y)
	left_pos_offset := glsl.vec4{min_size / 2, 0, min_size / 2, 1} * rotation
	left_pos := center + left_pos_offset.xz
	right_pos_offset := glsl.vec4{min_size / 2, 0, -min_size / 2, 1} * rotation
	right_pos := center + right_pos_offset.xz
	middle_pos_offset := glsl.vec4{min_size / 2, 0, 0, 1} * rotation
	middle_pos := center + middle_pos_offset.xz

	face_rotation := rotation
	draw_roof_triangle(
		{right_pos.x, roof.offset, right_pos.y},
		{min_size, min_size, min_size},
		false,
		face_rotation,
		1,
		face_lights[0],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{min_size, max_size},
		face_rotation,
		face_lights[0],
		vertices,
		indices,
	)

	face_rotation = rotation * glsl.mat4Rotate({0, 1, 0}, -0.5 * math.PI)
	draw_roof_triangle(
		{right_pos.x, roof.offset, right_pos.y},
		{min_size, min_size, min_size},
		true,
		face_rotation,
		1,
		face_lights[1],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_rectangle(
		{middle_pos.x, roof.offset, middle_pos.y},
		{max_size - min_size * 2, min_size, min_size},
		false,
		face_rotation,
		1,
		face_lights[1],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_triangle(
		{left_pos.x, roof.offset, left_pos.y},
		{min_size, min_size, min_size},
		false,
		face_rotation,
		1,
		face_lights[1],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{max_size, min_size},
		face_rotation,
		face_lights[1],
		vertices,
		indices,
	)

	face_rotation = rotation * glsl.mat4Rotate({0, 1, 0}, -1.0 * math.PI)
	draw_roof_triangle(
		{left_pos.x, roof.offset, left_pos.y},
		{min_size, min_size, min_size},
		true,
		face_rotation,
		1,
		face_lights[2],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{min_size, max_size},
		face_rotation,
		face_lights[2],
		vertices,
		indices,
	)
}

@(private = "file")
draw_half_hip_end_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	center := roof.start + (roof.end - roof.start) / 2
	min_size := min(size.x, size.y)
	max_size := max(size.x, size.y)
	peak_offset := (max_size - min_size) / 2
	peak_pos_offset := glsl.vec4{peak_offset, 0, 0, 1} * rotation
	peak_pos := center + peak_pos_offset.xz
	edge_size := min_size / 2 - peak_offset
	edge_offset := min_size / 4 + peak_offset / 2
	edge_pos_offset := glsl.vec4{edge_offset, 0, 0, 1} * rotation
	edge_pos := center + edge_pos_offset.xz

	face_rotation := rotation
	draw_roof_triangle(
		{peak_pos.x, roof.offset, peak_pos.y},
		{min_size - peak_offset, max_size / 2, max_size / 2},
		false,
		face_rotation,
		1,
		face_lights[0],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_rectangle(
		{edge_pos.x, roof.offset, edge_pos.y},
		{edge_size, max_size / 2, max_size / 2},
		false,
		face_rotation,
		1,
		face_lights[0],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{min_size, max_size},
		face_rotation,
		face_lights[0],
		vertices,
		indices,
	)

	face_rotation = rotation * glsl.mat4Rotate({0, 1, 0}, -0.5 * math.PI)
	draw_roof_pyramid_face(
		{peak_pos.x, roof.offset, peak_pos.y},
		{max_size / 2, max_size / 2, min_size - peak_offset},
		face_rotation,
		1,
		face_lights[1],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{max_size, min_size},
		face_rotation,
		face_lights[1],
		vertices,
		indices,
	)

	face_rotation = rotation * glsl.mat4Rotate({0, 1, 0}, -1.0 * math.PI)
	draw_roof_triangle(
		{peak_pos.x, roof.offset, peak_pos.y},
		{min_size - peak_offset, max_size / 2, max_size / 2},
		true,
		face_rotation,
		1,
		face_lights[2],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_rectangle(
		{edge_pos.x, roof.offset, edge_pos.y},
		{edge_size, max_size / 2, max_size / 2},
		false,
		face_rotation,
		1,
		face_lights[2],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{min_size, max_size},
		face_rotation,
		face_lights[2],
		vertices,
		indices,
	)
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

@(private = "file")
draw_pyramid_hip_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	height := size.x / 2
	center := roof.start + (roof.end - roof.start) / 2
	for i in 0 ..< 4 {
		side_rotation :=
			rotation * glsl.mat4Rotate({0, 1, 0}, f32(i) * (-math.PI / 2))
		pos := center

		face_size := size / 2
		draw_roof_pyramid_face(
			{pos.x, roof.offset, pos.y},
			{face_size.x, height, face_size.y},
			side_rotation,
			1,
			face_lights[i % 4],
			roof.slope,
			vertices,
			indices,
		)

		draw_roof_eave(
			{pos.x, roof.offset, pos.y},
			size,
			side_rotation,
			face_lights[i % 4],
			vertices,
			indices,
		)

	}
}

@(private = "file")
draw_trapezoid_hip_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	min_size := min(size.y, size.x)
	max_size := max(size.y, size.x)
	height := min(size.x, size.y) / 2
	center := roof.start + (roof.end - roof.start) / 2

	for i in 0 ..< 2 {
		side_rotation :=
			rotation * glsl.mat4Rotate({0, 1, 0}, f32(i * 2) * (-math.PI / 2))
		pos_offset := glsl.vec4{0, 0, -(max_size - min_size) / 2, 1}
		pos_offset *= side_rotation
		pos := center + pos_offset.xz

		face_size := glsl.vec2{min_size, min_size} * 0.5
		draw_roof_pyramid_face(
			{pos.x, roof.offset, pos.y},
			{face_size.x, height, face_size.y},
			side_rotation,
			1,
			face_lights[i * 2 % 4],
			roof.slope,
			vertices,
			indices,
		)

		draw_roof_eave(
			{pos.x, roof.offset, pos.y},
			{min_size, min_size},
			side_rotation,
			face_lights[i * 2 % 4],
			vertices,
			indices,
		)
	}

	for i in 0 ..< 2 {
		side_rotation :=
			rotation *
			glsl.mat4Rotate({0, 1, 0}, f32(i * 2 + 1) * (-math.PI / 2))

		draw_roof_hip_face(
			{center.x, roof.offset, center.y},
			{max_size, height, min_size},
			side_rotation,
			1,
			face_lights[(i * 2 + 1) % 4],
			roof.slope,
			vertices,
			indices,
		)

		draw_roof_eave(
			{center.x, roof.offset, center.y},
			{max_size, min_size},
			side_rotation,
			face_lights[(i * 2 + 1) % 4],
			vertices,
			indices,
		)
	}
}

@(private = "file")
draw_hip_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	ratio := max(size.x, size.y) / min(size.x, size.y)
	if ratio == 1 {
		draw_pyramid_hip_roof(
			roof,
			vertices,
			indices,
			size,
			rotation,
			face_lights,
		)
	} else {
		draw_trapezoid_hip_roof(
			roof,
			vertices,
			indices,
			size,
			rotation,
			face_lights,
		)
	}
}

@(private = "file")
draw_half_gable_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	min_size := min(size.y, size.x)
	max_size := max(size.y, size.x)
	height := min(size.x, size.y) / 2
	center := roof.start + (roof.end - roof.start) / 2

	side_rotation := rotation * glsl.mat4Rotate({0, 1, 0}, -math.PI / 2)
	pos_offset := glsl.vec4{0, 0, min_size / 2, 1}
	pos_offset *= side_rotation
	pos := center + pos_offset.xz

	draw_roof_rectangle(
		{pos.x, roof.offset, pos.y},
		{max_size, min_size, min_size},
		true,
		side_rotation,
		1,
		face_lights[1],
		roof.slope,
		vertices,
		indices,
	)

	draw_roof_eave(
		{center.x, roof.offset, center.y},
		{max_size, min_size},
		side_rotation,
		face_lights[1],
		vertices,
		indices,
	)

	draw_roof_gable_eave(
		{center.x, roof.offset, center.y},
		{min_size, min_size, max_size},
		side_rotation * glsl.mat4Rotate({0, 1, 0}, math.PI / 2),
		face_lights[0],
		false,
		vertices,
		indices,
	)

	draw_roof_gable_eave(
		{center.x, roof.offset, center.y},
		{min_size, min_size, max_size},
		side_rotation * glsl.mat4Rotate({0, 1, 0}, -math.PI / 2),
		face_lights[2],
		true,
		vertices,
		indices,
	)
}

@(private = "file")
draw_gable_roof :: proc(
	roof: ^Roof,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
	size: glsl.vec2,
	rotation: glsl.mat4,
	face_lights: [4]glsl.vec3,
) {
	min_size := min(size.y, size.x)
	max_size := max(size.y, size.x)
	height := min(size.x, size.y) / 2
	center := roof.start + (roof.end - roof.start) / 2

	for i in 0 ..< 2 {
		side_rotation := rotation * glsl.mat4Rotate({0, 1, 0}, f32((i * 2) + 1) * -math.PI / 2)

		draw_roof_rectangle(
			{center.x, roof.offset, center.y},
			{max_size, min_size / 2, min_size / 2},
			true,
			side_rotation,
			1,
			face_lights[(i * 2 + 1) % 4],
			roof.slope,
			vertices,
			indices,
		)

		draw_roof_eave(
			{center.x, roof.offset, center.y},
			{max_size, min_size},
			side_rotation,
			face_lights[(i * 2 + 1) % 4],
			vertices,
			indices,
		)

	    pos_offset := glsl.vec4{0, 0, -min_size / 4, 1} * side_rotation
		pos := center + pos_offset.xz
		draw_roof_gable_eave(
			{pos.x, roof.offset, pos.y},
			{min_size / 2, min_size / 2, max_size},
			side_rotation * glsl.mat4Rotate({0, 1, 0}, math.PI / 2),
			face_lights[i * 2],
			false,
			vertices,
			indices,
		)

		draw_roof_gable_eave(
			{pos.x, roof.offset, pos.y},
			{min_size / 2, min_size / 2, max_size},
			side_rotation * glsl.mat4Rotate({0, 1, 0}, -math.PI / 2),
			face_lights[(i * 2 + 2) % 4],
			true,
			vertices,
			indices,
		)
	}
}

@(private = "file")
draw_roof_triangle :: proc(
	pos: glsl.vec3,
	size: glsl.vec3,
	mirrored: bool,
	rotation: glsl.mat4,
	texture: f32,
	light: glsl.vec3,
	slope: f32,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
) {
	triangle_indices := [?]Roof_Index{0, 1, 2}

	triangle_vertices := [?]Roof_Vertex {
		{pos = {-1, 0, -1}, texcoords = {1, 1, 1}, color = light},
		{pos = {0, 0, -1}, texcoords = {0, 1, 1}, color = light},
		{pos = {0, 1, 0}, texcoords = {0, 0, 1}, color = light},
	}

	capping_vertices := [?]Roof_Vertex {
		{pos = {-1, 0, -1}, texcoords = {0, 1, 2}, color = light},
		{pos = {0, 1, 0}, texcoords = {0, 0, 2}, color = light},
	}

	capping_indices := [?]Roof_Index{0, 2, 3, 0, 3, 1}

	mirror := glsl.identity(glsl.mat4)
	if mirrored {
		mirror = glsl.mat4Scale({-1, 1, 1})
		triangle_indices = {2, 1, 0}
		capping_indices = {1, 3, 0, 3, 2, 0}
	}

	transform := mirror * rotation

	index_offset := u32(len(vertices))
	for &vertex in triangle_vertices {
		vertex.pos *= size - 0.2
		vertex.pos.y *= slope
		vertex.pos.z -= 0.2
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * transform).xyz
		vertex.pos += pos
		vertex.texcoords.xy *= size.xy
		vertex.color = light
		append(vertices, vertex)
	}

	for index in triangle_indices {
		append(indices, index + index_offset)
	}

	long_length := glsl.length(
		capping_vertices[0].pos * size - capping_vertices[1].pos * size,
	)
	short_length := glsl.length(
		capping_vertices[0].pos * (size - 0.2) -
		capping_vertices[1].pos * (size - 0.2),
	)

	index_offset = u32(len(vertices))
	capping_vertices[0].texcoords.xy = {0, 1}
	capping_vertices[1].texcoords.xy = {1, 1}
	for vertex in capping_vertices {
		vertex := vertex
		vertex.pos *= size
		vertex.pos.y *= slope
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * transform).xyz
		vertex.pos += pos
		vertex.texcoords.x *= long_length
		vertex.color = light
		append(vertices, vertex)
	}
	length_ratio := (1 - short_length / long_length) / 2

	capping_vertices[0].texcoords.xy = {length_ratio, 0}
	capping_vertices[1].texcoords.xy = {1 - length_ratio, 0}
	for vertex in capping_vertices {
		vertex := vertex
		vertex.pos *= size - 0.2
		vertex.pos.y *= slope
		vertex.pos.z -= 0.2
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * transform).xyz
		vertex.pos += pos
		vertex.texcoords.x *= long_length
		vertex.color = light
		append(vertices, vertex)
	}

	for index in capping_indices {
		append(indices, index + index_offset)
	}
}

@(private = "file")
draw_roof_rectangle :: proc(
	pos: glsl.vec3,
	size: glsl.vec3,
	mirrored: bool,
	rotation: glsl.mat4,
	texture: f32,
	light: glsl.vec3,
	slope: f32,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
) {
	rectangle_indices := [?]Roof_Index{0, 1, 2, 0, 2, 3}

	rectangle_vertices := [?]Roof_Vertex {
		{pos = {-0.5, 0, -1}, texcoords = {1, 1, 1}, color = light},
		{pos = {0.5, 0, -1}, texcoords = {0, 1, 1}, color = light},
		{pos = {0.5, 1, 0}, texcoords = {0, 0, 1}, color = light},
		{pos = {-0.5, 1, 0}, texcoords = {1, 0, 1}, color = light},
	}

	capping_vertices := [?]Roof_Vertex {
		{pos = {-0.5, 1, 0}, texcoords = {0, 1, 2}, color = light},
		{pos = {0.5, 1, 0}, texcoords = {1, 1, 2}, color = light},
	}

	capping_indices := [?]Roof_Index{0, 2, 3, 0, 3, 1}

	mirror := glsl.identity(glsl.mat4)
	if mirrored {
		mirror = glsl.mat4Scale({-1, 1, 1})
		rectangle_indices = {3, 2, 0, 2, 1, 0}
		capping_indices = {1, 3, 0, 3, 2, 0}
	}

	transform := mirror * rotation

	index_offset := u32(len(vertices))
	for &vertex in rectangle_vertices {
		vertex.pos.zy *= size.zy - 0.2
		vertex.pos.x *= size.x
		vertex.pos.y *= slope
		vertex.pos.z -= 0.2
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * transform).xyz
		vertex.pos += pos
		vertex.texcoords.xy *= size.xy
		vertex.color = light
		append(vertices, vertex)
	}

	for index in rectangle_indices {
		append(indices, index + index_offset)
	}

	index_offset = u32(len(vertices))
	capping_vertices[0].texcoords.y = 1
	capping_vertices[1].texcoords.y = 1
	for vertex in capping_vertices {
		vertex := vertex
		vertex.pos *= size
		vertex.pos.y *= slope
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * transform).xyz
		vertex.pos += pos
		vertex.texcoords.x *= size.x
		vertex.color = light
		append(vertices, vertex)
	}

	capping_vertices[0].texcoords.y = 0
	capping_vertices[1].texcoords.y = 0
	for vertex in capping_vertices {
		vertex := vertex
		vertex.pos.zy *= size.zy - 0.2
		vertex.pos.x *= size.x
		vertex.pos.y *= slope
		vertex.pos.z -= 0.2
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * transform).xyz
		vertex.pos += pos
		vertex.texcoords.x *= size.x
		vertex.color = light
		append(vertices, vertex)
	}

	for index in capping_indices {
		append(indices, index + index_offset)
	}
}


@(private = "file")
EAVE_VERTICES :: [?]Roof_Vertex {
	{pos = {-0.5, -0.2, -0.5}, texcoords = {0, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, -0.2, -0.5}, texcoords = {1, 1, 0}, color = {1, 1, 1}},
	{pos = {0.5, 0, -0.5}, texcoords = {0, 0, 0}, color = {1, 1, 1}},
	{pos = {-0.5, 0, -0.5}, texcoords = {1, 0, 0}, color = {1, 1, 1}},
}

@(private = "file")
EAVE_INDICES :: [?]Roof_Index{0, 1, 2, 0, 2, 3}

@(private = "file")
draw_roof_eave :: proc(
	pos: glsl.vec3,
	size: glsl.vec2,
	rotation: glsl.mat4,
	light: glsl.vec3,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
) {
	index_offset := u32(len(vertices))
	eave_vertices := EAVE_VERTICES
	eave_indices := EAVE_INDICES

	for &vertex in eave_vertices {
		vertex.pos.xz *= size
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * rotation).xyz
		vertex.texcoords.x *= size.x
		vertex.pos += pos
		vertex.color = light
		append(vertices, vertex)
	}

	for index in eave_indices {
		append(indices, index + index_offset)
	}
}

@(private = "file")
draw_roof_gable_eave :: proc(
	pos: glsl.vec3,
	size: glsl.vec3,
	rotation: glsl.mat4,
	light: glsl.vec3,
	mirror: bool,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
) {
	index_offset := u32(len(vertices))
	eave_vertices := EAVE_VERTICES
	eave_indices := EAVE_INDICES

	if mirror {
		eave_vertices[0].pos.y += size.y
		eave_vertices[3].pos.y += size.y
	} else {
		eave_vertices[1].pos.y += size.y
		eave_vertices[2].pos.y += size.y
	}

	for &vertex in eave_vertices {
		vertex.pos.xz *= size.xz
		pos4 := glsl.vec4{vertex.pos.x, vertex.pos.y, vertex.pos.z, 1}
		vertex.pos = (pos4 * rotation).xyz
		vertex.texcoords.x *= size.x
		vertex.pos += pos
		vertex.color = light
		append(vertices, vertex)
	}

	for index in eave_indices {
		append(indices, index + index_offset)
	}
}

@(private = "file")
draw_roof_pyramid_face :: proc(
	pos: glsl.vec3,
	size: glsl.vec3,
	rotation: glsl.mat4,
	texture: f32,
	light: glsl.vec3,
	slope: f32,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
) {
	draw_roof_triangle(
		pos,
		size,
		false,
		rotation,
		texture,
		light,
		slope,
		vertices,
		indices,
	)
	draw_roof_triangle(
		pos,
		size,
		true,
		rotation,
		texture,
		light,
		slope,
		vertices,
		indices,
	)
}

@(private = "file")
draw_roof_hip_face :: proc(
	pos: glsl.vec3,
	size: glsl.vec3,
	rotation: glsl.mat4,
	texture: f32,
	light: glsl.vec3,
	slope: f32,
	vertices: ^[dynamic]Roof_Vertex,
	indices: ^[dynamic]Roof_Index,
) {
	min_size := min(size.z, size.x)
	max_size := max(size.z, size.x)

	face_size := glsl.vec2{min_size, min_size} * 0.5

	pos_offset := glsl.vec4{-(max_size - min_size) / 2, 0, 0, 1}
	pos_offset *= rotation
	face_pos := pos + pos_offset.xyz
	draw_roof_triangle(
		face_pos,
		{face_size.x, size.y, face_size.y},
		false,
		rotation,
		1,
		light,
		slope,
		vertices,
		indices,
	)

	pos_offset = glsl.vec4{(max_size - min_size) / 2, 0, 0, 1}
	pos_offset *= rotation
	face_pos = pos + pos_offset.xyz
	draw_roof_triangle(
		face_pos,
		{face_size.x, size.y, face_size.y},
		true,
		rotation,
		1,
		light,
		slope,
		vertices,
		indices,
	)

	face_size = glsl.vec2{max_size - min_size, min_size / 2}
	draw_roof_rectangle(
		pos,
		{face_size.x, size.y, face_size.y},
		true,
		rotation,
		1,
		light,
		slope,
		vertices,
		indices,
	)
}
