class_name ItemDynamicData extends Node

## For storing dynamic item data like durability, amount in a stack, upgrades, whatever you want
## also any code that is needed for both ItemUI and ItemWorld should go here, e.g. stack tracking

var is_ui_item = false

var stackable = false
var max_stack = 1
var amount_in_stack = 1:
	set(value):
		amount_in_stack = value
		update_stack_texture()

var stack_texture_paths_ui = []
var stack_texture_paths_world = []

signal update_stack_texture_ui(texture: Texture)
signal update_stack_texture_world(texture: Texture)

static func create_new_item_dynamic_data(item_id: String, _is_ui_item: bool) -> ItemDynamicData:
	var item_dynamic_data := ItemDynamicData.new()
	item_dynamic_data.add_to_group("instanced")
	item_dynamic_data.initialize_dynamic_item_data(item_id, _is_ui_item)
	return item_dynamic_data

func initialize_dynamic_item_data(item_id: String, _is_ui_item: bool):
	is_ui_item = _is_ui_item
	var item_data = ItemDB.get_item_data(item_id)
	if ItemDB.ITEM_MAX_STACK_STR in item_data:
		stackable = true
		max_stack = item_data[ItemDB.ITEM_MAX_STACK_STR]
		if item_data[ItemDB.GRAPHICS_WORLD_PATH_STR] is Array:
			stack_texture_paths_world = item_data[ItemDB.GRAPHICS_WORLD_PATH_STR]
		if item_data[ItemDB.GRAPHICS_UI_PATH_STR] is Array:
			stack_texture_paths_ui = item_data[ItemDB.GRAPHICS_UI_PATH_STR]

func update_stack_texture():
	if !stack_texture_paths_ui.is_empty() and is_ui_item:
		var ind = clamp(amount_in_stack - 1, 0, stack_texture_paths_ui.size()-1)
		var texture = load(stack_texture_paths_ui[ind])
		update_stack_texture_ui.emit(texture)
	if !stack_texture_paths_world.is_empty() and !is_ui_item:
		var ind = clamp(amount_in_stack - 1, 0, stack_texture_paths_world.size()-1)
		var texture = load(stack_texture_paths_world[ind])
		update_stack_texture_world.emit(texture)

static func get_stack_texture_for_id(item_id: String, stack_size: int):
	var item_data = ItemDB.get_item_data(item_id)
	var texture_paths = item_data[ItemDB.GRAPHICS_WORLD_PATH_STR]
	if texture_paths is not Array:
		return null
	var ind = clamp(stack_size - 1, 0, texture_paths.size()-1)
	return load(texture_paths[ind])

func clear_signals():
	for connection in update_stack_texture_world.get_connections():
		update_stack_texture_world.disconnect(connection.callable)
	for connection in update_stack_texture_ui.get_connections():
		update_stack_texture_ui.disconnect(connection.callable)

func get_save_data():
	return {
		"amount_in_stack": amount_in_stack,
	}

func load_save_data(data : Dictionary):
	if "amount_in_stack" in data:
		amount_in_stack = roundi(data.amount_in_stack)
