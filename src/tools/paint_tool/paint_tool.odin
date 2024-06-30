package paint_tool

import "core:log"
import "core:math"
import "core:math/linalg/glsl"

import "../../camera"
import "../../cursor"
import "../../floor"
import "../../keyboard"
import "../../mouse"
import "../../tile"
import "../../wall"

WALL_SELECTION_DISTANCE :: 4

position: glsl.ivec3
side: tile.Tile_Triangle_Side

found_wall: bool
found_wall_intersect: Wall_Intersect
found_wall_texture: wall.Wall_Texture

texture: wall.Wall_Texture = .White
dirty: bool

Wall_Intersect :: struct {
	pos:  glsl.ivec3,
	axis: wall.Wall_Axis,
}

init :: proc() {
	floor.show_markers = false
}

deinit :: proc() {
	if found_wall {
		clear_previous_wall(
			found_wall_intersect.pos,
			found_wall_intersect.axis,
		)
	}
}

update :: proc() {
	previous_position := position
	previous_side := side

	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	texture := texture
	if keyboard.is_key_down(.Key_Left_Control) {
		texture = .Drywall
	}
	delete_state_changed :=
		keyboard.is_key_press(.Key_Left_Control) ||
		keyboard.is_key_release(.Key_Left_Control)

	changed :=
		dirty ||
		previous_position != position ||
		previous_side != side ||
		delete_state_changed
	if changed {
		previous_found_wall := found_wall
		previous_found_wall_intersect := found_wall_intersect

		found_wall_intersect, found_wall = find_wall_intersect(position, side)
		clear_previous_wall(
			previous_found_wall_intersect.pos,
			previous_found_wall_intersect.axis,
		)

		if mouse.is_button_down(.Left) {
			found_wall_texture = texture
		} else {
			found_wall_texture = get_found_wall_texture()
		}

		paint_wall(
			found_wall_intersect.pos,
			found_wall_intersect.axis,
			texture,
		)

		wall.update_cutaways(true)
		if found_wall {
			wall.set_wall_up(
				found_wall_intersect.pos,
				found_wall_intersect.axis,
			)
		}
	} else if found_wall && mouse.is_button_press(.Left) {
		if keyboard.is_key_down(.Key_Left_Shift) {
			apply_flood_fill(texture)
		}
		found_wall_texture = texture
		wall.update_cutaways(true)
	}

	dirty = false
}

set_texture :: proc(tex: wall.Wall_Texture) {
	texture = tex
	dirty = true
}

apply_flood_fill :: proc(texture: wall.Wall_Texture) {
	side_map := wall.WALL_SIDE_MAP
	wall_side := side_map[found_wall_intersect.axis][camera.rotation]

	flood_fill(
		found_wall_intersect.pos,
		found_wall_intersect.axis,
		wall_side,
		found_wall_texture,
		texture,
	)
}

clear_previous_wall :: proc(
	previous_found_wall_position: glsl.ivec3,
	previous_found_wall_axis: wall.Wall_Axis,
) {
	paint_wall(
		previous_found_wall_position,
		previous_found_wall_axis,
		found_wall_texture,
	)
}

get_found_wall_texture :: proc() -> wall.Wall_Texture {
	side_map := wall.WALL_SIDE_MAP
	using found_wall_intersect
	switch axis {
	case .E_W:
		if w, ok := wall.get_east_west_wall(pos); ok {
			return w.textures[side_map[axis][camera.rotation]]
		}
	case .N_S:
		if w, ok := wall.get_north_south_wall(pos); ok {
			return w.textures[side_map[axis][camera.rotation]]
		}
	case .NW_SE:
		if w, ok := wall.get_north_west_south_east_wall(pos); ok {
			return w.textures[side_map[axis][camera.rotation]]
		}
	case .SW_NE:
		if w, ok := wall.get_south_west_north_east_wall(pos); ok {
			return w.textures[side_map[axis][camera.rotation]]
		}
	}
	return .Drywall
}

