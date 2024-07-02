package terrain

import "core:fmt"
import "core:math"
import "core:math/linalg/glsl"
import "core:math/noise"

import "../constants"
import "../utils"

MIN_LIGHT :: 0.6

sun := glsl.vec3{1, -2, 1}
terrain_heights: [constants.WORLD_WIDTH + 1][constants.WORLD_DEPTH + 1]f32
terrain_lights: [constants.WORLD_WIDTH + 1][constants.WORLD_DEPTH + 1]glsl.vec3

init_terrain :: proc() {
	set_terrain_height(3, 3, .5)

	for x in 0 ..= constants.WORLD_WIDTH {
		for z in 0 ..= constants.WORLD_DEPTH {
			calculate_terrain_light(x, z)
		}
	}
}

calculate_terrain_light :: proc(x, z: int) {
	normal: glsl.vec3
	if x == 0 && z == 0 {
		triangles := [?][3]glsl.vec3 {
			 {
				{-0.5, terrain_heights[x][z], -0.5},
				{0.5, terrain_heights[x + 1][z], -0.5},
				{-0.5, terrain_heights[x][z + 1], 0.5},
			},
		}
		for tri in triangles {
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == constants.WORLD_WIDTH && z == constants.WORLD_DEPTH {
		triangles := [?][3]glsl.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
			},
		}
		for tri in triangles {
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == 0 && z == constants.WORLD_DEPTH {
		triangles := [?][3]glsl.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z - 1], -1.0},
				{1.0, terrain_heights[x + 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == 0 && x == constants.WORLD_WIDTH {
		triangles := [?][3]glsl.vec3 {
			 {
				{0.0, terrain_heights[x][z], 0.0},
				{0.0, terrain_heights[x][z + 1], 1.0},
				{-1.0, terrain_heights[x - 1][z], 0.0},
			},
		}
		for tri in triangles {
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == 0 {
		triangles := [?][3]glsl.vec3 {
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
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == 0 {
		triangles := [?][3]glsl.vec3 {
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
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if x == constants.WORLD_WIDTH {
		triangles := [?][3]glsl.vec3 {
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
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else if z == constants.WORLD_DEPTH {
		triangles := [?][3]glsl.vec3 {
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
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	} else {
		triangles := [?][3]glsl.vec3 {
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
			normal += utils.triangle_normal(tri[0], tri[1], tri[2])
		}
	}

	normal = glsl.normalize(normal)
	light := clamp(glsl.dot(glsl.normalize(sun), normal), MIN_LIGHT, 1)
	// light :f32 = 1.0
	terrain_lights[x][z] = {light, light, light}
}

get_tile_height :: proc(x, z: int) -> f32 {
	x := math.clamp(x, 0, constants.WORLD_WIDTH + 1)
	z := math.clamp(z, 0, constants.WORLD_DEPTH + 1)
	total :=
		terrain_heights[x][z] +
		terrain_heights[x + 1][z] +
		terrain_heights[x][z + 1] +
		terrain_heights[x + 1][z + 1]
	return total / 4
}

is_tile_flat :: proc(xz: glsl.ivec2) -> bool {
	return(
		terrain_heights[xz.x][xz.y] == terrain_heights[xz.x + 1][xz.y] &&
		terrain_heights[xz.x][xz.y] == terrain_heights[xz.x][xz.y + 1] &&
		terrain_heights[xz.x][xz.y] == terrain_heights[xz.x + 1][xz.y + 1] \
	)
}

set_terrain_height :: proc(x, z: int, height: f32) {
	if terrain_heights[x][z] == height {return}
	terrain_heights[x][z] = height
}

get_terrain_height :: proc(pos: glsl.ivec2) -> f32 {
	return(
		terrain_heights[clamp(pos.x, 0, constants.WORLD_WIDTH + 1)][clamp(pos.y, 0, constants.WORLD_DEPTH + 1)] \
	)
}
