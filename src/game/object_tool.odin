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

update_object_tool :: proc() {
	ctx := get_object_tool_context()
	previous_pos := ctx.cursor_pos
	cursor.on_tile_intersect(
		object_tool_on_intersect,
		floor.previous_floor,
		floor.floor,
	)

	if mouse.is_button_down(.Left) {
		mouse.set_cursor(.Rotate)

		dx := ctx.cursor_pos.x - ctx.object.pos.x
		dz := ctx.cursor_pos.z - ctx.object.pos.z

		if glsl.abs(dx) > glsl.abs(dz) {
			if dx == 0 {
			} else if dx > 0 {
				ctx.object.orientation = .East
			} else {
				ctx.object.orientation = .West
			}
		} else {
			if dz == 0 {
			} else if dz > 0 {
				ctx.object.orientation = .North
			} else {
				ctx.object.orientation = .South
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
		ctx.object.orientation,
		ctx.object.placement,
	)

	if can_add {
		ctx.object.pos.x = glsl.floor(ctx.object.pos.x + 0.5)
		ctx.object.pos.z = glsl.floor(ctx.object.pos.z + 0.5)
	}

	draw_object_tool(can_add)
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
