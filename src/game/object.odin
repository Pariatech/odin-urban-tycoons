package game

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import "core:path/filepath"
import "core:slice"
import "core:strings"
import "core:testing"

import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"

import "../camera"
import c "../constants"
import "../floor"
import "../renderer"
import "../terrain"
// import "../wall"

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
	Plank_Table_6Places,
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
	.Wood_Door           = .Door,
	.Wood_Window         = .Window,
	// .Wood_Chair                          = .Chair,
	// .Wood_Table_1x2                      = .Table,
	.Wood_Table_6Places  = .Table,
	.Plank_Table_6Places = .Table,
	.Wood_Table_8Places  = .Table,
	// .Poutine_Painting                    = .Painting,
	.Wood_Counter        = .Counter,
	// .Small_Carpet                        = .Carpet,
	// .Tree                                = .Tree,
}

OBJECT_MODEL_MAP :: [Object_Model]string {
	.Wood_Counter        = "Wood.Counter.Bake",
	.Wood_Window         = "Window.Wood.Bake",
	.Wood_Door           = "Door.Wood.Bake",
	.Wood_Table_6Places  = "Table.6Places.Bake",
	.Plank_Table_6Places = "Plank.Table.6Places.Bake",
	.Wood_Table_8Places  = "Table.8Places.Bake",
}

OBJECT_MODEL_TEXTURE_MAP :: [Object_Model]string {
	.Wood_Counter        = "objects/Wood.Counter.png",
	.Wood_Window         = "objects/Wood.Window.png",
	.Wood_Door           = "objects/Door.Wood.png",
	.Wood_Table_6Places  = "objects/Table.6Places.Wood.png",
	.Plank_Table_6Places = "objects/Table.6Places.Plank.png",
	// .Wood_Table_6Places = "tex_test.png",
	.Wood_Table_8Places  = "objects/Table.8Places.Wood.png",
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
	objects:       [dynamic]Object,
	dirty:         bool,
	placement_map: [c.CHUNK_WIDTH][c.CHUNK_DEPTH][Object_Placement][Object_Orientation]bool,
}

Object_Chunks :: [c.CHUNK_HEIGHT][c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Object_Chunk

Object_Uniform_Object :: struct {
	mvp: glsl.mat4,
}


OBJECT_SHADER :: Shader {
	vertex   = "resources/shaders/object.vert",
	fragment = "resources/shaders/object.frag",
}

Objects_Context :: struct {
	chunks: Object_Chunks,
	ubo:    u32,
	shader: Shader,
}


init_objects :: proc() -> (ok: bool = true) {
	ctx := get_game_context()

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)


	// renderer.load_shader_program(
	// 	&shader_program,
	// 	OBJECT_VERTEX_SHADER_PATH,
	// 	OBJECT_FRAGMENT_SHADER_PATH,
	// ) or_return
	ctx.objects.shader = OBJECT_SHADER
	init_shader(&ctx.objects.shader) or_return

	// gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture_sampler"), 0)
	set_shader_uniform(&ctx.objects.shader, "texture_sampler", i32(0))

	gl.GenBuffers(1, &ctx.objects.ubo)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.UseProgram(0)

	add_object({1, 0, 1}, .Wood_Counter, .South, .Floor)
	add_object({2, 0, 1}, .Wood_Counter, .South, .Floor)
	add_object({3, 0, 1}, .Wood_Counter, .South, .Floor)

	add_object({5, 0, 1}, .Plank_Table_6Places, .South, .Floor)
	add_object({8, 0, 1}, .Wood_Table_8Places, .South, .Floor)

	add_object({5, 0, 4}, .Plank_Table_6Places, .East, .Floor)
	add_object({8, 0, 4}, .Wood_Table_8Places, .East, .Floor)

	add_object({5, 0, 7}, .Plank_Table_6Places, .North, .Floor)
	add_object({8, 0, 7}, .Wood_Table_8Places, .North, .Floor)

	add_object({5, 0, 10}, .Plank_Table_6Places, .West, .Floor)
	add_object({8, 0, 10}, .Wood_Table_8Places, .West, .Floor)

	return true
}

