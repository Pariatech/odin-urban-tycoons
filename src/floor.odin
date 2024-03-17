package main

import "core:fmt"
import m "core:math/linalg/glsl"
import "core:testing"

FLOOR_OFFSET :: 0.0004

floor_quadtrees := [WORLD_HEIGHT]Floor_Quadtree {
	 {
		nodes =  {
			 {
				parent = 0,
				children =  {
					Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
					Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
					Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
					Tile_Triangle{texture = .Grass, mask_texture = .Grid_Mask},
				},
			},
		},
	},
	{{{}}},
	{{{}}},
	{{{}}},
}

Floor_Quadtree :: struct {
	nodes: [dynamic]Floor_Quadtree_Node,
}

Floor_Quadtree_Node_Index :: int

Floor_Quadtree_Node_Child :: union {
	Tile_Triangle,
	Floor_Quadtree_Node_Index,
}

Floor_Quadtree_Node :: struct {
	parent:   int,
	children: [4]Floor_Quadtree_Node_Child,
}

floor_quadtree_shake_node :: proc(
	floor_quadtree: ^Floor_Quadtree,
	node_index: int,
	node_pos: m.ivec2,
	node_size: i32,
) {
	node := floor_quadtree.nodes[node_index]
	parent := &floor_quadtree.nodes[node.parent]
	parent_index := node.parent
	parent_size := node_size * 2
	parent_pos := m.ivec2 {
		node_pos.x - (node_pos.x % parent_size),
		node_pos.y - (node_pos.y % parent_size),
	}
	i :=
		node_pos.x / (parent_pos.x + node_size) +
		node_pos.y / (parent_pos.y + node_size) * 2

	parent.children[i] = node.children[0]
	unordered_remove(&floor_quadtree.nodes, node_index)
	if node_index != len(floor_quadtree.nodes) {
		moved_index_parent := floor_quadtree.nodes[node_index].parent
		for child in &floor_quadtree.nodes[moved_index_parent].children {
			if child == len(floor_quadtree.nodes) {
				child = node_index
			}
		}

		for child in floor_quadtree.nodes[node_index].children {
			#partial switch value in child {
			case Floor_Quadtree_Node_Index:
				floor_quadtree.nodes[value].parent = node_index
			}
		}
	}

	if !floor_quadtree_shakable(
		   floor_quadtree,
		   parent_index,
		   parent_pos,
		   parent_size,
	   ) {return}

	floor_quadtree_shake_node(
		floor_quadtree,
		parent_index,
		parent_pos,
		parent_size,
	)
}

floor_quadtree_shakable :: proc(
	floor_quadtree: ^Floor_Quadtree,
	node_index: int,
	node_pos: m.ivec2,
	node_size: i32,
) -> bool {
	if node_index == 0 {return false}
	if terrain_heights[node_pos.x][node_pos.y + node_size] !=
		   terrain_heights[node_pos.x][node_pos.y] ||
	   terrain_heights[node_pos.x + node_size][node_pos.y + node_size] !=
		   terrain_heights[node_pos.x][node_pos.y] ||
	   terrain_heights[node_pos.x + node_size][node_pos.y] !=
		   terrain_heights[node_pos.x][node_pos.y] {
		return false
	}

	node := floor_quadtree.nodes[node_index]
	all_same_triangle := true
	all_nil := true
	triangle: Maybe(Tile_Triangle)
	for child in node.children {
		switch value in child {
		case nil:
			all_same_triangle = false
		case Floor_Quadtree_Node_Index:
			all_nil = false
			all_same_triangle = false
			break
		case Tile_Triangle:
			all_nil = false
			if triangle == nil {
				triangle = value
			} else if value.texture != triangle.?.texture ||
			   value.mask_texture != triangle.?.mask_texture {
				all_same_triangle = false
				break
			}
		}
	}

	return all_nil || all_same_triangle
}

