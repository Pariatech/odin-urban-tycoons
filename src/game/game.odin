package game

Game_Context :: struct {
	textures:          Textures_Context,
	models:            Models_Context,
	objects:           Objects_Context,
	shaders:           Shaders_Context,
	object_tool:       Object_Tool_Context,
	object_draws:      Object_Draws,
	object_blueprints: Object_Blueprints,
	roofs:             Roofs_Context,
}

get_game_context :: #force_inline proc() -> ^Game_Context {
	return cast(^Game_Context)context.user_ptr
}

get_textures_context :: proc() -> ^Textures_Context {
	return &get_game_context().textures
}

get_objects_context :: proc() -> ^Objects_Context {
	return &get_game_context().objects
}

get_models_context :: proc() -> ^Models_Context {
	return &get_game_context().models
}

get_shaders_context :: proc() -> ^Shaders_Context {
	return &get_game_context().shaders
}

get_object_tool_context :: proc() -> ^Object_Tool_Context {
	return &get_game_context().object_tool
}

get_object_draws_context :: proc() -> ^Object_Draws {
	return &get_game_context().object_draws
}

init_game :: proc() -> bool {
	load_object_blueprints() or_return
	init_object_draws() or_return
	init_object_tool()
	init_roofs() or_return

	// add_roof({type = .Half_Hip, start = {0, 0}, end = {0, 1}})
	// add_roof({type = .Half_Hip, start = {0, 3}, end = {0, 5}})
	// add_roof({type = .Half_Hip, start = {0, 7}, end = {1, 8}})
	// add_roof({type = .Half_Hip, start = {0, 10}, end = {3, 14}})
	// add_roof({type = .Half_Hip, start = {0, 16}, end = {2, 17}})
	// add_roof({type = .Half_Hip, start = {0, 19}, end = {2, 26}})
	// add_roof({type = .Half_Hip, start = {0, 28}, end = {2, 33}})
	// add_roof({type = .Hip, start = {3, 0}, end = {6, 3}})
	//
	add_roof({type = .Hip, start = {11.5, 11.5}, end = {23.5, 22.5}, offset = 6, slope = 1})
	add_roof({type = .Half_Hip, start = {9.5, 12}, end = {11, 22}, offset = 3, slope = 0.25})
	// add_roof({type = .Half_Hip, start = {8.5, 15.5}, end = {10.5, 18.5}, offset = 3, slope = 1})
	// add_roof({type = .Half_Hip, start = {31, 33}, end = {32, 34}})
	//
	// add_roof({type = .Hip, start = {32, 37}, end = {41, 41}}) // 10, 5
	// add_roof({type = .Hip, start = {26, 37}, end = {30, 47}}) // 5, 11
	// add_roof({type = .Half_Gable, start = {-0.5, 2.5}, end = {1.5, 7.5}}) // pyramid

	// add_roof({type = .Corner, start = {0, 7}, end = {1, 8}}) // corner
	// add_roof({start = {0, 10}, end = {1, 13}}) // pyramid

	return true
}

deinit_game :: proc() {
	deload_object_blueprints()
	deinit_object_draws()
	deinit_object_tool()
	deinit_roofs()
}

draw_game :: proc() {
	draw_roofs()
}

update_game_on_camera_rotation :: proc() {
	update_objects_on_camera_rotation()
}
