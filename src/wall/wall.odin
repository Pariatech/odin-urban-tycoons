package wall

import "core:fmt"
import "core:log"
import "core:math/linalg"
import glsl "core:math/linalg/glsl"
import "core:strings"

import gl "vendor:OpenGL"
import "vendor:cgltf"

import "../camera"
import "../constants"
import "../renderer"
import "../terrain"
import "../utils"


Wall_Mask_Texture :: enum (u16) {
	Full_Mask,
	Door_Opening,
	Window_Opening,
}

Wall_Axis :: enum {
	N_S,
	E_W,
	SW_NE,
	NW_SE,
}

Wall_Type_Part :: enum {
	End,
	Side,
	Left_Corner,
	Right_Corner,
}

Wall_Type :: enum {
	End_End,
	End_Side,
	End_Left_Corner,
	End_Right_Corner,
	Side_End,
	Left_Corner_End,
	Right_Corner_End,
	Side_Side,
	Side_Left_Corner,
	Side_Right_Corner,
	Left_Corner_Side,
	Right_Corner_Side,
	Left_Corner_Left_Corner,
	Right_Corner_Right_Corner,
	Left_Corner_Right_Corner,
	Right_Corner_Left_Corner,
}

Wall_Texture_Position :: enum {
	Base,
	Top,
}

Wall_Mask :: enum {
	Full,
	Extended_Side,
	Side,
	End,
}

State :: enum {
	Up,
	Down,
	Left,
	Right,
}

Wall_Top_Mesh :: enum {
	Full,
	Side,
}

Wall_Side :: enum {
	Inside,
	Outside,
}

Wall :: struct {
	type:     Wall_Type,
	textures: [Wall_Side]Wall_Texture,
	mask:     Wall_Mask_Texture,
	state:    State,
}


Wall_Vertex :: struct {
	pos:       glsl.vec3,
	light:     glsl.vec3,
	texcoords: glsl.vec4,
}

Chunk :: struct {
	north_south:           map[glsl.ivec2]Wall,
	east_west:             map[glsl.ivec2]Wall,
	south_west_north_east: map[glsl.ivec2]Wall,
	north_west_south_east: map[glsl.ivec2]Wall,
	vao, vbo, ebo:         u32,
	dirty:                 bool,
	initialized:           bool,
	num_indices:           i32,
}

Wall_Texture :: enum (u16) {
	Wall_Top,
	Frame,
	Drywall,
	Brick,
	White,
	Royal_Blue,
	Dark_Blue,
	White_Cladding,
	Light_Gray_Stone,
	Wood_Panel_Wallpaper,
	Red_Strip_Wallpaper,
	Green_Plaster_Brown_Marble,
	White_Marble,
}

Wall_Index :: u32

WALL_TEXTURE_HEIGHT :: 384
WALL_TEXTURE_WIDTH :: 128

WALL_TEXTURE_PATHS :: [Wall_Texture]cstring {
	.Wall_Top                   = "resources/textures/walls/wall-top.png",
	.Frame                      = "resources/textures/walls/frame.png",
	.Drywall                    = "resources/textures/walls/drywall.png",
	.Brick                      = "resources/textures/walls/brick-wall.png",
	.White                      = "resources/textures/walls/white.png",
	.Royal_Blue                 = "resources/textures/walls/royal_blue.png",
	.Dark_Blue                  = "resources/textures/walls/dark_blue.png",
	.White_Cladding             = "resources/textures/walls/white_cladding.png",
	.Light_Gray_Stone           = "resources/textures/walls/light_gray_stone.png",
	.Wood_Panel_Wallpaper       = "resources/textures/walls/wood_panel_wallpaper.png",
	.Red_Strip_Wallpaper        = "resources/textures/walls/red_strip_wallpaper.png",
	.Green_Plaster_Brown_Marble = "resources/textures/walls/green_plaster_brown_marble.png",
	.White_Marble               = "resources/textures/walls/white_marble.png",
}

WALL_MASK_PATHS :: [Wall_Mask_Texture]cstring {
	.Full_Mask      = "resources/textures/wall-masks/full.png",
	.Door_Opening   = "resources/textures/wall-masks/door-opening.png",
	.Window_Opening = "resources/textures/wall-masks/window-opening.png",
}

