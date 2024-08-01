package object

import "core:log"
import "core:math"
import "core:math/linalg/glsl"
import "core:slice"

import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"

import "../camera"
import c "../constants"
import "../floor"
import "../renderer"
import "../wall"

Type :: enum {
	Door,
	Window,
	Chair,
	Table,
	Painting,
	Counter,
	Carpet,
	Tree,
}

Model :: enum {
	Wood_Door,
	Wood_Window,
	Wood_Chair,
	Wood_Table_1x2,
	Poutine_Painting,
	Wood_Counter,
	Small_Carpet,
	Tree,
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

TYPE_PLACEMENT_TABLE :: #partial [Type]Placement_Set {
	.Door = {.Wall},
	.Window = {.Wall},
	.Chair = {.Floor},
	.Table = {.Floor},
	.Painting = {.Wall},
	.Counter = {.Floor},
	.Carpet = {.Floor},
	.Tree = {.Floor},
}

MODEL_PLACEMENT_TABLE :: #partial [Model]Placement_Set{}

MODEL_SIZE :: [Model]glsl.ivec2 {
	.Wood_Door = {1, 2},
	.Wood_Window = {1, 2},
	.Wood_Chair = {1, 1},
	.Wood_Table_1x2 = {1, 2},
	.Poutine_Painting = {1, 1},
	.Wood_Counter = {1, 1},
	.Small_Carpet = {1, 1},
	.Tree = {2, 2},
}

TYPE_MAP :: [Model]Type {
	.Wood_Door        = .Door,
	.Wood_Window      = .Window,
	.Wood_Chair       = .Chair,
	.Wood_Table_1x2   = .Table,
	.Poutine_Painting = .Painting,
	.Wood_Counter     = .Counter,
	.Small_Carpet     = .Carpet,
	.Tree             = .Tree,
}

WIDTH :: 256
HEIGHT :: 512

Instance :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   f32,
	depth_map: f32,
}

Texture :: enum {
	Wood_Door_1_S,
	Wood_Door_1_W,
	Wood_Door_1_N,
	Wood_Door_1_E,
	Wood_Door_2_S,
	Wood_Door_2_W,
	Wood_Door_2_N,
	Wood_Door_2_E,
	Wood_Window_1_S,
	Wood_Window_1_W,
	Wood_Window_1_N,
	Wood_Window_1_E,
	Wood_Window_2_S,
	Wood_Window_2_W,
	Wood_Window_2_N,
	Wood_Window_2_E,
	Wood_Chair_S,
	Wood_Chair_W,
	Wood_Chair_N,
	Wood_Chair_E,
	Wood_Table_1x2_1_S,
	Wood_Table_1x2_1_W,
	Wood_Table_1x2_1_N,
	Wood_Table_1x2_1_E,
	Wood_Table_1x2_2_S,
	Wood_Table_1x2_2_W,
	Wood_Table_1x2_2_N,
	Wood_Table_1x2_2_E,
	Poutine_Painting_S,
	Poutine_Painting_W,
	Poutine_Painting_N,
	Poutine_Painting_E,
	Wood_Counter_S,
	Wood_Counter_W,
	Wood_Counter_N,
	Wood_Counter_E,
	Small_Carpet_S,
	Small_Carpet_W,
	Small_Carpet_N,
	Small_Carpet_E,
	Tree_1_S,
	Tree_1_W,
	Tree_1_N,
	Tree_1_E,
	Tree_2_S,
	Tree_2_W,
	Tree_2_N,
	Tree_2_E,
	Tree_3_S,
	Tree_3_W,
	Tree_3_N,
	Tree_3_E,
	Tree_4_S,
	Tree_4_W,
	Tree_4_N,
	Tree_4_E,
}