paint_wall :: proc(
	position: glsl.ivec3,
	axis: wall.Wall_Axis,
	texture: wall.Wall_Texture,
) {
	side_map := wall.WALL_SIDE_MAP
	switch axis {
	case .E_W:
		if w, ok := wall.get_east_west_wall(position); ok {
			w.textures[side_map[axis][camera.rotation]] = texture
			wall.set_east_west_wall(position, w)
		}
	case .N_S:
		if w, ok := wall.get_north_south_wall(position); ok {
			w.textures[side_map[axis][camera.rotation]] = texture
			wall.set_north_south_wall(position, w)
		}
	case .NW_SE:
		if w, ok := wall.get_north_west_south_east_wall(position); ok {
			w.textures[side_map[axis][camera.rotation]] = texture
			wall.set_north_west_south_east_wall(position, w)
		}
	case .SW_NE:
		if w, ok := wall.get_south_west_north_east_wall(position); ok {
			w.textures[side_map[axis][camera.rotation]] = texture
			wall.set_south_west_north_east_wall(position, w)
		}
	}
}

on_intersect :: proc(intersect: glsl.vec3) {
	position.x = i32(intersect.x + 0.5)
	position.y = floor.floor
	position.z = i32(intersect.z + 0.5)

	x := intersect.x - math.floor(intersect.x + 0.5)
	z := intersect.z - math.floor(intersect.z + 0.5)

	if x >= z && x <= -z {
		side = .South
	} else if z >= -x && z <= x {
		side = .East
	} else if x >= -z && x <= z {
		side = .North
	} else {
		side = .West
	}
}

find_wall_intersect :: proc(
	position: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
) -> (
	Wall_Intersect,
	bool,
) {
	switch camera.rotation {
	case .South_West:
		return find_south_west_wall_intersect(position, side)
	case .South_East:
		return find_south_east_wall_intersect(position, side)
	case .North_East:
		return find_north_east_wall_intersect(position, side)
	case .North_West:
		return find_north_west_wall_intersect(position, side)
	}

	return {}, false
}

find_south_west_wall_intersect :: proc(
	position: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
) -> (
	Wall_Intersect,
	bool,
) {
	wall_selection_distance := i32(WALL_SELECTION_DISTANCE)
	if wall.cutaway_state == .Down {
		wall_selection_distance = 1
	}
	switch side {
	case .South:
		for i in i32(0) ..< wall_selection_distance {
			if pos :=
				   position -
				    {
						   wall_selection_distance - i,
						   0,
						   wall_selection_distance - i,
					   }; wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - i,
					   }; wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - i,
					   }; wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
		}
	case .East:
		for i in i32(0) ..< wall_selection_distance {
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - i,
					   }; wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - i,
					   }; wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
		}
	case .North:
		for i in i32(0) ..< wall_selection_distance {
			if pos :=
				   position -
				    {
						   wall_selection_distance - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
		}
	case .West:
		for i in i32(0) ..< wall_selection_distance {
			if pos := position - {wall_selection_distance - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos :=
				   position -
				    {
						   wall_selection_distance - 1 - i,
						   0,
						   wall_selection_distance - 1 - i,
					   }; wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
		}
	}

	return {}, false
}

find_south_east_wall_intersect :: proc(
	position: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
) -> (
	Wall_Intersect,
	bool,
) {
	switch side {
	case .South:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position - {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
		}
	case .West:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position - {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
		}
	case .North:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
		}
	case .East:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
		}
	}

	return {}, false
}

find_north_east_wall_intersect :: proc(
	position: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
) -> (
	Wall_Intersect,
	bool,
) {
	switch side {
	case .South:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position + {3 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
		}
	case .East:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
		}
	case .North:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
		}
	case .West:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position + {3 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				return {pos, .NW_SE}, true
			}
		}
	}

	return {}, false
}

find_north_west_wall_intersect :: proc(
	position: glsl.ivec3,
	side: tile.Tile_Triangle_Side,
) -> (
	Wall_Intersect,
	bool,
) {
	switch side {
	case .South:
		for i in i32(0) ..< 4 {
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position + {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
		}
	case .West:
		for i in i32(0) ..< 4 {
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position + {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
		}
	case .North:
		for i in i32(0) ..< 4 {
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
		}
	case .East:
		for i in i32(0) ..< 4 {
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				return {pos, .N_S}, true
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				return {pos, .E_W}, true
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				return {pos, .SW_NE}, true
			}
		}
	}

	return {}, false
}
