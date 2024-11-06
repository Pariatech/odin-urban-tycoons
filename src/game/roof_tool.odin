package game

import "core:log"
import "core:math"
import "core:math/linalg/glsl"

import "../cursor"
import "../floor"
import "../mouse"

import "../terrain"

Roof_Tool_Context :: struct {
	cursor: Object_Draw,
	roof:   Roof,
    active: bool,
}

init_roof_tool :: proc() {
	ctx := get_roof_tool_context()
	ctx.cursor.model = ROOF_TOOL_CURSOR_MODEL
	ctx.cursor.texture = ROOF_TOOL_CURSOR_TEXTURE
	ctx.cursor.light = {1, 1, 1}

	floor.show_markers = true

	get_roofs_context().floor_offset = 1
    ctx.active = true
}

deinit_roof_tool :: proc() {
	ctx := get_roof_tool_context()
	// delete_object_draw(ctx.cursor.id)

	floor.show_markers = false
	get_roofs_context().floor_offset = 0
    ctx.active = false
}

update_roof_tool :: proc() {
	ctx := get_roof_tool_context()

	cursor.on_tile_intersect(
		roof_tool_on_intersect,
		floor.previous_floor,
		floor.floor,
	)

	ctx.cursor.transform = glsl.mat4Translate(ctx.cursor.pos)

	if mouse.is_button_press(.Left) {
		ctx.roof.start = ctx.cursor.pos.xz
		ctx.roof.end = ctx.roof.start
		ctx.roof.slope = 1
		ctx.roof.offset =
			f32(floor.floor) * 3 +
			terrain.get_tile_height(
				int(ctx.cursor.pos.x + 0.5),
				int(ctx.cursor.pos.y + 0.5),
			)
        ctx.roof.light = {1, 1, 1, 0.5}
		ctx.roof.id = add_roof(ctx.roof)
	} else if mouse.is_button_down(.Left) {
		ctx.roof.end = ctx.cursor.pos.xz
		update_roof(ctx.roof)
	} else if mouse.is_button_release(.Left) {
        ctx.roof.light = {1, 1, 1, 1}
		update_roof(ctx.roof)
	}
}

draw_roof_tool :: proc() {
	ctx := get_roof_tool_context()
    if !ctx.active { return }
    draw_one_object(&ctx.cursor)
}

set_roof_tool_roof_type :: proc(type: Roof_Type) {
	ctx := get_roof_tool_context()
    ctx.roof.type = type
}

@(private = "file")
ROOF_TOOL_CURSOR_MODEL :: "resources/objects/cursors/roof_cursor/Roof_Cursor.glb"

@(private = "file")
ROOF_TOOL_CURSOR_TEXTURE :: "resources/objects/cursors/roof_cursor/Hip_Roof_Cursor.png"

@(private = "file")
roof_tool_on_intersect :: proc(intersect: glsl.vec3) {
	ctx := get_roof_tool_context()
	ctx.cursor.pos = intersect
	ctx.cursor.pos.x = math.trunc(ctx.cursor.pos.x)
	ctx.cursor.pos.z = math.trunc(ctx.cursor.pos.z)
	ctx.cursor.pos.x += 0.5
	ctx.cursor.pos.z += 0.5
}
