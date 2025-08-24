class_name ItemUI extends Control

## Item in ui that goes in players inventory/things being looted/ paper doll equipment


# exportable for testing, set id in inspector and run local scene
@export var item_id = ""  # nullable `String`

@onready var item_texture: TextureRect = $ItemTexture
@onready var item_shadow: TextureRect = $ItemShadow
@onready var item_shadow_2: TextureRect = $ItemShadow2
@export var shadow_offset : Vector2
@onready var amount_in_stack_display: Label = $AmountInStackDisplay

var item_dynamic_data: ItemDynamicData

@export_multiline var hover_info_format = ""

var last_container_inside_of : InventoryContainer
var position_when_grabbed : Vector2
var base_size : Vector2

const CUSTOM_BASE_SIZE = Vector2(80, 80)
const USE_CUSTOM_BASE_SIZE = true # if set false it will use texture size

var stack_display_textures = []

func _ready():
	if item_dynamic_data == null:
		item_dynamic_data = ItemDynamicData.create_new_item_dynamic_data(item_id, true)
	else:
		item_dynamic_data.is_ui_item = true
		item_dynamic_data.clear_signals()
	item_dynamic_data.update_stack_texture_ui.connect(update_texture)
	
	var item_data = ItemDB.get_item_data(item_id)
	
	#item_texture.texture = load(item_data[ItemDB.GRAPHICS_UI_PATH_STR])
	
	var texture_path = item_data[ItemDB.GRAPHICS_UI_PATH_STR]
	if texture_path is Array:
		texture_path = texture_path[0]
	item_texture.texture = load(texture_path)
	
	#update_size() # throws warning spam, no way to ignore :/
	await get_tree().process_frame # sometimes size is overridden after _ready so have to call it after
	update_size()
	
	amount_in_stack_display.hide()
	update_texture(item_texture.texture)
	item_shadow.position = item_texture.position + shadow_offset
	item_shadow_2.position = item_texture.position - shadow_offset / 2.0
	item_dynamic_data.update_stack_texture()

func update_size():
	size = item_texture.texture.get_size()
	base_size = size
	if USE_CUSTOM_BASE_SIZE:
		size = CUSTOM_BASE_SIZE
		base_size = CUSTOM_BASE_SIZE # size will get ignored in slot containers so need to set here
	custom_minimum_size = size
	item_texture.size = size
	item_shadow.size = size
	item_shadow_2.size = size

func update_texture(texture: Texture):
	item_texture.texture = texture
	item_shadow.texture = texture
	item_shadow_2.texture = texture
	amount_in_stack_display.visible = item_dynamic_data.stackable
	amount_in_stack_display.text = str(item_dynamic_data.amount_in_stack)

func grab(_cursor_pos: Vector2):
	position_when_grabbed = global_position
	reset_to_base_size()

func reset_to_base_size():
	custom_minimum_size = base_size
	size = base_size

func set_custom_size(s: Vector2):
	custom_minimum_size = s
	size = s

func complete_insert(container: InventoryContainer):
	set_last_container_inside_of(container)

func return_to_last_container():
	global_position = position_when_grabbed
	last_container_inside_of.insert_item(self, true)

func get_item_center_pos() -> Vector2:
	return global_position + size / 2

func set_item_center_pos(pos: Vector2):
	global_position = pos - size / 2

func set_last_container_inside_of(inv_container: InventoryContainer):
	last_container_inside_of = inv_container

func get_last_container_inside_of() -> InventoryContainer:
	return last_container_inside_of

func get_hover_info_text():
	var item_data = ItemDB.get_item_data(item_id)
	var item_name = item_data[ItemDB.ITEM_NAME_STR]
	var item_type = item_data[ItemDB.ITEM_TYPE_STR]
	var item_description = item_data[ItemDB.ITEM_DESCRIPTION_STR]
	var item_weight = item_data[ItemDB.ITEM_WEIGHT_STR]
	return hover_info_format.format({
		"name": item_name,
		"type": item_type,
		"description": item_description,
		"weight": item_weight,
	})

func get_item_world_instance() -> ItemWorld:
	var item_world : ItemWorld = ItemDB.create_item_for_world(item_id)
	item_world.item_dynamic_data = item_dynamic_data
	return item_world

func get_save_data(save_position=false) -> Dictionary: # not all containers need position stored
	var data = {"id": item_id}
	data.item_dynamic_data = item_dynamic_data.get_save_data()
	if save_position:
		data.position = var_to_str(Vector2i(position)) # round to int to save space in save file
	return data

static func create_item_ui_from_save_data(data: Dictionary):
	if "id" not in data:
		return null
	var _item_id = data.id
	var item_ui : ItemUI = ItemDB.create_item_for_ui(_item_id)
	if "item_dynamic_data" in data:
		var new_item_dynamic_data = ItemDynamicData.create_new_item_dynamic_data(_item_id, true)
		new_item_dynamic_data.load_save_data(data.item_dynamic_data)
		item_ui.item_dynamic_data = new_item_dynamic_data
	if "position" in data:
		item_ui.position = str_to_var(data.position) # will manually have to make sure this is correct in container
	return item_ui