delete_objects :: proc() {
	ctx := get_game_context()

	for &row in ctx.objects.chunks {
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

draw_object :: proc(object: ^Object) -> bool {
	ctx := get_game_context()

	translate := glsl.mat4Translate(object.pos)
	rotation_radian := f32(object.orientation) * 0.5 * math.PI
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
	bind_texture(object.texture) or_return

	bind_model(object.model) or_return
	draw_model(object.model)

	return true
}

draw_chunk :: proc(chunk: ^Object_Chunk) -> bool {
	if len(chunk.objects) == 0 {
		return true
	}

	for &object in chunk.objects {
		draw_object(&object) or_return
	}

	return true
}

draw_objects :: proc() -> bool {
	ctx := get_objects_context()

	gl.BindBuffer(gl.UNIFORM_BUFFER, ctx.ubo)
	set_shader_unifrom_block_binding(&ctx.shader, "UniformBufferObject", 2)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ctx.ubo)

	// gl.Disable(gl.MULTISAMPLE)

	bind_shader(&ctx.shader)
	// gl.UseProgram(shader_program)

	for floor in 0 ..= floor.floor {
		it := camera.make_visible_chunk_iterator()
		for pos in it->next() {
			draw_chunk(&ctx.chunks[floor][pos.x][pos.y]) or_return
		}
	}

	return true
}

world_pos_to_tile_pos :: proc(pos: glsl.vec3) -> (tile_pos: glsl.ivec2) {
	tile_pos.x = i32(pos.x + 0.5)
	tile_pos.y = i32(pos.z + 0.5)
	return
}

world_pos_to_chunk_pos :: proc(pos: glsl.vec3) -> (chunk_pos: glsl.ivec3) {
	tile_pos := world_pos_to_tile_pos(pos)
	tile_height := terrain.get_tile_height(int(tile_pos.x), int(tile_pos.y))
	chunk_pos.x = tile_pos.x / c.CHUNK_WIDTH
	chunk_pos.y = i32(pos.y - tile_height) / c.WALL_HEIGHT
	chunk_pos.z = tile_pos.y / c.CHUNK_DEPTH
	return
}

add_object :: proc(
	pos: glsl.vec3,
	model: Object_Model,
	orientation: Object_Orientation,
	placement: Object_Placement,
) -> bool {
	ctx := get_objects_context()
	tile_pos := world_pos_to_tile_pos(pos)
	chunk_pos := world_pos_to_chunk_pos(pos)

	model_map := OBJECT_MODEL_MAP
	can_add_object(pos, model_map[model], orientation, placement) or_return

	chunk := &ctx.chunks[chunk_pos.y][chunk_pos.x][chunk_pos.z]

	chunk.dirty = true

	type_map := OBJECT_TYPE_MAP

	texture_map := OBJECT_MODEL_TEXTURE_MAP

	update_object_placement_map(pos, model_map[model], placement, orientation)

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

update_object_placement_map :: proc(
	pos: glsl.vec3,
	model: string,
	placement: Object_Placement,
	orientation: Object_Orientation,
) {
	obj_size := get_object_size(model)

	log.info(model, obj_size)

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

			pos := pos + {f32(x), 0, f32(z)}
			tile_pos := world_pos_to_tile_pos(pos)
			chunk_pos := world_pos_to_chunk_pos(pos)
			ctx := get_objects_context()
			chunk := &ctx.chunks[chunk_pos.y][chunk_pos.x][chunk_pos.z]
			chunk.placement_map[tile_pos.x % c.CHUNK_WIDTH][tile_pos.y % c.CHUNK_DEPTH][placement][orientation] =
				true
		}
	}
}

get_object_size :: proc(model: string) -> glsl.ivec3 {
	models := get_models_context()
	object_model := models.models[model]
	return glsl.ivec3(
		linalg.array_cast(
			linalg.ceil(object_model.size - {0.01, 0.01, 0.01}),
			i32,
		),
	)
}

