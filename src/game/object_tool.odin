package game

import "core:math/linalg/glsl"

Object_Tool_Context :: struct {
	pos: glsl.vec3,
}

init_object_tool :: proc(ctx: ^Game_Context) {
    
}

update_object_tool :: proc(ctx: ^Game_Context) {

}

draw_object_tool :: proc(ctx: ^Game_Context) {
    a :^Game_Context = (^Game_Context)(context.user_ptr)
}
