package window_tool

import "core:log"
import "core:math"
import "core:math/linalg/glsl"

import "../../billboard"
import "../../camera"
import "../../cursor"
import "../../floor"
import "../../keyboard"
import "../../mouse"
import "../../terrain"
import "../../tile"
import "../../wall"
import "../paint_tool"

Texture :: enum {
	Wood,
	Dark_Wood,
}

TEXTURE_BILLBOARD_TEXTURES_MAP ::
	[Texture][wall.Wall_Axis][camera.Rotation]billboard.Texture_1x1 {
		.Wood = #partial {
			.E_W =  {
				.South_West = .Window_Wood_SW,
				.South_East = .Window_Wood_SE,
				.North_East = .Window_Wood_NE,
				.North_West = .Window_Wood_NW,
			},
			.N_S =  {
				.South_West = .Window_Wood_SE,
				.South_East = .Window_Wood_NE,
				.North_East = .Window_Wood_NW,
				.North_West = .Window_Wood_SW,
			},
		},
		.Dark_Wood = #partial {
			.E_W =  {
				.South_West = .Window_Dark_Wood_SW,
				.South_East = .Window_Dark_Wood_SE,
				.North_East = .Window_Dark_Wood_NE,
				.North_West = .Window_Dark_Wood_NW,
			},
			.N_S =  {
				.South_West = .Window_Dark_Wood_SE,
				.South_East = .Window_Dark_Wood_NE,
				.North_East = .Window_Dark_Wood_NW,
				.North_West = .Window_Dark_Wood_SW,
			},
		},
	}

cursor_billboard: Maybe(billboard.Key)
position: glsl.vec3
side: tile.Tile_Triangle_Side
texture: Texture

bound_wall: Maybe(glsl.ivec3)
bound_wall_axis: wall.Wall_Axis

init :: proc() {
	cursor.intersect_with_tiles(on_intersect, floor.floor)
}

deinit :: proc() {
	if key, ok := cursor_billboard.?; ok {
		billboard.billboard_1x1_remove(key)
		cursor_billboard = nil
	}
}

update :: proc() {
	previous_position := position
	previous_side := side
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	removing := keyboard.is_key_down(.Key_Left_Control)

	texmap := TEXTURE_BILLBOARD_TEXTURES_MAP
	if removing {
		revert_bound_wall()
		bound_wall = nil
		if key, ok := cursor_billboard.?; ok {
			billboard.billboard_1x1_remove(key)
			cursor_billboard = nil
		}

		if mouse.is_button_press(.Left) {
			remove_window()
		} else {
			mark_window_removal(previous_position, previous_side)
		}
	} else if key, ok := &cursor_billboard.?; ok {
		revert_bound_wall()
		if !bind_to_wall(key) {
			billboard.billboard_1x1_set_texture(
				key^,
				texmap[texture][.E_W][.South_West],
			)
			billboard.billboard_1x1_move(key, position)
			billboard.billboard_1x1_set_light(key^, {1, .5, .5})
			bound_wall = nil
		} else if mouse.is_button_press(.Left) {
			cursor_billboard = nil
			bound_wall = nil
		}
	} else {
		new_key := billboard.Key {
				pos  = position,
				type = .Window_E_W,
			}

		billboard.billboard_1x1_set(
			new_key,
			 {
				light = {1, 0.5, 0.5},
				texture = texmap[texture][.E_W][.South_West],
				depth_map = texmap[texture][.E_W][.South_West],
			},
		)

		cursor_billboard = new_key
	}
}

