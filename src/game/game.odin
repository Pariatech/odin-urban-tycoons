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
	add_roof({type = .Hip, start = {11, 11}, end = {24, 23}, offset = 6, slope = 1})

	add_roof({type = .Half_Hip, start = {-0.5, -0.5}, end = {0.5, 1.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {1.5, -0.5}, end = {0.5, 1.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {-0.5, 4.5}, end = {0.5, 2.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {1.5, 4.5}, end = {0.5, 2.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {-0.5, 5.5}, end = {1.5, 6.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {-0.5, 7.5}, end = {1.5, 6.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {1.5, 8.5}, end = {-0.5, 9.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {1.5, 10.5}, end = {-0.5, 9.5}, offset = 3, slope = 1.0})


	add_roof({type = .Half_Hip, start = {2.5, -0.5}, end = {3.5, 2.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {4.5, -0.5}, end = {3.5, 2.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {2.5, 6.5}, end = {3.5, 3.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {4.5, 6.5}, end = {3.5, 3.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {2.5, 7.5}, end = {5.5, 8.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {2.5, 9.5}, end = {5.5, 8.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {5.5, 10.5}, end = {2.5, 11.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {5.5, 12.5}, end = {2.5, 11.5}, offset = 3, slope = 1.0})


	add_roof({type = .Half_Hip, start = {6.5, -0.5}, end = {8.5, 2.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {10.5, -0.5}, end = {8.5, 2.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {6.5, 6.5}, end = {8.5, 3.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {10.5, 6.5}, end = {8.5, 3.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {6.5, 7.5}, end = {9.5, 9.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {6.5, 11.5}, end = {9.5, 9.5}, offset = 3, slope = 1.0})

	add_roof({type = .Half_Hip, start = {9.5, 12.5}, end = {6.5, 14.5}, offset = 3, slope = 1.0})
	add_roof({type = .Half_Hip, start = {9.5, 16.5}, end = {6.5, 14.5}, offset = 3, slope = 1.0})

	add_roof({type = .Hip, start = {11.5, -0.5}, end = {13.5, 1.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {11.5, 4.5}, end = {13.5, 2.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {16.5, -0.5}, end = {14.5, 1.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {16.5, 4.5}, end = {14.5, 2.5}, offset = 3, slope = 1})

	add_roof({type = .Hip, start = {17.5, -0.5}, end = {19.5, 2.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {17.5, 6.5}, end = {19.5, 3.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {22.5, -0.5}, end = {20.5, 2.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {22.5, 6.5}, end = {20.5, 3.5}, offset = 3, slope = 1})

	add_roof({type = .Hip, start = {23.5, -0.5}, end = {26.5, 1.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {23.5, 4.5}, end = {26.5, 2.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {30.5, -0.5}, end = {27.5, 1.5}, offset = 3, slope = 1})
	add_roof({type = .Hip, start = {30.5, 4.5}, end = {27.5, 2.5}, offset = 3, slope = 1})


    add_roof({type = .Half_Gable, start = {31.5, -0.5}, end = {34.5, 1.5}, offset = 3, slope = 1})
    add_roof({type = .Half_Gable, start = {31.5, 3.5}, end = {34.5, 1.5}, offset = 3, slope = 1})

    add_roof({type = .Half_Gable, start = {31.5, 4.5}, end = {33.5, 7.5}, offset = 3, slope = 1})
    add_roof({type = .Half_Gable, start = {35.5, 4.5}, end = {33.5, 7.5}, offset = 3, slope = 1})


    add_roof({type = .Gable, start = {36.5, -0.5}, end = {39.5, 3.5}, offset = 3, slope = 1})
    add_roof({type = .Gable, start = {36.5, 4.5}, end = {40.5, 7.5}, offset = 3, slope = 1})

	// add_roof({type = .Half_Hip, start = {-0.5, -0.5}, end = {1.5, 0.5}, offset = 3, slope = 1.0})

	// add_roof({type = .Half_Hip, start = {9.5, 12}, end = {11, 22}, offset = 3, slope = 1})
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
