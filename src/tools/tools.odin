package tools

import "../keyboard"
import "floor_tool"
import "terrain_tool"
import "wall_tool"

TERRAIN_TOOL_KEY :: keyboard.Key_Value.Key_T
WALL_TOOL_KEY :: keyboard.Key_Value.Key_G
FLOOR_TOOL_KEY :: keyboard.Key_Value.Key_F

active_tool: Tool = .Terrain

Tool :: enum {
	Terrain,
	Wall,
	Floor,
}

update :: proc(delta_time: f64) {
	if keyboard.is_key_press(WALL_TOOL_KEY) {
		open_wall_tool()
	} else if keyboard.is_key_press(TERRAIN_TOOL_KEY) {
		open_land_tool()
	} else if keyboard.is_key_press(FLOOR_TOOL_KEY) {
		open_floor_tool()
	}

	switch active_tool {
	case .Terrain:
		terrain_tool.update(delta_time)
	case .Wall:
		wall_tool.update()
	case .Floor:
		floor_tool.update()
	}
}

open_wall_tool :: proc() {
	terrain_tool.deinit()
	floor_tool.deinit()
	wall_tool.init()
	active_tool = .Wall
}

open_land_tool :: proc() {
	wall_tool.deinit()
	floor_tool.deinit()
	terrain_tool.init()
	active_tool = .Terrain
}

open_floor_tool :: proc() {
	wall_tool.deinit()
	terrain_tool.deinit()
	floor_tool.init()
	active_tool = .Floor
}
