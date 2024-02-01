package main

import "core:math/linalg/glsl"
import "core:math/linalg"

Draw_Component :: struct {
    model: glsl.mat4,
    vertices: []Vertex,
    indices: []u32,
    texture: Texture,
    mask: Texture,
    depth_map: Depth_Map_Texture,
}

draw_components := [dynamic]Draw_Component{}

draw :: proc(using component: Draw_Component) {
	index_offset := u32(len(world_vertices))
	for i in 0 ..< len(vertices) {
        vertex := vertices[i]
		vertex.texcoords.z = f32(component.texture)
		vertex.texcoords.w = f32(component.mask)
		vertex.pos = linalg.mul(model, vec4(vertex.pos, 1)).xyz
        vertex.depth_map = f32(component.depth_map)

        append(&world_vertices, vertex)
	}

    for idx in indices {
        append(&world_indices, idx + index_offset)
    }
}

draw_world :: proc() {
    // sort the draw components? 
    for draw_component in draw_components {
        draw(draw_component)
    }
}

append_draw_component :: proc(component: Draw_Component) {
    append(&draw_components, component)
}

clear_draw_components :: proc() {
    clear(&draw_components)
}
