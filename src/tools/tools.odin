package tools

import "../keyboard"
import "terrain_tool"
import "wall_tool"

TOOLS_CONTROLLER_TERRAIN_TOOL_KEY :: keyboard.Key_Value.Key_T
TOOLS_CONTROLLER_WALL_TOOL_KEY :: keyboard.Key_Value.Key_G

tools_controller_active_tool: Tool = .Terrain

Tool :: enum{
    Terrain,
    Wall,
}

update :: proc(delta_time: f64) {
    if keyboard.is_key_press(TOOLS_CONTROLLER_WALL_TOOL_KEY) {
        terrain_tool.deinit()
        wall_tool.init()
        tools_controller_active_tool = .Wall
    } else if keyboard.is_key_press(TOOLS_CONTROLLER_TERRAIN_TOOL_KEY) {
        wall_tool.deinit()
        terrain_tool.init()
        tools_controller_active_tool = .Terrain
    }
    switch tools_controller_active_tool {
	    case .Terrain: terrain_tool.update(delta_time)
        case .Wall: wall_tool.update()
    }
}
