package game

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../cursor"
import "../floor"
import "../mouse"

Object_Tool_Context :: struct {
	cursor_pos:  glsl.vec3,
	object:      Object,
	tile_marker: Object,
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
}

set_object_tool_model :: proc(model: string) {
	ctx := get_object_tool_context()
	ctx.object.model = model
    ctx.object.size = get_object_size(model)
}

set_object_tool_texture :: proc(texture: string) {
	ctx := get_object_tool_context()
	ctx.object.texture = texture
}

set_object_tool_placement :: proc(placement: Object_Placement) {
	ctx := get_object_tool_context()
	ctx.object.placement = placement
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


	can_add := can_add_object(
		ctx.object.pos,
		ctx.object.model,
		ctx.object.type,
		ctx.object.orientation,
		ctx.object.placement,
	)

	if can_add {
		ctx.object.pos.x = glsl.floor(ctx.object.pos.x + 0.5)
		ctx.object.pos.z = glsl.floor(ctx.object.pos.z + 0.5)
	} else if ctx.object.placement == .Wall && mouse.is_button_up(.Left) {
		snap_wall_object()
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

	if obj.type == .Window {
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

	ctx.tile_marker.light = object.light

	objects_ctx := get_objects_context()
	bind_shader(&objects_ctx.shader)

	gl.BindBuffer(gl.UNIFORM_BUFFER, objects_ctx.ubo)
	set_shader_unifrom_block_binding(
		&objects_ctx.shader,
		"UniformBufferObject",
		2,
	)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, objects_ctx.ubo)

	draw_object(&object) or_return

    // log.info(object.model, object.size)
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
			draw_object(&ctx.tile_marker) or_return
		}
	}

	return true
}