wall_vertices := [State][Wall_Mask][dynamic]Wall_Vertex{}
wall_indices := [State][Wall_Mask][dynamic]Wall_Index{}
wall_top_vertices := [State][Wall_Mask][dynamic]Wall_Vertex{}
wall_top_indices := [State][Wall_Mask][dynamic]Wall_Index{}

chunks: [constants.CHUNK_HEIGHT][constants.WORLD_CHUNK_WIDTH][constants.WORLD_CHUNK_DEPTH]Chunk

WALL_SIDE_TYPE_MAP :: [Wall_Type_Part][Wall_Type_Part]Wall_Type {
	.End =  {
		.End = .End_End,
		.Side = .End_Side,
		.Left_Corner = .End_Left_Corner,
		.Right_Corner = .End_Right_Corner,
	},
	.Side =  {
		.End = .Side_End,
		.Side = .Side_Side,
		.Left_Corner = .Side_Left_Corner,
		.Right_Corner = .Side_Right_Corner,
	},
	.Left_Corner =  {
		.End = .Left_Corner_End,
		.Side = .Left_Corner_Side,
		.Left_Corner = .Left_Corner_Left_Corner,
		.Right_Corner = .Left_Corner_Right_Corner,
	},
	.Right_Corner =  {
		.End = .Right_Corner_End,
		.Side = .Right_Corner_Side,
		.Left_Corner = .Right_Corner_Left_Corner,
		.Right_Corner = .Right_Corner_Right_Corner,
	},
}

WALL_SIDE_MAP :: [Wall_Axis][camera.Rotation]Wall_Side {
	.N_S =  {
		.South_West = .Outside,
		.South_East = .Inside,
		.North_East = .Inside,
		.North_West = .Outside,
	},
	.E_W =  {
		.South_West = .Outside,
		.South_East = .Outside,
		.North_East = .Inside,
		.North_West = .Inside,
	},
	.SW_NE =  {
		.South_West = .Outside,
		.South_East = .Inside,
		.North_East = .Inside,
		.North_West = .Outside,
	},
	.NW_SE =  {
		.South_West = .Outside,
		.South_East = .Outside,
		.North_East = .Inside,
		.North_West = .Inside,
	},
}

WALL_TRANSFORM_MAP :: #partial [Wall_Axis][camera.Rotation]glsl.mat4 {
	.N_S =  {
		.South_West = {0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.South_East = {0, 0, -1, -1, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1},
		.North_East = {0, 0, -1, -1, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
		.North_West = {0, 0, 1, 0, 0, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0, 1},
	},
	.E_W =  {
		.South_West = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.South_East = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
		.North_East = {-1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 1},
		.North_West = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, 0, 0, 1},
	},
}


WALL_TOP_MESH_MAP :: [Wall_Type][Wall_Axis][camera.Rotation]Wall_Mask {
	.End_End = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.Side_Side = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.End_Side = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Side,
		},
	},
	.Side_End = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
	},
	.Left_Corner_End = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.End_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.Right_Corner_End = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.End_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.Left_Corner_Side = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
	},
	.Side_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
	},
	.Right_Corner_Side = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Side_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Left_Corner_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.Right_Corner_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Left_Corner_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Full,
		},
	},
	.Right_Corner_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Full,
			.North_East = .Side,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Side,
			.North_East = .Full,
			.North_West = .Side,
		},
	},
}

// UP_WALL_MASK_MAP :: [State]