DIFFUSE_PATHS :: [Texture]cstring {
	.Wood_Door_1_S      = "resources/textures/objects/Doors/diffuse/Wood.Door.001_0001.png",
	.Wood_Door_1_W      = "resources/textures/objects/Doors/diffuse/Wood.Door.001_0002.png",
	.Wood_Door_1_N      = "resources/textures/objects/Doors/diffuse/Wood.Door.001_0003.png",
	.Wood_Door_1_E      = "resources/textures/objects/Doors/diffuse/Wood.Door.001_0004.png",
	.Wood_Door_2_S      = "resources/textures/objects/Doors/diffuse/Wood.Door.002_0001.png",
	.Wood_Door_2_W      = "resources/textures/objects/Doors/diffuse/Wood.Door.002_0002.png",
	.Wood_Door_2_N      = "resources/textures/objects/Doors/diffuse/Wood.Door.002_0003.png",
	.Wood_Door_2_E      = "resources/textures/objects/Doors/diffuse/Wood.Door.002_0004.png",
	.Wood_Window_1_S    = "resources/textures/objects/Windows/diffuse/Wood.Window.001_0001.png",
	.Wood_Window_1_W    = "resources/textures/objects/Windows/diffuse/Wood.Window.001_0002.png",
	.Wood_Window_1_N    = "resources/textures/objects/Windows/diffuse/Wood.Window.001_0003.png",
	.Wood_Window_1_E    = "resources/textures/objects/Windows/diffuse/Wood.Window.001_0004.png",
	.Wood_Window_2_S    = "resources/textures/objects/Windows/diffuse/Wood.Window.002_0001.png",
	.Wood_Window_2_W    = "resources/textures/objects/Windows/diffuse/Wood.Window.002_0002.png",
	.Wood_Window_2_N    = "resources/textures/objects/Windows/diffuse/Wood.Window.002_0003.png",
	.Wood_Window_2_E    = "resources/textures/objects/Windows/diffuse/Wood.Window.002_0004.png",
	.Wood_Chair_S       = "resources/textures/objects/Chairs/diffuse/Chair_0001.png",
	.Wood_Chair_W       = "resources/textures/objects/Chairs/diffuse/Chair_0002.png",
	.Wood_Chair_N       = "resources/textures/objects/Chairs/diffuse/Chair_0003.png",
	.Wood_Chair_E       = "resources/textures/objects/Chairs/diffuse/Chair_0004.png",
	.Wood_Table_1x2_1_S = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0001.png",
	.Wood_Table_1x2_2_S = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0001.png",
	.Wood_Table_1x2_1_W = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0002.png",
	.Wood_Table_1x2_2_W = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0002.png",
	.Wood_Table_1x2_1_N = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0003.png",
	.Wood_Table_1x2_2_N = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0003.png",
	.Wood_Table_1x2_1_E = "resources/textures/objects/Tables/diffuse/Table.6Places.001_0004.png",
	.Wood_Table_1x2_2_E = "resources/textures/objects/Tables/diffuse/Table.6Places.002_0004.png",
	.Poutine_Painting_S = "resources/textures/objects/Paintings/diffuse/Poutine.Painting_0001.png",
	.Poutine_Painting_W = "resources/textures/objects/Paintings/diffuse/Poutine.Painting_0002.png",
	.Poutine_Painting_N = "resources/textures/objects/Paintings/diffuse/Poutine.Painting_0003.png",
	.Poutine_Painting_E = "resources/textures/objects/Paintings/diffuse/Poutine.Painting_0004.png",
	.Wood_Counter_S     = "resources/textures/objects/Counters/diffuse/Wood.Counter_0001.png",
	.Wood_Counter_W     = "resources/textures/objects/Counters/diffuse/Wood.Counter_0002.png",
	.Wood_Counter_N     = "resources/textures/objects/Counters/diffuse/Wood.Counter_0003.png",
	.Wood_Counter_E     = "resources/textures/objects/Counters/diffuse/Wood.Counter_0004.png",
	.Small_Carpet_S     = "resources/textures/objects/Carpets/diffuse/Small.Carpet_0001.png",
	.Small_Carpet_W     = "resources/textures/objects/Carpets/diffuse/Small.Carpet_0002.png",
	.Small_Carpet_N     = "resources/textures/objects/Carpets/diffuse/Small.Carpet_0003.png",
	.Small_Carpet_E     = "resources/textures/objects/Carpets/diffuse/Small.Carpet_0004.png",
	.Tree_1_S           = "resources/textures/objects/Trees/diffuse/Tree.001_0001.png",
	.Tree_1_W           = "resources/textures/objects/Trees/diffuse/Tree.001_0002.png",
	.Tree_1_N           = "resources/textures/objects/Trees/diffuse/Tree.001_0003.png",
	.Tree_1_E           = "resources/textures/objects/Trees/diffuse/Tree.001_0004.png",
	.Tree_2_S           = "resources/textures/objects/Trees/diffuse/Tree.002_0001.png",
	.Tree_2_W           = "resources/textures/objects/Trees/diffuse/Tree.002_0002.png",
	.Tree_2_N           = "resources/textures/objects/Trees/diffuse/Tree.002_0003.png",
	.Tree_2_E           = "resources/textures/objects/Trees/diffuse/Tree.002_0004.png",
	.Tree_3_S           = "resources/textures/objects/Trees/diffuse/Tree.003_0001.png",
	.Tree_3_W           = "resources/textures/objects/Trees/diffuse/Tree.003_0002.png",
	.Tree_3_N           = "resources/textures/objects/Trees/diffuse/Tree.003_0003.png",
	.Tree_3_E           = "resources/textures/objects/Trees/diffuse/Tree.003_0004.png",
	.Tree_4_S           = "resources/textures/objects/Trees/diffuse/Tree.004_0001.png",
	.Tree_4_W           = "resources/textures/objects/Trees/diffuse/Tree.004_0002.png",
	.Tree_4_N           = "resources/textures/objects/Trees/diffuse/Tree.004_0003.png",
	.Tree_4_E           = "resources/textures/objects/Trees/diffuse/Tree.004_0004.png",
}

