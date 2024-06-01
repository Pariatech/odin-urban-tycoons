package ui

import "core:math/linalg/glsl"

import "../tools"
import "../tools/wall_tool"
import "../window"

WALL_PANEL_ICONS :: []cstring {
	"resources/icons/build.png",
	"resources/icons/wall_rectangle.png",
	"resources/icons/demolish.png",
}

Wall_Panel_Texture :: enum {
	Build,
	Rectangle,
	Demolish,
}

wall_panel_texture_array: u32

init_wall_panel :: proc() -> (ok: bool = true) {
	init_icon_texture_array(
		&wall_panel_texture_array,
		WALL_PANEL_ICONS,
	) or_return

	return
}

wall_panel_body :: proc(using ctx: ^Context, pos: glsl.vec2, size: glsl.vec2) {
	demolish_active :=
		wall_tool.get_mode() == .Demolish ||
		wall_tool.get_mode() == .Demolish_Rectangle
	if icon_button(
		   ctx,
		   pos = {pos.x + 4, pos.y + 4},
		   size = {66, 66},
		   color = DARK_BLUE if demolish_active else ROYAL_BLUE,
		   texture_array = wall_panel_texture_array,
		   texture = int(Wall_Panel_Texture.Demolish),
	   ) {
		if wall_tool.get_mode() == .Build {
			wall_tool.set_mode(.Demolish)
		} else if wall_tool.get_mode() == .Rectangle {
			wall_tool.set_mode(.Demolish_Rectangle)
		} else if wall_tool.get_mode() == .Demolish {
			wall_tool.set_mode(.Build)
		} else if wall_tool.get_mode() == .Demolish_Rectangle {
			wall_tool.set_mode(.Rectangle)
		}
	}

	rectangle_active :=
		wall_tool.get_mode() == .Rectangle ||
		wall_tool.get_mode() == .Demolish_Rectangle
	if icon_button(
		   ctx,
		   pos = {pos.x + 4 + 68, pos.y + 4},
		   size = {66, 66},
		   color = DARK_BLUE if rectangle_active else ROYAL_BLUE,
		   texture_array = wall_panel_texture_array,
		   texture = int(Wall_Panel_Texture.Rectangle),
	   ) {
		if wall_tool.get_mode() == .Rectangle {
			wall_tool.set_mode(.Build)
		} else if wall_tool.get_mode() == .Demolish_Rectangle {
			wall_tool.set_mode(.Demolish)
		} else if wall_tool.get_mode() == .Build {
			wall_tool.set_mode(.Rectangle)
		} else if wall_tool.get_mode() == .Demolish {
			wall_tool.set_mode(.Demolish_Rectangle)
		}
	}
}

wall_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Wall {
		container(
			ctx,
			pos = {0, window.size.y - 31 - FLOOR_PANEL_HEIGHT},
			size = {249, FLOOR_PANEL_HEIGHT},
			left_border_width = 0,
			body = wall_panel_body,
		)
	}
}