WALL_MASK_MAP :: [Wall_Type][Wall_Axis][camera.Rotation]Wall_Mask {
	.End_End = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Full,
			.North_East = .Full,
			.North_West = .Full,
		},
	},
	.Side_Side = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.End_Side = #partial {
		.N_S =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .End,
			.North_West = .End,
		},
		.E_W =  {
			.South_West = .End,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .End,
		},
	},
	.Side_End = #partial {
		.N_S =  {
			.South_West = .End,
			.South_East = .End,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
		.E_W =  {
			.South_West = .Extended_Side,
			.South_East = .End,
			.North_East = .End,
			.North_West = .Extended_Side,
		},
	},
	.Left_Corner_End = #partial {
		.N_S =  {
			.South_West = .End,
			.South_East = .Full,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
		.E_W =  {
			.South_West = .Extended_Side,
			.South_East = .Full,
			.North_East = .End,
			.North_West = .Extended_Side,
		},
	},
	.End_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .Full,
			.North_West = .End,
		},
		.E_W =  {
			.South_West = .Full,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .End,
		},
	},
	.Right_Corner_End = #partial {
		.N_S =  {
			.South_West = .Full,
			.South_East = .End,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
		.E_W =  {
			.South_West = .Extended_Side,
			.South_East = .End,
			.North_East = .Full,
			.North_West = .Extended_Side,
		},
	},
	.End_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .End,
			.North_West = .Full,
		},
		.E_W =  {
			.South_West = .End,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .Full,
		},
	},
	.Left_Corner_Side = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Side_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Right_Corner_Side = #partial {
		.N_S =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
	},
	.Side_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
	},
	.Left_Corner_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Extended_Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Side,
		},
	},
	.Right_Corner_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Extended_Side,
		},
	},
	.Left_Corner_Right_Corner = #partial {
		.N_S =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
		.E_W =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
	},
	.Right_Corner_Left_Corner = #partial {
		.N_S =  {
			.South_West = .Side,
			.South_East = .Extended_Side,
			.North_East = .Side,
			.North_West = .Extended_Side,
		},
		.E_W =  {
			.South_West = .Extended_Side,
			.South_East = .Side,
			.North_East = .Extended_Side,
			.North_West = .Side,
		},
	},
}

wall_texture_array: u32
wall_mask_array: u32

load_wall_mask_array :: proc() -> (ok: bool) {
	gl.ActiveTexture(gl.TEXTURE1)
	gl.GenTextures(1, &wall_mask_array)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_mask_array)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.NEAREST)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.NEAREST)

	return renderer.load_texture_2D_array(
		WALL_MASK_PATHS,
		WALL_TEXTURE_WIDTH,
		WALL_TEXTURE_HEIGHT,
	)
}

load_wall_texture_array :: proc() -> (ok: bool = true) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.GenTextures(1, &wall_texture_array)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_texture_array)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MIN_FILTER,
		gl.NEAREST_MIPMAP_LINEAR,
	)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
	max_anisotropy: f32
	gl.GetFloatv(gl.MAX_TEXTURE_MAX_ANISOTROPY, &max_anisotropy)
	gl.TexParameterf(
		gl.TEXTURE_2D_ARRAY,
		gl.TEXTURE_MAX_ANISOTROPY,
		max_anisotropy,
	)

	return renderer.load_texture_2D_array(
		WALL_TEXTURE_PATHS,
		WALL_TEXTURE_WIDTH,
		WALL_TEXTURE_HEIGHT,
	)
}

init_wall_renderer :: proc() -> (ok: bool) {
	load_wall_texture_array() or_return
	load_wall_mask_array() or_return
	load_models() or_return

	return true
}

deinit_wall_renderer :: proc() {

}

draw_wall_mesh :: proc(
	vertices: []Wall_Vertex,
	indices: []Wall_Index,
	model: glsl.mat4,
	texture: Wall_Texture,
	mask: Wall_Mask_Texture,
	light: glsl.vec3,
	vertex_buffer: ^[dynamic]Wall_Vertex,
	index_buffer: ^[dynamic]Wall_Index,
) {
	index_offset := u32(len(vertex_buffer))
	for i in 0 ..< len(vertices) {
		vertex := vertices[i]
		vertex.light = light
		vertex.texcoords.z = f32(texture)
		vertex.texcoords.w = f32(mask)
		vertex.pos = linalg.mul(model, utils.vec4(vertex.pos, 1)).xyz

		append(vertex_buffer, vertex)
	}

	for idx in indices {
		append(index_buffer, idx + index_offset)
	}
}

