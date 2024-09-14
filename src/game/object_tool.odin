package game

import "core:log"
import "core:math/linalg"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../cursor"
import "../floor"
import "../keyboard"
import "../mouse"

Object_Tool_Mode :: enum {
	Pick,
	Place,
	Move,
	Rotate,
}

Object_Tool_Context :: struct {
	cursor_pos:                   glsl.vec3,
	pos_offset:                   glsl.vec3,
	object:                       Object,
	original_object:              Object,
	tile_marker:                  Object,
	tile_draw_ids:                [dynamic]Object_Draw_Id,
	previous_object_under_cursor: Maybe(Object_Id),
	previous_mode:                Object_Tool_Mode,
	mode:                         Object_Tool_Mode,
}

init_object_tool :: proc() {
	ctx := get_object_tool_context()
	// ctx.object.type = .Table
	// ctx.object.light = {1, 1, 1}
	// ctx.object.model = PLANK_TABLE_6PLACES_MODEL
	// ctx.object.size = get_object_size(ctx.object.model)
	// ctx.object.texture = PLANK_TABLE_6PLACES_TEXTURE
	// ctx.object.placement = .Floor
	// ctx.object.orientation = .North

	ctx.tile_marker.model = "Tile_Marker.Bake"
	ctx.tile_marker.texture = "objects/Tile_Marker.Bake.png"
	ctx.tile_marker.light = {1, 1, 1}

	// ctx.object_draw_id = create_object_draw(
	// 	object_draw_from_object(ctx.object),
	// )

	// create_object_tool_tile_marker_object_draws()
}

deinit_object_tool :: proc() {
	ctx := get_object_tool_context()

	delete(ctx.tile_draw_ids)
}

clear_object_tool_tile_marker_object_draws :: proc() {
	ctx := get_object_tool_context()

	for id in ctx.tile_draw_ids {
		delete_object_draw(id)
	}

	clear(&ctx.tile_draw_ids)
}

create_object_tool_tile_marker_object_draws :: proc() {
	ctx := get_object_tool_context()

	clear_object_tool_tile_marker_object_draws()

	it := Object_Tiles_Iterator {
		object = ctx.object,
	}
	for pos in next_object_tile_pos(&it) {
		ctx.tile_marker.pos = pos
		append(
			&ctx.tile_draw_ids,
			create_object_draw(object_draw_from_object(ctx.tile_marker)),
		)
	}
}

update_object_tool_tile_marker_object_draws :: proc(light: glsl.vec3) {
	ctx := get_object_tool_context()

	it := make_object_tiles_iterator(ctx.object)
	for pos, i in next_object_tile_pos(&it) {
		ctx.tile_marker.pos = pos
		draw := object_draw_from_object(ctx.tile_marker)
		draw.light = light
		draw.id = ctx.tile_draw_ids[i]
		update_object_draw(draw)
	}
}

set_object_tool_object :: proc(object: Object) -> (ok: bool = true) {
	object := object
	ctx := get_object_tool_context()
	if ctx.mode == .Move || ctx.mode == .Rotate {
		return false
	}

	if ctx.mode == .Place {
		object.draw_id = ctx.object.draw_id
		update_object_draw(object_draw_from_object(object))
	} else {
		object.draw_id = create_object_draw(object_draw_from_object(object))
	}

	ctx.mode = .Place
	ctx.object = object
	ctx.pos_offset = {}

	create_object_tool_tile_marker_object_draws()
	return
}

