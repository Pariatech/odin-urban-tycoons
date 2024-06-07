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

position: glsl.ivec3
side: tile.Tile_Triangle_Side

found_wall: bool
found_wall_position: glsl.ivec3
found_wall_axis: wall.Wall_Axis
found_wall_texture: wall.Wall_Texture

found_diagonal_wall: bool
found_diagonal_wall_axis: wall.Diagonal_Wall_Axis

texture: wall.Wall_Texture = .Nyana
dirty: bool

init :: proc() {

}

deinit :: proc() {

}

update :: proc() {
	previous_position := position
	previous_side := side

	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	if dirty || previous_position != position || previous_side != side {
		previous_found_wall := found_wall
		previous_found_wall_position := found_wall_position
		previous_found_wall_axis := found_wall_axis
		previous_found_diagonal_wall := found_diagonal_wall
		previous_found_diagonal_wall_axis := found_diagonal_wall_axis

		found_diagonal_wall = false

		find_wall_intersect()
		clear_previous_wall(
			previous_found_wall_position,
			previous_found_wall_axis,
			previous_found_diagonal_wall,
			previous_found_diagonal_wall_axis,
		)

		if mouse.is_button_down(.Left) {
			found_wall_texture = texture
		} else {
			found_wall_texture = get_found_wall_texture()
		}

		if found_diagonal_wall {
			paint_diagonal_wall(
				found_wall_position,
				found_diagonal_wall_axis,
				texture,
			)
		} else {
			paint_wall(found_wall_position, found_wall_axis, texture)
		}
	} else if (found_wall || found_diagonal_wall) &&
	   mouse.is_button_press(.Left) {
		if keyboard.is_key_down(.Key_Left_Shift) {
			apply_flood_fill()
		}
		found_wall_texture = texture
	}

    dirty = false
}

set_texture :: proc(tex: wall.Wall_Texture) {
    texture = tex
    dirty = true
}

apply_flood_fill :: proc() {
	type: Wall_Type
	wall_side: wall.Wall_Side

	if found_diagonal_wall {
		switch found_diagonal_wall_axis {
		case .NW_SE:
			type = .NW_SE
		case .SW_NE:
			type = .SW_NE
		}

		side_map := wall.DIAGONAL_WALL_SIDE_MAP
		wall_side = side_map[found_diagonal_wall_axis][camera.rotation]
	} else {
		switch found_wall_axis {
		case .E_W:
			type = .E_W
		case .N_S:
			type = .N_S
		}

		side_map := wall.WALL_SIDE_MAP
		wall_side = side_map[found_wall_axis][camera.rotation]
	}

	flood_fill(
		found_wall_position,
		type,
		wall_side,
		found_wall_texture,
		texture,
	)
}

clear_previous_wall :: proc(
	previous_found_wall_position: glsl.ivec3,
	previous_found_wall_axis: wall.Wall_Axis,
	previous_found_diagonal_wall: bool,
	previous_found_diagonal_wall_axis: wall.Diagonal_Wall_Axis,
) {
	if previous_found_diagonal_wall {
		paint_diagonal_wall(
			previous_found_wall_position,
			previous_found_diagonal_wall_axis,
			found_wall_texture,
		)
	} else {
		paint_wall(
			previous_found_wall_position,
			previous_found_wall_axis,
			found_wall_texture,
		)
	}
}

get_found_wall_texture :: proc() -> wall.Wall_Texture {
	if found_diagonal_wall {
		side_map := wall.DIAGONAL_WALL_SIDE_MAP
		switch found_diagonal_wall_axis {
		case .NW_SE:
			if w, ok := wall.get_north_west_south_east_wall(
				found_wall_position,
			); ok {
				return(
					w.textures[side_map[found_diagonal_wall_axis][camera.rotation]] \
				)
			}
		case .SW_NE:
			if w, ok := wall.get_south_west_north_east_wall(
				found_wall_position,
			); ok {
				return(
					w.textures[side_map[found_diagonal_wall_axis][camera.rotation]] \
				)
			}
		}
	} else {
		side_map := wall.WALL_SIDE_MAP
		switch found_wall_axis {
		case .E_W:
			if w, ok := wall.get_east_west_wall(found_wall_position); ok {
				return w.textures[side_map[found_wall_axis][camera.rotation]]
			}
		case .N_S:
			if w, ok := wall.get_north_south_wall(found_wall_position); ok {
				return w.textures[side_map[found_wall_axis][camera.rotation]]
			}
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
	}
}

paint_diagonal_wall :: proc(
	position: glsl.ivec3,
	axis: wall.Diagonal_Wall_Axis,
	texture: wall.Wall_Texture,
) {
	side_map := wall.DIAGONAL_WALL_SIDE_MAP
	switch axis {
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

find_wall_intersect :: proc() {
	switch camera.rotation {
	case .South_West:
		find_south_west_wall_intersect()
	case .South_East:
		find_south_east_wall_intersect()
	case .North_East:
		find_north_east_wall_intersect()
	case .North_West:
		find_north_west_wall_intersect()
	}
}

find_south_west_wall_intersect :: proc() {
	switch side {
	case .South:
		for i in i32(0) ..< 4 {
			if pos := position - {4 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position - {3 - i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position - {3 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position - {3 - i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
		}
	case .East:
		for i in i32(0) ..< 4 {
			if pos := position - {3 - i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position - {3 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position - {3 - i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position - {3 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
		}
	case .North:
		for i in i32(0) ..< 4 {
			if pos := position - {4 - i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position - {4 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position - {3 - i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position - {3 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
		}
	case .West:
		for i in i32(0) ..< 4 {
			if pos := position - {4 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position - {4 - i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position - {4 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position - {3 - i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
		}
	}
}

find_south_east_wall_intersect :: proc() {
	switch side {
	case .South:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position - {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
		}
	case .West:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position - {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
		}
	case .North:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position - {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
		}
	case .East:
		for i in i32(0) ..< 4 {
			if pos := position - {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position - {-4 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
		}
	}
}

find_north_east_wall_intersect :: proc() {
	switch side {
	case .South:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position + {3 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
		}
	case .East:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position + {4 - i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
		}
	case .North:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
		}
	case .West:
		for i in i32(0) ..< 4 {
			if pos := position + {4 - i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
			if pos := position + {3 - i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position + {3 - i, 0, 3 - i};
			   wall.has_north_west_south_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .NW_SE
				found_diagonal_wall = true
				return
			}
		}
	}
}

find_north_west_wall_intersect :: proc() {
	switch side {
	case .South:
		for i in i32(0) ..< 4 {
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position + {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
		}
	case .West:
		for i in i32(0) ..< 4 {
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position + {-4 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
		}
	case .North:
		for i in i32(0) ..< 4 {
			if pos := position + {-4 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
		}
	case .East:
		for i in i32(0) ..< 4 {
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_north_south_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .N_S
				found_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 4 - i};
			   wall.has_east_west_wall(pos) {
				found_wall_position = pos
				found_wall_axis = .E_W
				found_wall = true
				return
			}
			if pos := position + {-3 + i, 0, 3 - i};
			   wall.has_south_west_north_east_wall(pos) {
				found_wall_position = pos
				found_diagonal_wall_axis = .SW_NE
				found_diagonal_wall = true
				return
			}
		}
	}
}
