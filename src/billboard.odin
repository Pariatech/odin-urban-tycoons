package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"


BILLBOARD_VERTEX_SHADER_PATH :: "resources/shaders/billboard.vert"
BILLBOARD_FRAGMENT_SHADER_PATH :: "resources/shaders/billboard.frag"
BILLBOARD_MODEL_PATH :: "resources/models/billboard.glb"

Billboard_System :: struct {
	indices:                 [6]u32,
	vertices:                [4]Vertex,
	billboards:              [dynamic]Billboard,
	uniform_object:          Billboard_Uniform_Object,
	vbo, ebo, vao, ibo, ubo: u32,
	shader_program:          u32,
	texture_array:           u32,
	depth_map_texture_array: u32,
}

billboard_system: Billboard_System

Billboard :: struct {
	pos:       glsl.vec3,
	light:     glsl.vec3,
	texture:   Texture,
	depth_map: Depth_Map_Texture,
}

Billboard_Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

Billboard_Instance :: struct {
	pos:       glsl.vec3,
	light:     glsl.vec3,
	texture:   f32,
	depth_map: f32,
}

Billboard_Uniform_Object :: struct {
	proj, view, rotation: glsl.mat4,
}

Billboard_Texture :: enum {
	Chair_North_Wood,
	Chair_South_Wood,
}

BILLBOARD_TEXTURE_PATHS :: [Billboard_Texture]cstring {
	.Chair_North_Wood = "resources/textures/chair-north-diffuse.png",
	.Chair_South_Wood = "resources/textures/chair-south-diffuse.png",
}

init_billboard_system :: proc() -> (ok: bool = false) {
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.GenBuffers(1, &billboard_system.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.vbo)

	gl.GenBuffers(1, &billboard_system.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, billboard_system.ebo)

	gl.GenBuffers(1, &billboard_system.ibo)
	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.ibo)

	gl.GenBuffers(1, &billboard_system.ubo)
	gl.BindBuffer(gl.UNIFORM_BUFFER, billboard_system.ubo)

	gl.GenVertexArrays(1, &billboard_system.vao)
	gl.BindVertexArray(billboard_system.vao)

	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Vertex),
		offset_of(Billboard_Vertex, pos),
	)
	gl.EnableVertexAttribArray(0)

	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Vertex),
		offset_of(Billboard_Vertex, texcoords),
	)
	gl.EnableVertexAttribArray(1)

	gl.VertexAttribPointer(
		2,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, pos),
	)
	gl.EnableVertexAttribArray(2)

	gl.VertexAttribPointer(
		3,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, light),
	)
	gl.EnableVertexAttribArray(3)

	gl.VertexAttribPointer(
		4,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, texture),
	)
	gl.EnableVertexAttribArray(4)

	gl.VertexAttribPointer(
		5,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, depth_map),
	)
	gl.EnableVertexAttribArray(5)

	load_shader_program(
		&billboard_system.shader_program,
		BILLBOARD_VERTEX_SHADER_PATH,
		BILLBOARD_FRAGMENT_SHADER_PATH,
	) or_return

	load_model(
		BILLBOARD_MODEL_PATH,
		&billboard_system.vertices,
		&billboard_system.indices,
	) or_return

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

    return true
}

draw_billboard :: proc(using billboard: Billboard) {
	transform := glsl.mat4 {
		-1,
		0,
		0,
		pos.x,
		0,
		1,
		0,
		pos.y,
		0,
		0,
		1,
		pos.z,
		0,
		0,
		0,
		1,
	}

	// append_draw_component(
	// 	 {
	// 		model = transform,
	// 		vertices = billboard_system.vertices[:],
	// 		indices = billboard_system.indices[:],
	// 		texture = texture,
	// 		mask = mask,
	// 		depth_map = depth_map,
	// 	},
	// )
}

append_billboard :: proc(using billboard: Billboard) {
	append(&billboard_system.billboards, billboard)
	draw_billboard(billboard)
}

rotate_billboards :: proc() {
	for billboard in billboard_system.billboards {
		draw_billboard(billboard)
	}
}
