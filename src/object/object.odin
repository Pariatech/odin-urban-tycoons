package object

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg/glsl"
import "core:path/filepath"
import "core:slice"
import "core:strings"

import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"

import "../camera"
import c "../constants"
import "../floor"
import "../renderer"
import "../wall"
import "../terrain"

Type :: enum {
	// Door,
	// Window,
	// Chair,
	// Table,
	// Painting,
	Counter,
	// Carpet,
	// Tree,
	// Wall,
	// Wall_Top,
}

Model :: enum {
	// Wood_Door,
	// Wood_Window,
	// Wood_Chair,
	// Wood_Table_1x2,
	// Poutine_Painting,
	Wood_Counter,
	// Small_Carpet,
	// Tree,
}

Orientation :: enum {
	South,
	East,
	North,
	West,
}

Placement :: enum {
	Floor,
	Wall,
	Counter,
	Table,
}

Placement_Set :: bit_set[Placement]

TYPE_PLACEMENT_TABLE :: [Type]Placement_Set {
	// .Door = {.Wall},
	// .Window = {.Wall},
	// .Chair = {.Floor},
	// .Table = {.Floor},
	// .Painting = {.Wall},
	.Counter = {.Floor},
	// .Carpet = {.Floor},
	// .Tree = {.Floor},
	// .Wall = {.Floor},
	// .Wall_Top = {.Wall},
}

MODEL_PLACEMENT_TABLE :: #partial [Model]Placement_Set{}

TYPE_MAP :: [Model]Type {
	// .Wood_Door                           = .Door,
	// .Wood_Window                         = .Window,
	// .Wood_Chair                          = .Chair,
	// .Wood_Table_1x2                      = .Table,
	// .Poutine_Painting                    = .Painting,
	.Wood_Counter                        = .Counter,
	// .Small_Carpet                        = .Carpet,
	// .Tree                                = .Tree,
}

MODEL_MAP :: [Model]string {
    .Wood_Counter = "Wood.Counter.Bake",
}

MODEL_TEXTURE_MAP :: [Model]string {
    .Wood_Counter = "objects/Wood.Counter.png",
}

Object :: struct {
	pos:         glsl.vec3,
	light:       glsl.vec3,
	model:       Model,
	texture:     string,
	type:        Type,
	orientation: Orientation,
	placement:   Placement,
}

Chunk :: struct {
	objects:  [dynamic]Object,
	dirty:    bool,
}

