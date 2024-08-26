package tools

import "../keyboard"
import "door_tool"
import "floor_tool"
import "paint_tool"
import "terrain_tool"
import "wall_tool"
import "window_tool"
import "furniture_tool"
import "../game"

TERRAIN_TOOL_KEY :: keyboard.Key_Value.Key_1
WALL_TOOL_KEY :: keyboard.Key_Value.Key_2
FLOOR_TOOL_KEY :: keyboard.Key_Value.Key_3
PAINT_TOOL_KEY :: keyboard.Key_Value.Key_4
DOOR_TOOL_KEY :: keyboard.Key_Value.Key_5
WINDOW_TOOL_KEY :: keyboard.Key_Value.Key_6
FURNITURE_TOOL_KEY :: keyboard.Key_Value.Key_7

active_tool: Tool = .Terrain

Tool :: enum {
	Terrain,
	Wall,
	Floor,
	Paint,
	Door,
	Window,
    Furniture,
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
	} else if keyboard.is_key_press(DOOR_TOOL_KEY) {
		open_door_tool()
	} else if keyboard.is_key_press(WINDOW_TOOL_KEY) {
		open_window_tool()
	} else if keyboard.is_key_press(FURNITURE_TOOL_KEY) {
        // open_furniture_tool()
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
	case .Door:
		door_tool.update()
	case .Window:
		window_tool.update()
    case .Furniture:
        // furniture_tool.update()
        game.update_object_tool()
	}
}

open_wall_tool :: proc() {
	terrain_tool.deinit()
	floor_tool.deinit()
	paint_tool.deinit()
	door_tool.deinit()
    window_tool.deinit()
    furniture_tool.deinit()

	wall_tool.init()
	active_tool = .Wall
}

open_land_tool :: proc() {
	wall_tool.deinit()
	floor_tool.deinit()
	paint_tool.deinit()
	door_tool.deinit()
    window_tool.deinit()
    furniture_tool.deinit()

	terrain_tool.init()
	active_tool = .Terrain
}

open_floor_tool :: proc() {
	wall_tool.deinit()
	terrain_tool.deinit()
	paint_tool.deinit()
	door_tool.deinit()
    window_tool.deinit()
    furniture_tool.deinit()

	floor_tool.init()
	active_tool = .Floor
}

open_paint_tool :: proc() {
	floor_tool.deinit()
	wall_tool.deinit()
	terrain_tool.deinit()
	door_tool.deinit()
    window_tool.deinit()
    furniture_tool.deinit()

	paint_tool.init()
	active_tool = .Paint
}

open_door_tool :: proc() {
	floor_tool.deinit()
	wall_tool.deinit()
	terrain_tool.deinit()
	paint_tool.deinit()
    window_tool.deinit()
    furniture_tool.deinit()

	door_tool.init()
	active_tool = .Door
}


open_window_tool :: proc() {
	floor_tool.deinit()
	wall_tool.deinit()
	terrain_tool.deinit()
	paint_tool.deinit()
	door_tool.deinit()
    furniture_tool.deinit()

	window_tool.init()
	active_tool = .Window
}

open_furniture_tool :: proc() {
	floor_tool.deinit()
	wall_tool.deinit()
	terrain_tool.deinit()
	paint_tool.deinit()
	door_tool.deinit()
	window_tool.deinit()

    // furniture_tool.init()
    // game.init_object_tool()
	active_tool = .Furniture
}

