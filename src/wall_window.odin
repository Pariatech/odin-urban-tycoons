package main

import "core:math/linalg"
import m "core:math/linalg/glsl"

Wall_Window :: struct {
	texture: Texture,
}

WALL_WINDOW_PATH :: "resources/models/window.glb"

north_south_wall_windows := map[m.ivec3]Wall_Window{}
east_west_wall_windows := map[m.ivec3]Wall_Window{}

wall_window_vertices: [12]Vertex
wall_window_indices: [18]u32

load_wall_window_mesh :: proc() {
	load_model(WALL_WINDOW_PATH, &wall_window_vertices, &wall_window_indices)
}

draw_wall_window :: proc(
	using wall_window: Wall_Window,
	pos: m.ivec3,
	axis: Wall_Axis,
	y: f32,
) {
	transform_map := WALL_DOOR_TRANSFORM_MAP
	position := m.vec3{f32(pos.x), y, f32(pos.z)}
	transform := m.mat4Translate(position)
	transform *= transform_map[axis][camera_rotation]

	append_draw_component(
		 {
			vertices = wall_window_vertices[:],
			indices = wall_window_indices[:],
			model = transform,
			texture = texture,
		},
	)
}

get_wall_window :: proc(axis: Wall_Axis, pos: m.ivec3) -> Maybe(Wall_Window) {
	switch axis {
	case .North_South:
		return north_south_wall_windows[pos]
	case .East_West:
		return east_west_wall_windows[pos]
	}

	return nil
}

insert_wall_window :: proc(
	axis: Wall_Axis,
	pos: m.ivec3,
	wall_window: Wall_Window,
) {
	switch axis {
	case .North_South:
		north_south_wall_windows[pos] = wall_window
	case .East_West:
		east_west_wall_windows[pos] = wall_window
	}
    draw_wall_window(wall_window, pos, axis, f32(pos.y * WALL_HEIGHT))
}

rotate_window :: proc(pos: m.ivec3, window: Wall_Window, axis: Wall_Axis) {
    draw_wall_window(window, pos, axis, f32(pos.y * WALL_HEIGHT))
}

rotate_windows :: proc() {
    for pos, window in north_south_wall_windows {
        rotate_window(pos, window, .North_South)
    }
    for pos, window in east_west_wall_windows {
        rotate_window(pos, window, .East_West)
    }
}
