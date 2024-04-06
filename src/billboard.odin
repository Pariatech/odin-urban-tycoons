package main

import "core:fmt"
import "core:math"
import "core:math/linalg"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"


BILLBOARD_VERTEX_SHADER_PATH :: "resources/shaders/billboard.vert"
BILLBOARD_FRAGMENT_SHADER_PATH :: "resources/shaders/billboard.frag"
BILLBOARD_MODEL_PATH :: "resources/models/billboard.glb"
FOUR_TILES_BILLBOARD_MODEL_PATH :: "resources/models/4tiles-billboard.glb"
BILLBOARD_TEXTURE_WIDTH :: 128
BILLBOARD_TEXTURE_HEIGHT :: 256
FOUR_TILES_BILLBOARD_TEXTURE_WIDTH :: 512
FOUR_TILES_BILLBOARD_TEXTURE_HEIGHT :: 1024

Billboard_System :: struct {
	indices:                 [6]u8,
	vertices:                [4]Billboard_Vertex,
	instances:               [dynamic]Billboard_Instance,
	quadtree:                Quadtree(int),
	uniform_object:          Billboard_Uniform_Object,
	vbo, ebo, vao, ibo, ubo: u32,
	shader_program:          u32,
	texture_array:           u32,
	depth_map_texture_array: u32,
}

billboard_system: Billboard_System
four_tiles_billboard_system: Billboard_System

Billboard_Instance :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   f32,
	depth_map: f32,
	rotation:  u8,
}

One_Tile_Billboard :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   Billboard_Texture,
	depth_map: Billboard_Texture,
	rotation:  u8,
}

Four_Tiles_Billboard :: struct {
	position:  glsl.vec3,
	light:     glsl.vec3,
	texture:   Four_Tiles_Billboard_Texture,
	depth_map: Four_Tiles_Billboard_Texture,
	rotation:  u8,
}

Billboard_Vertex :: struct {
	pos:       glsl.vec3,
	texcoords: glsl.vec2,
}

Billboard_Uniform_Object :: struct {
	proj, view, rotation: glsl.mat4,
	camera_rotation:      u32,
}

Billboard_Texture :: enum u8 {
	// Chair_Wood_SW,
	// Chair_Wood_SE,
	// Chair_Wood_NE,
	// Chair_Wood_NW,
	Door_Wood_SW,
	Door_Wood_SE,
	Door_Wood_NE,
	Door_Wood_NW,
	Window_Wood_SW,
	Window_Wood_SE,
	Window_Wood_NE,
	Window_Wood_NW,
	Shovel_1_SW,
	Shovel_1_SE,
	Shovel_1_NE,
	Shovel_1_NW,
	Shovel_2_SW,
	Shovel_2_SE,
	Shovel_2_NE,
	Shovel_2_NW,
	Shovel_3_SW,
	Shovel_3_SE,
	Shovel_3_NE,
	Shovel_3_NW,
	Shovel_4_SW,
	Shovel_4_SE,
	Shovel_4_NE,
	Shovel_4_NW,
	Shovel_5_SW,
	Shovel_5_SE,
	Shovel_5_NE,
	Shovel_5_NW,
	Shovel_6_SW,
	Shovel_6_SE,
	Shovel_6_NE,
	Shovel_6_NW,
	Shovel_7_SW,
	Shovel_7_SE,
	Shovel_7_NE,
	Shovel_7_NW,
	Shovel_8_SW,
	Shovel_8_SE,
	Shovel_8_NE,
	Shovel_8_NW,
	Shovel_9_SW,
	Shovel_9_SE,
	Shovel_9_NE,
	Shovel_9_NW,
	Shovel_10_SW,
	Shovel_10_SE,
	Shovel_10_NE,
	Shovel_10_NW,
}

Four_Tiles_Billboard_Texture :: enum u8 {
	Table_Wood_SW,
	Table_Wood_SE,
	Table_Wood_NE,
	Table_Wood_NW,
	Table_8_Places_Wood_SW,
	Table_8_Places_Wood_SE,
	Table_8_Places_Wood_NE,
	Table_8_Places_Wood_NW,
}