draw_wall :: proc(
	pos: glsl.ivec3,
	wall: Wall,
	axis: Wall_Axis,
	vertex_buffer: ^[dynamic]Wall_Vertex,
	index_buffer: ^[dynamic]Wall_Index,
) {
	mask_map := WALL_MASK_MAP
	side_map := WALL_SIDE_MAP
	transform_map := WALL_TRANSFORM_MAP
	top_mesh_map := WALL_TOP_MESH_MAP

	side := side_map[axis][camera.rotation]
	texture := wall.textures[side]
	mask := mask_map[wall.type][axis][camera.rotation]
	top_mesh := top_mesh_map[wall.type][axis][camera.rotation]

	position := glsl.vec3 {
		f32(pos.x),
		f32(pos.y) * constants.WALL_HEIGHT +
		terrain.terrain_heights[pos.x][pos.z],
		f32(pos.z),
	}
	transform := glsl.mat4Translate(position)
	transform *= transform_map[axis][camera.rotation]

	// vertices_map := WALL_VERTICES
	vertices_map := wall_vertices
	vertices: []Wall_Vertex = vertices_map[wall.state][mask][:]

	// indices_map := WALL_INDICES
	indices_map := wall_indices
	indices: []Wall_Index = indices_map[wall.state][mask][:]

	light := glsl.vec3{1, 1, 1}
	if axis == .N_S {
		light = glsl.vec3{0.9, 0.9, 0.9}
	}

	draw_wall_mesh(
		vertices,
		indices,
		transform,
		texture,
		wall.mask,
		light,
		vertex_buffer,
		index_buffer,
	)

	top_vertices := wall_top_vertices[wall.state][top_mesh][:]
	transform *= glsl.mat4Translate(
		{0, constants.WALL_TOP_OFFSET * f32(axis), 0},
	)

	draw_wall_mesh(
		top_vertices,
		wall_top_indices[wall.state][top_mesh][:],
		transform,
		.Wall_Top,
		wall.mask,
		light,
		vertex_buffer,
		index_buffer,
	)
}

get_chunk :: proc(pos: glsl.ivec3) -> ^Chunk {
	return(
		&chunks[pos.y][pos.x / constants.CHUNK_WIDTH][pos.z / constants.CHUNK_DEPTH] \
	)
}

set_north_south_wall :: proc(pos: glsl.ivec3, w: Wall) {
	if has_south_west_north_east_wall(pos) ||
	   has_north_west_south_east_wall(pos) ||
	   has_south_west_north_east_wall(pos + {-1, 0, 0}) ||
	   has_north_west_south_east_wall(pos + {-1, 0, 0}) {return
	}
	chunk_set_north_south_wall(get_chunk(pos), pos, w)
}

get_north_south_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_north_south_wall(get_chunk(pos), pos)
}

set_wall :: proc(pos: glsl.ivec3, axis: Wall_Axis, w: Wall) {
	switch axis {
	case .E_W:
		set_east_west_wall(pos, w)
	case .N_S:
		set_north_south_wall(pos, w)
	case .NW_SE:
		set_north_west_south_east_wall(pos, w)
	case .SW_NE:
		set_south_west_north_east_wall(pos, w)
	}
}

get_wall :: proc(pos: glsl.ivec3, axis: Wall_Axis) -> (Wall, bool) {
	switch axis {
	case .E_W:
		return get_east_west_wall(pos)
	case .N_S:
		return get_north_south_wall(pos)
	case .NW_SE:
		return get_north_west_south_east_wall(pos)
	case .SW_NE:
		return get_south_west_north_east_wall(pos)
	}

	return {}, false
}

has_north_south_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_north_south_wall(get_chunk(pos), pos) \
	)
}

remove_north_south_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_north_south_wall(get_chunk(pos), pos)
}

set_east_west_wall :: proc(pos: glsl.ivec3, w: Wall) {
	if has_south_west_north_east_wall(pos) ||
	   has_north_west_south_east_wall(pos) ||
	   has_south_west_north_east_wall(pos + {0, 0, -1}) ||
	   has_north_west_south_east_wall(pos + {0, 0, -1}) {
		return
	}
	chunk_set_east_west_wall(get_chunk(pos), pos, w)
}

get_east_west_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_east_west_wall(get_chunk(pos), pos)
}

