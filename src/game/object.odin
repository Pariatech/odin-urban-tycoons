package game

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg"
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
	Door,
	Window,
	// Chair,
	Table,
	// Painting,
	Counter,
	// Carpet,
	// Tree,
	// Wall,
	// Wall_Top,
}

Object_Model :: enum {
	Wood_Door,
	Wood_Window,
	// Wood_Chair,
	Wood_Table_6Places,
	Wood_Table_8Places,
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
	.Door = {.Wall},
	.Window = {.Wall},
	// .Chair = {.Floor},
	.Table = {.Floor},
	// .Painting = {.Wall},
	.Counter = {.Floor},
	// .Carpet = {.Floor},
	// .Tree = {.Floor},
	// .Wall = {.Floor},
	// .Wall_Top = {.Wall},
}

OBJECT_MODEL_PLACEMENT_TABLE :: #partial [Object_Model]Object_Placement_Set{}

OBJECT_TYPE_MAP :: [Object_Model]Object_Type {
	.Wood_Door          = .Door,
	.Wood_Window        = .Window,
	// .Wood_Chair                          = .Chair,
	// .Wood_Table_1x2                      = .Table,
	.Wood_Table_6Places = .Table,
	.Wood_Table_8Places = .Table,
	// .Poutine_Painting                    = .Painting,
	.Wood_Counter       = .Counter,
	// .Small_Carpet                        = .Carpet,
	// .Tree                                = .Tree,
}

OBJECT_MODEL_MAP :: [Object_Model]string {
	.Wood_Counter       = "Wood.Counter.Bake",
	.Wood_Window        = "Window.Wood.Bake",
	.Wood_Door          = "Door.Wood.Bake",
	.Wood_Table_6Places = "Table.6Places.Bake",
	.Wood_Table_8Places = "Table.8Places.Bake",
}

OBJECT_MODEL_TEXTURE_MAP :: [Object_Model]string {
	.Wood_Counter       = "objects/Wood.Counter.png",
	.Wood_Window        = "objects/Wood.Window.png",
	.Wood_Door          = "objects/Door.Wood.png",
	.Wood_Table_6Places = "objects/Table.6Places.Wood.png",
	.Wood_Table_8Places = "objects/Table.8Places.Wood.png",
}

Object :: struct {
	pos:         glsl.vec3,
	light:       glsl.vec3,
	model:       string,
	texture:     string,
	type:        Object_Type,
	orientation: Object_Orientation,
	placement:   Object_Placement,
	size:        glsl.ivec3,
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

	add_object(ctx, {5, 0, 1}, .Wood_Table_6Places, .South, .Floor)
	add_object(ctx, {8, 0, 1}, .Wood_Table_8Places, .South, .Floor)

	add_object(ctx, {5, 0, 4}, .Wood_Table_6Places, .East, .Floor)
	add_object(ctx, {8, 0, 4}, .Wood_Table_8Places, .East, .Floor)

	add_object(ctx, {5, 0, 7}, .Wood_Table_6Places, .North, .Floor)
	add_object(ctx, {8, 0, 7}, .Wood_Table_8Places, .North, .Floor)

	add_object(ctx, {5, 0, 10}, .Wood_Table_6Places, .West, .Floor)
	add_object(ctx, {8, 0, 10}, .Wood_Table_8Places, .West, .Floor)

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
	uniform_object := Object_Uniform_Object {
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

world_pos_to_tile_pos :: proc(pos: glsl.vec3) -> (tile_pos: glsl.ivec2) {
	tile_pos.x = i32(pos.x + 0.5)
	tile_pos.y = i32(pos.z + 0.5)
	return
}

world_pos_to_chunk_pos :: proc(
	g: ^Game_Context,
	pos: glsl.vec3,
) -> (
	chunk_pos: glsl.ivec3,
) {
	tile_pos := world_pos_to_tile_pos(pos)
	tile_height := terrain.get_tile_height(int(tile_pos.x), int(tile_pos.y))
	chunk_pos.x = tile_pos.x / c.CHUNK_WIDTH
	chunk_pos.y = i32(pos.y - tile_height) / c.WALL_HEIGHT
	chunk_pos.z = tile_pos.y / c.CHUNK_DEPTH
	return
}

add_object :: proc(
	using ctx: ^Game_Context,
	pos: glsl.vec3,
	model: Object_Model,
	orientation: Object_Orientation,
	placement: Object_Placement,
) -> bool {
	using objects

	tile_pos := world_pos_to_tile_pos(pos)
	chunk_pos := world_pos_to_chunk_pos(ctx, pos)

	can_add_object(
		ctx,
		pos,
		tile_pos,
		chunk_pos,
		model,
		orientation,
		placement,
	) or_return

	chunk := &chunks[chunk_pos.y][chunk_pos.x][chunk_pos.z]

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

	return true
}

get_object_size :: proc(g: ^Game_Context, model: Object_Model) -> glsl.ivec3 {
	model_map := OBJECT_MODEL_MAP
	model_name := model_map[model]
	object_model := g.models.models[model_name]
	return glsl.ivec3(linalg.array_cast(linalg.ceil(object_model.size), i32))
}

can_add_object :: proc(
	using ctx: ^Game_Context,
	pos: glsl.vec3,
	tile_pos: glsl.ivec2,
	chunk_pos: glsl.ivec3,
	model: Object_Model,
	orientation: Object_Orientation,
	placement: Object_Placement,
) -> bool {
	if tile_pos.x < 0 ||
	   tile_pos.x >= c.WORLD_WIDTH ||
	   tile_pos.y < 0 ||
	   tile_pos.y >= c.WORLD_DEPTH {
		return false
	}

	switch placement {
	case .Wall:
		return can_add_object_on_wall(
			ctx,
			pos,
			tile_pos,
			chunk_pos,
			model,
			orientation,
		)
	case .Floor:
		return can_add_object_on_floor(
			ctx,
			pos,
			tile_pos,
			chunk_pos,
			model,
			orientation,
		)
	case .Counter:
	case .Table:
	}

	return true
}

on_add_object :: proc(
	pos: glsl.vec3,
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

can_add_object_on_wall :: proc(
	using ctx: ^Game_Context,
	pos: glsl.vec3,
	tile_pos: glsl.ivec2,
	chunk_pos: glsl.ivec3,
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

	tile_pos := world_pos_to_tile_pos(pos)

	return true
}

can_add_object_on_floor :: proc(
	g: ^Game_Context,
	pos: glsl.vec3,
	tile_pos: glsl.ivec2,
	chunk_pos: glsl.ivec3,
	model: Object_Model,
	orientation: Object_Orientation,
) -> bool {
	obj_size := get_object_size(g, model)

	for x in 0 ..< obj_size.x {
		x := x
		if orientation == .North || orientation == .West {
			x = -x
		}
		for z in 0 ..< obj_size.z {
			z := z
			if orientation == .South || orientation == .West {
				z = -z
			}
			if has_object_at(g, pos + {f32(x), 0, f32(z)}, .Floor) {
				return false
			}
		}
	}

	return true
}

has_object_at :: proc(
	g: ^Game_Context,
	pos: glsl.vec3,
	placement: Object_Placement,
) -> bool {
	chunk_pos := world_pos_to_chunk_pos(g, pos)
	tile_pos := world_pos_to_tile_pos(pos)
	chunk := &g.objects.chunks[chunk_pos.y][chunk_pos.x][chunk_pos.z]

	for k, v in chunk.objects {
		if world_pos_to_tile_pos(k.pos) == tile_pos &&
		   k.placement == placement {
			return true
		}
	}

	return false
}
