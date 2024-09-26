package game

import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"
import "core:path/filepath"

Object_Blueprint_JSON :: struct {
	name:          string,
	category:      string,
	model:         string,
	icon:          string,
	texture:       string,
	placement_set: [dynamic]string,
}

Object_Blueprint :: struct {
	name:          string,
	category:      Object_Type,
	model:         string,
	icon:          string,
	texture:       string,
	placement_set: Object_Placement_Set,
}

Object_Blueprints :: [dynamic]Object_Blueprint

load_object_blueprints :: proc(
	game: ^Game_Context = cast(^Game_Context)context.user_ptr,
) -> bool {
	return read_object_blueprints_dir("resources/objects", game)
}

deload_object_blueprints :: proc(
	game: ^Game_Context = cast(^Game_Context)context.user_ptr,
) {
	for blueprint in game.object_blueprints {
		delete(blueprint.name)
		delete(blueprint.model)
		delete(blueprint.icon)
		delete(blueprint.texture)
	}
	delete(game.object_blueprints)
}

@(private="file")
read_object_blueprints_dir :: proc(
	path: string,
	game: ^Game_Context = cast(^Game_Context)context.user_ptr,
) -> bool {
	dir, err := os.open(path)
	defer os.close(dir)
	if err != nil {
		log.fatal("Failed to open", path)
		return false
	}

	if !os.is_dir(dir) {
		log.fatal(path, "is not a dir!")
		return false
	}

	file_infos, err1 := os.read_dir(dir, 0)
    defer delete(file_infos)
	if err1 != nil {
		log.fatal("Failed to read", path)
	}

	for file_info in file_infos {
        defer delete(file_info.fullpath)
		if file_info.is_dir {
			read_object_blueprints_dir(file_info.fullpath) or_return
		} else if filepath.ext(file_info.name) == ".json" {
			read_object_blueprint_json(file_info.fullpath, game) or_return
		}
	}
	return true
}

@(private="file")
read_object_blueprint_json :: proc(
	path: string,
	game: ^Game_Context = cast(^Game_Context)context.user_ptr,
) -> bool {
	data := os.read_entire_file_from_filename(path) or_return
	defer delete(data)

	blueprint_json: Object_Blueprint_JSON
	defer delete_object_blueprint_from_json(blueprint_json)

	err := json.unmarshal(data, &blueprint_json)
	if err != nil {
		return false
	}

	blueprint := object_blueprint_from_json_to_object_blueprint(
		blueprint_json,
	) or_return

	log.info(blueprint_json)
	log.info(blueprint)

	append(&game.object_blueprints, blueprint)
	return true
}

@(private="file")
delete_object_blueprint_from_json :: proc(
	blueprint_json: Object_Blueprint_JSON,
) {
	delete(blueprint_json.category)
	for &placement in blueprint_json.placement_set {
		delete(placement)
	}
	delete(blueprint_json.placement_set)
}

@(private="file")
object_blueprint_from_json_to_object_blueprint :: proc(
	blueprint_json: Object_Blueprint_JSON,
) -> (
	blueprint: Object_Blueprint = {},
	ok: bool = true,
) {
	blueprint.name = blueprint_json.name
	blueprint.category = fmt.string_to_enum_value(
		Object_Type,
		blueprint_json.category,
	) or_return
	blueprint.model = blueprint_json.model
	blueprint.icon = blueprint_json.icon
	blueprint.texture = blueprint_json.texture
	for &placement in blueprint_json.placement_set {
		placement_enum := fmt.string_to_enum_value(
			Object_Placement,
			placement,
		) or_return
		blueprint.placement_set += {placement_enum}
	}
	return
}
