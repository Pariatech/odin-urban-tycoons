package furniture

import "core:math/linalg/glsl"

import "../billboard"
import "../camera"
import "../constants"
import "../terrain"
import "../tile"

chunks: [constants.CHUNK_HEIGHT][constants.WORLD_CHUNK_WIDTH][constants.WORLD_CHUNK_DEPTH]Chunk

Chunk :: struct {
	furnitures: map[glsl.vec3]Furniture,
}

Furniture :: struct {
	type:     Type,
	rotation: Rotation,
	light:    glsl.vec3,
}

Type :: enum {
	Chair,
}

Rotation :: tile.Tile_Triangle_Side

TEXTURE_MAP :: [Type][Rotation][camera.Rotation]billboard.Texture_1x1 {
	.Chair =  {
		.South =  {
			.South_West = .Chair_Wood_SW,
			.South_East = .Chair_Wood_SE,
			.North_East = .Chair_Wood_NE,
			.North_West = .Chair_Wood_NW,
		},
		.East =  {
			.South_West = .Chair_Wood_NW,
			.South_East = .Chair_Wood_SW,
			.North_East = .Chair_Wood_SE,
			.North_West = .Chair_Wood_NE,
		},
		.North =  {
			.South_West = .Chair_Wood_NE,
			.South_East = .Chair_Wood_NW,
			.North_East = .Chair_Wood_SW,
			.North_West = .Chair_Wood_SE,
		},
		.West =  {
			.South_West = .Chair_Wood_SE,
			.South_East = .Chair_Wood_NE,
			.North_East = .Chair_Wood_NW,
			.North_West = .Chair_Wood_SW,
		},
	},
}

BILLBOARD_TYPE_MAP :: [Type]billboard.Billboard_Type {
	.Chair = .Chair,
}

get_chunk :: proc(pos: glsl.vec3) -> ^Chunk {
	x := pos.x / constants.WORLD_CHUNK_WIDTH
	y := pos.y - terrain.get_tile_height(int(pos.x), int(pos.z))
	y /= constants.WALL_HEIGHT
	z := pos.z / constants.WORLD_CHUNK_DEPTH
	return &chunks[int(y)][int(x)][int(z)]
}

add :: proc(
	pos: glsl.vec3,
	type: Type,
	rotation: Rotation,
	light: glsl.vec3 = {1, 1, 1},
) {
	chunk := get_chunk(pos)
	chunk.furnitures[pos] = {type, rotation, light}

	texture_map := TEXTURE_MAP

	billboard_type_map := BILLBOARD_TYPE_MAP

	billboard.billboard_1x1_set(
		{pos = pos, type = billboard_type_map[type]},
		 {
			light = light,
			texture = texture_map[type][rotation][camera.rotation],
			depth_map = texture_map[type][rotation][camera.rotation],
		},
	)
}

remove :: proc(pos: glsl.vec3) {
	chunk := get_chunk(pos)
	furniture := chunk.furnitures[pos]
	delete_key(&chunk.furnitures, pos)

	billboard_type_map := BILLBOARD_TYPE_MAP
	billboard.billboard_1x1_remove({pos, billboard_type_map[furniture.type]})
}

has :: proc(pos: glsl.vec3) -> bool {
	chunk := get_chunk(pos)

	return pos in chunk.furnitures
}
