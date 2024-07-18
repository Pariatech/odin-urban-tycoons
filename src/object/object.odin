package object

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"

import "../camera"
import c "../constants"
import "../floor"
import "../renderer"

Type :: enum {
	Door,
	Window,
	Chair,
	Table,
}

Model :: enum {
	Wood_Door,
	Wood_Window,
	Wood_Chair,
	Wood_Table_1x2,
}

Orientation :: enum {
	South,
	East,
	North,
	West,
}

MODEL_SIZE :: [Model]glsl.ivec2 {
	.Wood_Door = {1, 1},
	.Wood_Window = {1, 1},
	.Wood_Chair = {1, 1},
	.Wood_Table_1x2 = {1, 2},
}

TYPE_MAP :: [Model]Type {
	.Wood_Door      = .Door,
	.Wood_Window    = .Window,
	.Wood_Chair     = .Chair,
	.Wood_Table_1x2 = .Table,
}

WIDTH :: 128
HEIGHT :: 256

Instance :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   f32,
	depth_map: f32,
}

Texture :: enum {
	Wood_Door_SW,
	Wood_Door_SE,
	Wood_Door_NE,
	Wood_Door_NW,
	Wood_Window_SW,
	Wood_Window_SE,
	Wood_Window_NE,
	Wood_Window_NW,
	Wood_Chair_SW,
	Wood_Chair_SE,
	Wood_Chair_NE,
	Wood_Chair_NW,
	Wood_Table_1x2_1_SW,
	Wood_Table_1x2_2_SW,
	Wood_Table_1x2_1_SE,
	Wood_Table_1x2_2_SE,
	Wood_Table_1x2_1_NE,
	Wood_Table_1x2_2_NE,
	Wood_Table_1x2_1_NW,
	Wood_Table_1x2_2_NW,
}

DIFFUSE_PATHS :: [Texture]cstring {
	.Wood_Door_SW        = "resources/textures/billboards/door-wood/sw-diffuse.png",
	.Wood_Door_SE        = "resources/textures/billboards/door-wood/se-diffuse.png",
	.Wood_Door_NE        = "resources/textures/billboards/door-wood/ne-diffuse.png",
	.Wood_Door_NW        = "resources/textures/billboards/door-wood/nw-diffuse.png",
	.Wood_Window_SW      = "resources/textures/billboards/window-wood/sw-diffuse.png",
	.Wood_Window_SE      = "resources/textures/billboards/window-wood/se-diffuse.png",
	.Wood_Window_NE      = "resources/textures/billboards/window-wood/ne-diffuse.png",
	.Wood_Window_NW      = "resources/textures/billboards/window-wood/nw-diffuse.png",
	.Wood_Chair_SW       = "resources/textures/objects/Chairs/diffuse/Chair_0001.png",
	.Wood_Chair_SE       = "resources/textures/objects/Chairs/diffuse/Chair_0002.png",
	.Wood_Chair_NE       = "resources/textures/objects/Chairs/diffuse/Chair_0003.png",
	.Wood_Chair_NW       = "resources/textures/objects/Chairs/diffuse/Chair_0004.png",
	.Wood_Table_1x2_1_SW = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0001.png",
	.Wood_Table_1x2_2_SW = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0001.png",
	.Wood_Table_1x2_1_SE = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0002.png",
	.Wood_Table_1x2_2_SE = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0002.png",
	.Wood_Table_1x2_1_NE = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0003.png",
	.Wood_Table_1x2_2_NE = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0003.png",
	.Wood_Table_1x2_1_NW = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0004.png",
	.Wood_Table_1x2_2_NW = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0004.png",
}

DEPTH_MAP_PATHS :: [Texture]cstring {
	.Wood_Door_SW        = "resources/textures/billboards/door-wood/sw-depth-map.png",
	.Wood_Door_SE        = "resources/textures/billboards/door-wood/se-depth-map.png",
	.Wood_Door_NE        = "resources/textures/billboards/door-wood/ne-depth-map.png",
	.Wood_Door_NW        = "resources/textures/billboards/door-wood/nw-depth-map.png",
	.Wood_Window_SW      = "resources/textures/billboards/window-wood/sw-depth-map.png",
	.Wood_Window_SE      = "resources/textures/billboards/window-wood/se-depth-map.png",
	.Wood_Window_NE      = "resources/textures/billboards/window-wood/ne-depth-map.png",
	.Wood_Window_NW      = "resources/textures/billboards/window-wood/nw-depth-map.png",
	.Wood_Chair_SW       = "resources/textures/objects/Chairs/mist/Chair_0001.png",
	.Wood_Chair_SE       = "resources/textures/objects/Chairs/mist/Chair_0002.png",
	.Wood_Chair_NE       = "resources/textures/objects/Chairs/mist/Chair_0003.png",
	.Wood_Chair_NW       = "resources/textures/objects/Chairs/mist/Chair_0004.png",
	.Wood_Table_1x2_1_SW = "resources/textures/objects/Tables/mist/Table.6Places.001_0001.png",
	.Wood_Table_1x2_2_SW = "resources/textures/objects/Tables/mist/Table.6Places.002_0001.png",
	.Wood_Table_1x2_1_SE = "resources/textures/objects/Tables/mist/Table.6Places.001_0002.png",
	.Wood_Table_1x2_2_SE = "resources/textures/objects/Tables/mist/Table.6Places.002_0002.png",
	.Wood_Table_1x2_1_NE = "resources/textures/objects/Tables/mist/Table.6Places.001_0003.png",
	.Wood_Table_1x2_2_NE = "resources/textures/objects/Tables/mist/Table.6Places.002_0003.png",
	.Wood_Table_1x2_1_NW = "resources/textures/objects/Tables/mist/Table.6Places.001_0004.png",
	.Wood_Table_1x2_2_NW = "resources/textures/objects/Tables/mist/Table.6Places.002_0004.png",
}

