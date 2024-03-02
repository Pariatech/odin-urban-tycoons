package main

import "core:math/linalg/glsl"
import "core:testing"
import "core:fmt"

Quadtree_Node_Child_Type :: enum {
	Empty,
	Node,
	Point,
}

Quadtree_Node_Child :: struct {
	type:  Quadtree_Node_Child_Type,
	index: int,
}

Quadtree_Node :: struct {
	parent:   Maybe(int),
	children: [4]Quadtree_Node_Child,
}

Quadtree_Point :: struct($T: typeid) {
	pos:  glsl.ivec2,
	item: T,
	next: Maybe(int),
}

Quadtree :: struct($T: typeid) {
	nodes:  [dynamic]Quadtree_Node,
	points: [dynamic]Quadtree_Point(T),
	size:   i32,
}

quadtree_append :: proc(qt: ^Quadtree($T), pos: glsl.ivec2, item: T) {
	point_index := len(qt.points)
	append(&qt.points, Quadtree_Point(T){pos = pos, item = item})

	recur :: proc(
		qt: ^Quadtree($T),
		node_index, point_index: int,
		node_size: i32,
		node_pos, point_pos: glsl.ivec2,
	) {
		i :=
			point_pos.x / (node_pos.x + node_size / 2) +
			point_pos.y / (node_pos.y + node_size / 2) * 2

		child := &qt.nodes[node_index].children[i]
		child_pos := glsl.ivec2 {
			node_pos.x + (i % 2) * node_size / 2,
			node_pos.y + (i / 2) * node_size / 2,
		}
		switch child.type {
		case .Node:
			recur(
				qt,
				child.index,
				point_index,
				node_size / 2,
				child_pos,
				point_pos,
			)
		case .Point:
			child_point := &qt.points[child.index]
			child_i :=
				child_point.pos.x / (child_pos.x + node_size / 4) +
				child_point.pos.y / (child_pos.y + node_size / 4) * 2

			if node_size == 2 || child_point.pos == point_pos {
				qt.points[point_index].next = child.index
				child.index = point_index
			} else {
				node := Quadtree_Node{}
				node.children[child_i].type = .Point
				node.children[child_i].index = child.index
				node.parent = node_index

				child.type = .Node
				child.index = len(qt.nodes)
                child_index := child.index
				append(&qt.nodes, node)

				recur(
					qt,
					child_index,
					point_index,
					node_size / 2,
					child_pos,
					point_pos,
				)
			}
		case .Empty:
			child.type = .Point
			child.index = point_index
		}
	}

	if len(qt.nodes) == 0 {
		append(&qt.nodes, Quadtree_Node{})
	}
	recur(qt, 0, point_index, qt.size, {0, 0}, pos)
}

quadtree_update_point :: proc(
	qt: ^Quadtree($T),
	pos: glsl.ivec2,
	old, new: int,
) {
	node_index: int = 0
	node_size: i32 = qt.size
	node_pos: glsl.ivec2 = {0, 0}

	for {
		i :=
			pos.x / (node_pos.x + node_size / 2) +
			pos.y / (node_pos.y + node_size / 2) * 2

		child := &qt.nodes[node_index].children[i]
		child_pos := glsl.ivec2 {
			node_pos.x + (i % 2) * node_size / 2,
			node_pos.y + (i / 2) * node_size / 2,
		}

		switch child.type {
		case .Node:
			node_index = child.index
			node_size /= 2
			node_pos = child_pos
		case .Point:
			if child.index == old {
				child.index = new
				return
			}

			previous := child.index
			next, ok := qt.points[child.index].next.?
			for ok {
				if next == old {
					qt.points[previous].next = new
					return
				}
				previous = next
				next, ok = qt.points[next].next.?
			}
		case .Empty:
			return
		}
	}
}

quadtree_update_node :: proc(
	qt: ^Quadtree($T),
	pos: glsl.ivec2,
	old, new: int,
) {
    if old == new {return}
	node_index: int = 0
	node_size: i32 = qt.size
	node_pos: glsl.ivec2 = {0, 0}

	for {
		i :=
			pos.x / (node_pos.x + node_size / 2) +
			pos.y / (node_pos.y + node_size / 2) * 2

		child := &qt.nodes[node_index].children[i]
		child_pos := glsl.ivec2 {
			node_pos.x + (i % 2) * node_size / 2,
			node_pos.y + (i / 2) * node_size / 2,
		}

		if child.type != .Node {return}

		if child.index == old {
			child.index = new
			return
		}

		node_index = child.index
		node_size /= 2
		node_pos = child_pos
	}
}

quadtree_shake :: proc(qt: ^Quadtree($T), pos: glsl.ivec2) {
	previous_index: int = 0

	node_size := qt.size
	i := pos.x / (qt.size / 2) + pos.y / (qt.size / 2) * 2
	if qt.nodes[0].children[i].type != .Node {return}
	node_index := qt.nodes[0].children[i].index
	node_pos := glsl.ivec2 {
		(i % 2) * qt.size / 2,
		(i / 2) * qt.size / 2,
	}

	for {
		all_empty := true
		for child in qt.nodes[node_index].children {
			switch child.type {
			case .Node:
				all_empty = false
			case .Point:
				all_empty = false
			case .Empty:
			}
		}

		if all_empty {
			qt.nodes[previous_index].children[i].type = .Empty
			unordered_remove(&qt.nodes, node_index)
			quadtree_update_node(qt, pos, len(qt.nodes), node_index)
			quadtree_shake(qt, pos)
            return
		} else {
			i =
				pos.x / (node_pos.x + node_size / 2) +
				pos.y / (node_pos.y + node_size / 2) * 2

			child := &qt.nodes[node_index].children[i]

			child_pos := glsl.ivec2 {
				node_pos.x + (i % 2) * node_size / 2,
				node_pos.y + (i / 2) * node_size / 2,
			}

			if child.type != .Node {
				return
			}
            
            previous_index = node_index
			node_index = child.index
			node_size /= 2
			node_pos = child_pos
		}
	}
}

