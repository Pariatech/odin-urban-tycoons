package main

import "core:fmt"
import "core:math/linalg"
import m "core:math/linalg/glsl"

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


load_table_models :: proc() {
	load_models(TABLE_MODEL_PATHS, &table_model_vertices, &table_model_indices)
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