has_east_west_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_east_west_wall(get_chunk(pos), pos) \
	)
}

remove_east_west_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_east_west_wall(get_chunk(pos), pos)
}

set_north_west_south_east_wall :: proc(pos: glsl.ivec3, wall: Wall) {
	if has_north_south_wall(pos) ||
	   has_north_south_wall(pos + {1, 0, 0}) ||
	   has_east_west_wall(pos) ||
	   has_east_west_wall(pos + {0, 0, 1}) {
		return
	}
	chunk_set_north_west_south_east_wall(get_chunk(pos), pos, wall)
}

has_north_west_south_east_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_north_west_south_east_wall(get_chunk(pos), pos) \
	)
}

get_north_west_south_east_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_north_west_south_east_wall(get_chunk(pos), pos)
}

remove_north_west_south_east_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_north_west_south_east_wall(get_chunk(pos), pos)
}

set_south_west_north_east_wall :: proc(pos: glsl.ivec3, wall: Wall) {
	if has_north_south_wall(pos) ||
	   has_north_south_wall(pos + {1, 0, 0}) ||
	   has_east_west_wall(pos) ||
	   has_east_west_wall(pos + {0, 0, 1}) {
		return
	}
	chunk_set_south_west_north_east_wall(get_chunk(pos), pos, wall)
}

has_south_west_north_east_wall :: proc(pos: glsl.ivec3) -> bool {
	return(
		(pos.x >= 0 && pos.x < constants.WORLD_WIDTH) &&
		(pos.y >= 0 && pos.y < constants.WORLD_HEIGHT) &&
		(pos.z >= 0 && pos.z < constants.WORLD_DEPTH) &&
		chunk_has_south_west_north_east_wall(get_chunk(pos), pos) \
	)
}

get_south_west_north_east_wall :: proc(pos: glsl.ivec3) -> (Wall, bool) {
	return chunk_get_south_west_north_east_wall(get_chunk(pos), pos)
}

remove_south_west_north_east_wall :: proc(pos: glsl.ivec3) {
	chunk_remove_south_west_north_east_wall(get_chunk(pos), pos)
}

chunk_set_north_south_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	wall: Wall,
) {
	chunk.north_south[pos.xz] = wall
	chunk.dirty = true
}

chunk_has_north_south_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) -> bool {
	return pos.xz in chunk.north_south
}

chunk_get_north_south_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	Wall,
	bool,
) {
	return chunk.north_south[pos.xz]
}

chunk_remove_north_south_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	delete_key(&chunk.north_south, glsl.ivec2(pos.xz))
	chunk.dirty = true
}

chunk_set_east_west_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3, wall: Wall) {
	chunk.east_west[pos.xz] = wall
	chunk.dirty = true
}

chunk_has_east_west_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) -> bool {
	return pos.xz in chunk.east_west
}

chunk_get_east_west_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	Wall,
	bool,
) {
	return chunk.east_west[pos.xz]
}

chunk_remove_east_west_wall :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	delete_key(&chunk.east_west, glsl.ivec2(pos.xz))
	chunk.dirty = true
}


chunk_set_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	wall: Wall,
) {
	chunk.north_west_south_east[pos.xz] = wall
	chunk.dirty = true
}

chunk_has_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> bool {
	return pos.xz in chunk.north_west_south_east
}

chunk_get_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	Wall,
	bool,
) {
	return chunk.north_west_south_east[pos.xz]
}

chunk_remove_north_west_south_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) {
	delete_key(&chunk.north_west_south_east, glsl.ivec2(pos.xz))
	chunk.dirty = true
}

chunk_set_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
	wall: Wall,
) {
	chunk.south_west_north_east[pos.xz] = wall
	chunk.dirty = true
}

chunk_has_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> bool {
	return pos.xz in chunk.south_west_north_east
}

chunk_get_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) -> (
	Wall,
	bool,
) {
	return chunk.south_west_north_east[pos.xz]
}

chunk_remove_south_west_north_east_wall :: proc(
	chunk: ^Chunk,
	pos: glsl.ivec3,
) {
	delete_key(&chunk.south_west_north_east, glsl.ivec2(pos.xz))
	chunk.dirty = true
}