quadtree_remove :: proc(qt: ^Quadtree($T), pos: glsl.ivec2, item: T) {
	if len(qt.nodes) == 0 {return}

	node_index: int = 0
	node_size: i32 = qt.size
	node_pos: glsl.ivec2 = {0, 0}

	for {
		i :=
			pos.x / (node_pos.x + node_size / 2) +
			pos.y / (node_pos.y + node_size / 2) * 2

		child := &qt.nodes[node_index].children[i]
		child_pos := glsl.ivec2 {
			node_pos.x + (i % 2) * node_size / 2,
			node_pos.y + (i / 2) * node_size / 2,
		}

		switch child.type {
		case .Node:
			node_index = child.index
			node_size /= 2
			node_pos = child_pos
			continue
		case .Point:
			child_point := &qt.points[child.index]
			if child_point.pos != pos {return}

			previous: Maybe(int)
			next := child.index
			ok := true
			for ok {
				if qt.points[next].item == item {
					if previous, ok := previous.?; ok {
						qt.points[previous].next = qt.points[next].next
					} else if next, ok := qt.points[next].next.?; ok {
						child.index = next
					} else {
						child.type = .Empty
			            quadtree_shake(qt, pos)
					}

					unordered_remove(&qt.points, next)
                    if len(qt.points) == next {return}

					quadtree_update_point(
						qt,
						qt.points[next].pos,
						len(qt.points),
						next,
					)

					return
				}
				previous = next
				next, ok = qt.points[next].next.?
			}
		case .Empty:
			return
		}
	}
}

quadtree_search :: proc(qt: ^Quadtree($T), aabb: Rectangle) -> []T {
	recur :: proc(
		qt: ^Quadtree($T),
		node_index: int,
		node_size: i32,
		node_pos: glsl.ivec2,
		aabb: Rectangle,
		result: ^[dynamic]T,
	) {
		node_aabb := Rectangle{node_pos.x, node_pos.y, node_size, node_size}
		if !aabb_intersection(node_aabb, aabb) {return}

		for child, i in qt.nodes[node_index].children {
			child_node_pos := glsl.ivec2 {
				node_pos.x + (i32(i) % 2) * node_size / 2,
				node_pos.y + (i32(i) / 2) * node_size / 2,
			}

			switch child.type {
			case .Node:
				recur(
					qt,
					child.index,
					node_size / 2,
					child_node_pos,
					aabb,
					result,
				)
			case .Point:
				point_pos := qt.points[child.index].pos
				point_aabb := Rectangle{point_pos.x, point_pos.y, 1, 1}
				if !aabb_intersection(point_aabb, aabb) {return}

				append(result, qt.points[child.index].item)

				next, ok := qt.points[child.index].next.?
				for ok {
					append(result, qt.points[next].item)
					next, ok = qt.points[next].next.?
				}
			case .Empty:
			}
		}
	}

	if len(qt.nodes) == 0 {
		return []T{}
	}

	result := [dynamic]T{}
	recur(qt, 0, qt.size, {0, 0}, aabb, &result)

	return result[:]
}

@(test)
quadtree_test :: proc(t: ^testing.T) {
	qt := Quadtree(int) {
		size = 1024,
	}
	quadtree_append(&qt, {0, 0}, 69)
	testing.expect_value(t, qt.points[0].item, 69)
	result := quadtree_search(&qt, {0, 0, 1, 1})
	testing.expect_value(t, result[0], 69)
	delete(result)

	quadtree_append(&qt, {0, 0}, 420)
	testing.expect_value(t, qt.points[1].item, 420)
	result = quadtree_search(&qt, {0, 0, 1, 1})
	testing.expect_value(t, result[0], 420)
	testing.expect_value(t, result[1], 69)
	delete(result)

	quadtree_append(&qt, {2, 2}, 69420)
	testing.expect_value(t, qt.points[2].item, 69420)
	result = quadtree_search(&qt, {0, 0, 1, 1})
	testing.expect_value(t, len(result), 2)
	testing.expect_value(t, result[0], 420)
	testing.expect_value(t, result[1], 69)
	delete(result)

	result = quadtree_search(&qt, {0, 0, 2, 2})
	testing.expect_value(t, len(result), 3)
	testing.expect_value(t, result[0], 420)
	testing.expect_value(t, result[1], 69)
	testing.expect_value(t, result[2], 69420)
	delete(result)

	quadtree_remove(&qt, {0, 0}, 69)
	testing.expect_value(t, len(qt.points), 2)
	testing.expect_value(t, qt.points[0].item, 69420)

	result = quadtree_search(&qt, {0, 0, 2, 2})
	testing.expect_value(t, len(result), 2)
	testing.expect_value(t, result[0], 420)
	testing.expect_value(t, result[1], 69420)
	delete(result)

	testing.expect_value(t, len(qt.nodes), 9)
	quadtree_remove(&qt, {0, 0}, 420)
	quadtree_remove(&qt, {2, 2}, 69420)
	testing.expect_value(t, len(qt.points), 0)
	testing.expect_value(t, len(qt.nodes), 1)
}
