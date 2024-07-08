package tools

import "core:log"

import "floor_tool"
import "terrain_tool"

MAX_UNDOS :: 10

undos: [dynamic]Command
redos: [dynamic]Command

Command :: union {
	terrain_tool.Command,
	floor_tool.Command,
}

undo :: proc() {
	if len(undos) == 0 {
		log.debug("Nothing to undo!")
		return
	}

	command := pop(&undos)
	log.debug("undo", command)
	append(&redos, command)
	switch v in command {
	case terrain_tool.Command:
		terrain_tool.undo(v)
	case floor_tool.Command:
		floor_tool.undo(v)
	}
}

redo :: proc() {
	if len(redos) == 0 {
		log.debug("Nothing to redo!")
		return
	}

	command := pop(&redos)
	append(&undos, command)
	switch v in command {
	case terrain_tool.Command:
		terrain_tool.redo(v)
	case floor_tool.Command:
		floor_tool.redo(v)
	}
}

init :: proc() {
	set_add_command(&terrain_tool.add_command)
	set_add_command(&floor_tool.add_command)
}

deinit :: proc() {
	delete_undos()
	delete_redos()

	clear(&undos)
	clear(&redos)
}

delete_undos :: proc() {
	for undo in undos {
		delete_undo(undo)
	}
}

delete_undo :: proc(undo: Command) {
	switch &v in undo {
	case terrain_tool.Command:
	case floor_tool.Command:
		delete(v.before)
		delete(v.after)
	}
}

set_add_command :: proc(fn: ^proc(_: $T)) {
	fn^ = proc(command: T) {
		log.debug(command)
		if len(undos) == MAX_UNDOS {
			delete_undo(pop(&undos))
		}
		append(&undos, command)
		delete_redos()
		clear(&redos)
	}
}

delete_redos :: proc() {
	for redo in redos {
		switch &v in redo {
		case terrain_tool.Command:
		case floor_tool.Command:
			delete(v.before)
			delete(v.after)
		}
	}
}
