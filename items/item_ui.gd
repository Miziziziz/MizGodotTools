class_name ItemUI extends Control

## Item in ui that goes in players inventory/things being looted/ paper doll equipment


# exportable for testing, set id in inspector and run local scene
@export var item_id = ""  # nullable `String`

@onready var item_texture: TextureRect = $ItemTexture
@onready var item_shadow: TextureRect = $ItemShadow
@onready var item_shadow_2: TextureRect = $ItemShadow2
@export var shadow_offset : Vector2
@onready var amount_in_stack_display: Label = $AmountInStackDisplay

var stackable = false
var max_stack = 1
var amount_in_stack = 1:
	set(value):
		amount_in_stack = value
		update_stackable_graphics()

@export_multiline var hover_info_format = ""

var last_container_inside_of : InventoryContainer
var position_when_grabbed : Vector2
var base_size : Vector2
var stack_display_textures = []

func _ready():
	var item_data = ItemDB.get_item_data(item_id)
	if ItemDB.ITEM_MAX_STACK_STR in item_data:
		stackable = true
		max_stack = item_data[ItemDB.ITEM_MAX_STACK_STR]
	
	#item_texture.texture = load(item_data[ItemDB.GRAPHICS_UI_PATH_STR])
	
	var texture_path = item_data[ItemDB.GRAPHICS_UI_PATH_STR]
	if texture_path is Array:
		stack_display_textures = texture_path
		texture_path = stack_display_textures[0]
	item_texture.texture = load(texture_path)
	
	#update_size() # throws warning spam, no way to ignore :/
	await get_tree().process_frame # sometimes size is overridden after _ready so have to call it after
	update_size()
	
	item_shadow.texture = item_texture.texture
	item_shadow.position = item_texture.position + shadow_offset
	item_shadow_2.texture = item_texture.texture
	item_shadow_2.position = item_texture.position - shadow_offset / 2.0
	amount_in_stack_display.hide()
	update_stackable_graphics()

func update_size():
	size = item_texture.texture.get_size()
	custom_minimum_size = size
	base_size = size
	item_texture.size = size
	item_shadow.size = size
	item_shadow_2.size = size

func update_stackable_graphics():
	if !stackable:
		return
	amount_in_stack_display.visible = stackable
	amount_in_stack_display.text = str(amount_in_stack)
	if stack_display_textures.is_empty():
		return
	var ind = clamp(amount_in_stack - 1, 0, stack_display_textures.size()-1)
	var texture = load(stack_display_textures[ind])
	
	item_texture.texture = texture
	item_shadow.texture = texture
	item_shadow_2.texture = texture

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
	if stackable:
		item_world.amount_in_stack = amount_in_stack
	return item_world

func get_save_data(save_position=false) -> Dictionary: # not all containers need position stored
	var data = {"id": item_id}
	if stackable:
		data.amount = amount_in_stack
	if save_position:
		data.position = var_to_str(position)
	return data

static func create_item_ui_from_save_data(data: Dictionary):
	if "id" not in data:
		return null
	var _item_id = data.id
	var item_ui : ItemUI = ItemDB.create_item_for_ui(_item_id)
	if "amount" in data:
		item_ui.amount_in_stack = roundi(data.amount)
	if "position" in data:
		item_ui.position = str_to_var(data.position) # will manually have to make sure this is correct in container
	return item_ui
