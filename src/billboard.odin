package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"


BILLBOARD_VERTEX_SHADER_PATH :: "resources/shaders/billboard.vert"
BILLBOARD_FRAGMENT_SHADER_PATH :: "resources/shaders/billboard.frag"
BILLBOARD_MODEL_PATH :: "resources/models/billboard.glb"
FOUR_TILES_BILLBOARD_MODEL_PATH :: "resources/models/4tiles-billboard.glb"
BILLBOARD_TEXTURE_WIDTH :: 128
BILLBOARD_TEXTURE_HEIGHT :: 256
FOUR_TILES_BILLBOARD_TEXTURE_WIDTH :: 512
FOUR_TILES_BILLBOARD_TEXTURE_HEIGHT :: 1024

Billboard_Draw_Context :: struct {
	indices:                 [6]u8,
	vertices:                [4]Billboard_Vertex,
	vbo, ebo:                u32,
	texture_array:           u32,
	depth_map_texture_array: u32,
}

billboard_shader_program: u32
billboard_uniform_object: Billboard_Uniform_Object
billboard_ubo: u32
billboard_1x1_draw_context: Billboard_Draw_Context
billboard_2x2_draw_context: Billboard_Draw_Context

Billboard_Instance :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   f32,
	depth_map: f32,
}

Billboard_1x1 :: struct {
	light:     glsl.vec3,
	texture:   Billboard_Texture_1x1,
	depth_map: Billboard_Texture_1x1,
}

Billboard_2x2 :: struct {
	light:     glsl.vec3,
	texture:   Billboard_Texture_2x2,
	depth_map: Billboard_Texture_2x2,
}

Billboard_Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

Billboard_Uniform_Object :: struct {
	proj, view: glsl.mat4,
}

Billboard_Texture_1x1 :: enum u8 {
	// Chair_Wood_SW,
	// Chair_Wood_SE,
	// Chair_Wood_NE,
	// Chair_Wood_NW,
	Door_Wood_SW,
	Door_Wood_SE,
	Door_Wood_NE,
	Door_Wood_NW,
	Window_Wood_SW,
	Window_Wood_SE,
	Window_Wood_NE,
	Window_Wood_NW,
	Shovel_1_SW,
	Shovel_2_SW,
	Shovel_3_SW,
	Shovel_4_SW,
	Shovel_5_SW,
	Shovel_6_SW,
	Shovel_7_SW,
	Shovel_8_SW,
	Shovel_9_SW,
	Shovel_10_SW,
	Wall_Cursor,
}

BILLBOARD_CLOCKWISE_ROTATION_TABLE_1X1 ::
	[Billboard_Texture_1x1]Billboard_Texture_1x1 {
		.Door_Wood_SW   = .Door_Wood_SE,
		.Door_Wood_SE   = .Door_Wood_NE,
		.Door_Wood_NE   = .Door_Wood_NW,
		.Door_Wood_NW   = .Door_Wood_SW,
		.Window_Wood_SW = .Window_Wood_SE,
		.Window_Wood_SE = .Window_Wood_NE,
		.Window_Wood_NE = .Window_Wood_NW,
		.Window_Wood_NW = .Window_Wood_SW,
		.Shovel_1_SW    = .Shovel_1_SW,
		.Shovel_2_SW    = .Shovel_2_SW,
		.Shovel_3_SW    = .Shovel_3_SW,
		.Shovel_4_SW    = .Shovel_4_SW,
		.Shovel_5_SW    = .Shovel_5_SW,
		.Shovel_6_SW    = .Shovel_6_SW,
		.Shovel_7_SW    = .Shovel_7_SW,
		.Shovel_8_SW    = .Shovel_8_SW,
		.Shovel_9_SW    = .Shovel_9_SW,
		.Shovel_10_SW   = .Shovel_10_SW,
		.Wall_Cursor    = .Wall_Cursor,
	}

