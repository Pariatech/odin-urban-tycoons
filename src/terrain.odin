package main

import "core:math/noise"

terrain_heights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]f32
terrain_lights: [WORLD_WIDTH + 1][WORLD_DEPTH + 1]Vec3

init_terrain :: proc() {
	SEED :: 694201337
	for x in 0 ..= WORLD_WIDTH {
		for z in 0 ..= WORLD_DEPTH {
			terrain_heights[x][z] = noise.noise_2d(SEED, {f64(x), f64(z)}) / 2.0
		}
	}

	for x in 0 ..= WORLD_WIDTH {
		for z in 0 ..= WORLD_DEPTH {
			calculate_terrain_light(x, z)
		}
	}
}

calculate_terrain_light :: proc(x, z: int) {
	normal: Vec3
	if x == 0 && z == 0 {
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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
		triangles := [?][3]Vec3 {
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

	normal = normalize(normal)
	light := dot(normalize(sun), normal)
	terrain_lights[x][z] = {light, light, light}
}