can_add_object :: proc(
	pos: glsl.vec3,
	model: string,
	orientation: Object_Orientation,
	placement: Object_Placement,
) -> bool {
	tile_pos := world_pos_to_tile_pos(pos)
	chunk_pos := world_pos_to_chunk_pos(pos)

	if tile_pos.x < 0 ||
	   tile_pos.x >= c.WORLD_WIDTH ||
	   tile_pos.y < 0 ||
	   tile_pos.y >= c.WORLD_DEPTH {
		return false
	}

	switch placement {
	case .Wall:
		return can_add_object_on_wall(pos, tile_pos, chunk_pos, orientation)
	case .Floor:
		return can_add_object_on_floor(
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
	pos: glsl.vec3,
	tile_pos: glsl.ivec2,
	chunk_pos: glsl.ivec3,
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
	pos: glsl.vec3,
	tile_pos: glsl.ivec2,
	chunk_pos: glsl.ivec3,
	model: string,
	orientation: Object_Orientation,
) -> bool {
	obj_size := get_object_size(model)

	for x in 0 ..< obj_size.x {
		x := x
		wall_x := x
		if orientation == .North || orientation == .West {
			x = -x
			wall_x = x + 1
		}
		for z in 0 ..< obj_size.z {
			z := z
			wall_z := z
			if orientation == .South || orientation == .West {
				z = -z
				wall_z = z + 1
			}
			if has_object_at(pos + {f32(x), 0, f32(z)}, .Floor) {
				return false
			}

			if x != 0 &&
			   has_north_south_wall(
				   {tile_pos.x + wall_x, chunk_pos.y, tile_pos.y + z},
			   ) {
				return false
			}

			if z != 0 &&
			   has_east_west_wall(
				   {tile_pos.x + x, chunk_pos.y, tile_pos.y + wall_z},
			   ) {
				return false
			}

			if has_north_west_south_east_wall(
				   {tile_pos.x + x, chunk_pos.y, tile_pos.y + z},
			   ) ||
			   has_north_west_south_east_wall(
				   {tile_pos.x + x, chunk_pos.y, tile_pos.y + z},
			   ) {
				return false
			}

			if !terrain.is_tile_flat(tile_pos + {x, z}) {
				return false
			}
		}
	}

	return true
}

has_object_at :: proc(pos: glsl.vec3, placement: Object_Placement) -> bool {
	objects := get_objects_context()
	chunk_pos := world_pos_to_chunk_pos(pos)
	tile_pos := world_pos_to_tile_pos(pos)
	chunk := &objects.chunks[chunk_pos.y][chunk_pos.x][chunk_pos.z]

	orientations :=
		chunk.placement_map[tile_pos.x % c.CHUNK_WIDTH][tile_pos.y % c.CHUNK_DEPTH][placement]

	for orientation in orientations {
		if orientation {
			return true
		}
	}
	// for k, v in chunk.objects {
	// 	if world_pos_to_tile_pos(k.pos) == tile_pos &&
	// 	   k.placement == placement {
	// 		return true
	// 	}
	// }

	return false
}

@(test)
can_add_object_on_floor_test :: proc(t: ^testing.T) {
	game := new(Game_Context)
	context.user_ptr = game

	load_models()
	defer free_models()

	defer delete_objects()

	model_map := OBJECT_MODEL_MAP
	pos := glsl.vec3{1, 0, 1}
	add_object(pos, .Wood_Counter, .South, .Floor)
	r := can_add_object(pos, model_map[.Wood_Counter], .South, .Floor)
	testing.expect_value(t, r, false)

	pos = {2, 0, 1}
	r = can_add_object(pos, model_map[.Wood_Counter], .South, .Floor)
	testing.expect_value(t, r, true)

	pos = {1, 0, 1}
	r = can_add_object(pos, model_map[.Wood_Table_8Places], .South, .Floor)
	testing.expect_value(t, r, false)
	// add_object(&game, {2, 0, 1}, .Wood_Counter, .South, .Floor)
	// add_object(&game, {3, 0, 1}, .Wood_Counter, .South, .Floor)
	//
	// add_object(&game, {5, 0, 1}, .Plank_Table_6Places, .South, .Floor)
	// add_object(&game, {8, 0, 1}, .Wood_Table_8Places, .South, .Floor)
	//
	// add_object(&game, {5, 0, 4}, .Plank_Table_6Places, .East, .Floor)
	// add_object(&game, {8, 0, 4}, .Wood_Table_8Places, .East, .Floor)
	//
	// add_object(&game, {5, 0, 7}, .Plank_Table_6Places, .North, .Floor)
	// add_object(&game, {8, 0, 7}, .Wood_Table_8Places, .North, .Floor)
	//
	// add_object(&game, {5, 0, 10}, .Plank_Table_6Places, .West, .Floor)
	// add_object(&game, {8, 0, 10}, .Wood_Table_8Places, .West, .Floor)
}
