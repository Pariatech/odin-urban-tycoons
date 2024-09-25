package game

import "core:encoding/json"
import "core:fmt"
import "core:log"
import "core:os"

Object_Blueprint_JSON :: struct {
	name:          string,
	category:      string,
	// category:      Object_Type,
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
	data := os.read_entire_file_from_filename(
		"resources/objects/wood_chair/wood_chair.json",
	) or_return
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

delete_object_blueprint_from_json :: proc(
	blueprint_json: Object_Blueprint_JSON,
) {
	delete(blueprint_json.category)
	for &placement in blueprint_json.placement_set {
		delete(placement)
	}
	delete(blueprint_json.placement_set)
}

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
