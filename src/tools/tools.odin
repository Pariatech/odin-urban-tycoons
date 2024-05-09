package tools

import "../keyboard"
import "terrain_tool"
import "wall_tool"
import "floor_tool"

TERRAIN_TOOL_KEY :: keyboard.Key_Value.Key_T
WALL_TOOL_KEY :: keyboard.Key_Value.Key_G
FLOOR_TOOL_KEY :: keyboard.Key_Value.Key_F

active_tool: Tool = .Terrain

Tool :: enum{
    Terrain,
    Wall,
    Floor,
}

update :: proc(delta_time: f64) {
    if keyboard.is_key_press(WALL_TOOL_KEY) {
        terrain_tool.deinit()
        floor_tool.deinit()
        wall_tool.init()
        active_tool = .Wall
    } else if keyboard.is_key_press(TERRAIN_TOOL_KEY) {
        wall_tool.deinit()
        floor_tool.deinit()
        terrain_tool.init()
        active_tool = .Terrain
    } else if keyboard.is_key_press(FLOOR_TOOL_KEY) {
        wall_tool.deinit()
        terrain_tool.deinit()
        floor_tool.init()
        active_tool = .Floor
    }
    switch active_tool {
	    case .Terrain: terrain_tool.update(delta_time)
        case .Wall: wall_tool.update()
        case .Floor: floor_tool.update()
    }
}