BILLBOARD_TEXTURE_PATHS :: [Billboard_Texture]cstring {
	// .Chair_Wood_SW = "resources/textures/billboards/chair-wood/sw-diffuse.png",
	// .Chair_Wood_SE = "resources/textures/billboards/chair-wood/se-diffuse.png",
	// .Chair_Wood_NE = "resources/textures/billboards/chair-wood/ne-diffuse.png",
	// .Chair_Wood_NW = "resources/textures/billboards/chair-wood/nw-diffuse.png",
	.Door_Wood_SW   = "resources/textures/billboards/door-wood/sw-diffuse.png",
	.Door_Wood_SE   = "resources/textures/billboards/door-wood/se-diffuse.png",
	.Door_Wood_NE   = "resources/textures/billboards/door-wood/ne-diffuse.png",
	.Door_Wood_NW   = "resources/textures/billboards/door-wood/nw-diffuse.png",
	.Window_Wood_SW = "resources/textures/billboards/window-wood/sw-diffuse.png",
	.Window_Wood_SE = "resources/textures/billboards/window-wood/se-diffuse.png",
	.Window_Wood_NE = "resources/textures/billboards/window-wood/ne-diffuse.png",
	.Window_Wood_NW = "resources/textures/billboards/window-wood/nw-diffuse.png",
	.Shovel_1_SW    = "resources/textures/billboards/shovel/1-diffuse.png",
	.Shovel_1_SE    = "resources/textures/billboards/shovel/1-diffuse.png",
	.Shovel_1_NE    = "resources/textures/billboards/shovel/1-diffuse.png",
	.Shovel_1_NW    = "resources/textures/billboards/shovel/1-diffuse.png",
	.Shovel_2_SW    = "resources/textures/billboards/shovel/2-diffuse.png",
	.Shovel_2_SE    = "resources/textures/billboards/shovel/2-diffuse.png",
	.Shovel_2_NE    = "resources/textures/billboards/shovel/2-diffuse.png",
	.Shovel_2_NW    = "resources/textures/billboards/shovel/2-diffuse.png",
	.Shovel_3_SW    = "resources/textures/billboards/shovel/3-diffuse.png",
	.Shovel_3_SE    = "resources/textures/billboards/shovel/3-diffuse.png",
	.Shovel_3_NE    = "resources/textures/billboards/shovel/3-diffuse.png",
	.Shovel_3_NW    = "resources/textures/billboards/shovel/3-diffuse.png",
	.Shovel_4_SW    = "resources/textures/billboards/shovel/4-diffuse.png",
	.Shovel_4_SE    = "resources/textures/billboards/shovel/4-diffuse.png",
	.Shovel_4_NE    = "resources/textures/billboards/shovel/4-diffuse.png",
	.Shovel_4_NW    = "resources/textures/billboards/shovel/4-diffuse.png",
	.Shovel_5_SW    = "resources/textures/billboards/shovel/5-diffuse.png",
	.Shovel_5_SE    = "resources/textures/billboards/shovel/5-diffuse.png",
	.Shovel_5_NE    = "resources/textures/billboards/shovel/5-diffuse.png",
	.Shovel_5_NW    = "resources/textures/billboards/shovel/5-diffuse.png",
	.Shovel_6_SW    = "resources/textures/billboards/shovel/6-diffuse.png",
	.Shovel_6_SE    = "resources/textures/billboards/shovel/6-diffuse.png",
	.Shovel_6_NE    = "resources/textures/billboards/shovel/6-diffuse.png",
	.Shovel_6_NW    = "resources/textures/billboards/shovel/6-diffuse.png",
	.Shovel_7_SW    = "resources/textures/billboards/shovel/7-diffuse.png",
	.Shovel_7_SE    = "resources/textures/billboards/shovel/7-diffuse.png",
	.Shovel_7_NE    = "resources/textures/billboards/shovel/7-diffuse.png",
	.Shovel_7_NW    = "resources/textures/billboards/shovel/7-diffuse.png",
	.Shovel_8_SW    = "resources/textures/billboards/shovel/8-diffuse.png",
	.Shovel_8_SE    = "resources/textures/billboards/shovel/8-diffuse.png",
	.Shovel_8_NE    = "resources/textures/billboards/shovel/8-diffuse.png",
	.Shovel_8_NW    = "resources/textures/billboards/shovel/8-diffuse.png",
	.Shovel_9_SW    = "resources/textures/billboards/shovel/9-diffuse.png",
	.Shovel_9_SE    = "resources/textures/billboards/shovel/9-diffuse.png",
	.Shovel_9_NE    = "resources/textures/billboards/shovel/9-diffuse.png",
	.Shovel_9_NW    = "resources/textures/billboards/shovel/9-diffuse.png",
	.Shovel_10_SW   = "resources/textures/billboards/shovel/10-diffuse.png",
	.Shovel_10_SE   = "resources/textures/billboards/shovel/10-diffuse.png",
	.Shovel_10_NE   = "resources/textures/billboards/shovel/10-diffuse.png",
	.Shovel_10_NW   = "resources/textures/billboards/shovel/10-diffuse.png",
}

