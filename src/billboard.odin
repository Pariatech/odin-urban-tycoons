package main

import "core:fmt"
import "core:math/linalg/glsl"

billboard_vertices: [4]Vertex
billboard_indices: [6]u32
billboards: [dynamic]Billboard

Billboard :: struct {
	pos:     glsl.vec3,
	texture: Texture,
	mask:    Texture,
}

load_billboard_mesh :: proc() {
	load_model(
		"resources/models/billboard.glb",
		&billboard_vertices,
		&billboard_indices,
	)

	fmt.println("Billboard Vertices:", billboard_vertices)
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

	for v in &billboard_vertices {
		v.depth_map = 1.0
	}

	append_draw_component(
		 {
			model = transform,
			vertices = billboard_vertices[:],
			indices = billboard_indices[:],
			texture = texture,
			mask = mask,
		},
	)
}

append_billboard :: proc(using billboard: Billboard) {
	append(&billboards, billboard)
    draw_billboard(billboard)
}

rotate_billboards :: proc() {
	for billboard in billboards {
        draw_billboard(billboard)
	}
}
