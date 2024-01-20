package main

import "core:fmt"
import m "core:math/linalg/glsl"

SPRITE_WIDTH :: 1.115
SPRITE_HEIGHT :: 1.9312
SPRITE_START :: 0.0575
SPRITE_END :: 1.0575

SPRITE_VERTEX_POSITION_MAP :: [Camera_Rotation][4]m.vec3 {
	.South_West =  {
		{-SPRITE_END, 0.0, SPRITE_START},
		{-SPRITE_END, SPRITE_HEIGHT, SPRITE_START},
		{SPRITE_START, SPRITE_HEIGHT, -SPRITE_END},
		{SPRITE_START, 0.0, -SPRITE_END},
	},
	.South_East =  {
		{-SPRITE_START, 0.0, -SPRITE_END},
		{-SPRITE_START, SPRITE_HEIGHT, -SPRITE_END},
		{SPRITE_END, SPRITE_HEIGHT, SPRITE_START},
		{SPRITE_END, 0.0, SPRITE_START},
	},
	.North_East =  {
		{SPRITE_END, 0.0, -SPRITE_START},
		{SPRITE_END, SPRITE_HEIGHT, -SPRITE_START},
		{-SPRITE_START, SPRITE_HEIGHT, SPRITE_END},
		{-SPRITE_START, 0.0, SPRITE_END},
	},
	.North_West =  {
		{SPRITE_START, 0.0, SPRITE_END},
		{SPRITE_START, SPRITE_HEIGHT, SPRITE_END},
		{-SPRITE_END, SPRITE_HEIGHT, -SPRITE_START},
		{-SPRITE_END, 0.0, -SPRITE_START},
	},
}

Sprite_Mirror :: enum {
	Yes,
	No,
}

SPRITE_VERTEX_TEXCOORDS_MAP :: [Sprite_Mirror][4]m.vec4 {
	.No = {{0, 1, 0, 0}, {0, 0, 0, 0}, {1, 0, 0, 0}, {1, 1, 0, 0}},
	.Yes = {{1, 1, 0, 0}, {1, 0, 0, 0}, {0, 0, 0, 0}, {0, 1, 0, 0}},
}

Sprite :: struct {
    position: m.vec3,
    mirror: Sprite_Mirror,
    texture: Texture,
    mask_texture: Texture,
    lights: [4]m.vec3,
}

draw_sprite :: proc(sprite: Sprite) {
	position_map := SPRITE_VERTEX_POSITION_MAP
	texcoords_map := SPRITE_VERTEX_TEXCOORDS_MAP
	positions := position_map[camera_rotation]
	texcoords := texcoords_map[sprite.mirror]
	vertices: [4]Vertex

	for i in 0 ..< len(vertices) {
		texcoords[i].z = f32(sprite.texture)
		texcoords[i].w = f32(sprite.mask_texture)
	    positions[i] += sprite.position
		vertices[i] = {
			pos       = positions[i],
			light     = sprite.lights[i],
			texcoords = texcoords[i],
		}
	}

	draw_quad(vertices[0], vertices[1], vertices[2], vertices[3])
}