FOUR_TILES_BILLBOARD_TEXTURE_PATHS :: [Four_Tiles_Billboard_Texture]cstring {
	.Table_Wood_SW          = "resources/textures/billboards/table-6places-wood/sw-diffuse.png",
	.Table_Wood_SE          = "resources/textures/billboards/table-6places-wood/se-diffuse.png",
	.Table_Wood_NE          = "resources/textures/billboards/table-6places-wood/ne-diffuse.png",
	.Table_Wood_NW          = "resources/textures/billboards/table-6places-wood/nw-diffuse.png",
	.Table_8_Places_Wood_SW = "resources/textures/billboards/table-8places-wood/sw-diffuse.png",
	.Table_8_Places_Wood_SE = "resources/textures/billboards/table-8places-wood/se-diffuse.png",
	.Table_8_Places_Wood_NE = "resources/textures/billboards/table-8places-wood/ne-diffuse.png",
	.Table_8_Places_Wood_NW = "resources/textures/billboards/table-8places-wood/nw-diffuse.png",
}

BILLBOARD_DEPTH_MAP_TEXTURE_PATHS :: [Billboard_Texture]cstring {
	// .Chair_Wood_SW = "resources/textures/billboards/chair-wood/sw-depth-map.png",
	// .Chair_Wood_SE = "resources/textures/billboards/chair-wood/se-depth-map.png",
	// .Chair_Wood_NE = "resources/textures/billboards/chair-wood/ne-depth-map.png",
	// .Chair_Wood_NW = "resources/textures/billboards/chair-wood/nw-depth-map.png",
	.Door_Wood_SW   = "resources/textures/billboards/door-wood/sw-depth-map.png",
	.Door_Wood_SE   = "resources/textures/billboards/door-wood/se-depth-map.png",
	.Door_Wood_NE   = "resources/textures/billboards/door-wood/ne-depth-map.png",
	.Door_Wood_NW   = "resources/textures/billboards/door-wood/nw-depth-map.png",
	.Window_Wood_SW = "resources/textures/billboards/window-wood/sw-depth-map.png",
	.Window_Wood_SE = "resources/textures/billboards/window-wood/se-depth-map.png",
	.Window_Wood_NE = "resources/textures/billboards/window-wood/ne-depth-map.png",
	.Window_Wood_NW = "resources/textures/billboards/window-wood/nw-depth-map.png",
	.Shovel_1_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_1_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_1_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_1_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_2_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_2_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_2_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_2_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_3_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_3_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_3_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_3_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_4_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_4_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_4_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_4_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_5_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_5_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_5_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_5_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_6_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_6_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_6_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_6_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_7_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_7_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_7_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_7_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_8_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_8_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_8_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_8_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_9_SW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_9_SE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_9_NE    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_9_NW    = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_10_SW   = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_10_SE   = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_10_NE   = "resources/textures/billboards/shovel/depth-map.png",
	.Shovel_10_NW   = "resources/textures/billboards/shovel/depth-map.png",
}

