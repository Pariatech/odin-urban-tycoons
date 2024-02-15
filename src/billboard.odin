package main

import "core:fmt"
import "core:math/linalg/glsl"
import gl "vendor:OpenGL"
import "vendor:cgltf"
import stbi "vendor:stb/image"


BILLBOARD_VERTEX_SHADER_PATH :: "resources/shaders/billboard.vert"
BILLBOARD_FRAGMENT_SHADER_PATH :: "resources/shaders/billboard.frag"
BILLBOARD_MODEL_PATH :: "resources/models/billboard.glb"
FOUR_TILES_BILLBOARD_MODEL_PATH :: "resources/models/4tiles-billboard.glb"
BILLBOARD_TEXTURE_WIDTH :: 256
BILLBOARD_TEXTURE_HEIGHT :: 512
FOUR_TILES_BILLBOARD_TEXTURE_WIDTH :: 512
FOUR_TILES_BILLBOARD_TEXTURE_HEIGHT :: 1024

Billboard_System :: struct {
	indices:                 [6]u8,
	vertices:                [4]Billboard_Vertex,
	nodes:                   [dynamic]Billboard_Quad_Tree_Node,
	instances:               [dynamic]Billboard_Instance,
	uniform_object:          Billboard_Uniform_Object,
	vbo, ebo, vao, ibo, ubo: u32,
	shader_program:          u32,
	texture_array:           u32,
	depth_map_texture_array: u32,
	dirty:                   bool,
}

Billboard_Quad_Tree_Node_Children :: struct {
	children: [4]int,
}

Billboard_Quad_Tree_Node_Instances :: struct {
	index: int,
	len:   int,
}

Billboard_Quad_Tree_Node :: union {
	Billboard_Quad_Tree_Node_Children,
	Billboard_Quad_Tree_Node_Instances,
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
	Chair_Wood_SW,
	Chair_Wood_SE,
	Chair_Wood_NE,
	Chair_Wood_NW,
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
	.Chair_Wood_SW = "resources/textures/billboards/chair-wood/sw-diffuse.png",
	.Chair_Wood_SE = "resources/textures/billboards/chair-wood/se-diffuse.png",
	.Chair_Wood_NE = "resources/textures/billboards/chair-wood/ne-diffuse.png",
	.Chair_Wood_NW = "resources/textures/billboards/chair-wood/nw-diffuse.png",
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
	.Chair_Wood_SW = "resources/textures/billboards/chair-wood/sw-depth-map.png",
	.Chair_Wood_SE = "resources/textures/billboards/chair-wood/se-depth-map.png",
	.Chair_Wood_NE = "resources/textures/billboards/chair-wood/ne-depth-map.png",
	.Chair_Wood_NW = "resources/textures/billboards/chair-wood/nw-depth-map.png",
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

	append(&billboard_system.nodes, Billboard_Quad_Tree_Node_Instances{})

	return true
}

cull_draw_billboard_quad_tree_node :: proc(x, z, w: int) -> bool {
	// p0 := m.vec4{f32(x), terrain_heights[x][z], f32(z), 1}
	// p1 := m.vec4{f32(x + 1), terrain_heights[x + w][z], f32(z), 1}
	// p2 := m.vec4{f32(x + 1), terrain_heights[x + w][z + w], f32(z + w), 1}
	// p3 := m.vec4{f32(x), terrain_heights[x][z + w], f32(z + w), 1}
	p0 := glsl.vec4{f32(x), 0, f32(z), 1}
	p1 := glsl.vec4{f32(x + w), 0, f32(z), 1}
	p2 := glsl.vec4{f32(x + w), 0, f32(z + w), 1}
	p3 := glsl.vec4{f32(x), 0, f32(z + w), 1}
	p0_view_space := camera_vp * p0
	if point_in_square(p0_view_space.xy, {0, 0}, 2.4) {
		return false
	}

	p1_view_space := camera_vp * p1
	if point_in_square(p1_view_space.xy, {0, 0}, 2.4) {
		return false
	}

	p2_view_space := camera_vp * p2
	if point_in_square(p2_view_space.xy, {0, 0}, 2.4) {
		return false
	}

	p3_view_space := camera_vp * p3
	if point_in_square(p3_view_space.xy, {0, 0}, 2.4) {
		return false
	}

	center :=
		(p0_view_space.xy +
			p1_view_space.xy +
			p2_view_space.xy +
			p3_view_space.xy) /
		4

	if point_in_rhombus(
		   {-1.2, -1.2},
		   glsl.vec2(center),
		   p2_view_space.xy,
		   p1_view_space.xy,
		   p0_view_space.xy,
		   p3_view_space.xy,
	   ) {
		return false
	}

	if point_in_rhombus(
		   {1.2, -1.2},
		   glsl.vec2(center),
		   p2_view_space.xy,
		   p1_view_space.xy,
		   p0_view_space.xy,
		   p3_view_space.xy,
	   ) {
		return false
	}

	if point_in_rhombus(
		   {1.2, 1.2},
		   glsl.vec2(center),
		   p2_view_space.xy,
		   p1_view_space.xy,
		   p0_view_space.xy,
		   p3_view_space.xy,
	   ) {
		return false
	}

	if point_in_rhombus(
		   {-1.2, 1.2},
		   glsl.vec2(center),
		   p2_view_space.xy,
		   p1_view_space.xy,
		   p0_view_space.xy,
		   p3_view_space.xy,
	   ) {
		return false
	}

	return true
}

