package ui

import "core:math/linalg/glsl"
import "core:strings"

import "../billboard"
import g "../game"
import "../tools"
import "../tools/furniture_tool"
import "../window"

FURNITURE_PANEL_TILE_SIZE :: 47
FURNITURE_PANEL_PADDING :: 4

Furniture :: struct {
	icon:      cstring,
	model:     string,
	texture:   string,
	placement: g.Object_Placement_Set,
	type:      g.Object_Type,
}

FURNITURE_PANEL_ICONS :: []cstring {
	"resources/textures/object_icons/Plank.Table.6Places.png",
	"resources/textures/object_icons/Window.Wood.png",
	"resources/textures/object_icons/Poutine.Painting.png",
	"resources/textures/object_icons/Double_Window.png",
	"resources/textures/object_icons/Door_Wood.png",
	"resources/textures/object_icons/Old_Computer.png",
	"resources/textures/object_icons/Plate.png",
	"resources/textures/object_icons/L_Couch.png",
	// .Chair    = "resources/textures/object_icons/Chair.png",
	// .Table6   = "resources/textures/object_icons/Table.6Places.png",
	// .Letter_A = "resources/textures/object_icons/Letter_A.png",
	// .Letter_G = "resources/textures/object_icons/Letter_G.png",
	// .Letter_D = "resources/textures/object_icons/Letter_D.png",
	// .Letter_E = "resources/textures/object_icons/Letter_E.png",
}

FURNITURES :: []Furniture {
	 {
		icon = "resources/textures/object_icons/Plank.Table.6Places.png",
		model = g.PLANK_TABLE_6PLACES_MODEL,
		texture = g.PLANK_TABLE_6PLACES_TEXTURE,
		placement = {.Floor},
		type = .Table,
	},
	 {
		icon = "resources/textures/object_icons/Window.Wood.png",
		model = g.WOOD_WINDOW_MODEL,
		texture = g.WOOD_WINDOW_TEXTURE,
		placement = {.Wall},
		type = .Window,
	},
	 {
		icon = "resources/textures/object_icons/Poutine.Painting.png",
		model = g.POUTINE_PAINTING_MODEL,
		texture = g.POUTINE_PAINTING_TEXTURE,
		placement = {.Wall},
		type = .Painting,
	},
	 {
		icon = "resources/textures/object_icons/Double_Window.png",
		model = g.DOUBLE_WINDOW_MODEL,
		texture = g.DOUBLE_WINDOW_TEXTURE,
		placement = {.Wall},
		type = .Window,
	},
	 {
		icon = "resources/textures/object_icons/Door_Wood.png",
		model = g.WOOD_DOOR_MODEL,
		texture = g.WOOD_DOOR_TEXTURE,
		placement = {.Wall},
		type = .Door,
	},
	 {
		icon = "resources/textures/object_icons/Old_Computer.png",
		model = g.OLD_COMPUTER_MODEL,
		texture = g.OLD_COMPUTER_TEXTURE,
		placement = {.Table},
		type = .Computer,
	},
	 {
		icon = "resources/textures/object_icons/Plate.png",
		model = g.PLATE_MODEL,
		texture = g.PLATE_TEXTURE,
		placement = {.Floor, .Table, .Counter},
		type = .Plate,
	},
	 {
		icon = "resources/textures/object_icons/L_Couch.png",
		model = g.L_COUCH_MODEL,
		texture = g.L_COUCH_TEXTURE,
		placement = {.Floor},
		type = .Couch,
	},
}

furniture_panel_icon_texture_arrays: []u32

furniture_panel_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	game: ^g.Game_Context = cast(^g.Game_Context)context.user_ptr

	for blueprint, i in game.object_blueprints {
		border_width := f32(BORDER_WIDTH)
		// if furniture_tool.type == i && furniture_tool.state == .Moving {
		// 	border_width *= 2
		// }

		if icon_button(
			   ctx,
			    {
				   2 + f32(i / 2) * (FURNITURE_PANEL_TILE_SIZE + 2),
				   pos.y +
				   FURNITURE_PANEL_PADDING +
				   f32(i % 2) * (FURNITURE_PANEL_TILE_SIZE + 2),
			   }, // 2 + f32(i) * (FURNITURE_PANEL_TILE_SIZE + 2),// window.size.y - 31 - PANEL_HEIGHT + FLOOR_PANEL_PADDING,
			   {FURNITURE_PANEL_TILE_SIZE, FURNITURE_PANEL_TILE_SIZE},
			   furniture_panel_icon_texture_arrays[i],
			   int(i),
			   top_padding = 0,
			   bottom_padding = 0,
			   left_padding = 0,
			   right_padding = 0,
			   left_border_width = border_width,
			   right_border_width = border_width,
			   top_border_width = border_width,
			   bottom_border_width = border_width,
			   color = DAY_SKY_BLUE,
		   ) {
			// furniture_tool.place_furniture(i)
			furnitures := FURNITURES
			g.set_object_tool_object(
				 {
					model = blueprint.model,
					texture = blueprint.texture,
					type = blueprint.category,
					size = blueprint.size,
					light = {1, 1, 1},
					placement_set = blueprint.placement_set,
                    wall_mask = blueprint.wall_mask,
				},
			)
		}
	}
}

furniture_panel :: proc(using ctx: ^Context) {
	if tools.active_tool == .Furniture {
		container(
			ctx,
			pos = {0, window.size.y - 31 - PANEL_HEIGHT},
			size = {window.size.x, PANEL_HEIGHT},
			left_border_width = 0,
			body = furniture_panel_body,
		)
	}
}

init_furniture_panel :: proc(
	game: ^g.Game_Context = cast(^g.Game_Context)context.user_ptr,
) -> bool {
	furniture_panel_icon_texture_arrays = make(
		[]u32,
		len(game.object_blueprints),
	)
	for blueprint, i in game.object_blueprints {
		init_icon_texture_array(
			&furniture_panel_icon_texture_arrays[i],
			{strings.unsafe_string_to_cstring(blueprint.icon)},
		) or_return
	}

	return true
}