chunk_draw_walls :: proc(chunk: ^Chunk, pos: glsl.ivec3) {
	if !chunk.initialized {
		chunk.initialized = true
		chunk.dirty = true
		gl.GenVertexArrays(1, &chunk.vao)
		gl.BindVertexArray(chunk.vao)
		gl.GenBuffers(1, &chunk.vbo)
		gl.BindBuffer(gl.ARRAY_BUFFER, chunk.vbo)

		gl.GenBuffers(1, &chunk.ebo)

		gl.VertexAttribPointer(
			0,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Wall_Vertex),
			offset_of(Wall_Vertex, pos),
		)
		gl.EnableVertexAttribArray(0)

		gl.VertexAttribPointer(
			1,
			3,
			gl.FLOAT,
			gl.FALSE,
			size_of(Wall_Vertex),
			offset_of(Wall_Vertex, light),
		)
		gl.EnableVertexAttribArray(1)

		gl.VertexAttribPointer(
			2,
			4,
			gl.FLOAT,
			gl.FALSE,
			size_of(Wall_Vertex),
			offset_of(Wall_Vertex, texcoords),
		)
		gl.EnableVertexAttribArray(2)
	}

	gl.BindVertexArray(chunk.vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, chunk.vbo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, chunk.ebo)

	if chunk.dirty {
		chunk.dirty = false

		vertices: [dynamic]Wall_Vertex
		indices: [dynamic]Wall_Index
		defer delete(vertices)
		defer delete(indices)

		for wall_pos, w in chunk.east_west {
			draw_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.E_W,
				&vertices,
				&indices,
			)
		}

		for wall_pos, w in chunk.north_south {
			draw_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.N_S,
				&vertices,
				&indices,
			)
		}

		for wall_pos, w in chunk.south_west_north_east {
			draw_diagonal_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.SW_NE,
				&vertices,
				&indices,
			)
		}

		for wall_pos, w in chunk.north_west_south_east {
			draw_diagonal_wall(
				{wall_pos.x, pos.y, wall_pos.y},
				w,
				.NW_SE,
				&vertices,
				&indices,
			)
		}

		gl.BufferData(
			gl.ARRAY_BUFFER,
			len(vertices) * size_of(Wall_Vertex),
			raw_data(vertices),
			gl.STATIC_DRAW,
		)

		gl.BufferData(
			gl.ELEMENT_ARRAY_BUFFER,
			len(indices) * size_of(Wall_Index),
			raw_data(indices),
			gl.STATIC_DRAW,
		)
		chunk.num_indices = i32(len(indices))
	}

	gl.DrawElements(gl.TRIANGLES, chunk.num_indices, gl.UNSIGNED_INT, nil)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)
}


draw_walls :: proc(floor: i32) {
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, wall_mask_array)

	for x in camera.visible_chunks_start.x ..< camera.visible_chunks_end.x {
		for z in camera.visible_chunks_start.y ..< camera.visible_chunks_end.y {
			chunk := &chunks[floor][x][z]
			chunk_draw_walls(chunk, {x, i32(floor), z})
		}
	}
}

update_after_rotation :: proc() {
	for &floor in chunks {
		for &row in floor {
			for &chunk in row {
				chunk.dirty = true
			}
		}
	}
}