BILLBOARDS :: [Model][Orientation][]Texture {
	.Wood_Door =  {
		.South = {.Wood_Door_SW},
		.East = {.Wood_Door_SE},
		.North = {.Wood_Door_NE},
		.West = {.Wood_Door_NW},
	},
	.Wood_Window =  {
		.South = {.Wood_Window_SW},
		.East = {.Wood_Window_SE},
		.North = {.Wood_Window_NE},
		.West = {.Wood_Window_NW},
	},
	.Wood_Chair =  {
		.South = {.Wood_Chair_SW},
		.East = {.Wood_Chair_SE},
		.North = {.Wood_Chair_NE},
		.West = {.Wood_Chair_NW},
	},
	.Wood_Table_1x2 =  {
		.South = {.Wood_Table_1x2_1_SW, .Wood_Table_1x2_2_SW},
		.East = {.Wood_Table_1x2_1_SE, .Wood_Table_1x2_2_SE},
		.North = {.Wood_Table_1x2_1_NE, .Wood_Table_1x2_2_NE},
		.West = {.Wood_Table_1x2_1_NW, .Wood_Table_1x2_2_NW},
	},
}

Object :: struct {
	texture: Texture,
	light:   glsl.vec3,
	parent:  glsl.ivec3,
}

Chunk :: struct {
	objects:  [Type]map[glsl.ivec3]Object,
	vao, ibo: u32,
	dirty:    bool,
}

Chunks :: [c.CHUNK_HEIGHT][c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Chunk

Uniform_Object :: struct {
	proj, view: glsl.mat4,
}

Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

VERTEX_SHADER_PATH :: "resources/shaders/billboard.vert"
FRAGMENT_SHADER_PATH :: "resources/shaders/billboard.frag"
MODEL_PATH :: "resources/models/billboard.glb"

chunks: Chunks
shader_program: u32
ubo: u32
uniform_object: Uniform_Object
indices: [6]u8
vertices: [4]Vertex
vbo, ebo: u32
texture_array: u32
depth_map_texture_array: u32

init :: proc() -> (ok: bool = true) {
	load_model() or_return

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		&vertices,
		gl.STATIC_DRAW,
	)

	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(u8),
		&indices,
		gl.STATIC_DRAW,
	)


	gl.GenTextures(1, &texture_array)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)
	load_texture_array() or_return

	gl.GenTextures(1, &depth_map_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, depth_map_texture_array)
	load_depth_map_texture_array() or_return

	renderer.load_shader_program(
		&shader_program,
		VERTEX_SHADER_PATH,
		FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture_sampler"), 0)
	gl.Uniform1i(
		gl.GetUniformLocation(shader_program, "depth_map_texture_sampler"),
		1,
	)

	gl.GenBuffers(1, &ubo)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.UseProgram(0)

	for z in 0 ..< c.WORLD_HEIGHT {
		for x in 0 ..< c.WORLD_CHUNK_WIDTH {
			for y in 0 ..< c.WORLD_CHUNK_DEPTH {
				init_chunk(&chunks[z][x][y])
			}
		}
	}

    add({1, 0, 1}, .Wood_Chair, .South)

	return true
}

init_chunk :: proc(using chunk: ^Chunk) {
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)

	gl.GenBuffers(1, &ibo)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, texcoords),
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, ibo)

	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(
		2,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, position),
	)

	gl.EnableVertexAttribArray(3)
	gl.VertexAttribPointer(
		3,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, light),
	)

	gl.EnableVertexAttribArray(4)
	gl.VertexAttribPointer(
		4,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, texture),
	)

	gl.EnableVertexAttribArray(5)
	gl.VertexAttribPointer(
		5,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, depth_map),
	)

	gl.VertexAttribDivisor(2, 1)
	gl.VertexAttribDivisor(3, 1)
	gl.VertexAttribDivisor(4, 1)
	gl.VertexAttribDivisor(5, 1)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}

