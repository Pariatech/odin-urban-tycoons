package main

import "core:fmt"
import "core:math/linalg"
import m "core:math/linalg/glsl"
import "vendor:cgltf"

Wall_Door_Model :: enum {
	Wood,
}

Wall_Door :: struct {
	model: Wall_Door_Model,
}

WALL_DOOR_MODEL_PATHS :: [Wall_Door_Model]cstring {
	.Wood = "resources/models/door-wood.glb",
}

WALL_DOOR_MODEL_TEXTURES :: [Wall_Door_Model]Texture {
	.Wood = .Door_Wood,
}

wall_door_model_vertices: [Wall_Door_Model][12]Vertex
wall_door_model_indices: [Wall_Door_Model][18]u32

load_wall_door_models :: proc() {
	model_paths := WALL_DOOR_MODEL_PATHS
	model_textures := WALL_DOOR_MODEL_TEXTURES
	for model_path, model in model_paths {
		model_vertices := &wall_door_model_vertices[model]
		options: cgltf.options
		data, result := cgltf.parse_file(options, model_path)
		if result != .success {
			return
		}
		result = cgltf.load_buffers(options, data, model_path)
		if result != .success {
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
					wall_door_model_indices[model][i] = u32(index)
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
						model_vertices[i].texcoords.z = f32(
							model_textures[model],
						)
						model_vertices[i].light = {1, 1, 1}
						fmt.println("Texcoord", i, model_vertices[i].texcoords)
					}
				}
			}
		}
	}
}

draw_wall_door :: proc(
	using wall_door: Wall_Door,
	pos: m.ivec3,
	axis: Wall_Axis,
	y: f32,
) {
	transform_map := WALL_TRANSFORM_MAP
	position := m.vec3{f32(pos.x), y, f32(pos.z)}
	transform := transform_map[axis][camera_rotation]
    // transform = {
    //     1, 0, 0, 0,
    //     0, 1, 0, 0,
    //     0, 0, -1, 0,
    //     0, 0, 0, 1,
    // }

	vertices := wall_door_model_vertices[model]
	indices := wall_door_model_indices[model]
    // transform[2, 3] *= -1
	for i in 0 ..< len(vertices) {
		// vertices[i].texcoords.z = f32(texture)
		// vertices[i].texcoords.y = 1 - vertices[i].texcoords.y
		vertices[i].pos.z *= -1
		vertices[i].pos = linalg.mul(transform, vec4(vertices[i].pos, 1)).xyz
		vertices[i].pos += position
	}
	draw_mesh(vertices[:], indices[:])
}

draw_tile_wall_doors :: proc(pos: m.ivec3, y: f32) {
	north_south_key := pos
	#partial switch camera_rotation {
	case .South_East, .North_East:
		north_south_key.x += 1
	}
	if north_south_key.x < WORLD_WIDTH {
		if wall_door, ok := get_wall_door(.North_South, north_south_key).?;
		   ok {
			draw_wall_door(wall_door, north_south_key, .North_South, y)
		}
	}

	east_west_key := pos
	#partial switch camera_rotation {
	case .North_East, .North_West:
		east_west_key.z += 1
	}
	if east_west_key.z < WORLD_DEPTH {
		if wall_door, ok := get_wall_door(.East_West, east_west_key).?; ok {
			draw_wall_door(wall_door, east_west_key, .East_West, y)
		}
	}

}

get_wall_door :: proc(axis: Wall_Axis, pos: m.ivec3) -> Maybe(Wall_Door) {
	switch axis {
	case .North_South:
		return north_south_wall_doors[pos.x][pos.z][pos.y]
	case .East_West:
		return east_west_wall_doors[pos.x][pos.z][pos.y]
	}

	return nil
}

insert_wall_door :: proc(axis: Wall_Axis, pos: m.ivec3, wall_door: Wall_Door) {
	switch axis {
	case .North_South:
		north_south_wall_doors[pos.x][pos.z][pos.y] = wall_door
	case .East_West:
		east_west_wall_doors[pos.x][pos.z][pos.y] = wall_door
	}
}