object_tool_pick_object :: proc() {
	ctx := get_object_tool_context()

	if object_under_cursor, ok := get_object_under_cursor(); ok {
		if previous_object_under_cursor, ok := ctx.previous_object_under_cursor.?;
		   ok && previous_object_under_cursor != object_under_cursor {
			if previous_obj, ok := get_object_by_id(
				previous_object_under_cursor,
			); ok {
				mouse.set_cursor(.Arrow)
				previous_obj.light = {1, 1, 1}
				update_object_draw(object_draw_from_object(previous_obj))
			}
		}
		if object, ok := get_object_by_id(object_under_cursor); ok {
			if mouse.is_button_press(.Left) {
				ctx.previous_mode = ctx.mode
				ctx.mode = .Rotate
				mouse.set_cursor(.Rotate)
				ctx.object = object
				ctx.original_object = object
				cursor_tile_pos := world_pos_to_tile_pos(ctx.cursor_pos)
				object_tile_pos := world_pos_to_tile_pos(ctx.object.pos)
				ctx.pos_offset =  {
					f32(cursor_tile_pos.x - object_tile_pos.x),
					0,
					f32(cursor_tile_pos.y - object_tile_pos.y),
				}
				delete_object_by_id(object_under_cursor)
				ctx.object.draw_id = create_object_draw(
					object_draw_from_object(object),
				)
				create_object_tool_tile_marker_object_draws()
				ctx.previous_object_under_cursor = nil
			} else {
				mouse.set_cursor(.Hand)
				object.light = {1.5, 1.5, 1.5}
				update_object_draw(object_draw_from_object(object))
				ctx.previous_object_under_cursor = object_under_cursor
			}
		}
	} else if object_under_cursor, ok := ctx.previous_object_under_cursor.?;
	   ok {
		if object, ok := get_object_by_id(object_under_cursor); ok {
			mouse.set_cursor(.Arrow)
			object.light = {1, 1, 1}
			update_object_draw(object_draw_from_object(object))
			// ctx.previous_object_under_cursor = nil
		}
	}
}

object_tool_place_object :: proc() {
	ctx := get_object_tool_context()

	if keyboard.is_key_press(.Key_Escape) {
		ctx.previous_mode = ctx.mode
		ctx.mode = .Pick
	} else if mouse.is_button_press(.Left) {
		ctx.previous_mode = .Place
		ctx.mode = .Rotate
		mouse.set_cursor(.Rotate)
	} else {
		ctx.object.pos = ctx.cursor_pos - ctx.pos_offset
	}
}

object_tool_move_object :: proc() {
	ctx := get_object_tool_context()

	if keyboard.is_key_press(.Key_Escape) {
		ctx.previous_mode = ctx.mode
		ctx.mode = .Pick
		add_object(ctx.original_object)
	} else if mouse.is_button_press(.Left) {
		ctx.previous_mode = ctx.mode
		ctx.mode = .Rotate
		mouse.set_cursor(.Rotate)
	} else {
		ctx.object.pos = ctx.cursor_pos - ctx.pos_offset
	}
}

object_tool_rotate_object :: proc() {
	ctx := get_object_tool_context()

	dx := ctx.cursor_pos.x - (ctx.object.pos.x + ctx.pos_offset.x)
	dz := ctx.cursor_pos.z - (ctx.object.pos.z + ctx.pos_offset.z)
	outside_tile := glsl.abs(dx) > 0.5 || glsl.abs(dz) > 0.5
	if keyboard.is_key_press(.Key_Escape) {
		if ctx.previous_mode == .Move {
			add_object(ctx.original_object)
		}
		ctx.previous_mode = ctx.mode
		ctx.mode = .Pick
	} else if mouse.is_button_down(.Left) {
		if outside_tile {
			if glsl.abs(dx) > glsl.abs(dz) {
				if dx > 0 {
					ctx.object.orientation = .East
				} else {
					ctx.object.orientation = .West
				}
			} else {
				if dz > 0 {
					ctx.object.orientation = .North
				} else {
					ctx.object.orientation = .South
				}
			}
		}
	} else {
		if ctx.previous_mode == .Pick && !outside_tile {
			ctx.previous_mode = ctx.mode
			ctx.mode = .Move
			mouse.set_cursor(.Hand_Closed)
		} else {
			ctx.previous_mode = ctx.mode
			ctx.mode = .Pick
			id, _ := add_object(ctx.object)
            delete_object_draw(ctx.object.draw_id)
	        clear_object_tool_tile_marker_object_draws()
            ctx.object = {}
            ctx.previous_object_under_cursor = id
			mouse.set_cursor(.Arrow)
		}
	}
}

