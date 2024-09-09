package game

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../cursor"
import "../floor"
import "../mouse"

Object_Tool_Mode :: enum {
	Pick,
	Place,
	Move,
}

Object_Tool_Context :: struct {
	cursor_pos:                   glsl.vec3,
	placement_set:                Object_Placement_Set,
	object:                       Maybe(Object),
	tile_marker:                  Object,
	tile_draw_ids:                [dynamic]Object_Draw_Id,
	previous_object_under_cursor: Maybe(Object_Id),
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

	ctx.placement_set = {.Floor}

	// ctx.object_draw_id = create_object_draw(
	// 	object_draw_from_object(ctx.object),
	// )

	// create_object_tool_tile_marker_object_draws()
}

deinit_object_tool :: proc() {
	ctx := get_object_tool_context()

	delete(ctx.tile_draw_ids)
}

create_object_tool_tile_marker_object_draws :: proc() {
	ctx := get_object_tool_context()

	if object, ok := ctx.object.?; ok {
		for id in ctx.tile_draw_ids {
			delete_object_draw(id)
		}
		clear(&ctx.tile_draw_ids)

		for x in 0 ..< object.size.x {
			tx := x
			for z in 0 ..< object.size.z {
				tz := z
				switch object.orientation {
				case .South:
					tz = -z
				case .East:
					tx = z
					tz = x
				case .North:
					tx = -x
				case .West:
					tx = -z
					tz = -x
				}

				ctx.tile_marker.pos = object.pos + {f32(tx), 0, f32(tz)}
				append(
					&ctx.tile_draw_ids,
					create_object_draw(
						object_draw_from_object(ctx.tile_marker),
					),
				)
			}
		}
	}
}

update_object_tool_tile_marker_object_draws :: proc(light: glsl.vec3) {
	ctx := get_object_tool_context()

	if object, ok := ctx.object.?; ok {
		i: int = 0
		for x in 0 ..< object.size.x {
			tx := x
			for z in 0 ..< object.size.z {
				tz := z
				switch object.orientation {
				case .South:
					tz = -z
				case .East:
					tx = z
					tz = x
				case .North:
					tx = -x
				case .West:
					tx = -z
					tz = -x
				}

				ctx.tile_marker.pos = object.pos + {f32(tx), 0, f32(tz)}

				draw := object_draw_from_object(ctx.tile_marker)
				draw.light = light
				draw.id = ctx.tile_draw_ids[i]
				update_object_draw(draw)
				i += 1
			}
		}
	}
}

set_object_tool_model :: proc(model: string) {
	ctx := get_object_tool_context()
	if object, ok := &ctx.object.?; ok {
		object.model = model
		object.size = get_object_size(model)

		object.draw_id = create_object_draw(object_draw_from_object(object^))

		create_object_tool_tile_marker_object_draws()
	}
}

set_object_tool_texture :: proc(texture: string) {
	ctx := get_object_tool_context()
	if object, ok := &ctx.object.?; ok {
		object.texture = texture
	}
}

set_object_tool_placement_set :: proc(placement: Object_Placement_Set) {
	ctx := get_object_tool_context()
	ctx.placement_set = placement
}

set_object_tool_type :: proc(type: Object_Type) {
	ctx := get_object_tool_context()
	if object, ok := &ctx.object.?; ok {
		object.type = type
	}
}

object_tool_handle_object_under_cursor :: proc() {
	ctx := get_object_tool_context()
	if object_under_cursor, ok := get_object_under_cursor(); ok {
		if previous_object_under_cursor, ok := ctx.previous_object_under_cursor.?;
		   ok && previous_object_under_cursor != object_under_cursor {
			if previous_obj, ok := get_object_by_id(
				previous_object_under_cursor,
			); ok {
				mouse.set_cursor(.Arrow)
				// previous_obj.light = {1, 1, 1}
				update_object_draw(object_draw_from_object(previous_obj))
			}
		}
		if object, ok := get_object_by_id(object_under_cursor); ok {
			mouse.set_cursor(.Hand)
			// object.light = {0, 1, 0}
			update_object_draw(object_draw_from_object(object))
			ctx.previous_object_under_cursor = object_under_cursor
		}
	} else if object_under_cursor, ok := ctx.previous_object_under_cursor.?;
	   ok {
		if object, ok := get_object_by_id(object_under_cursor); ok {
			mouse.set_cursor(.Arrow)
			// object.light = {1, 1, 1}
			update_object_draw(object_draw_from_object(object))
			ctx.previous_object_under_cursor = nil
		}
	}
}

