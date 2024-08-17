package game

import "core:log"
import "core:math/linalg/glsl"
import "core:strings"

import gl "vendor:OpenGL"
import "vendor:cgltf"

MODELS_PATH :: "resources/models/models.glb"

Model_Index :: u32

Model_Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

Model :: struct {
	name:          string,
	vertices:      [dynamic]Model_Vertex,
	indices:       [dynamic]Model_Index,
	uploaded:      bool,
	vbo, ebo, vao: u32,
}

Models_Context :: struct {
	models: map[string]Model,
}

load_models :: proc(using ctx: ^Models_Context) -> (ok: bool) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, MODELS_PATH)
	if result != .success {
		log.error("Failed to parse models file!", result)
		return false
	}
	result = cgltf.load_buffers(options, data, MODELS_PATH)
	if result != .success {
		log.error("Failed to load models buffers!")
		return false
	}
	defer cgltf.free(data)

	for node in data.scene.nodes {
		mesh := node.mesh
		primitive := mesh.primitives[0]
		indices: [dynamic]Model_Index
		vertices: [dynamic]Model_Vertex
		// indices:= make([dynamic]Model_Index)
		// vertices:= make([dynamic]Model_Vertex)
		if primitive.indices != nil {
			accessor := primitive.indices
			for i in 0 ..< accessor.count {
				index := cgltf.accessor_read_index(accessor, i)
				append(&indices, u32(index))
			}
		}

		for attribute in primitive.attributes {
			if attribute.type == .position {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					if i >= len(vertices) {
						append(&vertices, Model_Vertex{})
					}
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
					if i >= len(vertices) {
						append(&vertices, Model_Vertex{})
					}
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].texcoords),
						2,
					)
				}
			}
		}

		name := strings.clone_from_cstring(node.name)
		models[name] = {
			name     = name,
			vertices = vertices,
			indices  = indices,
		}
	}

	return true
}

free_models :: proc(using ctx: ^Models_Context) {
	for k, v in models {
		delete(k)
		delete(v.indices)
		delete(v.vertices)
	}
	delete(models)
}

bind_model :: proc(using ctx: ^Models_Context, model_name: string) -> bool {
	model, ok := &models[model_name]
	if !ok {
		log.error("Model ", model_name, "isn't loaded!")
		return false
	}
	using model

	if !uploaded {
		uploaded = true
		gl.GenVertexArrays(1, &vao)
		gl.BindVertexArray(vao)

		gl.GenBuffers(1, &vbo)
		gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

		gl.GenBuffers(1, &ebo)
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)

		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(vertices) * size_of(Model_Vertex),
			raw_data(vertices),
			gl.STATIC_DRAW,
		)

		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(indices) * size_of(Model_Index),
			raw_data(indices),
			gl.STATIC_DRAW,
		)

		gl.VertexAttribPointer(
			0,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Model_Vertex),
			offset_of(Model_Vertex, pos),
		)
		gl.EnableVertexAttribArray(0)

		gl.VertexAttribPointer(
			1,
			2,
			gl.FLOAT,
			gl.FALSE,
			size_of(Model_Vertex),
			offset_of(Model_Vertex, texcoords),
		)
		gl.EnableVertexAttribArray(1)

		gl.BindVertexArray(0)
		gl.BindBuffer(gl.ARRAY_BUFFER, 0)
		gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	} 

	gl.BindVertexArray(vao)

	return true
}

unbind_model :: proc() {
	gl.BindVertexArray(0)
	// gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	// gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}

draw_model :: proc(using ctx: ^Models_Context, model_name: string) {
	model, ok := &models[model_name]
	if !ok {
		log.error("Did not find", model_name, "to draw!")
	}
	gl.DrawElements(gl.TRIANGLES, i32(len(model.indices)), gl.UNSIGNED_INT, nil)
}
