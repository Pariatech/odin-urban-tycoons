package main

import "core:fmt"
import "core:math/linalg"
import m "core:math/linalg/glsl"
import "vendor:cgltf"

Table_Model :: enum {
	Six_Places,
}

Table :: struct {
	model:   Table_Model,
	texture: Texture,
}

TABLE_MODEL_PATHS :: [Table_Model]cstring {
	.Six_Places = "resources/models/table-6places.glb",
}

table_model_vertices: [Table_Model][12]Vertex
table_model_indices: [Table_Model][18]u32

tables := [WORLD_WIDTH][WORLD_DEPTH][WORLD_HEIGHT]Maybe(Table){}

// find to share this function with the wall door
load_table_models :: proc() {
	fmt.println("Table Model:")
	model_paths := TABLE_MODEL_PATHS
	for model_path, model in model_paths {
		model_vertices := &table_model_vertices[model]
		model_indices := &table_model_indices[model]
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

		fmt.println("Vertices:")
		for mesh in data.meshes {
			primitive := mesh.primitives[0]
			if primitive.indices != nil {
				accessor := primitive.indices
				for i in 0 ..< accessor.count {
					index := cgltf.accessor_read_index(accessor, i)
					model_indices[i] = u32(index)
					fmt.println("Index:", index)
				}
			}

			for attribute in primitive.attributes {
				fmt.println("Attribute semantic:", attribute.name)

				if attribute.type == .position {
					fmt.println("Positions:")
					accessor := attribute.data

					for i in 0 ..< accessor.count {
						// position: [3]f32 = 
						_ = cgltf.accessor_read_float(
							accessor,
							i,
							raw_data(&model_vertices[i].pos),
							3,
						)
						fmt.println("Vertex", i, model_vertices[i].pos)
					}
				}
				if attribute.type == .texcoord {
					fmt.println("Texcoords:")

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
	}
}

OBJECT_TRANSFORM_MAP :: [Camera_Rotation]m.mat4 {
	.South_West = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
	.South_East = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
	.North_East = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0.9999, 0, 0, 0, 1},
	.North_West = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0.9999, 0, 0, 0, 1},
}

draw_table :: proc(using table: Table, pos: m.ivec3, y: f32) {
	transform_map := OBJECT_TRANSFORM_MAP
	position := m.vec3{f32(pos.x), y, f32(pos.z)}
	transform := transform_map[camera_rotation]
	// transform := m.mat4{1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0, 0, 0, 0, 1}

	vertices := table_model_vertices[model]
	indices := table_model_indices[model]
	// transform[2, 3] *= -1
	for i in 0 ..< len(vertices) {
		vertices[i].texcoords.z = f32(texture)
		// vertices[i].texcoords.y = 1 - vertices[i].texcoords.y
		// vertices[i].pos.z *= -1
		vertices[i].pos.x *= -1
		vertices[i].pos = linalg.mul(transform, vec4(vertices[i].pos, 1)).xyz
		vertices[i].pos += position
	}
	draw_mesh(vertices[:], indices[:])
}

draw_tile_table :: proc(pos: m.ivec3, y: f32) {
	if table, ok := get_table(pos).?; ok {
		draw_table(table, pos, y)
	}
}

get_table :: proc(pos: m.ivec3) -> Maybe(Table) {
	return tables[pos.x][pos.z][pos.y]
}

insert_table :: proc(pos: m.ivec3, table: Table) {
	tables[pos.x][pos.z][pos.y] = table
}