Chunks :: [c.CHUNK_HEIGHT][c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Chunk

Uniform_Object :: struct {
	mvp: glsl.mat4,
}

VERTEX_SHADER_PATH :: "resources/shaders/object.vert"
FRAGMENT_SHADER_PATH :: "resources/shaders/object.frag"

chunks: Chunks
shader_program: u32
ubo: u32
uniform_object: Uniform_Object

init :: proc() -> (ok: bool = true) {
	// gl.Enable(gl.MULTISAMPLE)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)


	renderer.load_shader_program(
		&shader_program,
		VERTEX_SHADER_PATH,
		FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture_sampler"), 0)

	gl.GenBuffers(1, &ubo)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.UseProgram(0)

	for z in 0 ..< c.WORLD_HEIGHT {
		for x in 0 ..< c.WORLD_CHUNK_WIDTH {
			for y in 0 ..< c.WORLD_CHUNK_DEPTH {
				init_chunk(&chunks[z][x][y])
			}
		}
	}

	// add({3, 0, 3}, .Wood_Chair, .South, .Floor)
	// add({4, 0, 4}, .Wood_Chair, .East, .Floor)
	// add({3, 0, 5}, .Wood_Chair, .North, .Floor)
	// add({2, 0, 4}, .Wood_Chair, .West, .Floor)
	//
	// add({0, 0, 1}, .Wood_Table_1x2, .South, .Floor)
	// add({2, 0, 0}, .Wood_Table_1x2, .North, .Floor)
	// add({0, 0, 2}, .Wood_Table_1x2, .East, .Floor)
	// add({1, 0, 4}, .Wood_Table_1x2, .West, .Floor)
	//
	// wall.set_wall(
	// 	{5, 0, 5},
	// 	.N_S,
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	// wall.set_wall(
	// 	{5, 0, 5},
	// 	.E_W,
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	//
	// add({5, 0, 5}, .Wood_Window, .South, .Wall)
	// add({5, 0, 5}, .Wood_Window, .West, .Wall)
	//
	// wall.set_wall(
	// 	{7, 0, 5},
	// 	.N_S,
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	// wall.set_wall(
	// 	{7, 0, 5},
	// 	.E_W,
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	//
	// add({7, 0, 4}, .Wood_Window, .North, .Wall)
	// add({6, 0, 5}, .Wood_Window, .East, .Wall)
	//
	// wall.set_wall(
	// 	{9, 0, 5},
	// 	.N_S,
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	// wall.set_wall(
	// 	{9, 0, 5},
	// 	.E_W,
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	//
	// add({9, 0, 5}, .Wood_Door, .South, .Wall)
	// add({9, 0, 5}, .Wood_Door, .West, .Wall)
	//
	// wall.set_wall(
	// 	{11, 0, 5},
	// 	.N_S,
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	// wall.set_wall(
	// 	{11, 0, 5},
	// 	.E_W,
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	//
	// add({11, 0, 4}, .Wood_Door, .North, .Wall)
	// add({10, 0, 5}, .Wood_Door, .East, .Wall)
	//
	// wall.set_wall(
	// 	{13, 0, 5},
	// 	.N_S,
	// 	 {
	// 		type = .End_Right_Corner,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	// wall.set_wall(
	// 	{13, 0, 5},
	// 	.E_W,
	// 	 {
	// 		type = .Left_Corner_End,
	// 		textures = {.Inside = .Brick, .Outside = .Brick},
	// 	},
	// )
	//
	// add({13, 0, 5}, .Poutine_Painting, .South, .Wall)
	// add({13, 0, 5}, .Poutine_Painting, .West, .Wall)
	// add({13, 0, 4}, .Poutine_Painting, .North, .Wall)
	// add({12, 0, 5}, .Poutine_Painting, .East, .Wall)
	//
	// add({1, 0, 7}, .Wood_Counter, .South, .Floor)
	// add({0, 0, 8}, .Wood_Counter, .West, .Floor)
	// add({2, 0, 8}, .Wood_Counter, .East, .Floor)
	// add({1, 0, 9}, .Wood_Counter, .North, .Floor)
	//
	// add({0, 0, 14}, .Wood_Counter, .West, .Floor)
	// add({0, 0, 13}, .Wood_Counter, .West, .Floor)
	// add({0, 0, 12}, .Wood_Counter, .West, .Floor)
	// add({0, 0, 11}, .Wood_Counter, .West, .Floor)
	//
	// add({12, 0, 0}, .Small_Carpet, .South, .Floor)
	//
	//
	// add({14, 0, 1}, .Tree, .South, .Floor)
	//
	// add({17, 0, 0}, .Tree, .North, .Floor)
	//
	// add({20, 0, 1}, .Tree, .East, .Floor)
	// add({24, 0, 0}, .Tree, .West, .Floor)
	//
	// add({3, 0, 11}, .Wall_Side_Top, .South, .Floor, mask = .None, offset_y = 2.75)
	// add({3, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .None)
	//
	// add({4, 0, 11}, .Wall_Cutaway_Left_Top, .South, .Floor, mask = .None)
	// add({4, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .Cutaway_Left)
	//
	// add({5, 0, 11}, .Wall_Side_Top, .South, .Floor, mask = .None, offset_y = 0.115)
	// add({5, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .Down)
	//
	// add({6, 0, 11}, .Wall_Short_Top, .South, .Floor, mask = .None, offset_y = 0.115)
	// add({6, 0, 11}, .Wall_Side_Bricks012, .South, .Floor, mask = .Down_Short)
	//
	// add({3, 0, 11}, .Wood_Counter, .East, .Floor)
	//
	// add({3, 0, 11}, .Wall_Side_Bricks012, .West, .Floor, mask = .None)
	// add({3, 0, 12}, .Wall_Side_Bricks012, .West, .Floor, mask = .None)
	// add({3, 0, 13}, .Wall_Side_Bricks012, .West, .Floor, mask = .Cutaway_Left)
	// add({3, 0, 14}, .Wall_Side_Bricks012, .West, .Floor, mask = .Down)
	// add({3, 0, 15}, .Wall_Side_Bricks012, .West, .Floor, mask = .Down_Short)
	//
	// add({15, 0, 15}, .Wall_Side_Bricks012, .South, .Floor, mask = .None)
	// add({15, 0, 15}, .Wall_Side_Bricks012, .West, .Floor, mask = .None)
	// add({15, 0, 15}, .Wood_Counter, .East, .Floor)

	// log.debug(can_add({0, 0, 1}, .Wood_Table_1x2, .South))
	// log.debug(can_add({0, 0, 0}, .Wood_Table_1x2, .North))
	// log.debug(can_add({1, 0, 0}, .Wood_Table_1x2, .West))
	// log.debug(can_add({1, 0, 0}, .Wood_Table_1x2, .East))
	// log.debug(can_add({3, 0, 4}, .Wood_Table_1x2, .East))

	return true
}

init_chunk :: proc(using chunk: ^Chunk) {
}

sort_objects :: proc(a, b: Object) -> bool {
	// switch camera.rotation {
	// case .South_West:
	// 	if a.type == .Wall &&
	// 	   b.type != .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return false
	// 	}
	// 	if a.type != .Wall &&
	// 	   b.type == .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return true
	// 	}
	// 	return a.pos.z > b.pos.z || (a.pos.z == b.pos.z && a.pos.x > b.pos.x)
	// case .South_East:
	// 	if a.type == .Wall &&
	// 	   b.type != .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return a.orientation == .West
	// 	}
	// 	if a.type != .Wall &&
	// 	   b.type == .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return b.orientation == .South
	// 	}
	// 	if a.type == .Wall &&
	// 	   b.type == .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return a.orientation == .West
	// 	}
	// 	return a.pos.z > b.pos.z || (a.pos.z == b.pos.z && a.pos.x < b.pos.x)
	// case .North_East:
	// 	if a.type == .Wall &&
	// 	   b.type != .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return true
	// 	}
	// 	if a.type != .Wall &&
	// 	   b.type == .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return false
	// 	}
	// 	return a.pos.z < b.pos.z || (a.pos.z == b.pos.z && a.pos.x < b.pos.x)
	// case .North_West:
	// 	if a.type == .Wall &&
	// 	   b.type != .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return a.orientation == .South
	// 	}
	// 	if a.type != .Wall &&
	// 	   b.type == .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return b.orientation == .West
	// 	}
	// 	if a.type == .Wall &&
	// 	   b.type == .Wall &&
	// 	   a.pos.x == b.pos.x &&
	// 	   a.pos.z == b.pos.z {
	// 		return a.orientation == .South
	// 	}
	// 	return a.pos.z < b.pos.z || (a.pos.z == b.pos.z && a.pos.x > b.pos.x)
	// }
	return false
}

draw_chunk :: proc(using chunk: ^Chunk) {
	// instances := len(objects)
	//
	// if dirty {
	// 	dirty = false
	//
	//
	// 	gl.BindBuffer(gl.ARRAY_BUFFER, ibo)
	// 	gl.BufferData(
	// 		gl.ARRAY_BUFFER,
	// 		instances * size_of(Instance),
	// 		nil,
	// 		gl.STATIC_DRAW,
	// 	)
	//
	// 	slice.sort_by(objects[:], sort_objects)
	// 	i := 0
	// 	for v in objects {
	// 		texture := f32(v.texture)
	// 		instance := get_instance(v)
	// 		gl.BufferSubData(
	// 			gl.ARRAY_BUFFER,
	// 			i * size_of(Instance),
	// 			size_of(Instance),
	// 			&instance,
	// 		)
	// 		i += 1
	// 	}
	//
	// 	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	// }
	//
	// gl.BindVertexArray(vao)
	// gl.DrawElementsInstanced(
	// 	gl.TRIANGLES,
	// 	i32(len(indices)),
	// 	gl.UNSIGNED_BYTE,
	// 	nil,
	// 	i32(instances),
	// )
	// gl.BindVertexArray(0)
}

draw :: proc() {
	// gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	// ubo_index := gl.GetUniformBlockIndex(shader_program, "UniformBufferObject")
	// gl.UniformBlockBinding(shader_program, ubo_index, 2)
	// gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)
	//
	// uniform_object.view_proj = camera.view_proj
	//
	// gl.BufferData(
	// 	gl.UNIFORM_BUFFER,
	// 	size_of(Uniform_Object),
	// 	&uniform_object,
	// 	gl.STATIC_DRAW,
	// )
	//
	// gl.UseProgram(shader_program)
	//
	// gl.ActiveTexture(gl.TEXTURE0)
	// gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)
	//
	// gl.ActiveTexture(gl.TEXTURE1)
	// gl.BindTexture(gl.TEXTURE_2D_ARRAY, depth_map_texture_array)
	//
	// gl.ActiveTexture(gl.TEXTURE2)
	// gl.BindTexture(gl.TEXTURE_2D_ARRAY, mask_texture_array)
	//
	// gl.DepthFunc(gl.ALWAYS)
	// defer gl.DepthFunc(gl.LEQUAL)
	//
	// gl.Disable(gl.MULTISAMPLE)
	// defer gl.Enable(gl.MULTISAMPLE)
	//
	// for floor in 0 ..< c.WORLD_HEIGHT {
	// 	it := camera.make_visible_chunk_iterator()
	// 	for pos in it->next() {
	// 		draw_chunk(&chunks[floor][pos.x][pos.y])
	// 	}
	// }
}

add :: proc(
	pos: glsl.vec3,
	model: Model,
	orientation: Orientation,
	placement: Placement,
	offset_y: f32 = 0,
) {
    x := int(pos.x)
    z := int(pos.z)
    y := int(pos.y - terrain.get_tile_height(x, z)) / c.WALL_HEIGHT
    x /= c.CHUNK_WIDTH
    z /= c.CHUNK_DEPTH
    chunk := &chunks[y][x][z]

    chunk.dirty = true
	// type_map := TYPE_MAP
	// model_size := MODEL_SIZE
	//
	// parent := pos
	// size := model_size[model]
	// type := type_map[model]
	// for x in 0 ..< size.x {
	// 	for y in 0 ..< size.y {
	// 		pos := pos + relative_pos(x, y, orientation)
	// 		chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]
	// 		append(
	// 			&chunk.objects,
	// 			Object {
	// 				pos = pos,
	// 				type = type,
	// 				model = model,
	// 				orientation = orientation,
	// 				placement = placement,
	// 				texture = get_texture(x, y, model, orientation),
	// 				depth_map = get_depth_map(x, y, model, orientation),
	// 				parent = parent,
	// 				light = {1, 1, 1},
	// 				mask = mask,
	// 				offset_y = offset_y,
	// 			},
	// 		)
	// 		chunk.dirty = true
	// 	}
	// }
	//
	// on_add(pos, model, orientation)
}

on_add :: proc(pos: glsl.ivec3, model: Model, orientation: Orientation) {
	// type_map := TYPE_MAP
	// type := type_map[model]
	//
	// if type != .Window && type != .Door {
	// 	return
	// }
	//
	// switch orientation {
	// case .South, .North:
	// 	pos := pos
	// 	if orientation == .North {
	// 		pos += {0, 0, 1}
	// 	}
	// 	if w, ok := wall.get_wall(pos, .E_W); ok {
	// 		if type == .Window {
	// 			w.mask = .Window_Opening
	// 		} else {
	// 			w.mask = .Door_Opening
	// 		}
	// 		wall.set_wall(pos, .E_W, w)
	// 	}
	// case .East, .West:
	// 	pos := pos
	// 	if orientation == .East {
	// 		pos += {1, 0, 0}
	// 	}
	// 	if w, ok := wall.get_wall(pos, .N_S); ok {
	// 		if type == .Window {
	// 			w.mask = .Window_Opening
	// 		} else {
	// 			w.mask = .Door_Opening
	// 		}
	// 		wall.set_wall(pos, .N_S, w)
	// 	}
	// }
}

can_add_on_wall :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
) -> bool {
	// model_size := MODEL_SIZE
	//
	// size := model_size[model]
	// for x in 0 ..< size.x {
	// 	switch orientation {
	// 	case .South, .North:
	// 		pos := pos + {x, 0, 0}
	// 		if orientation == .North {
	// 			pos += {0, 0, 1}
	// 		}
	// 		if !wall.has_east_west_wall(pos) {
	// 			return false
	// 		}
	// 	case .East, .West:
	// 		pos := pos + {0, 0, x}
	// 		if orientation == .East {
	// 			pos += {1, 0, 0}
	// 		}
	// 		if !wall.has_north_south_wall(pos) {
	// 			return false
	// 		}
	// 	}
	//
	// 	for y in 0 ..< size.y {
	// 		pos := pos + relative_pos(x, y, orientation)
	// 		chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]
	//
	// 		obstacle_orientation := orientation
	// 		if y != 0 {
	// 			obstacle_orientation = Orientation(int(orientation) + 2 % 4)
	// 		}
	// 		for k, v in chunk.objects {
	// 			if k.pos == pos &&
	// 			   k.placement == .Wall &&
	// 			   k.orientation == obstacle_orientation {
	// 				return false
	// 			}
	// 		}
	// 	}
	// }

	return true
}

can_add_on_floor :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
) -> bool {
	// model_size := MODEL_SIZE
	//
	// size := model_size[model]
	// for x in 0 ..< size.x {
	// 	for y in 0 ..< size.y {
	// 		pos := pos + relative_pos(x, y, orientation)
	// 		chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]
	//
	// 		for k, v in chunk.objects {
	// 			if k.pos == pos && k.placement == .Floor {
	// 				return false
	// 			}
	// 		}
	// 	}
	// }

	return true
}
