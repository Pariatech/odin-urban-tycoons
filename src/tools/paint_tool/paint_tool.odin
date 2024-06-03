package paint_tool

import "core:log"
import "core:math"
import "core:math/linalg/glsl"

import "../../camera"
import "../../cursor"
import "../../floor"
import "../../mouse"
import "../../tile"
import "../../wall"

position: glsl.ivec3
side: tile.Tile_Triangle_Side

found_wall: bool
found_wall_position: glsl.ivec3
found_wall_axis: wall.Wall_Axis
found_wall_texture: wall.Wall_Texture

texture: wall.Wall_Texture = .Nyana

init :: proc() {

}

deinit :: proc() {

}

update :: proc() {
	previous_position := position
	previous_side := side

	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	if previous_position != position || previous_side != side {
		previous_found_wall := found_wall
		previous_found_wall_position := found_wall_position
		previous_found_wall_axis := found_wall_axis

		found_wall = find_wall_intersect()
		if previous_found_wall &&
		   (!found_wall ||
				   previous_found_wall_position != found_wall_position ||
				   previous_found_wall_axis != found_wall_axis) {
			paint_wall(
				previous_found_wall_position,
				previous_found_wall_axis,
				found_wall_texture,
			)
		}

		if found_wall &&
		   (!previous_found_wall ||
				   previous_found_wall_position != found_wall_position ||
				   previous_found_wall_axis != found_wall_axis) {
			if mouse.is_button_down(.Left) {
				found_wall_texture = texture
			} else {
				found_wall_texture = get_found_wall_texture()
			}
			paint_wall(found_wall_position, found_wall_axis, .Nyana)
		}
	} else if found_wall && mouse.is_button_press(.Left) {
		found_wall_texture = texture
	}
}

get_found_wall_texture :: proc() -> wall.Wall_Texture {
	side_map := wall.WALL_SIDE_MAP
	switch found_wall_axis {
	case .East_West:
		if w, ok := wall.get_east_west_wall(found_wall_position); ok {
			return w.textures[side_map[found_wall_axis][camera.rotation]]
		}
	case .North_South:
		if w, ok := wall.get_north_south_wall(found_wall_position); ok {
			return w.textures[side_map[found_wall_axis][camera.rotation]]
		}
	}
	return .Brick
}

paint_wall :: proc(
	position: glsl.ivec3,
	axis: wall.Wall_Axis,
	texture: wall.Wall_Texture,
) {
	side_map := wall.WALL_SIDE_MAP
	switch axis {
	case .East_West:
		if w, ok := wall.get_east_west_wall(position); ok {
			w.textures[side_map[axis][camera.rotation]] = texture
			wall.set_east_west_wall(position, w)
		}
	case .North_South:
		if w, ok := wall.get_north_south_wall(position); ok {
			w.textures[side_map[axis][camera.rotation]] = texture
			wall.set_north_south_wall(position, w)
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

find_wall_intersect :: proc() -> bool {
	switch camera.rotation {
	case .South_West:
		return find_south_west_wall_intersect()
	case .South_East:
		return find_south_east_wall_intersect()
	case .North_East:
		return find_north_east_wall_intersect()
	case .North_West:
		return find_north_west_wall_intersect()
	}

	return false
}

find_south_west_wall_intersect :: proc() -> bool {
	switch side {
	case .South, .East:
		if pos := position - {3, 0, 4}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {3, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {2, 0, 3}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {2, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {1, 0, 2}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {1, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {0, 0, 1}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if wall.has_east_west_wall(position) {
			found_wall_position = position
			found_wall_axis = .East_West
			return true
		}
	case .North, .West:
		if pos := position - {4, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {3, 0, 3}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {3, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {2, 0, 2}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {2, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {1, 0, 1}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {1, 0, 0}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if wall.has_north_south_wall(position) {
			found_wall_position = position
			found_wall_axis = .North_South
			return true
		}
	}

	return false
}

find_south_east_wall_intersect :: proc() -> bool {
	switch side {
	case .South, .West:
		if pos := position - {-4, 0, 4}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {-3, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {-3, 0, 3};
		   wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {-2, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {-2, 0, 2};
		   wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {-1, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {-1, 0, 1};
		   wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if wall.has_east_west_wall(position) {
			found_wall_position = position
			found_wall_axis = .East_West
			return true
		}
	case .North, .East:
		if pos := position - {-4, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {-4, 0, 3};
		   wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {-3, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {-3, 0, 2};
		   wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {-2, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position - {-2, 0, 1};
		   wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position - {-1, 0, 0}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if wall.has_north_south_wall(position) {
			found_wall_position = position
			found_wall_axis = .North_South
			return true
		}
	}

	return false
}

find_north_east_wall_intersect :: proc() -> bool {
	switch side {
	case .South, .East:
		if pos := position + {4, 0, 4}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {4, 0, 3}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {3, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {3, 0, 2}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {2, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {2, 0, 1}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {1, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {1, 0, 1}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		}
	case .North, .West:
		if pos := position + {4, 0, 4}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {3, 0, 4}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {3, 0, 3}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {2, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {2, 0, 2}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {1, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {1, 0, 1}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {0, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		}
	}

	return false
}

find_north_west_wall_intersect :: proc() -> bool {
	switch side {
	case .South, .West:
		if pos := position + {-4, 0, 4}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {-3, 0, 3}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {-3, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {-2, 0, 2}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {-2, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {-1, 0, 1}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {-1, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		}
	case .North, .East:
		if pos := position + {-3, 0, 4}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {-3, 0, 4}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {-2, 0, 3}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {-2, 0, 3}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {-1, 0, 2}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {-1, 0, 2}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		} else if pos := position + {0, 0, 1}; wall.has_north_south_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .North_South
			return true
		} else if pos := position + {0, 0, 1}; wall.has_east_west_wall(pos) {
			found_wall_position = pos
			found_wall_axis = .East_West
			return true
		}
	}

	return false
}