floor_quadtrees_remove :: proc(pos: m.ivec3, side: Tile_Triangle_Side) {
	floor_quadtree := &floor_quadtrees[pos.y]

	node_index: int = 0
	node_pos: m.ivec2 = {0, 0}
	node_size: i32 = WORLD_WIDTH

	for {
		node := floor_quadtree.nodes[node_index]

		i: i32
		if node_size == 1 {
			i = i32(side)
		} else {
			i =
				pos.x / (node_pos.x + node_size / 2) +
				pos.z / (node_pos.y + node_size / 2) * 2
		}

		child := node.children[i]

		switch value in child {
		case nil:
			return
		case Floor_Quadtree_Node_Index:
			node_index = value
			node_pos = m.ivec2 {
				node_pos.x + (i % 2) * node_size / 2,
				node_pos.y + (i / 2) * node_size / 2,
			}
			node_size /= 2
		case Tile_Triangle:
			if node_size == 1 {
				floor_quadtree.nodes[node_index].children[i] = nil

				if floor_quadtree_shakable(
					   floor_quadtree,
					   node_index,
					   node_pos,
					   node_size,
				   ) {
					floor_quadtree_shake_node(
						floor_quadtree,
						node_index,
						node_pos,
						node_size,
					)
				}
				return
			} else {
				new_index := len(floor_quadtree.nodes)
				append(
					&floor_quadtree.nodes,
					Floor_Quadtree_Node {
						parent = node_index,
						children = {value, value, value, value},
					},
				)
				floor_quadtree.nodes[node_index].children[i] = new_index

				node_index = new_index
				node_pos = m.ivec2 {
					node_pos.x + (i % 2) * node_size / 2,
					node_pos.y + (i / 2) * node_size / 2,
				}
				node_size /= 2
			}
		}
	}
}

tile_quadtrees_set_height :: proc(pos: m.ivec3, height: f32) {
	if pos.y != 0 {return}

	floor_quadtree := &floor_quadtrees[0]
	node_index: int = 0
	node_pos: m.ivec2 = {0, 0}
	node_size: i32 = WORLD_WIDTH

	for {
		node := floor_quadtree.nodes[node_index]

		i :=
			pos.x / (node_pos.x + node_size / 2) +
			pos.z / (node_pos.y + node_size / 2) * 2

		child := node.children[i]

		switch value in child {
		case nil:
			return
		case Floor_Quadtree_Node_Index:
			node_index = value
			node_pos = m.ivec2 {
				node_pos.x + (i % 2) * node_size / 2,
				node_pos.y + (i / 2) * node_size / 2,
			}
			node_size /= 2
		case Tile_Triangle:
			if node_size == 1 {
				if floor_quadtree_shakable(
					   floor_quadtree,
					   node_index,
					   node_pos,
					   node_size,
				   ) {
					floor_quadtree_shake_node(
						floor_quadtree,
						node_index,
						node_pos,
						node_size,
					)
				}
				return
			} else {
				new_index := len(floor_quadtree.nodes)
				append(
					&floor_quadtree.nodes,
					Floor_Quadtree_Node {
						parent = node_index,
						children = {value, value, value, value},
					},
				)
				floor_quadtree.nodes[node_index].children[i] = new_index

				node_index = new_index
				node_pos = m.ivec2 {
					node_pos.x + (i % 2) * node_size / 2,
					node_pos.y + (i / 2) * node_size / 2,
				}
				node_size /= 2
			}
		}
	}
}

floor_quadtrees_append :: proc(
	pos: m.ivec3,
	side: Tile_Triangle_Side,
	tri: Tile_Triangle,
) {
	floor_quadtree := &floor_quadtrees[pos.y]

	node_index: int = 0
	node_pos: m.ivec2 = {0, 0}
	node_size: i32 = WORLD_WIDTH

	for {
		node := floor_quadtree.nodes[node_index]

		i: i32
		if node_size == 1 {
			i = i32(side)
		} else {
			i =
				pos.x / (node_pos.x + node_size / 2) +
				pos.z / (node_pos.y + node_size / 2) * 2
		}

		child := node.children[i]

		switch value in child {
		case nil:
			if node_size == 1 {
				floor_quadtree.nodes[node_index].children[i] = tri
				if floor_quadtree_shakable(
					   floor_quadtree,
					   node_index,
					   node_pos,
					   node_size,
				   ) {
					floor_quadtree_shake_node(
						floor_quadtree,
						node_index,
						node_pos,
						node_size,
					)
				}
				return
			} else {
				new_index := len(floor_quadtree.nodes)
				append(
					&floor_quadtree.nodes,
					Floor_Quadtree_Node{parent = node_index},
				)
				floor_quadtree.nodes[node_index].children[i] = new_index

				node_index = new_index
				node_pos = m.ivec2 {
					node_pos.x + (i % 2) * node_size / 2,
					node_pos.y + (i / 2) * node_size / 2,
				}
				node_size /= 2
			}
		case Floor_Quadtree_Node_Index:
			node_index = value
			node_pos = m.ivec2 {
				node_pos.x + (i % 2) * node_size / 2,
				node_pos.y + (i / 2) * node_size / 2,
			}
			node_size /= 2
		case Tile_Triangle:
			if node_size == 1 {
				floor_quadtree.nodes[node_index].children[i] = tri

				if floor_quadtree_shakable(
					   floor_quadtree,
					   node_index,
					   node_pos,
					   node_size,
				   ) {
					floor_quadtree_shake_node(
						floor_quadtree,
						node_index,
						node_pos,
						node_size,
					)
				}
				return
			} else {
				if value.texture == tri.texture &&
				   value.mask_texture == tri.mask_texture {
					return
				}

				new_index := len(floor_quadtree.nodes)
				append(
					&floor_quadtree.nodes,
					Floor_Quadtree_Node {
						parent = node_index,
						children = {value, value, value, value},
					},
				)
				floor_quadtree.nodes[node_index].children[i] = new_index

				node_index = new_index
				node_pos = m.ivec2 {
					node_pos.x + (i % 2) * node_size / 2,
					node_pos.y + (i / 2) * node_size / 2,
				}
				node_size /= 2
			}
		}
	}
}