cull_draw_billboard_system_instances :: proc(
	system: ^Billboard_System,
	visible_instances: ^[dynamic]Billboard_Instance,
	node_index, node_x, node_z, node_w: int,
) {
	if cull_draw_billboard_quad_tree_node(node_x, node_z, node_w) {
		return
	}
	node := system.nodes[node_index]
	switch &v in node {
	case Billboard_Quad_Tree_Node_Children:
		for child, i in v.children {
			cull_draw_billboard_system_instances(
				system,
				visible_instances,
				node_index + child,
				node_x + (i % 2) * (node_w / 2),
				node_z + (i / 2) * (node_w / 2),
				node_w / 2,
			)
		}
	case Billboard_Quad_Tree_Node_Instances:
		for i in v.index ..< v.index + v.len {
			// fmt.println("i:", i)
			append(visible_instances, system.instances[i])
		}
	}
}

draw_billboard_system_instances :: proc(billboard_system: ^Billboard_System) {
	if len(billboard_system.instances) == 0 do return

	// fmt.println("entered billboards:", len(billboard_system.instances))
	visible_instances := [dynamic]Billboard_Instance{}
	defer delete(visible_instances)
	// visible_instances := billboard_system.instances

	cull_draw_billboard_system_instances(
		billboard_system,
		&visible_instances,
		0,
		0,
		0,
		WORLD_WIDTH,
	)
	// for instance in billboard_system.instances {
	// 	// fmt.println("camera_vp:", camera_vp)
	// 	view_space := camera_vp * vec4(instance.position, 1.0)
	// 	if view_space.x >= -1.2 &&
	// 	   view_space.x <= 1.2 &&
	// 	   view_space.y >= -1.2 &&
	// 	   view_space.y <= 1.2 &&
	// 	   view_space.z >= -1.2 &&
	// 	   view_space.z <= 1.2 {
	// 		append(&visible_instances, instance)
	// 	}
	// }
	// fmt.println("visible billboards:", len(visible_instances))
	if len(visible_instances) == 0 do return

	// if billboard_system.dirty {
	gl.BindBuffer(gl.ARRAY_BUFFER, billboard_system.ibo)
	gl.BufferData(
		gl.ARRAY_BUFFER,
		len(visible_instances) * size_of(Billboard_Instance),
		raw_data(visible_instances),
		gl.STATIC_DRAW,
	)
	billboard_system.dirty = false
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)
	// }


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

append_billboard :: proc(using billboard: One_Tile_Billboard) {
	instance := Billboard_Instance {
		position  = position,
		light     = light,
		texture   = f32(texture),
		depth_map = f32(depth_map),
		rotation  = rotation,
	}
	// fmt.println("-------------")
	append_billboard_instance_to_quad_tree_node(
		&billboard_system,
		instance,
		0,
		0,
		0,
		WORLD_WIDTH,
	)

	// for node in billboard_system.nodes {
	// 	switch v in node {
	// 	case Billboard_Quad_Tree_Node_Children:
	// 		fmt.println("children:", v.children)
	// 	case Billboard_Quad_Tree_Node_Instances:
	// 		fmt.println("index:", v.index, "len:", v.len)
	// 	}
	// }
}