BILLBOARD_COUNTER_CLOCKWISE_ROTATION_TABLE_1X1 ::
	[Billboard_Texture_1x1]Billboard_Texture_1x1 {
		.Door_Wood_SW   = .Door_Wood_NW,
		.Door_Wood_SE   = .Door_Wood_SW,
		.Door_Wood_NE   = .Door_Wood_SE,
		.Door_Wood_NW   = .Door_Wood_NE,
		.Window_Wood_SW = .Window_Wood_NW,
		.Window_Wood_SE = .Window_Wood_SW,
		.Window_Wood_NE = .Window_Wood_SE,
		.Window_Wood_NW = .Window_Wood_NE,
		.Shovel_1_SW    = .Shovel_1_SW,
		.Shovel_2_SW    = .Shovel_2_SW,
		.Shovel_3_SW    = .Shovel_3_SW,
		.Shovel_4_SW    = .Shovel_4_SW,
		.Shovel_5_SW    = .Shovel_5_SW,
		.Shovel_6_SW    = .Shovel_6_SW,
		.Shovel_7_SW    = .Shovel_7_SW,
		.Shovel_8_SW    = .Shovel_8_SW,
		.Shovel_9_SW    = .Shovel_9_SW,
		.Shovel_10_SW   = .Shovel_10_SW,
		.Wall_Cursor    = .Wall_Cursor,
	}

Billboard_Texture_2x2 :: enum u8 {
	Table_Wood_SW,
	Table_Wood_SE,
	Table_Wood_NE,
	Table_Wood_NW,
	Table_8_Places_Wood_SW,
	Table_8_Places_Wood_SE,
	Table_8_Places_Wood_NE,
	Table_8_Places_Wood_NW,
}

BILLBOARD_CLOCKWISE_ROTATION_TABLE_2X2 ::
	[Billboard_Texture_2x2]Billboard_Texture_2x2 {
		.Table_Wood_SW          = .Table_Wood_SE,
		.Table_Wood_SE          = .Table_Wood_NE,
		.Table_Wood_NE          = .Table_Wood_NW,
		.Table_Wood_NW          = .Table_Wood_SW,
		.Table_8_Places_Wood_SW = .Table_8_Places_Wood_SE,
		.Table_8_Places_Wood_SE = .Table_8_Places_Wood_NE,
		.Table_8_Places_Wood_NE = .Table_8_Places_Wood_NW,
		.Table_8_Places_Wood_NW = .Table_8_Places_Wood_SW,
	}

BILLBOARD_COUNTER_CLOCKWISE_ROTATION_TABLE_2X2 ::
	[Billboard_Texture_2x2]Billboard_Texture_2x2 {
		.Table_Wood_SW          = .Table_Wood_NW,
		.Table_Wood_SE          = .Table_Wood_SW,
		.Table_Wood_NE          = .Table_Wood_SE,
		.Table_Wood_NW          = .Table_Wood_NE,
		.Table_8_Places_Wood_SW = .Table_8_Places_Wood_NW,
		.Table_8_Places_Wood_SE = .Table_8_Places_Wood_SW,
		.Table_8_Places_Wood_NE = .Table_8_Places_Wood_SE,
		.Table_8_Places_Wood_NW = .Table_8_Places_Wood_NE,
	}

BILLBOARD_TEXTURE_PATHS :: [Billboard_Texture_1x1]cstring {
		// .Chair_Wood_SW = "resources/textures/billboards/chair-wood/sw-diffuse.png",
		// .Chair_Wood_SE = "resources/textures/billboards/chair-wood/se-diffuse.png",
		// .Chair_Wood_NE = "resources/textures/billboards/chair-wood/ne-diffuse.png",
		// .Chair_Wood_NW = "resources/textures/billboards/chair-wood/nw-diffuse.png",
		.Door_Wood_SW   = "resources/textures/billboards/door-wood/sw-diffuse.png",
		.Door_Wood_SE   = "resources/textures/billboards/door-wood/se-diffuse.png",
		.Door_Wood_NE   = "resources/textures/billboards/door-wood/ne-diffuse.png",
		.Door_Wood_NW   = "resources/textures/billboards/door-wood/nw-diffuse.png",
		.Window_Wood_SW = "resources/textures/billboards/window-wood/sw-diffuse.png",
		.Window_Wood_SE = "resources/textures/billboards/window-wood/se-diffuse.png",
		.Window_Wood_NE = "resources/textures/billboards/window-wood/ne-diffuse.png",
		.Window_Wood_NW = "resources/textures/billboards/window-wood/nw-diffuse.png",
		.Shovel_1_SW    = "resources/textures/billboards/shovel/1-diffuse.png",
		.Shovel_2_SW    = "resources/textures/billboards/shovel/2-diffuse.png",
		.Shovel_3_SW    = "resources/textures/billboards/shovel/3-diffuse.png",
		.Shovel_4_SW    = "resources/textures/billboards/shovel/4-diffuse.png",
		.Shovel_5_SW    = "resources/textures/billboards/shovel/5-diffuse.png",
		.Shovel_6_SW    = "resources/textures/billboards/shovel/6-diffuse.png",
		.Shovel_7_SW    = "resources/textures/billboards/shovel/7-diffuse.png",
		.Shovel_8_SW    = "resources/textures/billboards/shovel/8-diffuse.png",
		.Shovel_9_SW    = "resources/textures/billboards/shovel/9-diffuse.png",
		.Shovel_10_SW   = "resources/textures/billboards/shovel/10-diffuse.png",
		.Wall_Cursor    = "resources/textures/billboards/wall-cursor/diffuse.png",
	}

