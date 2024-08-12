package models

import "core:log"
import "core:math/linalg/glsl"
import "core:strings"

import "vendor:cgltf"

PATH :: "resources/models/models.glb"

Index :: u32

Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

Model :: struct {
	name:     string,
	vertices: [dynamic]Vertex,
	indices:  [dynamic]Index,
}

models: map[string]Model

load :: proc() -> (ok: bool) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, PATH)
	if result != .success {
		log.error("Failed to parse models file!", result)
		return false
	}
	result = cgltf.load_buffers(options, data, PATH)
	if result != .success {
		log.error("Failed to load models buffers!")
		return false
	}
	defer cgltf.free(data)

	for node in data.scene.nodes {
		mesh := node.mesh
		primitive := mesh.primitives[0]
		indices: [dynamic]Index
		vertices: [dynamic]Vertex
		// indices:= make([dynamic]Index)
		// vertices:= make([dynamic]Vertex)
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
						append(&vertices, Vertex{})
					}
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].pos),
						3,
					)
					// vertices[i].pos.x *= -1
				}
			}
			if attribute.type == .texcoord {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					if i >= len(vertices) {
						append(&vertices, Vertex{})
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