tile_quadtree_node_on_visilbe :: proc(
	floor_quadtree: Floor_Quadtree,
	floor: int,
	node_index: int,
	node_pos: m.ivec2,
	node_size: i32,
	aabb: Rectangle,
	fn: proc(
		tri: Tile_Triangle,
		side: Tile_Triangle_Side,
		lights: [3]m.vec3,
		heights: [3]f32,
		pos: m.vec2,
		size: f32,
	) -> (
		stop: bool = true
	),
) -> bool {
	node := floor_quadtree.nodes[node_index]

	node_aabb := Rectangle{node_pos.x, node_pos.y, node_size, node_size}
	if !aabb_intersection(node_aabb, aabb) {return false}

	for child, i in node.children {
		switch value in child {
		case nil:
		case Floor_Quadtree_Node_Index:
			if tile_quadtree_node_on_visilbe(
				   floor_quadtree,
				   floor,
				   value,
				   m.ivec2 {
					   node_pos.x + (i32(i) % 2) * node_size / 2,
					   node_pos.y + (i32(i) / 2) * node_size / 2,
				   },
				   node_size / 2,
				   aabb,
				   fn,
			   ) {
				return true
			}
		case Tile_Triangle:
			y: f32 = terrain_heights[node_pos.x][node_pos.y]
			y += f32(floor) * WALL_HEIGHT
			lights := [3]m.vec3{1, 1, 1}


			// heights := [3]f32 {
			// 	y + FLOOR_OFFSET,
			// 	y + FLOOR_OFFSET,
			// 	y + FLOOR_OFFSET,
			// }

			if node_size == 1 {
				heights := get_terrain_tile_triangle_heights(
					Tile_Triangle_Side(i),
					int(node_pos.x),
					int(node_pos.y),
					int(1),
				)

				heights[0] += f32(floor) * WALL_HEIGHT + FLOOR_OFFSET
				heights[1] += f32(floor) * WALL_HEIGHT + FLOOR_OFFSET
				heights[2] += f32(floor) * WALL_HEIGHT + FLOOR_OFFSET
				if fn(
					   value,
					   Tile_Triangle_Side(i),
					   lights,
					   heights,
					    {
						   f32(node_pos.x + node_size / 2),
						   f32(node_pos.y + node_size / 2),
					   },
					   f32(node_size),
				   ) {
					return true
				}
			} else {
				child_node_pos := m.ivec2 {
					node_pos.x + (i32(i) % 2) * node_size / 2,
					node_pos.y + (i32(i) / 2) * node_size / 2,
				}
				for j in 0 ..< 4 {
					heights := get_terrain_tile_triangle_heights(
						Tile_Triangle_Side(j),
						int(child_node_pos.x),
						int(child_node_pos.y),
						int(node_size / 4),
					)
					heights[0] += f32(floor) * WALL_HEIGHT + FLOOR_OFFSET
					heights[1] += f32(floor) * WALL_HEIGHT + FLOOR_OFFSET
					heights[2] += f32(floor) * WALL_HEIGHT + FLOOR_OFFSET

					if fn(
						   value,
						   Tile_Triangle_Side(j),
						   lights,
						   heights,
						    {
							   f32(child_node_pos.x) +
							   f32(node_size) / 4 -
							   0.5,
							   f32(child_node_pos.y) +
							   f32(node_size) / 4 -
							   0.5,
						   },
						   f32(node_size / 2),
					   ) {
						return true
					}
				}
			}
		}
	}

	return false
}

draw_floor_tiles :: proc() {
	aabb := get_camera_aabb()

	for floor_quadtree, floor in floor_quadtrees {
		tile_quadtree_node_on_visilbe(
			floor_quadtree,
			floor,
			0,
			{0, 0},
			WORLD_WIDTH,
			aabb,
			draw_tile_triangle,
		)
	}
}

insert_north_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	floor_quadtrees_append(pos, .North, tri)
}

insert_east_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	floor_quadtrees_append(pos, .East, tri)
}

insert_west_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	floor_quadtrees_append(pos, .West, tri)
}