DEPTH_MAP_PATHS :: [Texture]cstring {
	.Wood_Door_1_S      = "resources/textures/objects/Doors/mist/Wood.Door.001_0001.png",
	.Wood_Door_1_W      = "resources/textures/objects/Doors/mist/Wood.Door.001_0002.png",
	.Wood_Door_1_N      = "resources/textures/objects/Doors/mist/Wood.Door.001_0003.png",
	.Wood_Door_1_E      = "resources/textures/objects/Doors/mist/Wood.Door.001_0004.png",
	.Wood_Door_2_S      = "resources/textures/objects/Doors/mist/Wood.Door.002_0001.png",
	.Wood_Door_2_W      = "resources/textures/objects/Doors/mist/Wood.Door.002_0002.png",
	.Wood_Door_2_N      = "resources/textures/objects/Doors/mist/Wood.Door.002_0003.png",
	.Wood_Door_2_E      = "resources/textures/objects/Doors/mist/Wood.Door.002_0004.png",
	.Wood_Window_1_S    = "resources/textures/objects/Windows/mist/Wood.Window.001_0001.png",
	.Wood_Window_1_W    = "resources/textures/objects/Windows/mist/Wood.Window.001_0002.png",
	.Wood_Window_1_N    = "resources/textures/objects/Windows/mist/Wood.Window.001_0003.png",
	.Wood_Window_1_E    = "resources/textures/objects/Windows/mist/Wood.Window.001_0004.png",
	.Wood_Window_2_S    = "resources/textures/objects/Windows/mist/Wood.Window.002_0001.png",
	.Wood_Window_2_W    = "resources/textures/objects/Windows/mist/Wood.Window.002_0002.png",
	.Wood_Window_2_N    = "resources/textures/objects/Windows/mist/Wood.Window.002_0003.png",
	.Wood_Window_2_E    = "resources/textures/objects/Windows/mist/Wood.Window.002_0004.png",
	.Wood_Chair_S       = "resources/textures/objects/Chairs/mist/Chair_0001.png",
	.Wood_Chair_W       = "resources/textures/objects/Chairs/mist/Chair_0002.png",
	.Wood_Chair_N       = "resources/textures/objects/Chairs/mist/Chair_0003.png",
	.Wood_Chair_E       = "resources/textures/objects/Chairs/mist/Chair_0004.png",
	.Wood_Table_1x2_1_S = "resources/textures/objects/Tables/mist/Table.6Places.001_0001.png",
	.Wood_Table_1x2_2_S = "resources/textures/objects/Tables/mist/Table.6Places.002_0001.png",
	.Wood_Table_1x2_1_W = "resources/textures/objects/Tables/mist/Table.6Places.001_0002.png",
	.Wood_Table_1x2_2_W = "resources/textures/objects/Tables/mist/Table.6Places.002_0002.png",
	.Wood_Table_1x2_1_N = "resources/textures/objects/Tables/mist/Table.6Places.001_0003.png",
	.Wood_Table_1x2_2_N = "resources/textures/objects/Tables/mist/Table.6Places.002_0003.png",
	.Wood_Table_1x2_1_E = "resources/textures/objects/Tables/mist/Table.6Places.001_0004.png",
	.Wood_Table_1x2_2_E = "resources/textures/objects/Tables/mist/Table.6Places.002_0004.png",
	.Poutine_Painting_S = "resources/textures/objects/Paintings/mist/Poutine.Painting_0001.png",
	.Poutine_Painting_W = "resources/textures/objects/Paintings/mist/Poutine.Painting_0002.png",
	.Poutine_Painting_N = "resources/textures/objects/Paintings/mist/Poutine.Painting_0003.png",
	.Poutine_Painting_E = "resources/textures/objects/Paintings/mist/Poutine.Painting_0004.png",
	.Wood_Counter_S     = "resources/textures/objects/Counters/mist/Wood.Counter_0001.png",
	.Wood_Counter_W     = "resources/textures/objects/Counters/mist/Wood.Counter_0002.png",
	.Wood_Counter_N     = "resources/textures/objects/Counters/mist/Wood.Counter_0003.png",
	.Wood_Counter_E     = "resources/textures/objects/Counters/mist/Wood.Counter_0004.png",
	.Small_Carpet_S     = "resources/textures/objects/Carpets/mist/Small.Carpet_0001.png",
	.Small_Carpet_W     = "resources/textures/objects/Carpets/mist/Small.Carpet_0002.png",
	.Small_Carpet_N     = "resources/textures/objects/Carpets/mist/Small.Carpet_0003.png",
	.Small_Carpet_E     = "resources/textures/objects/Carpets/mist/Small.Carpet_0004.png",
	.Tree_1_S           = "resources/textures/objects/Trees/mist/Tree.001_0001.png",
	.Tree_1_W           = "resources/textures/objects/Trees/mist/Tree.001_0002.png",
	.Tree_1_N           = "resources/textures/objects/Trees/mist/Tree.001_0003.png",
	.Tree_1_E           = "resources/textures/objects/Trees/mist/Tree.001_0004.png",
	.Tree_2_S           = "resources/textures/objects/Trees/mist/Tree.002_0001.png",
	.Tree_2_W           = "resources/textures/objects/Trees/mist/Tree.002_0002.png",
	.Tree_2_N           = "resources/textures/objects/Trees/mist/Tree.002_0003.png",
	.Tree_2_E           = "resources/textures/objects/Trees/mist/Tree.002_0004.png",
	.Tree_3_S           = "resources/textures/objects/Trees/mist/Tree.003_0001.png",
	.Tree_3_W           = "resources/textures/objects/Trees/mist/Tree.003_0002.png",
	.Tree_3_N           = "resources/textures/objects/Trees/mist/Tree.003_0003.png",
	.Tree_3_E           = "resources/textures/objects/Trees/mist/Tree.003_0004.png",
	.Tree_4_S           = "resources/textures/objects/Trees/mist/Tree.004_0001.png",
	.Tree_4_W           = "resources/textures/objects/Trees/mist/Tree.004_0002.png",
	.Tree_4_N           = "resources/textures/objects/Trees/mist/Tree.004_0003.png",
	.Tree_4_E           = "resources/textures/objects/Trees/mist/Tree.004_0004.png",
}

