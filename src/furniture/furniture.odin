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
	parent:   Maybe(glsl.vec3),
}

Category :: enum {
	// Chair,
	// Table,
    // Letter,
}

Type :: enum {
	// Chair,
	// Table6,
    // Letter_A,
    // Letter_G,
    // Letter_D,
    // Letter_E,
}

Rotation :: tile.Tile_Triangle_Side

texture_map := [Type][Rotation][camera.Rotation][][]billboard.Texture_1x1 {
	// .Chair =  {
	// 	.South =  {
	// 		.South_West = {{.Chair_Wood_SW}},
	// 		.South_East = {{.Chair_Wood_SE}},
	// 		.North_East = {{.Chair_Wood_NE}},
	// 		.North_West = {{.Chair_Wood_NW}},
	// 	},
	// 	.East =  {
	// 		.South_West = {{.Chair_Wood_NW}},
	// 		.South_East = {{.Chair_Wood_SW}},
	// 		.North_East = {{.Chair_Wood_SE}},
	// 		.North_West = {{.Chair_Wood_NE}},
	// 	},
	// 	.North =  {
	// 		.South_West = {{.Chair_Wood_NE}},
	// 		.South_East = {{.Chair_Wood_NW}},
	// 		.North_East = {{.Chair_Wood_SW}},
	// 		.North_West = {{.Chair_Wood_SE}},
	// 	},
	// 	.West =  {
	// 		.South_West = {{.Chair_Wood_SE}},
	// 		.South_East = {{.Chair_Wood_NE}},
	// 		.North_East = {{.Chair_Wood_NW}},
	// 		.North_West = {{.Chair_Wood_SW}},
	// 	},
	// },
	// .Table6 =  {
	// 	.South =  {
	// 		.South_West = {{.Table6_001_Wood_NE, .Table6_002_Wood_NE}},
	// 		.South_East = {{.Table6_001_Wood_NW, .Table6_002_Wood_NW}},
	// 		.North_East = {{.Table6_001_Wood_SW, .Table6_002_Wood_SW}},
	// 		.North_West = {{.Table6_001_Wood_SE, .Table6_002_Wood_SE}},
	// 	},
	// 	.East =  {
	// 		.South_West = {{.Table6_001_Wood_SE, .Table6_002_Wood_SE}},
	// 		.South_East = {{.Table6_001_Wood_NE, .Table6_002_Wood_NE}},
	// 		.North_East = {{.Table6_001_Wood_NW, .Table6_002_Wood_NW}},
	// 		.North_West = {{.Table6_001_Wood_SW, .Table6_002_Wood_SW}},
	// 	},
	// 	.North =  {
	// 		.South_West = {{.Table6_001_Wood_SW, .Table6_002_Wood_SW}},
	// 		.South_East = {{.Table6_001_Wood_SE, .Table6_002_Wood_SE}},
	// 		.North_East = {{.Table6_001_Wood_NE, .Table6_002_Wood_NE}},
	// 		.North_West = {{.Table6_001_Wood_NW, .Table6_002_Wood_NW}},
	// 	},
	// 	.West =  {
	// 		.South_West = {{.Table6_001_Wood_NW, .Table6_002_Wood_NW}},
	// 		.South_East = {{.Table6_001_Wood_SW, .Table6_002_Wood_SW}},
	// 		.North_East = {{.Table6_001_Wood_SE, .Table6_002_Wood_SE}},
	// 		.North_West = {{.Table6_001_Wood_NE, .Table6_002_Wood_NE}},
	// 	},
	// },
  //   .Letter_A = {
		// .South =  {
		// 	.South_West = {{.Letter_A_SW}},
		// 	.South_East = {{.Letter_A_SE}},
		// 	.North_East = {{.Letter_A_NE}},
		// 	.North_West = {{.Letter_A_NW}},
		// },
		// .East =  {
		// 	.South_West = {{.Letter_A_NW}},
		// 	.South_East = {{.Letter_A_SW}},
		// 	.North_East = {{.Letter_A_SE}},
		// 	.North_West = {{.Letter_A_NE}},
		// },
		// .North =  {
		// 	.South_West = {{.Letter_A_NE}},
		// 	.South_East = {{.Letter_A_NW}},
		// 	.North_East = {{.Letter_A_SW}},
		// 	.North_West = {{.Letter_A_SE}},
		// },
		// .West =  {
		// 	.South_West = {{.Letter_A_SE}},
		// 	.South_East = {{.Letter_A_NE}},
		// 	.North_East = {{.Letter_A_NW}},
		// 	.North_West = {{.Letter_A_SW}},
		// },
  //   },
  //   .Letter_G = {
		// .South =  {
		// 	.South_West = {{.Letter_G_SW}},
		// 	.South_East = {{.Letter_G_SE}},
		// 	.North_East = {{.Letter_G_NE}},
		// 	.North_West = {{.Letter_G_NW}},
		// },
		// .East =  {
		// 	.South_West = {{.Letter_G_NW}},
		// 	.South_East = {{.Letter_G_SW}},
		// 	.North_East = {{.Letter_G_SE}},
		// 	.North_West = {{.Letter_G_NE}},
		// },
		// .North =  {
		// 	.South_West = {{.Letter_G_NE}},
		// 	.South_East = {{.Letter_G_NW}},
		// 	.North_East = {{.Letter_G_SW}},
		// 	.North_West = {{.Letter_G_SE}},
		// },
		// .West =  {
		// 	.South_West = {{.Letter_G_SE}},
		// 	.South_East = {{.Letter_G_NE}},
		// 	.North_East = {{.Letter_G_NW}},
		// 	.North_West = {{.Letter_G_SW}},
		// },
  //   },
  //   .Letter_D = {
		// .South =  {
		// 	.South_West = {{.Letter_D_SW}},
		// 	.South_East = {{.Letter_D_SE}},
		// 	.North_East = {{.Letter_D_NE}},
		// 	.North_West = {{.Letter_D_NW}},
		// },
		// .East =  {
		// 	.South_West = {{.Letter_D_NW}},
		// 	.South_East = {{.Letter_D_SW}},
		// 	.North_East = {{.Letter_D_SE}},
		// 	.North_West = {{.Letter_D_NE}},
		// },
		// .North =  {
		// 	.South_West = {{.Letter_D_NE}},
		// 	.South_East = {{.Letter_D_NW}},
		// 	.North_East = {{.Letter_D_SW}},
		// 	.North_West = {{.Letter_D_SE}},
		// },
		// .West =  {
		// 	.South_West = {{.Letter_D_SE}},
		// 	.South_East = {{.Letter_D_NE}},
		// 	.North_East = {{.Letter_D_NW}},
		// 	.North_West = {{.Letter_D_SW}},
		// },
  //   },
  //   .Letter_E = {
		// .South =  {
		// 	.South_West = {{.Letter_E_SW}},
		// 	.South_East = {{.Letter_E_SE}},
		// 	.North_East = {{.Letter_E_NE}},
		// 	.North_West = {{.Letter_E_NW}},
		// },
		// .East =  {
		// 	.South_West = {{.Letter_E_NW}},
		// 	.South_East = {{.Letter_E_SW}},
		// 	.North_East = {{.Letter_E_SE}},
		// 	.North_West = {{.Letter_E_NE}},
		// },
		// .North =  {
		// 	.South_West = {{.Letter_E_NE}},
		// 	.South_East = {{.Letter_E_NW}},
		// 	.North_East = {{.Letter_E_SW}},
		// 	.North_West = {{.Letter_E_SE}},
		// },
		// .West =  {
		// 	.South_West = {{.Letter_E_SE}},
		// 	.South_East = {{.Letter_E_NE}},
		// 	.North_East = {{.Letter_E_NW}},
		// 	.North_West = {{.Letter_E_SW}},
		// },
  //   },
}