FOUR_TILES_BILLBOARD_DEPTH_MAP_TEXTURE_PATHS ::
	[Four_Tiles_Billboard_Texture]cstring {
		.Table_Wood_SW          = "resources/textures/billboards/table-6places-wood/sw-depth-map.png",
		.Table_Wood_SE          = "resources/textures/billboards/table-6places-wood/se-depth-map.png",
		.Table_Wood_NE          = "resources/textures/billboards/table-6places-wood/ne-depth-map.png",
		.Table_Wood_NW          = "resources/textures/billboards/table-6places-wood/nw-depth-map.png",
		.Table_8_Places_Wood_SW = "resources/textures/billboards/table-8places-wood/sw-depth-map.png",
		.Table_8_Places_Wood_SE = "resources/textures/billboards/table-8places-wood/se-depth-map.png",
		.Table_8_Places_Wood_NE = "resources/textures/billboards/table-8places-wood/ne-depth-map.png",
		.Table_8_Places_Wood_NW = "resources/textures/billboards/table-8places-wood/nw-depth-map.png",
	}

init_billboard_systems :: proc() -> (ok: bool = false) {
	init_billboard_system(
		&billboard_system,
		BILLBOARD_MODEL_PATH,
		BILLBOARD_TEXTURE_PATHS,
		BILLBOARD_DEPTH_MAP_TEXTURE_PATHS,
		BILLBOARD_TEXTURE_WIDTH,
		BILLBOARD_TEXTURE_HEIGHT,
	) or_return

	init_billboard_system(
		&four_tiles_billboard_system,
		FOUR_TILES_BILLBOARD_MODEL_PATH,
		FOUR_TILES_BILLBOARD_TEXTURE_PATHS,
		FOUR_TILES_BILLBOARD_DEPTH_MAP_TEXTURE_PATHS,
		FOUR_TILES_BILLBOARD_TEXTURE_WIDTH,
		FOUR_TILES_BILLBOARD_TEXTURE_HEIGHT,
	) or_return
	return true
}

