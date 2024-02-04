package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"


BILLBOARD_VERTEX_SHADER_PATH :: "resources/shaders/billboard.vert"
BILLBOARD_FRAGMENT_SHADER_PATH :: "resources/shaders/billboard.frag"
BILLBOARD_MODEL_PATH :: "resources/models/billboard.glb"
BILLBOARD_TEXTURE_WIDTH :: 256
BILLBOARD_TEXTURE_HEIGHT :: 512

Billboard_System :: struct {
	indices:                 [6]u8,
	vertices:                [4]Billboard_Vertex,
	instances:               [dynamic]Billboard_Instance,
	uniform_object:          Billboard_Uniform_Object,
	vbo, ebo, vao, ibo, ubo: u32,
	shader_program:          u32,
	texture_array:           u32,
	depth_map_texture_array: u32,
	dirty:                   bool,
}

billboard_system: Billboard_System

Billboard_Instance :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   Billboard_Texture,
	depth_map: Billboard_Depth_Map_Texture,
	rotation:  u8,
}

Billboard_Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

Billboard_Uniform_Object :: struct {
	proj, view, rotation: glsl.mat4,
    camera_rotation: u32,
}

Billboard_Texture :: enum u8 {
	Chair_North_Wood,
	Chair_South_Wood,
}

BILLBOARD_TEXTURE_PATHS :: [Billboard_Texture]cstring {
	.Chair_North_Wood = "resources/textures/chair-north-diffuse.png",
	.Chair_South_Wood = "resources/textures/chair-south-diffuse.png",
}

Billboard_Depth_Map_Texture :: enum u8 {
	Chair_North,
	Chair_South,
}

BILLBOARD_DEPTH_MAP_TEXTURE_PATHS :: [Billboard_Depth_Map_Texture]cstring {
	.Chair_North = "resources/textures/chair-north-depth-map.png",
	.Chair_South = "resources/textures/chair-south-depth-map.png",
}

init_billboard_system :: proc() -> (ok: bool = false) {
	load_billboard_model() or_return
	fmt.println("billboard vertices:", billboard_system.vertices)
	fmt.println("billboard indices:", billboard_system.indices)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.GenBuffers(1, &billboard_system.ibo)
	// gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.ibo)

	gl.GenVertexArrays(1, &billboard_system.vao)
	gl.BindVertexArray(billboard_system.vao)

	gl.GenBuffers(1, &billboard_system.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(billboard_system.vertices) * size_of(Billboard_Vertex),
		&billboard_system.vertices,
		gl.STATIC_DRAW,
	)

	gl.GenBuffers(1, &billboard_system.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, billboard_system.ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(billboard_system.indices) * size_of(u8),
		&billboard_system.indices,
		gl.STATIC_DRAW,
	)


	gl.GenBuffers(1, &billboard_system.ubo)
	gl.BindBuffer(gl.UNIFORM_BUFFER, billboard_system.ubo)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, billboard_system.ubo)

	gl.GenTextures(1, &billboard_system.texture_array)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, billboard_system.texture_array)
	load_billboard_texture_array() or_return

	gl.GenTextures(1, &billboard_system.depth_map_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(
		gl.TEXTURE_2D_ARRAY,
		billboard_system.depth_map_texture_array,
	)
	load_billboard_depth_map_texture_array() or_return

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

	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.ibo)

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
		gl.UNSIGNED_BYTE,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, texture),
	)

	gl.EnableVertexAttribArray(5)
	gl.VertexAttribPointer(
		5,
		1,
		gl.UNSIGNED_BYTE,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, depth_map),
	)

	gl.EnableVertexAttribArray(6)
	gl.VertexAttribPointer(
		6,
		1,
		gl.UNSIGNED_BYTE,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, rotation),
	)

	gl.VertexAttribDivisor(2, 1)
	gl.VertexAttribDivisor(3, 1)
	gl.VertexAttribDivisor(4, 1)
	gl.VertexAttribDivisor(5, 1)
	gl.VertexAttribDivisor(6, 1)

	load_shader_program(
		&billboard_system.shader_program,
		BILLBOARD_VERTEX_SHADER_PATH,
		BILLBOARD_FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(
		gl.GetUniformLocation(
			billboard_system.shader_program,
			"texture_sampler",
		),
		0,
	)
	gl.Uniform1i(
		gl.GetUniformLocation(
			billboard_system.shader_program,
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

draw_billboards :: proc() {
	if len(billboard_system.instances) == 0 do return

	if billboard_system.dirty {
		gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.ibo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(billboard_system.instances) * size_of(Billboard_Instance),
			raw_data(billboard_system.instances),
			gl.STATIC_DRAW,
		)
		billboard_system.dirty = false
		gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	}

	gl.UseProgram(billboard_system.shader_program)

	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, billboard_system.texture_array)

	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(
		gl.TEXTURE_2D_ARRAY,
		billboard_system.depth_map_texture_array,
	)

	gl.BindBuffer(gl.UNIFORM_BUFFER, billboard_system.ubo)
	billboard_system.uniform_object.view = camera_view
	billboard_system.uniform_object.proj = camera_proj
	billboard_system.uniform_object.rotation = glsl.mat4Rotate(
		{0, 1, 0},
		glsl.radians_f32(f32(camera_rotation) * -90.0),
	)
    billboard_system.uniform_object.camera_rotation = u32(camera_rotation)
	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Billboard_Uniform_Object),
		&billboard_system.uniform_object,
		gl.STATIC_DRAW,
	)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

	gl.BindVertexArray(billboard_system.vao)
	gl.DrawElementsInstanced(
		gl.TRIANGLES,
		i32(len(billboard_system.indices)),
		gl.UNSIGNED_BYTE,
		nil,
		i32(len(billboard_system.instances)),
	)
	gl.BindVertexArray(0)
}

