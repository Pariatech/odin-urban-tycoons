package wall

import "core:log"
import "core:math/linalg/glsl"

import "../camera"
import "../floor"

Cutaway_State :: enum {
	Up,
	Down,
}

cutaway_state: Cutaway_State

previous_visible_chunks_start: glsl.ivec2
previous_visible_chunks_end: glsl.ivec2

set_walls_down :: proc() {
	cutaway_state = .Down
    set_cutaway(.Down)
}

set_walls_up :: proc() {
	cutaway_state = .Up
    set_cutaway(.Up)
}

set_cutaway :: proc(state: State) {
	for x in camera.visible_chunks_start.x ..< camera.visible_chunks_end.x {
		for z in camera.visible_chunks_start.y ..< camera.visible_chunks_end.y {
			chunk := &chunks[floor.floor][x][z]
			chunk.dirty = true

			for wall_pos, &w in chunk.east_west {
				w.state = state
			}

			for wall_pos, &w in chunk.north_south {
				w.state = state
			}

			for wall_pos, &w in chunk.south_west_north_east {
				w.state = state
			}

			for wall_pos, &w in chunk.north_west_south_east {
				w.state = state
			}
		}
	}
}

init_cutaways :: proc() {
	// set_walls_down()
}

apply_cutaway :: proc() -> bool {
	if cutaway_state != .Down {
		return false
	}

	if floor.previous_floor != floor.floor {
		return true
	}

	if previous_visible_chunks_start != camera.visible_chunks_start {
		return true
	}

	if previous_visible_chunks_end != camera.visible_chunks_end {
		return true
	}

	return false
}

update_cutaways :: proc() {
	if apply_cutaway() {
		for x in camera.visible_chunks_start.x ..< camera.visible_chunks_end.x {
			for z in camera.visible_chunks_start.y ..< camera.visible_chunks_end.y {
				chunk := &chunks[floor.previous_floor][x][z]
				chunk.dirty = true

				for wall_pos, &w in chunk.east_west {
					w.state = .Up
				}

				for wall_pos, &w in chunk.north_south {
					w.state = .Up
				}

				for wall_pos, &w in chunk.south_west_north_east {
					w.state = .Up
				}

				for wall_pos, &w in chunk.north_west_south_east {
					w.state = .Up
				}

				if cutaway_state == .Down {
					chunk := &chunks[floor.floor][x][z]
					chunk.dirty = true

					for wall_pos, &w in chunk.east_west {
						w.state = .Down
					}

					for wall_pos, &w in chunk.north_south {
						w.state = .Down
					}

					for wall_pos, &w in chunk.south_west_north_east {
						w.state = .Down
					}

					for wall_pos, &w in chunk.north_west_south_east {
						w.state = .Down
					}
				}
			}
		}
	}

	previous_visible_chunks_start = camera.visible_chunks_start
	previous_visible_chunks_end = camera.visible_chunks_end
}
