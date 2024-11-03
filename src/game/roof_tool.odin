package game

import "core:log"
import "core:math/linalg/glsl"
import "core:math"

import "../cursor"
import "../floor"

Roof_Tool_Context :: struct {
    cursor: Object_Draw,
}

init_roof_tool :: proc() {
    ctx := get_roof_tool_context()
    ctx.cursor.model = ROOF_TOOL_CURSOR_MODEL
    ctx.cursor.texture = ROOF_TOOL_CURSOR_TEXTURE
    ctx.cursor.light = {1, 1, 1}
    ctx.cursor.id = create_object_draw(ctx.cursor)
}

deinit_roof_tool :: proc() {
    ctx := get_roof_tool_context()
    delete_object_draw(ctx.cursor.id)
}

update_roof_tool :: proc() {
    ctx := get_roof_tool_context()

	cursor.on_tile_intersect(
		roof_tool_on_intersect,
		floor.previous_floor,
		floor.floor,
	)

    ctx.cursor.transform = glsl.mat4Translate(ctx.cursor.pos)

    update_object_draw(ctx.cursor)
}

@(private="file")
ROOF_TOOL_CURSOR_MODEL :: "resources/objects/cursors/roof_cursor/Roof_Cursor.glb"

@(private="file")
ROOF_TOOL_CURSOR_TEXTURE :: "resources/objects/cursors/roof_cursor/Hip_Roof_Cursor.png"

@(private="file")
roof_tool_on_intersect :: proc(intersect: glsl.vec3) {
	ctx := get_roof_tool_context()
	ctx.cursor.pos = intersect
    ctx.cursor.pos.x = math.trunc(ctx.cursor.pos.x)
    ctx.cursor.pos.z = math.trunc(ctx.cursor.pos.z)
    ctx.cursor.pos.x += 0.5
    ctx.cursor.pos.z += 0.5
}