BILLBOARD_TYPE_MAP :: [Type]billboard.Billboard_Type {
	// .Chair  = .Chair,
	// .Table6 = .Table,
    // .Letter_A = .Object,
    // .Letter_G = .Object,
    // .Letter_D = .Object,
    // .Letter_E = .Object,
}

get_chunk :: proc(pos: glsl.vec3) -> ^Chunk {
	x := pos.x / constants.WORLD_CHUNK_WIDTH
	y := pos.y - terrain.get_tile_height(int(pos.x), int(pos.z))
	y /= constants.WALL_HEIGHT
	z := pos.z / constants.WORLD_CHUNK_DEPTH
	return &chunks[int(y)][int(x)][int(z)]
}

add_child :: proc(
	parent: glsl.vec3,
	pos: glsl.vec3,
	type: Type,
	rotation: Rotation,
	light: glsl.vec3 = {1, 1, 1},
	texture: billboard.Texture_1x1,
) {
	chunk := get_chunk(pos)

	chunk.furnitures[pos] = {type, rotation, light, parent}

	billboard_type_map := BILLBOARD_TYPE_MAP
	billboard.billboard_1x1_set(
		{pos = pos, type = billboard_type_map[type]},
		{light = light, texture = texture, depth_map = texture},
	)
}

get_translate :: proc(
	rotation: Rotation,
	x, z: int,
) -> (
	translate: glsl.vec3,
) {
	switch rotation {
	case .North:
		translate.x = f32(x)
		translate.z = f32(z)
	case .South:
		translate.x = f32(x)
		translate.z = f32(-z)
	case .East:
		translate.x = f32(z)
		translate.z = f32(x)
	case .West:
		translate.x = f32(-z)
		translate.z = f32(x)
	}
	return
}