append_four_tiles_billboard :: proc(using billboard: Four_Tiles_Billboard) {
	instance := Billboard_Instance {
		position  = position,
		light     = light,
		texture   = f32(texture),
		depth_map = f32(depth_map),
		rotation  = rotation,
	}
	append_billboard_instance_to_quad_tree_node(
		&four_tiles_billboard_system,
		instance,
		0,
		0,
		0,
		WORLD_WIDTH,
	)
}

increment_other_billboard_node_index :: proc(
	system: ^Billboard_System,
	node_index: int,
) {
	if node_index + 1 < len(system.nodes) {
		for i in node_index + 1 ..< len(system.nodes) {
			node := &system.nodes[i]
			if v, ok := &node.(Billboard_Quad_Tree_Node_Instances); ok {
				v.index += 1
			}
		}
	}
}

increment_billboard_quad_tree_node_childrens_past_target :: proc(
	system: ^Billboard_System,
	node_index, target_index: int,
) {
	node := &system.nodes[node_index]

	if v, ok := &node.(Billboard_Quad_Tree_Node_Children); ok {
		for i in 0 ..< 4 {
			child := node_index + v.children[3 - i]
			if child == target_index do return

			if child > target_index {
				v.children[3 - i] += 4
			} else if child < target_index {
				increment_billboard_quad_tree_node_childrens_past_target(
					system,
					child,
					target_index,
				)
				return
			}
		}
	}
}

append_billboard_instance_to_quad_tree_node :: proc(
	system: ^Billboard_System,
	instance: Billboard_Instance,
	node_index, node_x, node_z, node_w: int,
) {
	node := &system.nodes[node_index]
	x := int(instance.position.x + 0.5)
	z := int(instance.position.z + 0.5)
	switch &v in node {
	case Billboard_Quad_Tree_Node_Children:
		i := x / (node_x + node_w / 2) + z / (node_z + node_w / 2) * 2
		append_billboard_instance_to_quad_tree_node(
			system,
			instance,
			node_index + v.children[i],
			node_x + (i % 2) * (node_w / 2),
			node_z + (i / 2) * (node_w / 2),
			node_w / 2,
		)
	case Billboard_Quad_Tree_Node_Instances:
		copy_value: Billboard_Quad_Tree_Node_Instances = v
		if v.len == 0 || node_w == 1 {
			inject_at(&system.instances, v.index + v.len, instance)
			v.len += 1
			increment_other_billboard_node_index(system, node_index)
			return
		}

		existing_instance := system.instances[v.index]
		existing_instance_x := int(existing_instance.position.x + 0.5)
		existing_instance_z := int(existing_instance.position.z + 0.5)
		existing_instance_i :=
			existing_instance_x / (node_x + node_w / 2) +
			existing_instance_z / (node_z + node_w / 2) * 2
		if existing_instance_x == x && existing_instance_z == z {
			inject_at(&system.instances, v.index + v.len, instance)
			v.len += 1
			increment_other_billboard_node_index(system, node_index)
			return
		}

		children: [4]int
		indices: [4]int
		for i in 0 ..< 4 {
			children[i] = i + 1
			indices[i] = v.index
			if i > existing_instance_i {
				indices[i] += v.len
			}
		}

		inject_at(
			&system.nodes,
			node_index + children[0],
			Billboard_Quad_Tree_Node_Instances{index = indices[0]},
			Billboard_Quad_Tree_Node_Instances{index = indices[1]},
			Billboard_Quad_Tree_Node_Instances{index = indices[2]},
			Billboard_Quad_Tree_Node_Instances{index = indices[3]},
		)


		increment_billboard_quad_tree_node_childrens_past_target(
			system,
			0,
			node_index,
		)

		system.nodes[node_index + children[existing_instance_i]] = copy_value
		system.nodes[node_index] = Billboard_Quad_Tree_Node_Children {
			children = children,
		}
		i := x / (node_x + node_w / 2) + z / (node_z + node_w / 2) * 2
		// fmt.println("x:", x, "z:", z, "i:", i)
		append_billboard_instance_to_quad_tree_node(
			system,
			instance,
			node_index + children[i],
			node_x + (i % 2) * (node_w / 2),
			node_z + (i / 2) * (node_w / 2),
			node_w / 2,
		)
	}
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
