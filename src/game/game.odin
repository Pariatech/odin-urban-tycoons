package game

Game_Context :: struct {
    textures: Textures_Context,
    models: Models_Context,
    objects: Objects_Context,
    shaders: Shaders_Context,
    object_tool: Object_Tool_Context,
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

init_game :: proc() -> bool {
    init_object_tool()
    return true
}

