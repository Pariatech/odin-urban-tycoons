package main

import "core:math/linalg/glsl"
import "core:math/linalg"

Draw_Component :: struct {
    model: glsl.mat4,
    vertices: []Vertex,
    indices: []u32,
    texture: Texture,
    mask: Texture,
}

draw_components := [dynamic]Draw_Component{}

draw :: proc(using component: Draw_Component) {
	index_offset := u32(len(world_vertices))
	for i in 0 ..< len(vertices) {
        vertex := vertices[i]
		vertex.texcoords.z = f32(component.texture)
		vertex.texcoords.w = f32(component.mask)
		vertex.pos = linalg.mul(model, vec4(vertex.pos, 1)).xyz

        append(&world_vertices, vertex)
	}

    for idx in indices {
        append(&world_indices, idx + index_offset)
    }
}

draw_world :: proc() {
	width := WORLD_WIDTH
	depth := WORLD_DEPTH
	for x in 0 ..< width {
		x := x
		#partial switch camera_rotation {
		case .South_West, .North_West:
			x = width - x - 1
		}
		for z in 0 ..< depth {
			z := z
			#partial switch camera_rotation {
			case .South_West, .South_East:
				z = depth - z - 1
			}

			for side in Tile_Triangle_Side {
				// draw_terrain_tile_triangle(side, x, z)
			}

			y := get_tile_height(x, z)
		}
	}

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