init_billboard_system :: proc(
	billboard_system: ^Billboard_System,
	model_path: cstring,
	texture_paths: [$T]cstring,
	depth_map_texture_paths: [$D]cstring,
	expected_texture_width: i32,
	expected_texture_height: i32,
) -> (
	ok: bool = false,
) {
	billboard_system.quadtree.size = WORLD_WIDTH
	load_billboard_model(
		model_path,
		&billboard_system.vertices,
		&billboard_system.indices,
	) or_return
	fmt.println("billboard vertices:", billboard_system.vertices)
	fmt.println("billboard indices:", billboard_system.indices)

	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.BindVertexArray(0)

	gl.GenBuffers(1, &billboard_system.ibo)

	gl.GenVertexArrays(1, &billboard_system.vao)
	gl.BindVertexArray(billboard_system.vao)

	gl.GenBuffers(1, &billboard_system.vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(billboard_system.vertices) * size_of(Billboard_Vertex),
		&billboard_system.vertices,
		gl.STATIC_DRAW,
	)

	gl.GenBuffers(1, &billboard_system.ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, billboard_system.ebo)
	gl.BufferData(
		gl.ELEMENT_ARRAY_BUFFER,
		len(billboard_system.indices) * size_of(u8),
		&billboard_system.indices,
		gl.STATIC_DRAW,
	)


	gl.GenBuffers(1, &billboard_system.ubo)
	gl.BindBuffer(gl.UNIFORM_BUFFER, billboard_system.ubo)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, billboard_system.ubo)

	gl.GenTextures(1, &billboard_system.texture_array)
	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, billboard_system.texture_array)
	load_billboard_texture_array(
		texture_paths,
		expected_texture_width,
		expected_texture_height,
	) or_return

	gl.GenTextures(1, &billboard_system.depth_map_texture_array)
	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(
		gl.TEXTURE_2D_ARRAY,
		billboard_system.depth_map_texture_array,
	)
	load_billboard_depth_map_texture_array(
		depth_map_texture_paths,
		expected_texture_width,
		expected_texture_height,
	) or_return

	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(
		0,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Vertex),
		offset_of(Billboard_Vertex, pos),
	)

	gl.EnableVertexAttribArray(1)
	gl.VertexAttribPointer(
		1,
		2,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Vertex),
		offset_of(Billboard_Vertex, texcoords),
	)

	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.ibo)

	gl.EnableVertexAttribArray(2)
	gl.VertexAttribPointer(
		2,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, position),
	)

	gl.EnableVertexAttribArray(3)
	gl.VertexAttribPointer(
		3,
		3,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, light),
	)

	gl.EnableVertexAttribArray(4)
	gl.VertexAttribPointer(
		4,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, texture),
	)

	gl.EnableVertexAttribArray(5)
	gl.VertexAttribPointer(
		5,
		1,
		gl.FLOAT,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, depth_map),
	)

	gl.EnableVertexAttribArray(6)
	gl.VertexAttribPointer(
		6,
		1,
		gl.UNSIGNED_BYTE,
		gl.FALSE,
		size_of(Billboard_Instance),
		offset_of(Billboard_Instance, rotation),
	)

	gl.VertexAttribDivisor(2, 1)
	gl.VertexAttribDivisor(3, 1)
	gl.VertexAttribDivisor(4, 1)
	gl.VertexAttribDivisor(5, 1)
	gl.VertexAttribDivisor(6, 1)

	load_shader_program(
		&billboard_system.shader_program,
		BILLBOARD_VERTEX_SHADER_PATH,
		BILLBOARD_FRAGMENT_SHADER_PATH,
	) or_return


	gl.Uniform1i(
		gl.GetUniformLocation(
			billboard_system.shader_program,
			"texture_sampler",
		),
		0,
	)
	gl.Uniform1i(
		gl.GetUniformLocation(
			billboard_system.shader_program,
			"depth_map_texture_sampler",
		),
		1,
	)

	gl.BindVertexArray(0)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0)
	gl.UseProgram(0)

	return true
}

get_view_corner :: proc(screen_point: glsl.vec2) -> glsl.vec2 {
	p1 :=
		linalg.inverse(camera_vp) *
		glsl.vec4{screen_point.x, screen_point.y, -1, 1}
	p2 :=
		linalg.inverse(camera_vp) *
		glsl.vec4{screen_point.x, screen_point.y, 1, 1}
	t := -p1.y / (p2.y - p1.y)
	return glsl.vec2{p1.x + t * (p2.x - p1.x), p1.z + t * (p2.z - p1.z)}
}

