package main

import "core:fmt"
import "core:math/linalg"
import m "core:math/linalg/glsl"
import "vendor:cgltf"

get_model_info :: proc(model_path: cstring) {
	fmt.println("Model:", model_path)
	options: cgltf.options
	data, result := cgltf.parse_file(options, model_path)
	if result != .success {
		fmt.println("failed to parse file")
		return
	}
	defer cgltf.free(data)

	for mesh in data.meshes {
		primitive := mesh.primitives[0]
		if primitive.indices != nil {
			accessor := primitive.indices
			fmt.println("Indices:", accessor.count)
		}

		for attribute in primitive.attributes {
			if attribute.type == .position {
				accessor := attribute.data
				fmt.println("Vertices:", accessor.count)
			}
		}
	}
}
get_models_info :: proc(paths: [$T]cstring) {
	for model_path in paths {
		get_model_info(model_path)
	}
}

load_model :: proc(
	model_path: cstring,
	model_vertices: ^[$E]Vertex,
	model_indices: ^[$O]u32,
) -> (
	ok: bool = false,
) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, model_path)
	if result != .success {
		fmt.println("failed to parse file")
		return
	}
	result = cgltf.load_buffers(options, data, model_path)
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
				model_indices[i] = u32(index)
			}
		}

		for attribute in primitive.attributes {
			if attribute.type == .position {
				accessor := attribute.data

				for i in 0 ..< accessor.count {
					// position: [3]f32 = 
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&model_vertices[i].pos),
						3,
					)
				}
			}
			if attribute.type == .texcoord {

				accessor := attribute.data

				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&model_vertices[i].texcoords),
						2,
					)
					model_vertices[i].light = {1, 1, 1}
					fmt.println("Texcoord", i, model_vertices[i].texcoords)
				}
			}
		}
	}

	return true
}

load_models :: proc(
	paths: [$T]cstring,
	vertices: ^[T][$E]Vertex,
	indices: ^[T][$O]u32,
) -> (
	ok: bool = false,
) {
	for model_path, model in paths {
		model_vertices := &vertices[model]
		model_indices := &indices[model]
		load_model(model_path, model_vertices, model_indices) or_return
	}

	return true
}