FOUR_TILES_BILLBOARD_TEXTURE_PATHS :: [Billboard_Texture_2x2]cstring {
		.Table_Wood_SW          = "resources/textures/billboards/table-6places-wood/sw-diffuse.png",
		.Table_Wood_SE          = "resources/textures/billboards/table-6places-wood/se-diffuse.png",
		.Table_Wood_NE          = "resources/textures/billboards/table-6places-wood/ne-diffuse.png",
		.Table_Wood_NW          = "resources/textures/billboards/table-6places-wood/nw-diffuse.png",
		.Table_8_Places_Wood_SW = "resources/textures/billboards/table-8places-wood/sw-diffuse.png",
		.Table_8_Places_Wood_SE = "resources/textures/billboards/table-8places-wood/se-diffuse.png",
		.Table_8_Places_Wood_NE = "resources/textures/billboards/table-8places-wood/ne-diffuse.png",
		.Table_8_Places_Wood_NW = "resources/textures/billboards/table-8places-wood/nw-diffuse.png",
	}

BILLBOARD_DEPTH_MAP_TEXTURE_PATHS :: [Billboard_Texture_1x1]cstring {
		// .Chair_Wood_SW = "resources/textures/billboards/chair-wood/sw-depth-map.png",
		// .Chair_Wood_SE = "resources/textures/billboards/chair-wood/se-depth-map.png",
		// .Chair_Wood_NE = "resources/textures/billboards/chair-wood/ne-depth-map.png",
		// .Chair_Wood_NW = "resources/textures/billboards/chair-wood/nw-depth-map.png",
		.Door_Wood_SW   = "resources/textures/billboards/door-wood/sw-depth-map.png",
		.Door_Wood_SE   = "resources/textures/billboards/door-wood/se-depth-map.png",
		.Door_Wood_NE   = "resources/textures/billboards/door-wood/ne-depth-map.png",
		.Door_Wood_NW   = "resources/textures/billboards/door-wood/nw-depth-map.png",
		.Window_Wood_SW = "resources/textures/billboards/window-wood/sw-depth-map.png",
		.Window_Wood_SE = "resources/textures/billboards/window-wood/se-depth-map.png",
		.Window_Wood_NE = "resources/textures/billboards/window-wood/ne-depth-map.png",
		.Window_Wood_NW = "resources/textures/billboards/window-wood/nw-depth-map.png",
		.Shovel_1_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_2_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_3_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_4_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_5_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_6_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_7_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_8_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_9_SW    = "resources/textures/billboards/shovel/depth-map.png",
		.Shovel_10_SW   = "resources/textures/billboards/shovel/depth-map.png",
		.Wall_Cursor    = "resources/textures/billboards/wall-cursor/depth-map.png",
	}

FOUR_TILES_BILLBOARD_DEPTH_MAP_TEXTURE_PATHS ::
	[Billboard_Texture_2x2]cstring {
		.Table_Wood_SW          = "resources/textures/billboards/table-6places-wood/sw-depth-map.png",
		.Table_Wood_SE          = "resources/textures/billboards/table-6places-wood/se-depth-map.png",
		.Table_Wood_NE          = "resources/textures/billboards/table-6places-wood/ne-depth-map.png",
		.Table_Wood_NW          = "resources/textures/billboards/table-6places-wood/nw-depth-map.png",
		.Table_8_Places_Wood_SW = "resources/textures/billboards/table-8places-wood/sw-depth-map.png",
		.Table_8_Places_Wood_SE = "resources/textures/billboards/table-8places-wood/se-depth-map.png",
		.Table_8_Places_Wood_NE = "resources/textures/billboards/table-8places-wood/ne-depth-map.png",
		.Table_8_Places_Wood_NW = "resources/textures/billboards/table-8places-wood/nw-depth-map.png",
	}