BILLBOARDS :: [Model][Orientation][]Texture {
	.Wood_Door =  {
		.South = {.Wood_Door_1_S, .Wood_Door_2_S},
		.East = {.Wood_Door_1_E, .Wood_Door_2_E},
		.North = {.Wood_Door_1_N, .Wood_Door_2_N},
		.West = {.Wood_Door_1_W, .Wood_Door_2_W},
	},
	.Wood_Window =  {
		.South = {.Wood_Window_1_S, .Wood_Window_2_S},
		.East = {.Wood_Window_1_E, .Wood_Window_2_E},
		.North = {.Wood_Window_1_N, .Wood_Window_2_N},
		.West = {.Wood_Window_1_W, .Wood_Window_2_W},
	},
	.Wood_Chair =  {
		.South = {.Wood_Chair_S},
		.East = {.Wood_Chair_E},
		.North = {.Wood_Chair_N},
		.West = {.Wood_Chair_W},
	},
	.Wood_Table_1x2 =  {
		.South = {.Wood_Table_1x2_1_S, .Wood_Table_1x2_2_S},
		.East = {.Wood_Table_1x2_1_E, .Wood_Table_1x2_2_E},
		.North = {.Wood_Table_1x2_1_N, .Wood_Table_1x2_2_N},
		.West = {.Wood_Table_1x2_1_W, .Wood_Table_1x2_2_W},
	},
	.Poutine_Painting =  {
		.South = {.Poutine_Painting_S},
		.East = {.Poutine_Painting_E},
		.North = {.Poutine_Painting_N},
		.West = {.Poutine_Painting_W},
	},
	.Wood_Counter =  {
		.South = {.Wood_Counter_S},
		.East = {.Wood_Counter_E},
		.North = {.Wood_Counter_N},
		.West = {.Wood_Counter_W},
	},
	.Small_Carpet =  {
		.South = {.Small_Carpet_S},
		.East = {.Small_Carpet_E},
		.North = {.Small_Carpet_N},
		.West = {.Small_Carpet_W},
	},
	.Tree =  {
		.South = {.Tree_1_S, .Tree_2_S, .Tree_3_S, .Tree_4_S},
		.East = {.Tree_1_E, .Tree_2_E, .Tree_3_E, .Tree_4_E},
		.North = {.Tree_1_N, .Tree_2_N, .Tree_3_N, .Tree_4_N},
		.West = {.Tree_1_W, .Tree_2_W, .Tree_3_W, .Tree_4_W},
	},
}

