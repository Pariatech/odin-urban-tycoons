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

tables := map[m.ivec3]Table{}


load_table_models :: proc() {
	load_models(TABLE_MODEL_PATHS, &table_model_vertices, &table_model_indices)
}

OBJECT_TRANSFORM_MAP :: [Camera_Rotation]m.mat4 {
	.South_West = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
	.South_East = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
	.North_East = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0.9999, 0, 0, 0, 1},
	.North_West = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, 0.9999, 0, 0, 0, 1},
}

draw_table :: proc(using table: Table, pos: m.ivec3, y: f32) {
	transform_map := OBJECT_TRANSFORM_MAP
	position := m.vec3{f32(pos.x), y, f32(pos.z)}
    transform := m.mat4Translate(position)
	transform *= transform_map[camera_rotation]

	vertices := table_model_vertices[model]
	indices := table_model_indices[model]

	append_draw_component(
		 {
			vertices = table_model_vertices[model][:],
			indices = table_model_indices[model][:],
			model = transform,
			texture = texture,
		},
	)
}

get_table :: proc(pos: m.ivec3) -> Maybe(Table) {
	return tables[pos]
}

insert_table :: proc(pos: m.ivec3, table: Table) {
	tables[pos] = table
    draw_table(table, pos, 0)
}

rotate_table :: proc(pos: m.ivec3, table: Table) {
    draw_table(table, pos, 0)
}

rotate_tables :: proc() {
    for pos, table in tables {
        rotate_table(pos, table)
    }
}