on_intersect :: proc(intersect: glsl.vec3) {
	position = intersect

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

remove_window :: proc() {
	pos := glsl.ivec3 {
		i32(position.x + 0.5),
		floor.floor,
		i32(position.z + 0.5),
	}

	if intersect, ok := paint_tool.find_wall_intersect(pos, side); ok {
		pos = intersect.pos
		fpos := glsl.vec3 {
			f32(pos.x),
			terrain.get_tile_height(int(pos.x), int(pos.z)),
			f32(pos.z),
		}

		type: billboard.Billboard_Type = .Window_E_W
		if intersect.axis == .N_S {
			type = .Window_N_S
		}

		if billboard.has_billboard_1x1({pos = fpos, type = type}) {
			billboard.billboard_1x1_remove({pos = fpos, type = type})
			w, _ := wall.get_wall(intersect.pos, intersect.axis)
			w.mask = .Full_Mask
			wall.set_wall(intersect.pos, intersect.axis, w)
		}
	}
}

set_window_light :: proc(
	position: glsl.vec3,
	side: tile.Tile_Triangle_Side,
	light: glsl.vec3,
) {
	pos := glsl.ivec3 {
		i32(position.x + 0.5),
		floor.floor,
		i32(position.z + 0.5),
	}

	if intersect, ok := paint_tool.find_wall_intersect(pos, side); ok {
		pos = intersect.pos
		fpos := glsl.vec3 {
			f32(pos.x),
			terrain.get_tile_height(int(pos.x), int(pos.z)),
			f32(pos.z),
		}

		type: billboard.Billboard_Type = .Window_E_W
		if intersect.axis == .N_S {
			type = .Window_N_S
		}

		key := billboard.Key {
			pos  = fpos,
			type = type,
		}
		if billboard.has_billboard_1x1(key) {
			billboard.billboard_1x1_set_light(key, light)
		}
	}
}

mark_window_removal :: proc(
	previous_position: glsl.vec3,
	previous_side: tile.Tile_Triangle_Side,
) {
	set_window_light(previous_position, previous_side, {1, 1, 1})
	set_window_light(position, side, {1, .5, .5})
}

revert_bound_wall :: proc() {
	if pos, ok := bound_wall.?; ok {
		w, _ := wall.get_wall(pos, bound_wall_axis)
		w.mask = .Full_Mask
		wall.set_wall(pos, bound_wall_axis, w)
	}
}

bind_to_wall :: proc(key: ^billboard.Key) -> bool {
	pos := glsl.ivec3 {
		i32(position.x + 0.5),
		floor.floor,
		i32(position.z + 0.5),
	}

	intersect := paint_tool.find_wall_intersect(pos, side) or_return

	pos = intersect.pos

	fpos := glsl.vec3 {
		f32(pos.x),
		terrain.get_tile_height(int(pos.x), int(pos.z)),
		f32(pos.z),
	}

	window_type: billboard.Billboard_Type = .Window_E_W
	if intersect.axis == .N_S {
		window_type = .Window_N_S
	}

	if ((bound_wall == nil || bound_wall.? != pos) &&
		   billboard.has_billboard_1x1({pos = fpos, type = window_type})) ||
	   billboard.has_billboard_1x1({pos = fpos, type = .Door}) {
		return false
	}

	texmap := TEXTURE_BILLBOARD_TEXTURES_MAP

	if window_type != key.type {
		billboard.billboard_1x1_remove(key^)
		key.type = window_type
		billboard.billboard_1x1_set(
			key^,
			 {
				light = {1, 0.5, 0.5},
				texture = texmap[texture][intersect.axis][.South_West],
				depth_map = texmap[texture][intersect.axis][.South_West],
			},
		)
	}

	switch intersect.axis {
	case .E_W, .N_S:
		billboard.billboard_1x1_set_texture(
			key^,
			texmap[texture][intersect.axis][camera.rotation],
		)
	case .NW_SE, .SW_NE:
		return false
	}

	bound_wall = pos
	bound_wall_axis = intersect.axis

	billboard.billboard_1x1_move(key, fpos)
	billboard.billboard_1x1_set_light(key^, {1, 1, 1})

	if w, ok := wall.get_wall(pos, intersect.axis); ok {
		w := w
		w.mask = .Window_Opening
		wall.set_wall(pos, intersect.axis, w)
	}

	return true
}