Object :: struct {
	pos:         glsl.ivec3,
	type:        Type,
	orientation: Orientation,
	placement:   Placement,
	texture:     Texture,
	light:       glsl.vec3,
	parent:      glsl.ivec3,
}

Chunk :: struct {
	objects:  [dynamic]Object,
	vao, ibo: u32,
	dirty:    bool,
}

Chunks :: [c.CHUNK_HEIGHT][c.WORLD_CHUNK_WIDTH][c.WORLD_CHUNK_DEPTH]Chunk

Uniform_Object :: struct {
	proj, view: glsl.mat4,
}

Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

VERTEX_SHADER_PATH :: "resources/shaders/billboard.vert"
FRAGMENT_SHADER_PATH :: "resources/shaders/billboard.frag"
MODEL_PATH :: "resources/models/billboard.glb"

chunks: Chunks
shader_program: u32
ubo: u32
uniform_object: Uniform_Object
indices: [6]u8
vertices: [4]Vertex
vbo, ebo: u32
texture_array: u32
depth_map_texture_array: u32

init :: proc() -> (ok: bool = true) {
	// gl.Enable(gl.MULTISAMPLE)

	load_model() or_return

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	defer gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(vertices) * size_of(Vertex),
		&vertices,
		gl.STATIC_DRAW,
	)

	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	defer gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(indices) * size_of(u8),
		&indices,
		gl.STATIC_DRAW,
	)


	gl.GenTextures(1, &texture_array)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)
	load_texture_array() or_return

	gl.GenTextures(1, &depth_map_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, depth_map_texture_array)
	load_depth_map_texture_array() or_return

	renderer.load_shader_program(
		&shader_program,
		VERTEX_SHADER_PATH,
		FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(gl.GetUniformLocation(shader_program, "texture_sampler"), 0)
	gl.Uniform1i(
		gl.GetUniformLocation(shader_program, "depth_map_texture_sampler"),
		1,
	)

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

	add({3, 0, 3}, .Wood_Chair, .South, .Floor)
	add({4, 0, 4}, .Wood_Chair, .East, .Floor)
	add({3, 0, 5}, .Wood_Chair, .North, .Floor)
	add({2, 0, 4}, .Wood_Chair, .West, .Floor)

	add({0, 0, 1}, .Wood_Table_1x2, .South, .Floor)
	add({2, 0, 0}, .Wood_Table_1x2, .North, .Floor)
	add({0, 0, 2}, .Wood_Table_1x2, .East, .Floor)
	add({1, 0, 4}, .Wood_Table_1x2, .West, .Floor)

	wall.set_wall(
		{5, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{5, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({5, 0, 5}, .Wood_Window, .South, .Wall)
	add({5, 0, 5}, .Wood_Window, .West, .Wall)

	wall.set_wall(
		{7, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{7, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({7, 0, 4}, .Wood_Window, .North, .Wall)
	add({6, 0, 5}, .Wood_Window, .East, .Wall)

	wall.set_wall(
		{9, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{9, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({9, 0, 5}, .Wood_Door, .South, .Wall)
	add({9, 0, 5}, .Wood_Door, .West, .Wall)

	wall.set_wall(
		{11, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{11, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({11, 0, 4}, .Wood_Door, .North, .Wall)
	add({10, 0, 5}, .Wood_Door, .East, .Wall)

	wall.set_wall(
		{13, 0, 5},
		.N_S,
		 {
			type = .End_Right_Corner,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)
	wall.set_wall(
		{13, 0, 5},
		.E_W,
		 {
			type = .Left_Corner_End,
			textures = {.Inside = .Brick, .Outside = .Brick},
		},
	)

	add({13, 0, 5}, .Poutine_Painting, .South, .Wall)
	add({13, 0, 5}, .Poutine_Painting, .West, .Wall)
	add({13, 0, 4}, .Poutine_Painting, .North, .Wall)
	add({12, 0, 5}, .Poutine_Painting, .East, .Wall)

	add({1, 0, 7}, .Wood_Counter, .South, .Floor)
	add({0, 0, 8}, .Wood_Counter, .West, .Floor)
	add({2, 0, 8}, .Wood_Counter, .East, .Floor)
	add({1, 0, 9}, .Wood_Counter, .North, .Floor)

	add({0, 0, 14}, .Wood_Counter, .West, .Floor)
	add({0, 0, 13}, .Wood_Counter, .West, .Floor)
	add({0, 0, 12}, .Wood_Counter, .West, .Floor)
	add({0, 0, 11}, .Wood_Counter, .West, .Floor)

	add({12, 0, 0}, .Small_Carpet, .South, .Floor)


	add({14, 0, 1}, .Tree, .South, .Floor)

	add({17, 0, 0}, .Tree, .North, .Floor)

	add({20, 0, 1}, .Tree, .East, .Floor)
	add({24, 0, 0}, .Tree, .West, .Floor)

	// log.debug(can_add({0, 0, 1}, .Wood_Table_1x2, .South))
	// log.debug(can_add({0, 0, 0}, .Wood_Table_1x2, .North))
	// log.debug(can_add({1, 0, 0}, .Wood_Table_1x2, .West))
	// log.debug(can_add({1, 0, 0}, .Wood_Table_1x2, .East))
	// log.debug(can_add({3, 0, 4}, .Wood_Table_1x2, .East))

	return true
}

init_chunk :: proc(using chunk: ^Chunk) {
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)

	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)

	gl.GenBuffers(1, &ibo)

	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Vertex),
		offset_of(Vertex, texcoords),
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, ibo)

	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(
		2,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, position),
	)

	gl.EnableVertexAttribArray(3)
	gl.VertexAttribPointer(
		3,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, light),
	)

	gl.EnableVertexAttribArray(4)
	gl.VertexAttribPointer(
		4,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, texture),
	)

	gl.EnableVertexAttribArray(5)
	gl.VertexAttribPointer(
		5,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Instance),
		offset_of(Instance, depth_map),
	)

	gl.VertexAttribDivisor(2, 1)
	gl.VertexAttribDivisor(3, 1)
	gl.VertexAttribDivisor(4, 1)
	gl.VertexAttribDivisor(5, 1)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
}

get_draw_texture :: proc(tex: Texture) -> f32 {
	family := (int(tex) / 4) * 4
	index := int(tex) - family
	return f32(family + (index + int(camera.rotation)) % 4)
}

sort_objects :: proc(a, b: Object) -> bool {
	switch camera.rotation {
	case .South_West:
		return a.pos.z > b.pos.z || (a.pos.z == b.pos.z && a.pos.x > b.pos.x)
    case .South_East:
		return a.pos.z > b.pos.z || (a.pos.z == b.pos.z && a.pos.x < b.pos.x)
    case .North_East:
		return a.pos.z < b.pos.z || (a.pos.z == b.pos.z && a.pos.x < b.pos.x)
    case .North_West:
		return a.pos.z < b.pos.z || (a.pos.z == b.pos.z && a.pos.x > b.pos.x)
	}
    return false
}

draw_chunk :: proc(using chunk: ^Chunk) {
	instances := len(objects)

	if dirty {
		dirty = false


		gl.BindBuffer(gl.ARRAY_BUFFER, ibo)
		gl.BufferData(
			gl.ARRAY_BUFFER,
			instances * size_of(Instance),
			nil,
			gl.STATIC_DRAW,
		)

	    slice.sort_by(objects[:], sort_objects)
		i := 0
		for v in objects {
			texture := f32(v.texture)
			instance: Instance = {
				position = {f32(v.pos.x), f32(v.pos.y), f32(v.pos.z)},
				light = v.light,
				texture = get_draw_texture(v.texture),
				depth_map = get_draw_texture(v.texture),
			}
			gl.BufferSubData(
				gl.ARRAY_BUFFER,
				i * size_of(Instance),
				size_of(Instance),
				&instance,
			)
			i += 1
		}

		gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	}

	gl.BindVertexArray(vao)
	gl.DrawElementsInstanced(
		gl.TRIANGLES,
		i32(len(indices)),
		gl.UNSIGNED_BYTE,
		nil,
		i32(instances),
	)
	gl.BindVertexArray(0)
}

draw :: proc() {
	gl.BindBuffer(gl.UNIFORM_BUFFER, ubo)
	ubo_index := gl.GetUniformBlockIndex(shader_program, "UniformBufferObject")
	gl.UniformBlockBinding(shader_program, ubo_index, 2)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, ubo)

	uniform_object.view = camera.view
	uniform_object.proj = camera.proj

	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Uniform_Object),
		&uniform_object,
		gl.STATIC_DRAW,
	)

	gl.UseProgram(shader_program)

	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, texture_array)

	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, depth_map_texture_array)

    gl.DepthFunc(gl.ALWAYS)
	defer gl.DepthFunc(gl.LEQUAL)

    gl.Disable(gl.MULTISAMPLE)
    defer gl.Enable(gl.MULTISAMPLE)

	for floor in 0 ..< c.WORLD_HEIGHT {
		it := camera.make_visible_chunk_iterator()
		for pos in it->next() {
			draw_chunk(&chunks[floor][pos.x][pos.y])
		}
	}
}

