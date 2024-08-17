package game

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
import "../terrain"

Object_Type :: enum {
	// Door,
	Window,
	// Chair,
	// Table,
	// Painting,
	Counter,
	// Carpet,
	// Tree,
	// Wall,
	// Wall_Top,
}

Object_Model :: enum {
	// Wood_Door,
	Wood_Window,
	// Wood_Chair,
	// Wood_Table_1x2,
	// Poutine_Painting,
	Wood_Counter,
	// Small_Carpet,
	// Tree,
}

Object_Orientation :: enum {
	South,
	West,
	North,
	East,
}

Object_Placement :: enum {
	Floor,
	Wall,
	Counter,
	Table,
}

Object_Placement_Set :: bit_set[Object_Placement]

OBJECT_TYPE_PLACEMENT_TABLE :: [Object_Type]Object_Placement_Set {
	// .Door = {.Wall},
	.Window = {.Wall},
	// .Chair = {.Floor},
	// .Table = {.Floor},
	// .Painting = {.Wall},
	.Counter = {.Floor},
	// .Carpet = {.Floor},
	// .Tree = {.Floor},
	// .Wall = {.Floor},
	// .Wall_Top = {.Wall},
}

OBJECT_MODEL_PLACEMENT_TABLE :: #partial [Object_Model]Object_Placement_Set{}

OBJECT_TYPE_MAP :: [Object_Model]Object_Type {
	// .Wood_Door                           = .Door,
	.Wood_Window                         = .Window,
	// .Wood_Chair                          = .Chair,
	// .Wood_Table_1x2                      = .Table,
	// .Poutine_Painting                    = .Painting,
	.Wood_Counter = .Counter,
	// .Small_Carpet                        = .Carpet,
	// .Tree                                = .Tree,
}

OBJECT_MODEL_MAP :: [Object_Model]string {
	.Wood_Counter = "Wood.Counter.Bake",
	.Wood_Window = "Window.Wood.Bake",
}

OBJECT_MODEL_TEXTURE_MAP :: [Object_Model]string {
	.Wood_Counter = "objects/Wood.Counter.png",
	.Wood_Window = "objects/Wood.Window.png",
}

Object :: struct {
	pos:         glsl.vec3,
	light:       glsl.vec3,
	model:       string,
	texture:     string,
	type:        Object_Type,
	orientation: Object_Orientation,
	placement:   Object_Placement,
}

Object_Chunk :: struct {
	objects: [dynamic]Object,
	dirty:   bool,
}

Object_Chunks :: [c.CHUNK_HEIGHT][c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Object_Chunk

Object_Uniform_Object :: struct {
	mvp: glsl.mat4,
}

OBJECT_VERTEX_SHADER_PATH :: "resources/shaders/object.vert"
OBJECT_FRAGMENT_SHADER_PATH :: "resources/shaders/object.frag"

Objects_Context :: struct {
	chunks:         Object_Chunks,
	shader_program: u32,
	ubo:            u32,
}


init_objects :: proc(using ctx: ^Game_Context) -> (ok: bool = true) {
	using ctx.objects

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)


	renderer.load_shader_program(
		&shader_program,
		OBJECT_VERTEX_SHADER_PATH,
		OBJECT_FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture_sampler"), 0)

	gl.GenBuffers(1, &ubo)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.UseProgram(0)

	add_object(ctx, {1, 0, 1}, .Wood_Counter, .South, .Floor)
	add_object(ctx, {2, 0, 1}, .Wood_Counter, .South, .Floor)
	add_object(ctx, {3, 0, 1}, .Wood_Counter, .South, .Floor)

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

delete_objects :: proc(using ctx: ^Game_Context) {
    using objects

    for &row in chunks {
        for &col in row {
            for &chunk in col {
                delete(chunk.objects)
            }
        }
    }
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

draw_object :: proc(using ctx: ^Game_Context, using object: ^Object) -> bool {
	translate := glsl.mat4Translate(object.pos)
    rotation_radian := f32(orientation) * 0.5 * math.PI
    rotation := glsl.mat4Rotate({0, 1, 0}, rotation_radian)
    uniform_object:= Object_Uniform_Object{
	    mvp = camera.view_proj * translate * rotation,
    }

	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Object_Uniform_Object),
		&uniform_object,
		gl.STATIC_DRAW,
	)

	gl.ActiveTexture(gl.TEXTURE0)
    bind_texture(&textures, texture)

	bind_model(&models, model) or_return
    draw_model(&models, model)

    return true
}

draw_chunk :: proc(ctx: ^Game_Context, using chunk: ^Object_Chunk) -> bool {
    if len(objects) == 0 {
        return true
    }

	for &object in objects {
		draw_object(ctx, &object) or_return
	}

    return true
}

draw_objects :: proc(using ctx: ^Game_Context) -> bool {
    using objects

	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	ubo_index := gl.GetUniformBlockIndex(shader_program, "UniformBufferObject")
	gl.UniformBlockBinding(shader_program, ubo_index, 2)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)

	//
	gl.UseProgram(shader_program)
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
	for floor in 0 ..= floor.floor {
		it := camera.make_visible_chunk_iterator()
		for pos in it->next() {
			draw_chunk(ctx, &chunks[floor][pos.x][pos.y]) or_return
		}
	}

    return true
}

add_object :: proc(
	using ctx: ^Game_Context,
	pos: glsl.vec3,
	model: Object_Model,
	orientation: Object_Orientation,
	placement: Object_Placement,
) {
	using objects
	x := int(pos.x)
	z := int(pos.z)
	y := int(pos.y - terrain.get_tile_height(x, z)) / c.WALL_HEIGHT
	x /= c.CHUNK_WIDTH
	z /= c.CHUNK_DEPTH
	chunk := &chunks[y][x][z]

	chunk.dirty = true

	type_map := OBJECT_TYPE_MAP

	model_map := OBJECT_MODEL_MAP
	texture_map := OBJECT_MODEL_TEXTURE_MAP

	append(
		&chunk.objects,
		Object {
			pos = pos,
			type = type_map[model],
			model = model_map[model],
			texture = texture_map[model],
			orientation = orientation,
			placement = placement,
		},
	)
}

on_add :: proc(
	pos: glsl.ivec3,
	model: Object_Model,
	orientation: Object_Orientation,
) {
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
	model: Object_Model,
	orientation: Object_Orientation,
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
	model: Object_Model,
	orientation: Object_Orientation,
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