update_object_tool :: proc() {
	ctx := get_object_tool_context()

	previous_pos := ctx.object.pos
	previous_orientation := ctx.object.orientation

	cursor.on_tile_intersect(
		object_tool_on_intersect,
		floor.previous_floor,
		floor.floor,
	)

	switch ctx.mode {
	case .Pick:
		object_tool_pick_object()
	case .Place:
		object_tool_place_object()
	case .Move:
		object_tool_move_object()
	case .Rotate:
		object_tool_rotate_object()
	}

	if ctx.mode != .Pick {
		can_add: bool
		for placement in ctx.object.placement_set {
			ctx.object.placement = placement
			can_add = can_add_object(
				ctx.object.pos,
				ctx.object.model,
				ctx.object.type,
				ctx.object.orientation,
				ctx.object.placement,
			)

			if can_add {
				ctx.object.pos.x = glsl.floor(ctx.object.pos.x + 0.5)
				ctx.object.pos.z = glsl.floor(ctx.object.pos.z + 0.5)
				break
			} else if ctx.object.placement == .Wall &&
			   mouse.is_button_up(.Left) {
				snap_wall_object()
				break
			}
		}

		update_wall_masks_on_object_placement(
			previous_pos,
			previous_orientation,
		)

		draw_object_tool(can_add)
	}
}

snap_wall_object :: proc() {
	ctx := get_object_tool_context()

	for i in 0 ..< len(Object_Orientation) {
		obj := ctx.object
		obj.orientation = Object_Orientation(
			(int(obj.orientation) + i) % len(Object_Orientation),
		)

		if can_add_object(
			   obj.pos,
			   obj.model,
			   obj.type,
			   obj.orientation,
			   obj.placement,
		   ) {
			ctx.object.orientation = obj.orientation
			break
		}
	}
}

update_wall_masks_on_object_placement :: proc(
	previous_pos: glsl.vec3,
	previous_orientation: Object_Orientation,
) {
	ctx := get_object_tool_context()

	if ctx.object.type != .Window && ctx.object.type != .Door {
		return
	}

	previous_tile_pos := world_pos_to_tile_pos(previous_pos)
	current_tile_pos := world_pos_to_tile_pos(ctx.cursor_pos)
	if previous_tile_pos == current_tile_pos &&
	   ctx.object.orientation == previous_orientation {
		return
	}

	previous_obj := ctx.object
	previous_obj.pos = previous_pos
	previous_obj.orientation = previous_orientation

	if can_add_object(
		   previous_pos,
		   ctx.object.model,
		   ctx.object.type,
		   previous_orientation,
		   ctx.object.placement,
	   ) {
		set_wall_mask_from_object(previous_obj, .Full_Mask)
	}

	if can_add_object(
		   ctx.object.pos,
		   ctx.object.model,
		   ctx.object.type,
		   ctx.object.orientation,
		   ctx.object.placement,
	   ) {
		if ctx.object.type == .Window {
			mask := window_model_to_wall_mask_map[ctx.object.model]
			set_wall_mask_from_object(ctx.object, mask)
		} else {
			set_wall_mask_from_object(ctx.object, .Door_Opening)
		}
	}
}

set_wall_mask_from_object :: proc(obj: Object, mask: Wall_Mask_Texture) {
	tile_pos := world_pos_to_tile_pos(obj.pos)
	chunk_pos := world_pos_to_chunk_pos(obj.pos)

	for x in 0 ..< obj.size.x {
		tx := x
		tz: i32 = 0
		#partial switch obj.orientation {
		case .East:
			tx = 0
			tz = x
		case .North:
			tx = -x
		case .West:
			tx = 0
			tz = -x
		}

		tpos := obj.pos + {f32(tx), 0, f32(tz)}

		tile_pos := world_pos_to_tile_pos(tpos)
		wall_pos: glsl.ivec3 = {tile_pos.x, chunk_pos.y, tile_pos.y}
		axis: Wall_Axis

		switch obj.orientation {
		case .East:
			wall_pos.x += 1
			axis = .N_S
		case .West:
			axis = .N_S
		case .South:
			axis = .E_W
		case .North:
			wall_pos.z += 1
			axis = .E_W
		}

		w, _ := get_wall(wall_pos, axis)
		w.mask = mask
		set_wall(wall_pos, axis, w)
	}
}

object_tool_on_intersect :: proc(intersect: glsl.vec3) {
	ctx := get_object_tool_context()
	ctx.cursor_pos = intersect
}

draw_object_tool :: proc(can_add: bool) -> bool {
	ctx := get_object_tool_context()
	object := ctx.object

	if !can_add {
		object.light = {0.8, 0.2, 0.2}
		object.pos += {0, 0.01, 0}
	} else {
		object.light = {1, 1, 1}
	}

	if object.placement == .Counter || object.placement == .Table {
		object.pos.y += 0.8
	}

	draw := object_draw_from_object(object)
	update_object_draw(draw)

	update_object_tool_tile_marker_object_draws(object.light)

	return true
}
