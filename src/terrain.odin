package main

import "core:fmt"
import m "core:math/linalg/glsl"
import "core:math/noise"

terrain_heights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]f32
terrain_lights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]m.vec3

terrain_quad_tree_nodes: [dynamic]Terrain_Quad_Tree_Node

Terrain_Quad_Tree_Node_Indices :: struct {
	children: [4]int,
}

Terrain_Quad_Tree_Node_Tile_Triangles :: struct {
	children: [4]Tile_Triangle,
}

Terrain_Quad_Tree_Node :: union {
	Terrain_Quad_Tree_Node_Indices,
	Terrain_Quad_Tree_Node_Tile_Triangles,
}

init_terrain :: proc() {
	append(
		&terrain_quad_tree_nodes,
		Terrain_Quad_Tree_Node_Tile_Triangles {
			children =  {
				{texture = .Grass, mask_texture = .Grid_Mask},
				{texture = .Grass, mask_texture = .Grid_Mask},
				{texture = .Grass, mask_texture = .Grid_Mask},
				{texture = .Grass, mask_texture = .Grid_Mask},
			},
		},
	)

	set_terrain_tile_triangle(
		0,
		0,
		{texture = .Gravel, mask_texture = .Grid_Mask},
		.South,
	)

	set_terrain_tile_triangle(
		0,
		0,
		{texture = .Grass, mask_texture = .Grid_Mask},
		.South,
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
	switch value in node {
	case Terrain_Quad_Tree_Node_Indices:
		for child, i in value.children {
			draw_terrain_quad_tree_node(
				terrain_quad_tree_nodes[child],
				x + (i % 2) * (w / 2),
				z + (i / 2) * (w / 2),
				w / 2,
			)
		}
	case Terrain_Quad_Tree_Node_Tile_Triangles:
		for tri, i in value.children {
			side := Tile_Triangle_Side(i)

			lights := get_terrain_tile_triangle_lights(side, x, z, w)
			heights := get_terrain_tile_triangle_heights(side, x, z, w)

			draw_tile_triangle(
				tri,
				side,
				lights,
				heights,
				{f32(x) + f32(w) / 2 - 0.5, f32(z) + f32(w) / 2 - 0.5},
				f32(w),
			)
		}
	}
}

draw_terrain :: proc() {
	root := terrain_quad_tree_nodes[0]
	draw_terrain_quad_tree_node(root, 0, 0, WORLD_WIDTH)
}

set_terrain_height :: proc(x, z: int, height: f32) {
	set_terrain_quad_tree_node_height(0, 0, 0, WORLD_WIDTH, x, z, height)
}

set_terrain_quad_tree_node_height :: proc(
	node_index, node_x, node_z, node_w, x, z: int,
	height: f32,
) {

}

collapse_terrain_quad_tree_node :: proc(
	node_index, node_x, node_z, node_w: int,
	value: ^Terrain_Quad_Tree_Node_Indices,
) {
    // value := terrain_quad_tree_nodes[node_index].(Terrain_Quad_Tree_Node_Indices)
	triangles, ok := terrain_quad_tree_nodes[value.children[0]].(Terrain_Quad_Tree_Node_Tile_Triangles)
	fmt.println("\nCheck for collapse-----\n")
	if !ok {return}
	triangle := triangles.children[0]
	fmt.println(triangle)
	for child in value.children {
		triangles, ok =
		terrain_quad_tree_nodes[child].(Terrain_Quad_Tree_Node_Tile_Triangles)
		if !ok {return}

		for tri in triangles.children {
			if tri.texture != triangle.texture ||
			   tri.mask_texture != triangle.mask_texture {
				return
			}
		}
	}

	height := terrain_heights[node_x][node_z]
	for i in node_x ..= node_w {
		for j in node_z ..= node_w {
			if terrain_heights[i][j] != height {
				// not flat!
				return
			}
		}
	}

	// colapse children?
	fmt.println("\ncolapse?--------------\n", value.children)
	for child in value.children {
        fmt.println("removing", child)
		ordered_remove(&terrain_quad_tree_nodes, child)
		for n in &terrain_quad_tree_nodes {
			if indices, ok := &n.(Terrain_Quad_Tree_Node_Indices); ok {
				for idx, i in &indices.children {
					if idx > child {
						idx -= 1
					}
				}
			}
		}
	}
	terrain_quad_tree_nodes[node_index] = triangles
}

set_terrain_quad_tree_node_tile_triangle :: proc(
	node_index, node_x, node_z, node_w, x, z: int,
	tri: Tile_Triangle,
	side: Tile_Triangle_Side,
) {
	node := &terrain_quad_tree_nodes[node_index]
	switch value in node {
	case Terrain_Quad_Tree_Node_Indices:
		i := x / (node_x + node_w) + z / (node_z + node_w) * 2
		set_terrain_quad_tree_node_tile_triangle(
			value.children[i],
			node_x + (i % 2) * (node_w / 2),
			node_z + (i / 2) * (node_w / 2),
			node_w / 2,
			x,
			z,
			tri,
			side,
		)

		collapse_terrain_quad_tree_node(
			node_index,
			node_x,
			node_z,
			node_w,
			&value,
		)
	// triangles, ok := terrain_quad_tree_nodes[value.children[0]].(Terrain_Quad_Tree_Node_Tile_Triangles)
	// fmt.println("\nCheck for collapse-----\n")
	// if !ok {return}
	// triangle := triangles.children[0]
	// fmt.println(triangle)
	// for child in value.children {
	// 	triangles, ok =
	// 	terrain_quad_tree_nodes[child].(Terrain_Quad_Tree_Node_Tile_Triangles)
	// 	if !ok {return}
	//
	// 	for tri in triangles.children {
	// 		if tri.texture != triangle.texture ||
	// 		   tri.mask_texture != triangle.mask_texture {
	// 			return
	// 		}
	// 	}
	// }
	//
	// height := terrain_heights[node_x][node_z]
	// for i in node_x ..= node_w {
	// 	for j in node_z ..= node_w {
	// 		if terrain_heights[i][j] != height {
	// 			// not flat!
	// 			return
	// 		}
	// 	}
	// }
	//
	// // colapse children?
	// fmt.println("\ncolapse?--------------\n", value.children)
	// for child in value.children {
 //        fmt.println("removing", child)
	// 	ordered_remove(&terrain_quad_tree_nodes, child)
	// 	for n in &terrain_quad_tree_nodes {
	// 		if indices, ok := &n.(Terrain_Quad_Tree_Node_Indices); ok {
	// 			for idx, i in &indices.children {
	// 				if idx > child {
	// 					idx -= 1
	// 				}
	// 			}
	// 		}
	// 	}
	// }
	// terrain_quad_tree_nodes[node_index] = triangles

	case Terrain_Quad_Tree_Node_Tile_Triangles:
		existing_tri := value.children[int(side)]
		if existing_tri.texture != tri.texture ||
		   existing_tri.mask_texture != tri.mask_texture {
			if node_w > 1 {
				index := len(terrain_quad_tree_nodes)
				children := value.children
				indices := Terrain_Quad_Tree_Node_Indices {
					children = {index, index + 1, index + 2, index + 3},
				}
				terrain_quad_tree_nodes[node_index] = indices
				for i in 0 ..< 4 {
					append(
						&terrain_quad_tree_nodes,
						Terrain_Quad_Tree_Node_Tile_Triangles {
							children = children,
						},
					)
				}

				i := x / (node_x + node_w) + z / (node_z + node_w) * 2
				set_terrain_quad_tree_node_tile_triangle(
					indices.children[i],
					node_x + (i % 2) * (node_w / 2),
					node_z + (i / 2) * (node_w / 2),
					node_w / 2,
					x,
					z,
					tri,
					side,
				)
			} else {
				i := int(side)
				value.children[i] = tri
			}
		}
	}
}

set_terrain_tile_triangle :: proc(
	x, z: int,
	tri: Tile_Triangle,
	side: Tile_Triangle_Side,
) {
	set_terrain_quad_tree_node_tile_triangle(
		0,
		0,
		0,
		WORLD_WIDTH,
		x,
		z,
		tri,
		side,
	)
}
