package main

import "core:fmt"

Octree_Point :: struct {
	position: Vec3,
	index:    int,
}

Octree_Node_Child :: union {
	^Octree_Node,
	Octree_Point,
}

Octree_Node :: struct {
	children: [2][2][2]Octree_Node_Child,
}

insert_in_octree :: proc(
	node: ^Octree_Node,
	using point: Octree_Point,
	center: Vec3,
	size: f32,
) {
	relative := position - center
	half_size := size / 2
	quarter_size := size / 4
	x := int(1 + relative.x / half_size)
	y := int(1 + relative.y / half_size)
	z := int(1 + relative.z / half_size)

	child := node.children[x][y][z]

    if child == nil{
		node.children[x][y][z] = point
	} else {
		switch v in child {
		case Octree_Point:
			if (v.position == point.position) {
				fmt.println("existing point")
			    node.children[x][y][z] = point
                return 
			}
			new_node := new(Octree_Node)
			new_center := Vec3 {
				center.x + f32(2 * x - 1) * quarter_size,
				center.y + f32(2 * y - 1) * quarter_size,
				center.z + f32(2 * z - 1) * quarter_size,
			}
			node.children[x][y][z] = new_node

			insert_in_octree(new_node, v, new_center, half_size)
			insert_in_octree(new_node, point, new_center, half_size)
		case ^Octree_Node:
			new_center := Vec3 {
				center.x + f32(2 * x - 1) * quarter_size,
				center.y + f32(2 * y - 1) * quarter_size,
				center.z + f32(2 * z - 1) * quarter_size,
			}
			insert_in_octree(v, point, new_center, half_size)
		}
	}
}

get_in_octree :: proc(
	node: ^Octree_Node,
	position: Vec3,
	center: Vec3,
	size: f32,
) -> Maybe(int) {
	relative := position - center
	half_size := size / 2
	quarter_size := size / 4
	x := int(1 + relative.x / half_size)
	y := int(1 + relative.y / half_size)
	z := int(1 + relative.z / half_size)

	child := node.children[x][y][z]
    if child == nil {
        return nil
    } else {
		switch v in child {
		case Octree_Point:
			if (v.position == position) {
                return v.index
			}

            return nil
		case ^Octree_Node:
			new_center := Vec3 {
				center.x + f32(2 * x - 1) * quarter_size,
				center.y + f32(2 * y - 1) * quarter_size,
				center.z + f32(2 * z - 1) * quarter_size,
			}
			return get_in_octree(v, position, new_center, half_size)
		}
    }
    return nil
}
