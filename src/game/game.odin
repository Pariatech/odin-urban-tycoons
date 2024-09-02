package game

Game_Context :: struct {
    textures: Textures_Context,
    models: Models_Context,
    objects: Objects_Context,
    shaders: Shaders_Context,
    object_tool: Object_Tool_Context,
    object_draws: Object_Draws,
}

get_game_context :: proc() -> ^Game_Context {
    return (^Game_Context)(context.user_ptr)
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
    init_object_draws() or_return
    init_object_tool()
    return true
}

deinit_game :: proc() {
    deinit_object_draws()
    deinit_object_tool()
}

update_game_on_camera_rotation :: proc() {
    update_objects_on_camera_rotation()
}

