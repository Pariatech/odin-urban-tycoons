package main

import m "core:math/linalg/glsl"
import "core:math/noise"
import "core:fmt"

terrain_heights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]f32
terrain_lights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]m.vec3
terrain_tile_triangles: [WORLD_WIDTH][WORLD_DEPTH][Tile_Triangle_Side]Tile_Triangle

init_terrain :: proc() {
	// SEED :: 694201337
	// for x in 0 ..= WORLD_WIDTH {
	// 	for z in 0 ..= WORLD_DEPTH {
	// 		terrain_heights[x][z] =
	// 			noise.noise_2d(SEED, {f64(x), f64(z)}) / 2.0
	// 	}
	// }

	for x in 0 ..= WORLD_WIDTH {
		for z in 0 ..= WORLD_DEPTH {
			calculate_terrain_light(x, z)
		}
	}
}

calculate_terrain_light :: proc(x, z: int) {
	normal: m.vec3
	if x == 0 && z == 0 {
		triangles := [?][3]m.vec3 {
			 {
				{-0.5, terrain_heights[x][z], -0.5},
				{0.5, terrain_heights[x + 1][z], -0.5},
				{-0.5, terrain_heights[x][z + 1], 0.5},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == WORLD_WIDTH && z == WORLD_DEPTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == 0 && z == WORLD_DEPTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == 0 && x == WORLD_WIDTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == 0 {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == 0 {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == WORLD_WIDTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == WORLD_DEPTH {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	} else {
		triangles := [?][3]m.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
		}
		for tri in triangles {
			normal += triangle_normal(tri[0], tri[1], tri[2])
		}
	}

	normal = m.normalize(normal)
	light := m.dot(m.normalize(sun), normal)
	terrain_lights[x][z] = {light, light, light}
}

get_terrain_tile_triangle_lights :: proc(
	side: Tile_Triangle_Side,
	x, z: int,
) -> (
	lights: [3]m.vec3,
) {
	lights = {{1, 1, 1}, {1, 1, 1}, {1, 1, 1}}

	tile_lights := [4]m.vec3 {
		terrain_lights[x][z],
		terrain_lights[x + 1][z],
		terrain_lights[x + 1][z + 1],
		terrain_lights[x][z + 1],
	}

	lights[2] = {0, 0, 0}
	for light in tile_lights {
		lights[2] += light
	}
	lights[2] /= 4
	switch side {
	case .South:
		lights[0] = tile_lights[0]
		lights[1] = tile_lights[1]
	case .East:
		lights[0] = tile_lights[1]
		lights[1] = tile_lights[2]
	case .North:
		lights[0] = tile_lights[2]
		lights[1] = tile_lights[3]
	case .West:
		lights[0] = tile_lights[3]
		lights[1] = tile_lights[0]
	}

	return
}

get_terrain_tile_triangle_heights :: proc(
	side: Tile_Triangle_Side,
	x, z: int,
) -> (
	heights: [3]f32,
) {
	heights = {0, 0, 0}

	tile_heights := [4]f32 {
		terrain_heights[x][z],
		terrain_heights[x + 1][z],
		terrain_heights[x + 1][z + 1],
		terrain_heights[x][z + 1],
	}

	heights[2] = 0
	for height in tile_heights {
		heights[2] += height
	}
	heights[2] /= 4
	switch side {
	case .South:
		heights[0] = tile_heights[0]
		heights[1] = tile_heights[1]
	case .East:
		heights[0] = tile_heights[1]
		heights[1] = tile_heights[2]
	case .North:
		heights[0] = tile_heights[2]
		heights[1] = tile_heights[3]
	case .West:
		heights[0] = tile_heights[3]
		heights[1] = tile_heights[0]
	}

	return
}

draw_terrain_tile_triangle :: proc(side: Tile_Triangle_Side, x, z: int) {
	tri := terrain_tile_triangles[x][z][side]

	lights := get_terrain_tile_triangle_lights(side, x, z)
	heights := get_terrain_tile_triangle_heights(side, x, z)

	draw_tile_triangle(tri, side, lights, heights, {f32(x), f32(z)})
}

set_terrain_tile_triangle :: proc(
	side: Tile_Triangle_Side,
	x, z: int,
	texture: Texture,
	mask: Texture,
) {
	terrain_tile_triangles[x][z][side] = Tile_Triangle {
		texture      = texture,
		mask_texture = mask,
	}
	draw_terrain_tile_triangle(side, x, z)
}

get_tile_height :: proc(x, z: int) -> f32 {
	total :=
		terrain_heights[x][z] +
		terrain_heights[x + 1][z] +
		terrain_heights[x][z + 1] +
		terrain_heights[x + 1][z + 1]
	return total / 4
}