draw_chunk :: proc(using chunk: ^Chunk) {
	instances: int
	for o in objects {
		instances += len(o)
	}

	if dirty {
		dirty = false


		gl.BindBuffer(gl.ARRAY_BUFFER, ibo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			instances * size_of(Instance),
			nil,
			gl.STATIC_DRAW,
		)

		i := 0
		for o in objects {
			for pos, v in o {
				instance: Instance = {
					position = {f32(pos.x), f32(pos.y), f32(pos.z)},
					light = v.light,
					texture = f32(v.texture),
					depth_map = f32(v.texture),
				}
				gl.BufferSubData(
					gl.ARRAY_BUFFER,
					i * size_of(Instance),
					size_of(Instance),
					&instance,
				)
				i += 1
			}
		}

		gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	}

	gl.BindVertexArray(vao)
	gl.DrawElementsInstanced(
		gl.TRIANGLES,
		i32(len(indices)),
		gl.UNSIGNED_BYTE,
		nil,
		i32(instances),
	)
	gl.BindVertexArray(0)
}

draw :: proc() {
	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	ubo_index := gl.GetUniformBlockIndex(shader_program, "UniformBufferObject")
	gl.UniformBlockBinding(shader_program, ubo_index, 2)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)

	uniform_object.view = camera.view
	uniform_object.proj = camera.proj

	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Uniform_Object),
		&uniform_object,
		gl.STATIC_DRAW,
	)

	gl.UseProgram(shader_program)

	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)

	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, depth_map_texture_array)

    // gl.Disable(gl.DEPTH_TEST)
    // defer gl.Enable(gl.DEPTH_TEST)

	for floor in 0 ..< c.WORLD_HEIGHT {
		for x in camera.visible_chunks_start.x ..< camera.visible_chunks_end.x {
			for z in camera.visible_chunks_start.y ..< camera.visible_chunks_end.y {
				draw_chunk(&chunks[floor][x][z])
			}
		}
	}
}

load_model :: proc() -> (ok: bool = true) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, MODEL_PATH)
	if result != .success {
		log.error("failed to parse file")
		return false
	}
	result = cgltf.load_buffers(options, data, MODEL_PATH)
	if result != .success {
		log.error("failed to load buffers")
		return false
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

load_depth_map_texture_array :: proc() -> (ok: bool = true) {
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.CLAMP)
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.CLAMP)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

	paths := DEPTH_MAP_PATHS
	textures := i32(len(paths))

	if (textures == 0) {
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexImage3D(
		gl.TEXTURE_2D_ARRAY,
		0,
		gl.R16,
		WIDTH,
		HEIGHT,
		textures,
		0,
		gl.RED,
		gl.UNSIGNED_SHORT,
		nil,
	)

	for path, i in paths {
		width: i32
		height: i32
		channels: i32
		pixels := stbi.load_16(path, &width, &height, &channels, 1)
		defer stbi.image_free(pixels)

		if pixels == nil {
			log.error("Failed to load texture: ", path)
			return false
		}

		if width != WIDTH {
			log.error(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				WIDTH,
				" got: ",
				width,
			)
			return false
		}

		if height != HEIGHT {
			log.error(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				HEIGHT,
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
			WIDTH,
			HEIGHT,
			1,
			gl.RED,
			gl.UNSIGNED_SHORT,
			pixels,
		)
	}

	gl_error := gl.GetError()
	if (gl_error != gl.NO_ERROR) {
		log.error(
			"Error loading billboard depth map texture array: ",
			gl_error,
		)
		return false
	}

	return
}

load_texture_array :: proc() -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	paths := DIFFUSE_PATHS
	textures := i32(len(paths))

	if (textures == 0) {
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexImage3D(
		gl.TEXTURE_2D_ARRAY,
		0,
		gl.RGBA8,
		WIDTH,
		HEIGHT,
		textures,
		0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		nil,
	)

	for path, i in paths {
		width: i32
		height: i32
		pixels := stbi.load(path, &width, &height, nil, 4)
		defer stbi.image_free(pixels)

		if pixels == nil {
			log.error("Failed to load texture: ", path)
			return false
		}

		if width != WIDTH {
			log.error(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				WIDTH,
				" got: ",
				width,
			)
			return false
		}

		if height != HEIGHT {
			log.error(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				HEIGHT,
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
			WIDTH,
			HEIGHT,
			1,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			pixels,
		)
	}

	return
}

relative_pos :: proc(x, z: i32, orientation: Orientation) -> glsl.ivec3 {
	switch orientation {
	case .South:
		return {x, 0, z}
	case .East:
		return {-x, 0, z}
	case .North:
		return {x, 0, -z}
	case .West:
		return {-x, 0, -z}
	}

	return {}
}

get_texture :: proc(
	x, z: i32,
	model: Model,
	orientation: Orientation,
) -> Texture {
	billboards := BILLBOARDS
	model_size := MODEL_SIZE
	size := model_size[model]

	return billboards[model][orientation][x * size.x + z]
}

add :: proc(pos: glsl.ivec3, model: Model, orientation: Orientation) {
	type_map := TYPE_MAP
	model_size := MODEL_SIZE

    parent := pos
	size := model_size[model]
	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
            pos := pos + relative_pos(x, y, orientation)
	        chunk := &chunks[pos.y][pos.x][pos.z]
			chunk.objects[type_map[model]][pos] = {
				texture = get_texture(x, y, model, orientation),
				parent  = parent,
                light = {1, 1, 1},
			}
	        chunk.dirty = true
		}
	}
}