load_wall_model :: proc(
	parts: []string,
	node: ^cgltf.node,
	vertices: ^[State][Wall_Mask][dynamic]Wall_Vertex,
	indices: ^[State][Wall_Mask][dynamic]Wall_Index,
) {
	state: State
	mask: Wall_Mask

	switch parts[0] {
	case "Left":
		state = .Left
	case "Right":
		state = .Right
	case "Up":
		state = .Up
	case "Down":
		state = .Down
	}
	switch parts[1] {
	case "End":
		mask = .End
	case "Extended_Side":
		mask = .Extended_Side
	case "Full":
		mask = .Full
	case "Side":
		mask = .Side
	}

	mesh := node.mesh
	primitive := mesh.primitives[0]
	if primitive.indices != nil {
		accessor := primitive.indices
		for i in 0 ..< accessor.count {
			index := cgltf.accessor_read_index(accessor, i)
			append(&indices[state][mask], Wall_Index(index))
		}
	}

	for attribute in primitive.attributes {
		if attribute.type == .position {
			accessor := attribute.data
			for i in 0 ..< accessor.count {
				if i >= len(vertices[state][mask]) {
					append(&vertices[state][mask], Wall_Vertex{})
				}
				_ = cgltf.accessor_read_float(
					accessor,
					i,
					raw_data(&vertices[state][mask][i].pos),
					3,
				)
				vertices[state][mask][i].pos.x *= -1
			}
		}
		if attribute.type == .texcoord {
			accessor := attribute.data
			for i in 0 ..< accessor.count {
				if i >= len(vertices[state][mask]) {
					append(&vertices[state][mask], Wall_Vertex{})
				}
				_ = cgltf.accessor_read_float(
					accessor,
					i,
					raw_data(&vertices[state][mask][i].texcoords),
					2,
				)
			}
		}
	}
}

load_diagonal_wall_model :: proc(
	parts: []string,
	node: ^cgltf.node,
	vertices: ^[State][Diagonal_Wall_Mask][dynamic]Wall_Vertex,
	indices: ^[State][Diagonal_Wall_Mask][dynamic]Wall_Index,
) {
	state: State
	mask: Diagonal_Wall_Mask

	switch parts[0] {
	case "Left":
		state = .Left
	case "Right":
		state = .Right
	case "Up":
		state = .Up
	case "Down":
		state = .Down
	}
	switch parts[1] {
	case "Cross":
		mask = .Cross
	case "Left_Extension":
		mask = .Left_Extension
	case "Right_Extension":
		mask = .Right_Extension
	case "Full":
		mask = .Full
	case "Side":
		mask = .Side
	}

	mesh := node.mesh
	primitive := mesh.primitives[0]
	if primitive.indices != nil {
		accessor := primitive.indices
		for i in 0 ..< accessor.count {
			index := cgltf.accessor_read_index(accessor, i)
			append(&indices[state][mask], Wall_Index(index))
		}
	}

	for attribute in primitive.attributes {
		if attribute.type == .position {
			accessor := attribute.data
			for i in 0 ..< accessor.count {
				if i >= len(vertices[state][mask]) {
					append(&vertices[state][mask], Wall_Vertex{})
				}
				_ = cgltf.accessor_read_float(
					accessor,
					i,
					raw_data(&vertices[state][mask][i].pos),
					3,
				)
				vertices[state][mask][i].pos.x *= -1
			}
		}
		if attribute.type == .texcoord {
			accessor := attribute.data
			for i in 0 ..< accessor.count {
				if i >= len(vertices[state][mask]) {
					append(&vertices[state][mask], Wall_Vertex{})
				}
				_ = cgltf.accessor_read_float(
					accessor,
					i,
					raw_data(&vertices[state][mask][i].texcoords),
					2,
				)
			}
		}
	}

}

load_models :: proc() -> (ok: bool = false) {
	path: cstring = "resources/models/walls.glb"
	options: cgltf.options
	data, result := cgltf.parse_file(options, path)
	if result != .success {
		fmt.println("failed to parse file")
		return
	}
	result = cgltf.load_buffers(options, data, path)
	if result != .success {
		fmt.println("failed to load buffers")
		return
	}
	defer cgltf.free(data)

	for node in data.scene.nodes {

		parts := strings.split(string(node.name), ".")
		defer delete(parts)

		switch parts[0] {
		case "Wall":
			load_wall_model(parts[1:], node, &wall_vertices, &wall_indices)
		case "Wall_Top":
			load_wall_model(
				parts[1:],
				node,
				&wall_top_vertices,
				&wall_top_indices,
			)
		case "Diagonal_Wall":
			load_diagonal_wall_model(
				parts[1:],
				node,
				&diagonal_wall_vertices,
				&diagonal_wall_indices,
			)
		case "Diagonal_Wall_Top":
			load_diagonal_wall_model(
				parts[1:],
				node,
				&diagonal_wall_top_vertices,
				&diagonal_wall_top_indices,
			)
		}
	}

	return true
}