billboard_init_draw_context :: proc(
	draw_context: ^Billboard_Draw_Context,
	model_path: cstring,
	texture_paths: [$T]cstring,
	depth_map_texture_paths: [$D]cstring,
	expected_texture_width: i32,
	expected_texture_height: i32,
) -> (
	ok: bool = false,
) {
	load_billboard_model(
		model_path,
		&draw_context.vertices,
		&draw_context.indices,
	) or_return
	fmt.println("billboard vertices:", draw_context.vertices)
	fmt.println("billboard indices:", draw_context.indices)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.GenBuffers(1, &draw_context.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, draw_context.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(draw_context.vertices) * size_of(Billboard_Vertex),
		&draw_context.vertices,
		gl.STATIC_DRAW,
	)

	gl.GenBuffers(1, &draw_context.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, draw_context.ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(draw_context.indices) * size_of(u8),
		&draw_context.indices,
		gl.STATIC_DRAW,
	)


	gl.GenTextures(1, &draw_context.texture_array)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, draw_context.texture_array)
	load_billboard_texture_array(
		texture_paths,
		expected_texture_width,
		expected_texture_height,
	) or_return

	gl.GenTextures(1, &draw_context.depth_map_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, draw_context.depth_map_texture_array)
	load_billboard_depth_map_texture_array(
		depth_map_texture_paths,
		expected_texture_width,
		expected_texture_height,
	) or_return

	load_shader_program(
		&billboard_shader_program,
		BILLBOARD_VERTEX_SHADER_PATH,
		BILLBOARD_FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(
		gl.GetUniformLocation(billboard_shader_program, "texture_sampler"),
		0,
	)
	gl.Uniform1i(
		gl.GetUniformLocation(
			billboard_shader_program,
			"depth_map_texture_sampler",
		),
		1,
	)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.UseProgram(0)

	return true
}

load_billboard_model :: proc(
	path: cstring,
	vertices: ^[4]Billboard_Vertex,
	indices: ^[6]u8,
) -> (
	ok: bool = false,
) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, path)
	if result != .success {
		fmt.println("failed to parse file")
		return
	}
	result = cgltf.load_buffers(options, data, path)
	if result != .success {
		fmt.println("failed to load buffers")
		return
	}
	defer cgltf.free(data)

	for mesh in data.meshes {
		primitive := mesh.primitives[0]
		if primitive.indices != nil {
			accessor := primitive.indices
			for i in 0 ..< accessor.count {
				index := cgltf.accessor_read_index(accessor, i)
				indices[i] = u8(index)
			}
		}

		for attribute in primitive.attributes {
			if attribute.type == .position {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].pos),
						3,
					)
					vertices[i].pos.x *= -1
				}
			}
			if attribute.type == .texcoord {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].texcoords),
						2,
					)
				}
			}
		}
	}

	return true
}

load_billboard_depth_map_texture_array :: proc(
	paths: [$T]cstring,
	expected_width: i32,
	expected_height: i32,
) -> (
	ok: bool = true,
) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.CLAMP)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.CLAMP)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

	textures :: len(paths)

	if (textures == 0) {
		fmt.println("No textures to load.")
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	fmt.println("depth map TexStorage3D")
	gl.TexStorage3D(
		gl.TEXTURE_2D_ARRAY,
		1,
		gl.R16,
		expected_width,
		expected_height,
		textures,
	)

	for path, i in paths {
		width: i32
		height: i32
		channels: i32
		pixels := stbi.load_16(path, &width, &height, &channels, 1)
		fmt.println("channels", channels)
		fmt.println("dimensions:", width, ",", height)
		defer stbi.image_free(pixels)

		if pixels == nil {
			fmt.eprintln("Failed to load texture: ", path)
			return false
		}

		if width != expected_width {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				expected_width,
				" got: ",
				width,
			)
			return false
		}

		if height != expected_height {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				expected_height,
				" got: ",
				height,
			)
			return false
		}

		fmt.println("TexSubImage3D")
		gl.TexSubImage3D(
			gl.TEXTURE_2D_ARRAY,
			0,
			0,
			0,
			i32(i),
			expected_width,
			expected_height,
			1,
			gl.RED,
			gl.UNSIGNED_SHORT,
			pixels,
		)
	}

	gl_error := gl.GetError()
	if (gl_error != gl.NO_ERROR) {
		fmt.println(
			"Error loading billboard depth map texture array: ",
			gl_error,
		)
		return false
	}

	return
}

