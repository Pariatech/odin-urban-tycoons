package tools

import "../keyboard"
import "floor_tool"
import "terrain_tool"
import "wall_tool"
import "paint_tool"

TERRAIN_TOOL_KEY :: keyboard.Key_Value.Key_T
WALL_TOOL_KEY :: keyboard.Key_Value.Key_G
FLOOR_TOOL_KEY :: keyboard.Key_Value.Key_F
PAINT_TOOL_KEY :: keyboard.Key_Value.Key_P

active_tool: Tool = .Terrain

Tool :: enum {
	Terrain,
	Wall,
	Floor,
    Paint,
}

update :: proc(delta_time: f64) {
	if keyboard.is_key_press(WALL_TOOL_KEY) {
		open_wall_tool()
	} else if keyboard.is_key_press(TERRAIN_TOOL_KEY) {
		open_land_tool()
	} else if keyboard.is_key_press(FLOOR_TOOL_KEY) {
		open_floor_tool()
	} else if keyboard.is_key_press(PAINT_TOOL_KEY) {
        open_paint_tool()
    }

	switch active_tool {
	case .Terrain:
		terrain_tool.update(delta_time)
	case .Wall:
		wall_tool.update()
	case .Floor:
		floor_tool.update()
    case .Paint:
        paint_tool.update()
	}
}

open_wall_tool :: proc() {
	terrain_tool.deinit()
	floor_tool.deinit()
    paint_tool.deinit()

	wall_tool.init()
	active_tool = .Wall
}

open_land_tool :: proc() {
	wall_tool.deinit()
	floor_tool.deinit()
    paint_tool.deinit()

	terrain_tool.init()
	active_tool = .Terrain
}

open_floor_tool :: proc() {
	wall_tool.deinit()
	terrain_tool.deinit()
    paint_tool.deinit()

	floor_tool.init()
	active_tool = .Floor
}

open_paint_tool :: proc() {
	floor_tool.deinit()
	wall_tool.deinit()
	terrain_tool.deinit()

    paint_tool.init()
    active_tool = .Paint
}