append_billboard :: proc(using billboard: Billboard_Instance) {
	append(&billboard_system.instances, billboard)
	billboard_system.dirty = true
}

load_billboard_model :: proc() -> (ok: bool = false) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, BILLBOARD_MODEL_PATH)
	if result != .success {
		fmt.println("failed to parse file")
		return
	}
	result = cgltf.load_buffers(options, data, BILLBOARD_MODEL_PATH)
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
				billboard_system.indices[i] = u8(index)
			}
		}

		for attribute in primitive.attributes {
			if attribute.type == .position {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&billboard_system.vertices[i].pos),
						3,
					)
					billboard_system.vertices[i].pos.x *= -1
				}
			}
			if attribute.type == .texcoord {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&billboard_system.vertices[i].texcoords),
						2,
					)
				}
			}
		}
	}

	return true
}

load_billboard_depth_map_texture_array :: proc() -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.CLAMP)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.CLAMP)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	textures :: len(BILLBOARD_DEPTH_MAP_TEXTURE_PATHS)

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
		BILLBOARD_TEXTURE_WIDTH,
		BILLBOARD_TEXTURE_HEIGHT,
		textures,
	)

	for path, i in BILLBOARD_DEPTH_MAP_TEXTURE_PATHS {
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

		if width != BILLBOARD_TEXTURE_WIDTH {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				BILLBOARD_TEXTURE_WIDTH,
				" got: ",
				width,
			)
			return false
		}

		if height != BILLBOARD_TEXTURE_HEIGHT {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				BILLBOARD_TEXTURE_HEIGHT,
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
			BILLBOARD_TEXTURE_WIDTH,
			BILLBOARD_TEXTURE_HEIGHT,
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

load_billboard_texture_array :: proc() -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	textures :: len(BILLBOARD_TEXTURE_PATHS)

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
		BILLBOARD_TEXTURE_WIDTH,
		BILLBOARD_TEXTURE_HEIGHT,
		textures,
	)

	for path, i in BILLBOARD_TEXTURE_PATHS {
		width: i32
		height: i32
		pixels := stbi.load(path, &width, &height, nil, 4)
		defer stbi.image_free(pixels)

		if pixels == nil {
			fmt.eprintln("Failed to load texture: ", path)
			return false
		}

		if width != BILLBOARD_TEXTURE_WIDTH {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				BILLBOARD_TEXTURE_WIDTH,
				" got: ",
				width,
			)
			return false
		}

		if height != BILLBOARD_TEXTURE_HEIGHT {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				BILLBOARD_TEXTURE_HEIGHT,
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
			BILLBOARD_TEXTURE_WIDTH,
			BILLBOARD_TEXTURE_HEIGHT,
			1,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			pixels,
		)
	}

	return
}
