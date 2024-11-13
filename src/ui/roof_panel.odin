package ui

import "core:fmt"
import "core:log"
import "core:math/linalg/glsl"
import "core:strings"

import "../game"
import "../tools"
import "../window"

ROOF_PANEL_TILE_SIZE :: 47
ROOF_PANEL_PADDING :: 4

ROOF_PANEL_ICONS :: [game.Roof_Type]cstring {
	.Half_Hip   = "resources/roofs/half_hip_roof_icon.png",
	.Half_Gable = "resources/roofs/half_gable_roof_icon.png",
	.Hip        = "resources/roofs/hip_roof_icon.png",
	.Gable      = "resources/roofs/gable_roof_icon.png",
}

@(private = "file")
ROOF_PANEL_ROOF_HEIGHT_ICON :: "resources/roofs/roof_height_icon.png"

roof_panel_icon_texture_arrays: u32

@(private = "file")
roof_panel_roof_height_icon_texture_arrays: u32

@(private = "file")
roof_panel_roof_angle: string

roof_panel_body :: proc(using ctx: ^Context, pos: glsl.vec2, size: glsl.vec2) {
	icons := ROOF_PANEL_ICONS
	for icon, i in icons {
		color := DAY_SKY_BLUE
		if game.get_roof_tool_context().roof.type == i {
			color = DARK_BLUE
		}
		if icon_button(
			   ctx,
			    {
				   pos.x + 2 + f32(i32(i) / 2) * (ROOF_PANEL_TILE_SIZE + 2),
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
			   color = color,
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


@(private = "file")
ROOF_PANEL_ROOF_HEIGHT_ICON_WIDTH :: 78

@(private = "file")
ROOF_PANEL_ROOF_HEIGHT_ICON_HEIGHT :: 96

@(private = "file")
ROOF_PANEL_ROOF_HEIGHT_PANEL_WIDTH ::
	ROOF_PANEL_ROOF_HEIGHT_ICON_WIDTH + 4 + 32 + 4 * 2

@(private = "file")
roof_panel_roof_height_panel :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	icon(
		ctx,
		 {
			pos = {pos.x + 4, pos.y + 4},
			size =  {
				ROOF_PANEL_ROOF_HEIGHT_ICON_WIDTH,
				ROOF_PANEL_ROOF_HEIGHT_ICON_HEIGHT,
			},
			color = {1, 1, 1, 0},
			texture_array = roof_panel_roof_height_icon_texture_arrays,
		},
	)

	if button(
		ctx,
		{pos.x + 8 + ROOF_PANEL_ROOF_HEIGHT_ICON_WIDTH, pos.y + 4},
		{32, 32},
		"+",
		padding_top = 4,
	) {
        game.increment_roof_tool_roof_angle()
    }

    roof_tool_ctx := game.get_roof_tool_context()
    angle := game.get_roof_tool_roof_angle()

    bytes := transmute([]u8)roof_panel_roof_angle    
    bytes[0] = u8(angle / 10) + '0'
    bytes[1] = u8(int(angle) % 10) + '0'
    // defer delete(angle)
	text(
		ctx,
		{pos.x + 8 + ROOF_PANEL_ROOF_HEIGHT_ICON_WIDTH + 16, pos.y + 6 + 48},
		roof_panel_roof_angle,
		ah = .CENTER,
		av = .MIDDLE,
        size = 24,
	)

	if button(
		ctx,
		{pos.x + 8 + ROOF_PANEL_ROOF_HEIGHT_ICON_WIDTH, pos.y + 4 + 64},
		{32, 32},
		"-",
		padding_top = 2,
	) {
        game.decrement_roof_tool_roof_angle()
    }
}

roof_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Roof {
		container(
			ctx,
			pos = {0, window.size.y - 31 - PANEL_HEIGHT},
			size = {ROOF_PANEL_ROOF_HEIGHT_PANEL_WIDTH, PANEL_HEIGHT},
			left_border_width = 0,
			body = roof_panel_roof_height_panel,
		)

		container(
			ctx,
			pos =  {
				ROOF_PANEL_ROOF_HEIGHT_PANEL_WIDTH,
				window.size.y - 31 - PANEL_HEIGHT,
			},
			size =  {
				window.size.x - ROOF_PANEL_ROOF_HEIGHT_PANEL_WIDTH,
				PANEL_HEIGHT,
			},
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

	roof_height_icon := [?]cstring{ROOF_PANEL_ROOF_HEIGHT_ICON}
	init_icon_texture_array(
		&roof_panel_roof_height_icon_texture_arrays,
		roof_height_icon[:],
	) or_return

    roof_panel_roof_angle = fmt.aprint("45", "°", sep = "")

	//    for blueprint, i in game.object_blueprints {
	// 	init_icon_texture_array(
	// 		&furniture_panel_icon_texture_arrays[i],
	// 		{strings.unsafe_string_to_cstring(blueprint.icon)},
	// 	) or_return
	// }

	return true
}
