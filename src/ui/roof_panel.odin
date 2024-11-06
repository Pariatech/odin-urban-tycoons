package ui

import "core:math/linalg/glsl"
import "core:strings"
import "core:log"

import "../game"
import "../tools"
import "../window"

ROOF_PANEL_TILE_SIZE :: 47
ROOF_PANEL_PADDING :: 4

ROOF_PANEL_ICONS :: [game.Roof_Type]cstring {
	.Half_Hip = "resources/roofs/half_hip_roof_icon.png",
	.Half_Gable = "resources/roofs/half_gable_roof_icon.png",
	.Hip = "resources/roofs/hip_roof_icon.png",
	.Gable = "resources/roofs/gable_roof_icon.png",
}

roof_panel_icon_texture_arrays: u32

roof_panel_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
    icons := ROOF_PANEL_ICONS
    for icon, i in icons {
		if icon_button(
			   ctx,
			    {
				   2 + f32(i32(i) / 2) * (ROOF_PANEL_TILE_SIZE + 2),
				   pos.y +
				   FURNITURE_PANEL_PADDING +
				   f32(i32(i) % 2) * (FURNITURE_PANEL_TILE_SIZE + 2),
			   }, // 2 + f32(i) * (FURNITURE_PANEL_TILE_SIZE + 2),// window.size.y - 31 - PANEL_HEIGHT + FLOOR_PANEL_PADDING,
			   {FURNITURE_PANEL_TILE_SIZE, FURNITURE_PANEL_TILE_SIZE},
			   roof_panel_icon_texture_arrays,
			   int(i),
			   top_padding = 0,
			   bottom_padding = 0,
			   left_padding = 0,
			   right_padding = 0,
			   left_border_width = f32(BORDER_WIDTH),
			   right_border_width = f32(BORDER_WIDTH),
			   top_border_width = f32(BORDER_WIDTH),
			   bottom_border_width = f32(BORDER_WIDTH),
			   color = DAY_SKY_BLUE,
		   ) {
            log.info(i)
			game.set_roof_tool_roof_type(i)
		}
    }
	// for blueprint, i in game.object_blueprints {
	// 	border_width := f32(BORDER_WIDTH)
	//
	// }
}

roof_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Roof {
		container(
			ctx,
			pos = {0, window.size.y - 31 - PANEL_HEIGHT},
			size = {window.size.x, PANEL_HEIGHT},
			left_border_width = 0,
			body = roof_panel_body,
		)
	}
}

init_roof_panel :: proc() -> bool {
    icons := ROOF_PANEL_ICONS
	init_icon_texture_array(
		&roof_panel_icon_texture_arrays,
		raw_data(&icons)[0:len(icons)],
	) or_return
 //    for blueprint, i in game.object_blueprints {
	// 	init_icon_texture_array(
	// 		&furniture_panel_icon_texture_arrays[i],
	// 		{strings.unsafe_string_to_cstring(blueprint.icon)},
	// 	) or_return
	// }

	return true
}