load_billboard_texture_array :: proc(
	paths: [$T]cstring,
	expected_width: i32,
	expected_height: i32,
) -> (
	ok: bool = true,
) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MIN_FILTER,
		gl.LINEAR_MIPMAP_LINEAR,
	)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	textures :: len(paths)

	if (textures == 0) {
		fmt.println("No textures to load.")
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexStorage3D(
		gl.TEXTURE_2D_ARRAY,
		1,
		gl.RGBA8,
		expected_width,
		expected_height,
		textures,
	)

	for path, i in paths {
		width: i32
		height: i32
		pixels := stbi.load(path, &width, &height, nil, 4)
		defer stbi.image_free(pixels)

		if pixels == nil {
			fmt.eprintln("Failed to load texture: ", path)
			return false
		}

		if width != expected_width {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				expected_width,
				" got: ",
				width,
			)
			return false
		}

		if height != expected_height {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				expected_height,
				" got: ",
				height,
			)
			return false
		}

		gl.TexSubImage3D(
			gl.TEXTURE_2D_ARRAY,
			0,
			0,
			0,
			i32(i),
			expected_width,
			expected_height,
			1,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			pixels,
		)
	}

	return
}

billboard_init_draw_contexts :: proc() -> bool {
	gl.GenBuffers(1, &billboard_ubo)

	billboard_init_draw_context(
		&billboard_1x1_draw_context,
		BILLBOARD_MODEL_PATH,
		BILLBOARD_TEXTURE_PATHS,
		BILLBOARD_DEPTH_MAP_TEXTURE_PATHS,
		BILLBOARD_TEXTURE_WIDTH,
		BILLBOARD_TEXTURE_HEIGHT,
	) or_return

	billboard_init_draw_context(
		&billboard_2x2_draw_context,
		FOUR_TILES_BILLBOARD_MODEL_PATH,
		FOUR_TILES_BILLBOARD_TEXTURE_PATHS,
		FOUR_TILES_BILLBOARD_DEPTH_MAP_TEXTURE_PATHS,
		FOUR_TILES_BILLBOARD_TEXTURE_WIDTH,
		FOUR_TILES_BILLBOARD_TEXTURE_HEIGHT,
	) or_return

	return true
}

billboard_1x1_set_texture :: proc(
	pos: glsl.vec3,
	texture: Billboard_Texture_1x1,
) {
	chunk := world_get_chunk({i32(pos.x), i32(pos.z)})
	billboard, ok := &chunk.billboards_1x1.instances[pos]
	if ok {
		billboard.texture = texture
		chunk.billboards_1x1.dirty = true
	}
}

billboard_1x1_remove :: proc(pos: glsl.vec3) {
	chunk := world_get_chunk({i32(pos.x), i32(pos.z)})
	delete_key(&chunk.billboards_1x1.instances, pos)
	chunk.billboards_1x1.dirty = true
}

billboard_1x1_move :: proc(from: glsl.vec3, to: glsl.vec3) {
	if from == to {
		return
	}
	from_chunk := world_get_chunk({i32(from.x), i32(from.z)})
	to_chunk := world_get_chunk({i32(to.x), i32(to.z)})
	billboard, ok := from_chunk.billboards_1x1.instances[from]
	if ok {
		to_chunk.billboards_1x1.instances[to] = billboard
		delete_key(&from_chunk.billboards_1x1.instances, from)
		to_chunk.billboards_1x1.dirty = true
		from_chunk.billboards_1x1.dirty = true
	}
}

billboard_1x1_set :: proc(pos: glsl.vec3, billboard: Billboard_1x1) {
	chunk := world_get_chunk({i32(pos.x), i32(pos.z)})
	chunk.billboards_1x1.instances[pos] = billboard
	chunk.billboards_1x1.dirty = true
}

