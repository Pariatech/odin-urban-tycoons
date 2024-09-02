package ui

import "core:math/linalg/glsl"

import "../billboard"
import "../game"
import "../tools"
import "../tools/furniture_tool"
import "../window"

FURNITURE_PANEL_TILE_SIZE :: 47
FURNITURE_PANEL_PADDING :: 4

Furniture :: struct {
	icon:      cstring,
	model:     string,
	texture:   string,
	placement: game.Object_Placement,
	type:      game.Object_Type,
}

FURNITURE_PANEL_ICONS :: []cstring {
	"resources/textures/object_icons/Plank.Table.6Places.png",
	"resources/textures/object_icons/Window.Wood.png",
	"resources/textures/object_icons/Poutine.Painting.png",
	"resources/textures/object_icons/Double_Window.png",
	"resources/textures/object_icons/Door_Wood.png",
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
		model = game.PLANK_TABLE_6PLACES_MODEL,
		texture = game.PLANK_TABLE_6PLACES_TEXTURE,
		placement = .Floor,
		type = .Table,
	},
	 {
		icon = "resources/textures/object_icons/Window.Wood.png",
		model = game.WOOD_WINDOW_MODEL,
		texture = game.WOOD_WINDOW_TEXTURE,
		placement = .Wall,
		type = .Window,
	},
	 {
		icon = "resources/textures/object_icons/Poutine.Painting.png",
		model = game.POUTINE_PAINTING_MODEL,
		texture = game.POUTINE_PAINTING_TEXTURE,
		placement = .Wall,
		type = .Painting,
	},
	 {
		icon = "resources/textures/object_icons/Double_Window.png",
		model = game.DOUBLE_WINDOW_MODEL,
		texture = game.DOUBLE_WINDOW_TEXTURE,
		placement = .Wall,
		type = .Window,
	},
	 {
		icon = "resources/textures/object_icons/Door_Wood.png",
		model = game.WOOD_DOOR_MODEL,
		texture = game.WOOD_DOOR_TEXTURE,
		placement = .Wall,
		type = .Door,
	},
}

furniture_panel_icon_texture_array: u32

furniture_panel_body :: proc(
	using ctx: ^Context,
	pos: glsl.vec2,
	size: glsl.vec2,
) {
	icons := FURNITURE_PANEL_ICONS
	for icon, i in icons {
		border_width := f32(BORDER_WIDTH)
		// if furniture_tool.type == i && furniture_tool.state == .Moving {
		// 	border_width *= 2
		// }

		if icon_button(
			   ctx,
			    {
				   2 + f32(i / 2) * (FURNITURE_PANEL_TILE_SIZE + 2),
				   pos.y +
				   FURNITURE_PANEL_PADDING +// 2 + f32(i) * (FURNITURE_PANEL_TILE_SIZE + 2),// window.size.y - 31 - PANEL_HEIGHT + FLOOR_PANEL_PADDING,
				   f32(i % 2) * (FURNITURE_PANEL_TILE_SIZE + 2),
			   },
			   {FURNITURE_PANEL_TILE_SIZE, FURNITURE_PANEL_TILE_SIZE},
			   furniture_panel_icon_texture_array,
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
			game.set_object_tool_model(furnitures[i].model)
			game.set_object_tool_texture(furnitures[i].texture)
			game.set_object_tool_placement(furnitures[i].placement)
			game.set_object_tool_type(furnitures[i].type)
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

init_furniture_panel :: proc() -> bool {
	icons := FURNITURE_PANEL_ICONS

	init_icon_texture_array(
		&furniture_panel_icon_texture_array,
		icons,
	) or_return

	return true
}
