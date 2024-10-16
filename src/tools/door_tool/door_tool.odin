package door_tool

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
import "../../game"
import "../paint_tool"

Texture :: enum {
	Wood,
	Dark_Wood,
}

door_billboard: Maybe(billboard.Key)
position: glsl.vec3
side: tile.Tile_Triangle_Side
texture: Texture

bound_wall: Maybe(glsl.ivec3)
bound_wall_axis: game.Wall_Axis

TEXTURE_BILLBOARD_TEXTURES_MAP ::
	[Texture][game.Wall_Axis][camera.Rotation]billboard.Texture_1x1 {
		.Wood = #partial {
			.E_W =  {
				.South_West = .Door_Wood_SW,
				.South_East = .Door_Wood_SE,
				.North_East = .Door_Wood_NE,
				.North_West = .Door_Wood_NW,
			},
			.N_S =  {
				.South_West = .Door_Wood_SE,
				.South_East = .Door_Wood_NE,
				.North_East = .Door_Wood_NW,
				.North_West = .Door_Wood_SW,
			},
		},
		.Dark_Wood = #partial {
			.E_W =  {
				.South_West = .Door_Dark_Wood_SW,
				.South_East = .Door_Dark_Wood_SE,
				.North_East = .Door_Dark_Wood_NE,
				.North_West = .Door_Dark_Wood_NW,
			},
			.N_S =  {
				.South_West = .Door_Dark_Wood_SE,
				.South_East = .Door_Dark_Wood_NE,
				.North_East = .Door_Dark_Wood_NW,
				.North_West = .Door_Dark_Wood_SW,
			},
		},
	}

init :: proc() {
	cursor.intersect_with_tiles(on_intersect, floor.floor)
    floor.show_markers = true
}

deinit :: proc() {
	if key, ok := door_billboard.?; ok {
		billboard.billboard_1x1_remove(key)
		door_billboard = nil
	}
}

update :: proc() {
	previous_position := position
	previous_side := side
	cursor.on_tile_intersect(on_intersect, floor.previous_floor, floor.floor)

	removing := keyboard.is_key_down(.Key_Left_Control)

	if removing {
		revert_bound_wall()
		bound_wall = nil
		if key, ok := door_billboard.?; ok {
			billboard.billboard_1x1_remove(key)
			door_billboard = nil
		}

		if mouse.is_button_press(.Left) {
			remove_door()
		} else {
			mark_door_removal(previous_position, previous_side)
		}
	} else if key, ok := &door_billboard.?; ok {
		revert_bound_wall()
		if !bind_to_wall(key) {
	        texmap := TEXTURE_BILLBOARD_TEXTURES_MAP
			billboard.billboard_1x1_set_texture(key^, texmap[texture][.E_W][.South_West])
			billboard.billboard_1x1_move(key, position)
			billboard.billboard_1x1_set_light(key^, {1, .5, .5})
			bound_wall = nil
		} else if mouse.is_button_press(.Left) {
			door_billboard = nil
			bound_wall = nil
		}
	} else {
		new_key := billboard.Key {
				pos  = position,
				type = .Door,
			}

		billboard.billboard_1x1_set(
			new_key,
			 {
				light = {1, 0.5, 0.5},
				texture = .Door_Wood_SW,
				depth_map = .Door_Wood_SW,
			},
		)

		door_billboard = new_key
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

remove_door :: proc() {
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

		if billboard.has_billboard_1x1({pos = fpos, type = .Door}) {
			billboard.billboard_1x1_remove({pos = fpos, type = .Door})
			w, _ := game.get_wall(intersect.pos, intersect.axis)
			w.mask = .Full_Mask
			game.set_wall(intersect.pos, intersect.axis, w)
		}
	}
}

set_door_light :: proc(
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

		key := billboard.Key {
			pos  = fpos,
			type = .Door,
		}
		if billboard.has_billboard_1x1(key) {
			billboard.billboard_1x1_set_light(key, light)
		}
	}
}

mark_door_removal :: proc(
	previous_position: glsl.vec3,
	previous_side: tile.Tile_Triangle_Side,
) {
	set_door_light(previous_position, previous_side, {1, 1, 1})
	set_door_light(position, side, {1, .5, .5})
}

revert_bound_wall :: proc() {
	if pos, ok := bound_wall.?; ok {
		w, _ := game.get_wall(pos, bound_wall_axis)
		w.mask = .Full_Mask
		game.set_wall(pos, bound_wall_axis, w)
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
		   billboard.has_billboard_1x1({pos = fpos, type = .Door})) ||
	   billboard.has_billboard_1x1({pos = fpos, type = window_type}) {
		return false
	}

	texmap := TEXTURE_BILLBOARD_TEXTURES_MAP

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

	if w, ok := game.get_wall(pos, intersect.axis); ok {
		w := w
		w.mask = .Door_Opening
		game.set_wall(pos, intersect.axis, w)
	}

	return true
}
