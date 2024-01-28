package main

import "core:math/linalg/glsl"
import "core:math/linalg"

Draw_Component :: struct {
    model: glsl.mat4,
    vertices: []Vertex,
    indices: []u32,
    texture: f32,
    mask: f32,
}

draw :: proc(using component: Draw_Component) {
	index_offset := u32(len(world_vertices))
	for i in 0 ..< len(vertices) {
        vertex := vertices[i]
		vertex.texcoords.z = f32(component.texture)
		vertex.pos = linalg.mul(model, vec4(vertex.pos, 1)).xyz

        append(&world_vertices, vertex)
	}

    for idx in indices {
        append(&world_indices, idx + index_offset)
    }
}