update :: proc(
	pos: glsl.vec3,
	type: Type,
	rotation: Rotation,
	light: glsl.vec3 = {1, 1, 1},
) {
	remove(pos)
	add(pos, type, rotation, light)
}

Child_Iterator :: struct {
	textures: [][]billboard.Texture_1x1,
	x, z, i:  int,
}

Child :: struct {
	x, z:    int,
	texture: billboard.Texture_1x1,
}

make_child_iterator :: proc(
	type: Type,
	rotation: Rotation,
) -> (
	it: Child_Iterator,
) {
	it.textures = texture_map[type][rotation][camera.rotation]
	return
}

next_child :: proc(it: ^Child_Iterator) -> (child: Child, i: int, ok: bool) {
	for {
		if it.x >= len(it.textures) {
			return
		}

		if it.z < len(it.textures[it.x]) {
			child.x = it.x
			child.z = it.z
			child.texture = it.textures[it.x][it.z]
			i = it.i
			it.z += 1
			it.i += 1

			return child, i, true
		}

		it.z = 0
		it.x += 1
	}

	return
}

add :: proc(
	pos: glsl.vec3,
	type: Type,
	rotation: Rotation,
	light: glsl.vec3 = {1, 1, 1},
) {
	chunk := get_chunk(pos)

	textures := texture_map[type][rotation][camera.rotation]
	for col, x in textures {
		for texture, z in col {
			translate := get_translate(rotation, x, z)
			add_child(pos, pos + translate, type, rotation, light, texture)
		}
	}

	chunk.furnitures[pos] = {type, rotation, light, nil}
}

remove_parent :: proc(pos: glsl.vec3) {
	chunk := get_chunk(pos)
	furniture := chunk.furnitures[pos]

	textures :=
		texture_map[furniture.type][furniture.rotation][camera.rotation]
	for col, x in textures {
		for texture, z in col {
			translate := get_translate(furniture.rotation, x, z)
			remove_child(pos + translate)
		}
	}
}

remove_child :: proc(pos: glsl.vec3) {
	chunk := get_chunk(pos)
	furniture := chunk.furnitures[pos]

	billboard_type_map := BILLBOARD_TYPE_MAP
	billboard.billboard_1x1_remove({pos, billboard_type_map[furniture.type]})

	delete_key(&chunk.furnitures, pos)
}

remove :: proc(pos: glsl.vec3) {
	chunk := get_chunk(pos)
	furniture := chunk.furnitures[pos]
	if parent, ok := furniture.parent.?; ok {
		remove_parent(parent)
	} else {
		remove_parent(pos)
	}
}

has :: proc(pos: glsl.vec3) -> bool {
	chunk := get_chunk(pos)

	return pos in chunk.furnitures
}

get :: proc(pos: glsl.vec3) -> (Furniture, bool) {
	chunk := get_chunk(pos)

	return chunk.furnitures[pos]
}

can_place :: proc(pos: glsl.vec3, type: Type, rotation: Rotation) -> bool {
	textures := texture_map[type][rotation][camera.rotation]

	for col, x in textures {
		for texture, z in col {
			translate := get_translate(rotation, x, z)
			if has(pos + translate) {
				return false
			}
		}
	}

	return true
}
