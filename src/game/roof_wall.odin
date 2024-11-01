package game

import "core:math/linalg/glsl"

Roof_Wall :: struct {
	textures: [Wall_Side]Wall_Texture,
	slope:    glsl.vec3,
}

Roof_Wall_Context :: struct {

}
//
// Roof_Chunk :: struct {
// 	roofs:        [dynamic]Roof,
// 	dirty:        bool,
// 	roofs_inside: [dynamic]Roof_Id,
// }
//
// Roof_Chunks :: [c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Roof_Chunk
//
// Roof_Uniform_Object :: struct {
// 	mvp:   glsl.mat4,
// 	light: glsl.vec3,
// }
//
// Roof_Vertex :: struct {
// 	pos:       glsl.vec3,
// 	texcoords: glsl.vec3,
// 	color:     glsl.vec3,
// }
//
// Roof_Index :: u32
//
// Roofs_Context :: struct {
// 	chunks:        Roof_Chunks,
// 	keys:          map[Roof_Id]Roof_Key,
// 	next_id:       Roof_Id,
// 	ubo:           u32,
// 	shader:        Shader,
// 	vao, vbo, ebo: u32,
// 	texture_array: u32,
// }
