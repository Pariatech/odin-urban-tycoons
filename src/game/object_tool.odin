package game

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../cursor"
import "../floor"
import "../mouse"

Object_Tool_Context :: struct {
	cursor_pos:     glsl.vec3,
	placement_set:  Object_Placement_Set,
	object:         Object,
	tile_marker:    Object,
	object_draw_id: Object_Draw_Id,
	tile_draw_ids:  [dynamic]Object_Draw_Id,
}

init_object_tool :: proc() {
	ctx := get_object_tool_context()
	ctx.object.type = .Table
	ctx.object.light = {1, 1, 1}
	ctx.object.model = PLANK_TABLE_6PLACES_MODEL
	ctx.object.size = get_object_size(ctx.object.model)
	ctx.object.texture = PLANK_TABLE_6PLACES_TEXTURE
	ctx.object.placement = .Floor
	ctx.object.orientation = .North

	ctx.tile_marker.model = "Tile_Marker.Bake"
	ctx.tile_marker.texture = "objects/Tile_Marker.Bake.png"
	ctx.tile_marker.light = {1, 1, 1}

    ctx.placement_set = {.Floor}

	ctx.object_draw_id = create_object_draw(
		object_draw_from_object(ctx.object),
	)

	create_object_tool_tile_marker_object_draws()
}

deinit_object_tool :: proc() {
	ctx := get_object_tool_context()

	delete(ctx.tile_draw_ids)
}

create_object_tool_tile_marker_object_draws :: proc() {
	ctx := get_object_tool_context()
	for id in ctx.tile_draw_ids {
		delete_object_draw(id)
	}
	clear(&ctx.tile_draw_ids)

	for x in 0 ..< ctx.object.size.x {
		tx := x
		for z in 0 ..< ctx.object.size.z {
			tz := z
			switch ctx.object.orientation {
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

			ctx.tile_marker.pos = ctx.object.pos + {f32(tx), 0, f32(tz)}
			append(
				&ctx.tile_draw_ids,
				create_object_draw(object_draw_from_object(ctx.tile_marker)),
			)
		}
	}
}

update_object_tool_tile_marker_object_draws :: proc(light: glsl.vec3) {
	ctx := get_object_tool_context()
	i: int = 0
	for x in 0 ..< ctx.object.size.x {
		tx := x
		for z in 0 ..< ctx.object.size.z {
			tz := z
			switch ctx.object.orientation {
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

			ctx.tile_marker.pos = ctx.object.pos + {f32(tx), 0, f32(tz)}

			draw := object_draw_from_object(ctx.tile_marker)
			draw.light = light
			draw.id = ctx.tile_draw_ids[i]
			update_object_draw(draw)
			i += 1
		}
	}
}

set_object_tool_model :: proc(model: string) {
	ctx := get_object_tool_context()
	ctx.object.model = model
	ctx.object.size = get_object_size(model)

	create_object_tool_tile_marker_object_draws()
}

set_object_tool_texture :: proc(texture: string) {
	ctx := get_object_tool_context()
	ctx.object.texture = texture
}

set_object_tool_placement_set :: proc(placement: Object_Placement_Set) {
	ctx := get_object_tool_context()
	ctx.placement_set = placement
}

set_object_tool_type :: proc(type: Object_Type) {
	ctx := get_object_tool_context()
	ctx.object.type = type
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

	if mouse.is_button_down(.Left) {
		mouse.set_cursor(.Rotate)

		dx := ctx.cursor_pos.x - ctx.object.pos.x
		dz := ctx.cursor_pos.z - ctx.object.pos.z

		if glsl.abs(dx) > 0.5 || glsl.abs(dz) > 0.5 {
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
	} else if mouse.is_button_release(.Left) {
		mouse.set_cursor(.Arrow)
		obj := ctx.object
		obj.pos.x = glsl.floor(obj.pos.x + 0.5)
		obj.pos.z = glsl.floor(obj.pos.z + 0.5)
		obj.light = glsl.vec3{1, 1, 1}
		add_object(obj)
	} else {
		mouse.set_cursor(.Arrow)
		ctx.object.pos = ctx.cursor_pos
	}

	can_add: bool
	for placement in ctx.placement_set {
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
		} else if ctx.object.placement == .Wall && mouse.is_button_up(.Left) {
			snap_wall_object()
			break
		}
	}

	update_wall_masks_on_object_placement(previous_pos, previous_orientation)

	draw_object_tool(can_add)

}

snap_wall_object :: proc() {
	ctx := get_object_tool_context()

	for i in 0 ..< len(Object_Orientation) - 1 {
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
	}

	if object.placement == .Counter || object.placement == .Table {
		object.pos.y += 0.8
	}

	draw := object_draw_from_object(object)
	draw.id = ctx.object_draw_id
	update_object_draw(draw)

	update_object_tool_tile_marker_object_draws(object.light)

	return true
}