load_model :: proc() -> (ok: bool = true) {
	options: cgltf.options
	data, result := cgltf.parse_file(options, MODEL_PATH)
	if result != .success {
		log.error("failed to parse file")
		return false
	}
	result = cgltf.load_buffers(options, data, MODEL_PATH)
	if result != .success {
		log.error("failed to load buffers")
		return false
	}
	defer cgltf.free(data)

	for mesh in data.meshes {
		primitive := mesh.primitives[0]
		if primitive.indices != nil {
			accessor := primitive.indices
			for i in 0 ..< accessor.count {
				index := cgltf.accessor_read_index(accessor, i)
				indices[i] = u8(index)
			}
		}

		for attribute in primitive.attributes {
			if attribute.type == .position {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].pos),
						3,
					)
					vertices[i].pos.x *= -1
				}
			}
			if attribute.type == .texcoord {
				accessor := attribute.data
				for i in 0 ..< accessor.count {
					_ = cgltf.accessor_read_float(
						accessor,
						i,
						raw_data(&vertices[i].texcoords),
						2,
					)
				}
			}
		}
	}

    log.info(vertices)

	return true
}

load_depth_map_texture_array :: proc() -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.CLAMP)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.CLAMP)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	// gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	// max_anisotropy: f32
	// gl.GetFloatv(gl.MAX_TEXTURE_MAX_ANISOTROPY, &max_anisotropy)
	// gl.TexParameterf(
	// 	gl.TEXTURE_2D_ARRAY,
	// 	gl.TEXTURE_MAX_ANISOTROPY,
	// 	max_anisotropy,
	// )

	paths := DEPTH_MAP_PATHS
	textures := i32(len(paths))

	if (textures == 0) {
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexImage3D(
		gl.TEXTURE_2D_ARRAY,
		0,
		gl.R16,
		WIDTH,
		HEIGHT,
		textures,
		0,
		gl.RED,
		gl.UNSIGNED_SHORT,
		nil,
	)

	for path, i in paths {
		width: i32
		height: i32
		channels: i32
		pixels := stbi.load_16(path, &width, &height, &channels, 1)
		defer stbi.image_free(pixels)

		if pixels == nil {
			log.error("Failed to load texture: ", path)
			return false
		}

		if width != WIDTH {
			log.error(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				WIDTH,
				" got: ",
				width,
			)
			return false
		}

		if height != HEIGHT {
			log.error(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				HEIGHT,
				" got: ",
				height,
			)
			return false
		}

		gl.TexSubImage3D(
			gl.TEXTURE_2D_ARRAY,
			0,
			0,
			0,
			i32(i),
			WIDTH,
			HEIGHT,
			1,
			gl.RED,
			gl.UNSIGNED_SHORT,
			pixels,
		)
	}

	gl_error := gl.GetError()
	if (gl_error != gl.NO_ERROR) {
		log.error(
			"Error loading billboard depth map texture array: ",
			gl_error,
		)
		return false
	}

	return
}

