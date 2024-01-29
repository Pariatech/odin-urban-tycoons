package main

import "core:fmt"
import "core:math/linalg"
import m "core:math/linalg/glsl"

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

WALL_DOOR_TRANSFORM_MAP :: [Wall_Axis][Camera_Rotation]m.mat4 {
	.North_South =  {
		.South_West = {0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
		.South_East = {0, 0, -1, -1, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
		.North_East = {0, 0, -1, -1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.North_West = {0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
	},
	.East_West =  {
		.South_West = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.South_East = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.North_East = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 1},
		.North_West = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 1},
	},
}

wall_door_model_vertices: [Wall_Door_Model][12]Vertex
wall_door_model_indices: [Wall_Door_Model][18]u32

north_south_wall_doors := map[m.ivec3]Wall_Door{}
east_west_wall_doors := map[m.ivec3]Wall_Door{}

load_wall_door_models :: proc() {
	load_models(
		WALL_DOOR_MODEL_PATHS,
		&wall_door_model_vertices,
		&wall_door_model_indices,
	)
}

draw_wall_door :: proc(
	using wall_door: Wall_Door,
	pos: m.ivec3,
	axis: Wall_Axis,
	y: f32,
) {
	transform_map := WALL_DOOR_TRANSFORM_MAP
	texture_map := WALL_DOOR_MODEL_TEXTURES
	position := m.vec3{f32(pos.x), y, f32(pos.z)}
    transform := m.mat4Translate(position)
	transform *= transform_map[axis][camera_rotation]
    texture := texture_map[model]

	append_draw_component(
		 {
			vertices = wall_door_model_vertices[model][:],
			indices = wall_door_model_indices[model][:],
			model = transform,
			texture = texture,
		},
	)
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
		return north_south_wall_doors[pos]
	case .East_West:
		return east_west_wall_doors[pos]
	}

	return nil
}

insert_wall_door :: proc(axis: Wall_Axis, pos: m.ivec3, wall_door: Wall_Door) {
	switch axis {
	case .North_South:
		north_south_wall_doors[pos] = wall_door
	case .East_West:
		east_west_wall_doors[pos] = wall_door
	}
    draw_wall_door(wall_door, pos, axis, 0)
}

rotate_door :: proc(pos: m.ivec3, door: Wall_Door, axis: Wall_Axis) {
    draw_wall_door(door, pos, axis, 0)
}

rotate_doors :: proc() {
    for pos, door in north_south_wall_doors {
        rotate_door(pos, door, .North_South)
    }
    for pos, door in east_west_wall_doors {
        rotate_door(pos, door, .East_West)
    }
}