get_camera_aabb :: proc() -> Rectangle {
	bottom_left := get_view_corner({-1, -1})
	top_left := get_view_corner({-1, 1})
	bottom_right := get_view_corner({1, -1})
	top_right := get_view_corner({1, 1})
	camera := camera_position + camera_translate

	aabb: Rectangle
	switch camera_rotation {
	case .South_West:
		// camera.x = math.min(camera.x, bottom_left.x)
		// camera.z = math.min(camera.z, bottom_right.y)
		camera.x = bottom_left.x
		camera.z = bottom_right.y
		width := top_right.x - camera.x
		height := top_left.y - camera.z

		aabb = Rectangle {
				x = i32(camera.x),
				y = i32(camera.z),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .South_East:
		camera.x = math.max(camera.x, bottom_right.x)
		camera.z = math.min(camera.z, bottom_left.y)
		width := camera.x - top_left.x
		height := top_right.y - camera.z

		aabb = Rectangle {
				x = i32(top_left.x),
				y = i32(camera.z),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .North_East:
		camera.x = math.max(camera.x, bottom_left.x)
		camera.z = math.max(camera.z, bottom_right.y)
		width := camera.x - top_right.x
		height := camera.z - top_left.y

		aabb = Rectangle {
				x = i32(top_right.x),
				y = i32(top_left.y),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	case .North_West:
		camera.x = math.min(camera.x, bottom_right.x)
		camera.z = math.max(camera.z, bottom_left.y)
		width := top_left.x - camera.x
		height := camera.z - top_right.y

		aabb = Rectangle {
				x = i32(camera.x),
				y = i32(top_right.y),
				w = i32(math.ceil(width)),
				h = i32(math.ceil(height)),
			}
	}

	return aabb
}

draw_billboard_system_instances :: proc(billboard_system: ^Billboard_System) {
	if len(billboard_system.instances) == 0 do return

	visible_instances := [dynamic]Billboard_Instance{}
	defer delete(visible_instances)

	aabb := get_camera_aabb()
	indices := quadtree_search(&billboard_system.quadtree, aabb)
	defer delete(indices)
	for index in indices {
		append(&visible_instances, billboard_system.instances[index])
	}

	// fmt.println("visible billboards:", len(visible_instances))
	if len(visible_instances) == 0 do return

	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.ibo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(visible_instances) * size_of(Billboard_Instance),
		raw_data(visible_instances),
		gl.STATIC_DRAW,
	)
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)


	gl.ActiveTexture(gl.TEXTURE0)
	gl.BindTexture(gl.TEXTURE_2D_ARRAY, billboard_system.texture_array)

	gl.ActiveTexture(gl.TEXTURE1)
	gl.BindTexture(
		gl.TEXTURE_2D_ARRAY,
		billboard_system.depth_map_texture_array,
	)

	gl.BindBuffer(gl.UNIFORM_BUFFER, billboard_system.ubo)
	gl.BindBufferBase(gl.UNIFORM_BUFFER, 2, billboard_system.ubo)
	billboard_system.uniform_object.view = camera_view
	billboard_system.uniform_object.proj = camera_proj
	billboard_system.uniform_object.rotation = glsl.mat4Rotate(
		{0, 1, 0},
		glsl.radians_f32(f32(camera_rotation) * -90.0),
	)
	billboard_system.uniform_object.camera_rotation = u32(camera_rotation)
	gl.BufferData(
		gl.UNIFORM_BUFFER,
		size_of(Billboard_Uniform_Object),
		&billboard_system.uniform_object,
		gl.STATIC_DRAW,
	)
	gl.BindBuffer(gl.UNIFORM_BUFFER, 0)

	gl.BindVertexArray(billboard_system.vao)
	gl.DrawElementsInstanced(
		gl.TRIANGLES,
		i32(len(billboard_system.indices)),
		gl.UNSIGNED_BYTE,
		nil,
		i32(len(visible_instances)),
	)
	gl.BindVertexArray(0)

}

draw_billboards :: proc() {
	gl.UseProgram(billboard_system.shader_program)
	draw_billboard_system_instances(&billboard_system)
	draw_billboard_system_instances(&four_tiles_billboard_system)
}

append_billboard :: proc(using billboard: One_Tile_Billboard) -> int {
	instance := Billboard_Instance {
		position  = position,
		light     = light,
		texture   = f32(texture),
		depth_map = f32(depth_map),
		rotation  = rotation,
	}

	index := len(billboard_system.instances)
	append(&billboard_system.instances, instance)
	quadtree_append(
		&billboard_system.quadtree,
		{i32(position.x + 0.5), i32(position.z + 0.5)},
		index,
	)

	return index
}

billboard_set_texture :: proc(index: int, texture: Billboard_Texture) {
	billboard_system.instances[index].texture = f32(texture)
}

remove_billboard :: proc(index: int) {
	position := billboard_system.instances[index].position
	old := glsl.ivec2{i32(position.x + 0.5), i32(position.z + 0.5)}
	quadtree_remove(&billboard_system.quadtree, old, index)
}

move_billboard :: proc(index: int, to: glsl.vec3) {
	position := billboard_system.instances[index].position
	billboard_system.instances[index].position = to

	old := glsl.ivec2{i32(position.x + 0.5), i32(position.z + 0.5)}
	new := glsl.ivec2{i32(to.x + 0.5), i32(to.z + 0.5)}

	if old != new {
		quadtree_remove(&billboard_system.quadtree, old, index)
		quadtree_append(&billboard_system.quadtree, new, index)
	}
}

append_four_tiles_billboard :: proc(using billboard: Four_Tiles_Billboard) {
	instance := Billboard_Instance {
		position  = position,
		light     = light,
		texture   = f32(texture),
		depth_map = f32(depth_map),
		rotation  = rotation,
	}
	index := len(four_tiles_billboard_system.instances)
	append(&four_tiles_billboard_system.instances, instance)
	quadtree_append(
		&four_tiles_billboard_system.quadtree,
		{i32(position.x + 0.5), i32(position.z + 0.5)},
		index,
	)
}

load_billboard_model :: proc(
	path: cstring,
	vertices: ^[4]Billboard_Vertex,
	indices: ^[6]u8,
) -> (
	ok: bool = false,
) {
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

	return true
}

load_billboard_depth_map_texture_array :: proc(
	paths: [$T]cstring,
	expected_width: i32,
	expected_height: i32,
) -> (
	ok: bool = true,
) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.CLAMP)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.CLAMP)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	textures :: len(paths)

	if (textures == 0) {
		fmt.println("No textures to load.")
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	fmt.println("depth map TexStorage3D")
	gl.TexStorage3D(
		gl.TEXTURE_2D_ARRAY,
		1,
		gl.R16,
		expected_width,
		expected_height,
		textures,
	)

	for path, i in paths {
		width: i32
		height: i32
		channels: i32
		pixels := stbi.load_16(path, &width, &height, &channels, 1)
		fmt.println("channels", channels)
		fmt.println("dimensions:", width, ",", height)
		defer stbi.image_free(pixels)

		if pixels == nil {
			fmt.eprintln("Failed to load texture: ", path)
			return false
		}

		if width != expected_width {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				expected_width,
				" got: ",
				width,
			)
			return false
		}

		if height != expected_height {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				expected_height,
				" got: ",
				height,
			)
			return false
		}

		fmt.println("TexSubImage3D")
		gl.TexSubImage3D(
			gl.TEXTURE_2D_ARRAY,
			0,
			0,
			0,
			i32(i),
			expected_width,
			expected_height,
			1,
			gl.RED,
			gl.UNSIGNED_SHORT,
			pixels,
		)
	}

	gl_error := gl.GetError()
	if (gl_error != gl.NO_ERROR) {
		fmt.println(
			"Error loading billboard depth map texture array: ",
			gl_error,
		)
		return false
	}

	return
}