insert_south_floor_tile_triangle :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	floor_quadtrees_append(pos, .South, tri)
}

insert_floor_tile :: proc(pos: m.ivec3, tri: Tile_Triangle) {
	insert_north_floor_tile_triangle(pos, tri)
	insert_south_floor_tile_triangle(pos, tri)
	insert_east_floor_tile_triangle(pos, tri)
	insert_west_floor_tile_triangle(pos, tri)
}

tile_on_visible :: proc(
	floor: int,
	fn: proc(
		tri: Tile_Triangle,
		side: Tile_Triangle_Side,
		lights: [3]m.vec3,
		heights: [3]f32,
		pos: m.vec2,
		size: f32,
	) -> (
		stop: bool = true
	),
) {
	aabb := get_camera_aabb()
	floor_quadtree := floor_quadtrees[floor]

	tile_quadtree_node_on_visilbe(
		floor_quadtree,
		floor,
		0,
		{0, 0},
		WORLD_WIDTH,
		aabb,
		fn,
	)
}

@(test)
floor_test :: proc(t: ^testing.T) {
	// fmt.println("sizeof Texture:", size_of(floor_quadtrees))

	triangle := Tile_Triangle {
		texture      = .Grass,
		mask_texture = .Full_Mask,
	}

	floor_quadtree := &floor_quadtrees[0]
	//
	// insert_south_floor_tile_triangle({0, 0, 0}, triangle)
	// testing.expect_value(t, len(floor_quadtree.nodes), 11)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[0].(Tile_Triangle),
	// 	triangle,
	// )
	// testing.expect_value(t, floor_quadtree.nodes[10].children[1], nil)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[2], nil)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[3], nil)
	//
	// insert_west_floor_tile_triangle({0, 0, 0}, triangle)
	// testing.expect_value(t, len(floor_quadtree.nodes), 11)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[0].(Tile_Triangle),
	// 	triangle,
	// )
	// testing.expect_value(t, floor_quadtree.nodes[10].children[1], nil)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[2], nil)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[3].(Tile_Triangle),
	// 	triangle,
	// )
	//
	// insert_east_floor_tile_triangle({0, 0, 0}, triangle)
	// testing.expect_value(t, len(floor_quadtree.nodes), 11)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[0].(Tile_Triangle),
	// 	triangle,
	// )
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[1].(Tile_Triangle),
	// 	triangle,
	// )
	// testing.expect_value(t, floor_quadtree.nodes[10].children[2], nil)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[3].(Tile_Triangle),
	// 	triangle,
	// )
	//
	// insert_north_floor_tile_triangle({0, 0, 0}, triangle)
	// testing.expect_value(t, len(floor_quadtree.nodes), 10)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[9].children[0].(Tile_Triangle),
	// 	triangle,
	// )
	//
	// floor_quadtrees_remove({0, 0, 0}, .South)
	// testing.expect_value(t, len(floor_quadtree.nodes), 11)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[0], nil)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[1].(Tile_Triangle),
	// 	triangle,
	// )
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[2].(Tile_Triangle),
	// 	triangle,
	// )
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[3].(Tile_Triangle),
	// 	triangle,
	// )
	//
	// floor_quadtrees_remove({0, 0, 0}, .East)
	// testing.expect_value(t, len(floor_quadtree.nodes), 11)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[0], nil)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[1], nil)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[2].(Tile_Triangle),
	// 	triangle,
	// )
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[3].(Tile_Triangle),
	// 	triangle,
	// )
	//
	// floor_quadtrees_remove({0, 0, 0}, .North)
	// testing.expect_value(t, len(floor_quadtree.nodes), 11)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[0], nil)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[1], nil)
	// testing.expect_value(t, floor_quadtree.nodes[10].children[2], nil)
	// testing.expect_value(
	// 	t,
	// 	floor_quadtree.nodes[10].children[3].(Tile_Triangle),
	// 	triangle,
	// )
	//
	// floor_quadtrees_remove({0, 0, 0}, .West)
	// testing.expect_value(t, len(floor_quadtree.nodes), 1)
	// testing.expect_value(t, floor_quadtree.nodes[0].children[0], nil)
	// testing.expect_value(t, floor_quadtree.nodes[0].children[1], nil)
	// testing.expect_value(t, floor_quadtree.nodes[0].children[2], nil)
	// testing.expect_value(t, floor_quadtree.nodes[0].children[3], nil)


	for x in 0 ..< 4 {
		for z in 0 ..< 4 {
			insert_floor_tile(
				{house_x + i32(x), 0, house_z + i32(z) + 7},
				triangle,
			)
		}
	}
	testing.expect_value(t, len(floor_quadtree.nodes), 15)
	for node, i in floor_quadtree.nodes {
		fmt.println(i, node)
	}


}