load_texture_array :: proc() -> (ok: bool = true) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.CLAMP)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.CLAMP)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)


	paths := DIFFUSE_PATHS
	textures := i32(len(paths))

	if (textures == 0) {
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexImage3D(
		gl.TEXTURE_2D_ARRAY,
		0,
		gl.RGBA8,
		WIDTH,
		HEIGHT,
		textures,
		0,
		gl.RGBA,
		gl.UNSIGNED_BYTE,
		nil,
	)

	for path, i in paths {
		width: i32
		height: i32
		pixels := stbi.load(path, &width, &height, nil, 4)
		defer stbi.image_free(pixels)

		if pixels == nil {
			log.error("Failed to load texture: ", path)
			return false
		}

		if width != WIDTH {
			log.error(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				WIDTH,
				" got: ",
				width,
			)
			return false
		}

		if height != HEIGHT {
			log.error(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				HEIGHT,
				" got: ",
				height,
			)
			return false
		}

		gl.TexSubImage3D(
			gl.TEXTURE_2D_ARRAY,
			0,
			0,
			0,
			i32(i),
			WIDTH,
			HEIGHT,
			1,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			pixels,
		)
	}

	return
}

relative_pos :: proc(x, z: i32, orientation: Orientation) -> glsl.ivec3 {
	switch orientation {
	case .South:
		return {-x, 0, -z}
	case .East:
		return {z, 0, -x}
	case .North:
		return {x, 0, z}
	case .West:
		return {-z, 0, x}
	}

	return {}
}