update_object_tool :: proc() {
	ctx := get_object_tool_context()
	cursor.on_tile_intersect(
		object_tool_on_intersect,
		floor.previous_floor,
		floor.floor,
	)

	object_tool_handle_object_under_cursor()

	if object, ok := &ctx.object.?; ok {
		previous_pos := object.pos
		previous_orientation := object.orientation
		if mouse.is_button_down(.Left) {
			mouse.set_cursor(.Rotate)

			dx := ctx.cursor_pos.x - object.pos.x
			dz := ctx.cursor_pos.z - object.pos.z

			if glsl.abs(dx) > 0.5 || glsl.abs(dz) > 0.5 {
				if glsl.abs(dx) > glsl.abs(dz) {
					if dx > 0 {
						object.orientation = .East
					} else {
						object.orientation = .West
					}
				} else {
					if dz > 0 {
						object.orientation = .North
					} else {
						object.orientation = .South
					}
				}
			}
		} else if mouse.is_button_release(.Left) {
			mouse.set_cursor(.Arrow)
			obj := object^
			obj.pos.x = glsl.floor(obj.pos.x + 0.5)
			obj.pos.z = glsl.floor(obj.pos.z + 0.5)
			obj.light = glsl.vec3{1, 1, 1}
			add_object(obj)
		} else {
			mouse.set_cursor(.Arrow)
			object.pos = ctx.cursor_pos
		}

		can_add: bool
		for placement in ctx.placement_set {
			object.placement = placement
			can_add = can_add_object(
				object.pos,
				object.model,
				object.type,
				object.orientation,
				object.placement,
			)

			if can_add {
				object.pos.x = glsl.floor(object.pos.x + 0.5)
				object.pos.z = glsl.floor(object.pos.z + 0.5)
				break
			} else if object.placement == .Wall && mouse.is_button_up(.Left) {
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

	for i in 0 ..< len(Object_Orientation) - 1 {
		if object, ok := &ctx.object.?; ok {
			obj := object^
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
				object.orientation = obj.orientation
				break
			}
		}
	}
}

update_wall_masks_on_object_placement :: proc(
	previous_pos: glsl.vec3,
	previous_orientation: Object_Orientation,
) {
	ctx := get_object_tool_context()

	if object, ok := ctx.object.?; ok {
		if object.type != .Window && object.type != .Door {
			return
		}

		previous_tile_pos := world_pos_to_tile_pos(previous_pos)
		current_tile_pos := world_pos_to_tile_pos(ctx.cursor_pos)
		if previous_tile_pos == current_tile_pos &&
		   object.orientation == previous_orientation {
			return
		}

		previous_obj := object
		previous_obj.pos = previous_pos
		previous_obj.orientation = previous_orientation

		if can_add_object(
			   previous_pos,
			   object.model,
			   object.type,
			   previous_orientation,
			   object.placement,
		   ) {
			set_wall_mask_from_object(previous_obj, .Full_Mask)
		}

		if can_add_object(
			   object.pos,
			   object.model,
			   object.type,
			   object.orientation,
			   object.placement,
		   ) {
			if object.type == .Window {
				mask := window_model_to_wall_mask_map[object.model]
				set_wall_mask_from_object(object, mask)
			} else {
				set_wall_mask_from_object(object, .Door_Opening)
			}
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
	if object, ok := &ctx.object.?; ok {
		if !can_add {
			object.light = {0.8, 0.2, 0.2}
			object.pos += {0, 0.01, 0}
		}

		if object.placement == .Counter || object.placement == .Table {
			object.pos.y += 0.8
		}

		draw := object_draw_from_object(object^)
		update_object_draw(draw)

		update_object_tool_tile_marker_object_draws(object.light)
	}

	return true
}