load_billboard_texture_array :: proc(
	paths: [$T]cstring,
	expected_width: i32,
	expected_height: i32,
) -> (
	ok: bool = true,
) {
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_WRAP_T, gl.REPEAT)

	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D_ARRAY, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	textures :: len(paths)

	if (textures == 0) {
		fmt.println("No textures to load.")
		return true
	}

	stbi.set_flip_vertically_on_load(0)
	stbi.set_flip_vertically_on_load_thread(false)

	gl.TexStorage3D(
		gl.TEXTURE_2D_ARRAY,
		1,
		gl.RGBA8,
		expected_width,
		expected_height,
		textures,
	)

	for path, i in paths {
		width: i32
		height: i32
		pixels := stbi.load(path, &width, &height, nil, 4)
		defer stbi.image_free(pixels)

		if pixels == nil {
			fmt.eprintln("Failed to load texture: ", path)
			return false
		}

		if width != expected_width {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different width. expected: ",
				expected_width,
				" got: ",
				width,
			)
			return false
		}

		if height != expected_height {
			fmt.eprintln(
				"Texture: ",
				path,
				" is of a different height. expected: ",
				expected_height,
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
			expected_width,
			expected_height,
			1,
			gl.RGBA,
			gl.UNSIGNED_BYTE,
			pixels,
		)
	}

	return
}
