package main

import "core:fmt"
import m "core:math/linalg/glsl"
import "core:math/noise"

terrain_heights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]f32
terrain_lights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]m.vec3

terrain_quad_tree_nodes: [dynamic]Terrain_Quad_Tree_Node
terrain_quad_tree_tile_triangles: [dynamic]Tile_Triangle

Terrain_Quad_Tree_Node_Children_Type :: enum {
	Node,
	Tile_Triangle,
}

Terrain_Quad_Tree_Node :: struct {
	children_type: Terrain_Quad_Tree_Node_Children_Type,
	children:      [4]u32,
}

init_terrain :: proc() {
	append(
		&terrain_quad_tree_nodes,
		Terrain_Quad_Tree_Node {
			children_type = .Tile_Triangle,
			children = {0, 1, 2, 3},
		},
	)
	append(
		&terrain_quad_tree_tile_triangles,
		Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
		Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
		Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
		Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
	)

	// SEED :: 694201337
	// for x in 0 ..= WORLD_WIDTH {
	// 	for z in 0 ..= WORLD_DEPTH {
	// 		terrain_heights[x][z] =
	// 			noise.noise_2d(SEED, {f64(x), f64(z)}) / 2.0
	// 	}
	// }

	for x in 0 ..= WORLD_WIDTH {
		for z in 0 ..= WORLD_DEPTH {
			calculate_terrain_light(x, z)
		}
	}
}

calculate_terrain_light :: proc(x, z: int) {
	normal: m.vec3
	if x == 0 && z == 0 {
		triangles := [?][3]m.vec3 {
			 {
				{-0.5, terrain_heights[x][z], -0.5},
				{0.5, terrain_heights[x + 1][z], -0.5},
				{-0.5, terrain_heights[x][z + 1], 0.5},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == WORLD_WIDTH && z == WORLD_DEPTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == 0 && z == WORLD_DEPTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == 0 && x == WORLD_WIDTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == 0 {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == 0 {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == WORLD_WIDTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == WORLD_DEPTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	}

	normal = m.normalize(normal)
	light := m.dot(m.normalize(sun), normal)
	terrain_lights[x][z] = {light, light, light}
}

get_terrain_tile_triangle_lights :: proc(
	side: Tile_Triangle_Side,
	x, z, w: int,
) -> (
	lights: [3]m.vec3,
) {
	lights = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}}

	tile_lights := [4]m.vec3 {
		terrain_lights[x][z],
		terrain_lights[x + w][z],
		terrain_lights[x + w][z + w],
		terrain_lights[x][z + w],
	}

	lights[2] = {0, 0, 0}
	for light in tile_lights {
		lights[2] += light
	}
	lights[2] /= 4
	switch side {
	case .South:
		lights[0] = tile_lights[0]
		lights[1] = tile_lights[1]
	case .East:
		lights[0] = tile_lights[1]
		lights[1] = tile_lights[2]
	case .North:
		lights[0] = tile_lights[2]
		lights[1] = tile_lights[3]
	case .West:
		lights[0] = tile_lights[3]
		lights[1] = tile_lights[0]
	}

	return
}

get_terrain_tile_triangle_heights :: proc(
	side: Tile_Triangle_Side,
	x, z, w: int,
) -> (
	heights: [3]f32,
) {
	heights = {0, 0, 0}

	tile_heights := [4]f32 {
		terrain_heights[x][z],
		terrain_heights[x + w][z],
		terrain_heights[x + w][z + w],
		terrain_heights[x][z + w],
	}

	heights[2] = 0
	for height in tile_heights {
		heights[2] += height
	}
	heights[2] /= 4
	switch side {
	case .South:
		heights[0] = tile_heights[0]
		heights[1] = tile_heights[1]
	case .East:
		heights[0] = tile_heights[1]
		heights[1] = tile_heights[2]
	case .North:
		heights[0] = tile_heights[2]
		heights[1] = tile_heights[3]
	case .West:
		heights[0] = tile_heights[3]
		heights[1] = tile_heights[0]
	}

	return
}

get_tile_height :: proc(x, z: int) -> f32 {
	total :=
		terrain_heights[x][z] +
		terrain_heights[x + 1][z] +
		terrain_heights[x][z + 1] +
		terrain_heights[x + 1][z + 1]
	return total / 4
}

draw_terrain_quad_tree_node :: proc(
	node: Terrain_Quad_Tree_Node,
	x, z, w: int,
) {
	switch node.children_type {
	case .Node:
		draw_terrain_quad_tree_node(
			terrain_quad_tree_nodes[node.children[0]],
			x,
			z,
			w / 2,
		)
	case .Tile_Triangle:
		for child, i in node.children {
			tri := terrain_quad_tree_tile_triangles[child]
			side := Tile_Triangle_Side(i)

			lights := get_terrain_tile_triangle_lights(side, x, z, w)
			heights := get_terrain_tile_triangle_heights(side, x, z, w)
            fmt.println("wtf!?")

			draw_tile_triangle(
				tri,
				side,
				lights,
				heights,
				{f32(x + w / 2) - 0.5, f32(z + w / 2) - 0.5},
				f32(w),
			)
		}
	}
}

draw_terrain :: proc() {
	root := terrain_quad_tree_nodes[0]
    draw_terrain_quad_tree_node(root, 0, 0, WORLD_WIDTH)
}
