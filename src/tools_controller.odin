package main

TOOLS_CONTROLLER_TERRAIN_TOOL_KEY :: Key_Value.Key_T
TOOLS_CONTROLLER_WALL_TOOL_KEY :: Key_Value.Key_G

tools_controller_active_tool: Tool = .Terrain

Tool :: enum{
    Terrain,
    Wall,
}

tools_controller_update :: proc() {
    // if is_key_press(TOOLS_CONTROLLER_WALL_TOOL_KEY) {
    //     terrain_tool_deinit()
    // } else if is_key_press(TOOLS_CONTROLLER_TERRAIN_TOOL_KEY) {
    //     terrain_tool_init()
    // }
    switch tools_controller_active_tool {
	    case .Terrain: terrain_tool_update()
        case .Wall:
    }
}