chunk_billboards_draw :: proc(
	billboards: ^Chunk_Billboards($T),
	billboard_draw_context: Billboard_Draw_Context,
) {
	if !billboards.initialized {
		billboards.initialized = true
		billboards.dirty = true

		gl.GenVertexArrays(1, &billboards.vao)
		gl.BindVertexArray(billboards.vao)

		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, billboard_draw_context.ebo)

		gl.GenBuffers(1, &billboards.ibo)

		gl.BindBuffer(gl.ARRAY_BUFFER, billboard_draw_context.vbo)

		gl.EnableVertexAttribArray(0)
		gl.VertexAttribPointer(
			0,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Billboard_Vertex),
			offset_of(Billboard_Vertex, pos),
		)

		gl.EnableVertexAttribArray(1)
		gl.VertexAttribPointer(
			1,
			2,
			gl.FLOAT,
			gl.FALSE,
			size_of(Billboard_Vertex),
			offset_of(Billboard_Vertex, texcoords),
		)

		gl.BindBuffer(gl.ARRAY_BUFFER, billboards.ibo)

		gl.EnableVertexAttribArray(2)
		gl.VertexAttribPointer(
			2,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Billboard_Instance),
			offset_of(Billboard_Instance, position),
		)

		gl.EnableVertexAttribArray(3)
		gl.VertexAttribPointer(
			3,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Billboard_Instance),
			offset_of(Billboard_Instance, light),
		)

		gl.EnableVertexAttribArray(4)
		gl.VertexAttribPointer(
			4,
			1,
			gl.FLOAT,
			gl.FALSE,
			size_of(Billboard_Instance),
			offset_of(Billboard_Instance, texture),
		)

		gl.EnableVertexAttribArray(5)
		gl.VertexAttribPointer(
			5,
			1,
			gl.FLOAT,
			gl.FALSE,
			size_of(Billboard_Instance),
			offset_of(Billboard_Instance, depth_map),
		)

		gl.VertexAttribDivisor(2, 1)
		gl.VertexAttribDivisor(3, 1)
		gl.VertexAttribDivisor(4, 1)
		gl.VertexAttribDivisor(5, 1)

		gl.BindVertexArray(0)
		gl.BindBuffer(gl.ARRAY_BUFFER, 0)
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	}

	if billboards.dirty {
		billboards.dirty = false

		gl.BindBuffer(gl.ARRAY_BUFFER, billboards.ibo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(billboards.instances) * size_of(Billboard_Instance),
			nil,
			gl.STATIC_DRAW,
		)

		i := 0
		for k, v in billboards.instances {
			instance: Billboard_Instance = {
				position  = k,
				light     = v.light,
				texture   = f32(v.texture),
				depth_map = f32(v.depth_map),
			}
			gl.BufferSubData(
				gl.ARRAY_BUFFER,
				i * size_of(Billboard_Instance),
				size_of(Billboard_Instance),
				&instance,
			)
			i += 1
		}

		gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	}

	gl.BindVertexArray(billboards.vao)
	gl.DrawElementsInstanced(
		gl.TRIANGLES,
		i32(len(billboard_draw_context.indices)),
		gl.UNSIGNED_BYTE,
		nil,
		i32(len(billboards.instances)),
	)
	gl.BindVertexArray(0)
}

billboard_update_draw_context_after_rotation :: proc(draw_context: $T) {
	gl.BindBuffer(gl.ARRAY_BUFFER, draw_context.vbo)
	for v, i in draw_context.vertices {
		v := v
		rotation := glsl.mat4Rotate(
			{0, 1, 0},
			(math.PI / 2) * f32(camera_rotation),
		)
		v.pos = (glsl.vec4{v.pos.x, v.pos.y, v.pos.z, 1} * rotation).xyz
		gl.BufferSubData(
			gl.ARRAY_BUFFER,
			i * size_of(Billboard_Vertex),
			size_of(Billboard_Vertex),
			&v,
		)
	}
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
}

billboard_update_after_rotation :: proc() {
	billboard_update_draw_context_after_rotation(billboard_1x1_draw_context)
	billboard_update_draw_context_after_rotation(billboard_2x2_draw_context)
}