get_texture :: proc(
	x, z: i32,
	model: Model,
	orientation: Orientation,
) -> Texture {
	billboards := BILLBOARDS
	model_size := MODEL_SIZE
	size := model_size[model]

	return billboards[model][orientation][x * size.x + z]
}

add :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
	placement: Placement,
) {
	type_map := TYPE_MAP
	model_size := MODEL_SIZE

	parent := pos
	size := model_size[model]
	type := type_map[model]
	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
			pos := pos + relative_pos(x, y, orientation)
			chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]
			append(
				&chunk.objects,
				Object {
					pos = pos,
					type = type,
					orientation = orientation,
					placement = placement,
					texture = get_texture(x, y, model, orientation),
					parent = parent,
					light = {1, 1, 1},
				},
			)
			chunk.dirty = true
		}
	}

	on_add(pos, model, orientation)
}

on_add :: proc(pos: glsl.ivec3, model: Model, orientation: Orientation) {
	type_map := TYPE_MAP
	type := type_map[model]

	if type != .Window && type != .Door {
		return
	}

	switch orientation {
	case .South, .North:
		pos := pos
		if orientation == .North {
			pos += {0, 0, 1}
		}
		if w, ok := wall.get_wall(pos, .E_W); ok {
			if type == .Window {
				w.mask = .Window_Opening
			} else {
				w.mask = .Door_Opening
			}
			wall.set_wall(pos, .E_W, w)
		}
	case .East, .West:
		pos := pos
		if orientation == .East {
			pos += {1, 0, 0}
		}
		if w, ok := wall.get_wall(pos, .N_S); ok {
			if type == .Window {
				w.mask = .Window_Opening
			} else {
				w.mask = .Door_Opening
			}
			wall.set_wall(pos, .N_S, w)
		}
	}
}

can_add_on_wall :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
) -> bool {
	model_size := MODEL_SIZE

	size := model_size[model]
	for x in 0 ..< size.x {
		switch orientation {
		case .South, .North:
			pos := pos + {x, 0, 0}
			if orientation == .North {
				pos += {0, 0, 1}
			}
			if !wall.has_east_west_wall(pos) {
				return false
			}
		case .East, .West:
			pos := pos + {0, 0, x}
			if orientation == .East {
				pos += {1, 0, 0}
			}
			if !wall.has_north_south_wall(pos) {
				return false
			}
		}

		for y in 0 ..< size.y {
			pos := pos + relative_pos(x, y, orientation)
			chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]

			obstacle_orientation := orientation
			if y != 0 {
				obstacle_orientation = Orientation(int(orientation) + 2 % 4)
			}
			for k, v in chunk.objects {
				if k.pos == pos &&
				   k.placement == .Wall &&
				   k.orientation == obstacle_orientation {
					return false
				}
			}
		}
	}

	return true
}

can_add_on_floor :: proc(
	pos: glsl.ivec3,
	model: Model,
	orientation: Orientation,
) -> bool {
	model_size := MODEL_SIZE

	size := model_size[model]
	for x in 0 ..< size.x {
		for y in 0 ..< size.y {
			pos := pos + relative_pos(x, y, orientation)
			chunk := &chunks[pos.y][pos.x / c.CHUNK_WIDTH][pos.z / c.CHUNK_DEPTH]

			for k, v in chunk.objects {
				if k.pos == pos && k.placement == .Floor {
					return false
				}
			}
		}
	}

	return true
}

on_rotation :: proc() {
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	for v, i in vertices {
		v := v
		rotation := glsl.mat4Rotate(
			{0, 1, 0},
			(math.PI / 2) * f32(camera.rotation),
		)
		v.pos = (glsl.vec4{v.pos.x, v.pos.y, v.pos.z, 1} * rotation).xyz
		gl.BufferSubData(
			gl.ARRAY_BUFFER,
			i * size_of(Vertex),
			size_of(Vertex),
			&v,
		)
	}
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	for &y in chunks {
		for &x in y {
			for &z in x {
				z.dirty = true
			}
		}
	}
}
