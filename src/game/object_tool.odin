package game

import "core:log"
import "core:math/linalg/glsl"

import gl "vendor:OpenGL"

import "../cursor"
import "../floor"

Object_Tool_Context :: struct {
	object:      Object,
	tile_marker: Object,
}

init_object_tool :: proc() {
	ctx := get_object_tool_context()
	ctx.object.type = .Table
	ctx.object.light = {1, 1, 1}
	model_map := OBJECT_MODEL_MAP
	ctx.object.model = model_map[.Plank_Table_6Places]
	ctx.object.size = get_object_size(ctx.object.model)
	texture_map := OBJECT_MODEL_TEXTURE_MAP
	ctx.object.texture = texture_map[.Plank_Table_6Places]
	ctx.object.placement = .Floor
	ctx.object.orientation = .South

	ctx.tile_marker.model = "Tile_Marker.Bake"
	ctx.tile_marker.texture = "objects/Tile_Marker.Bake.png"
	ctx.tile_marker.light = {1, 1, 1}
}

update_object_tool :: proc() {
	ctx := get_object_tool_context()
	previous_pos := ctx.object.pos
	cursor.on_tile_intersect(
		object_tool_on_intersect,
		floor.previous_floor,
		floor.floor,
	)

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

	draw_object_tool()
}

object_tool_on_intersect :: proc(intersect: glsl.vec3) {
	ctx := get_object_tool_context()
	ctx.object.pos = intersect
}

draw_object_tool :: proc() -> bool {
	ctx := get_object_tool_context()

	objects_ctx := get_objects_context()
	bind_shader(&objects_ctx.shader)

	gl.BindBuffer(gl.UNIFORM_BUFFER, objects_ctx.ubo)
	set_shader_unifrom_block_binding(
		&objects_ctx.shader,
		"UniformBufferObject",
		2,
	)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, objects_ctx.ubo)

	draw_object(&ctx.object) or_return

	models := get_models_context()
	model_map := OBJECT_MODEL_MAP
	model_name := model_map[.Plank_Table_6Places]
	object_model := models.models[model_name]
	for x in 0 ..< ctx.object.size.x {
		x := x
		if ctx.object.orientation == .North ||
		   ctx.object.orientation == .West {
			x = -x
		}
		for z in 0 ..< ctx.object.size.z {
			z := z
			if ctx.object.orientation == .South ||
			   ctx.object.orientation == .West {
				z = -z
			}

			ctx.tile_marker.pos = ctx.object.pos + {f32(x), 0, f32(z)}
			draw_object(&ctx.tile_marker) or_return
		}
	}
	return true
}
