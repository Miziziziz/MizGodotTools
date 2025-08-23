@tool # making it a tool will make graphics auto-update when placed in editor
class_name ItemWorld extends Area2D

## Item in world on ground

## if placed in game it goes in the 'instanced' group (handled automatically)
## if placed in editor it does not go in the 'instanced' group (handled automatically)
## do not add to 'serializable' group, it will be done automatically when needed

@export var item_id = "":
	set(value):
		item_id = value
		if Engine.is_editor_hint() and item_id != "":
			initialize_item()

@export var starting_stack_size = 1: # used in editor to specify stack size of an item on the ground
	set(value):
		starting_stack_size = value
		var t = ItemDynamicData.get_stack_texture_for_id(item_id, starting_stack_size)
		if t:
			update_texture(t)


@export var custom_graphics = false
@onready var collision_shape_2d = $CollisionShape2D

@onready var item_graphics: Sprite2D = $ItemGraphics
@onready var item_outline: Sprite2D = $ItemOutline

var item_dynamic_data: ItemDynamicData

func _ready():
	if item_id == "":
		return
	initialize_item()

func initialize_item():
	if is_in_group("instanced"):
		add_to_group("serializable")
	
	if item_dynamic_data == null:
		item_dynamic_data = ItemDynamicData.create_new_item_dynamic_data(item_id, false)
		item_dynamic_data.amount_in_stack = starting_stack_size
	else:
		item_dynamic_data.is_ui_item = false # probably transferred from ItemUI to here
		item_dynamic_data.clear_signals()
	item_dynamic_data.update_stack_texture_world.connect(update_texture)
	
	var item_data = ItemDB.get_item_data(item_id)
	var texture_path = item_data[ItemDB.GRAPHICS_WORLD_PATH_STR]
	if custom_graphics or (texture_path is String and texture_path.get_extension() == "tscn"):
		return
	
	if texture_path is Array: # for stackable items with custom stack graphics
		texture_path = texture_path[0]
	
	var texture = load(texture_path)
	if Engine.is_editor_hint() and item_id != "":
		$ItemGraphics.texture = texture
		name = item_id.capitalize()
		return
	
	update_texture(texture)
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = texture.get_size()
	collision_shape_2d.shape = rect_shape
	item_dynamic_data.update_stack_texture()

func update_texture(texture: Texture):
	$ItemGraphics.texture = texture
	$ItemOutline.texture = texture

func pickup_item():
	if !is_in_group("instanced"):
		SaveManager.add_deleted_node_path(get_path())
	queue_free()

func get_item_ui_instance() -> ItemUI:
	var item_ui : ItemUI = ItemDB.create_item_for_ui(item_id)
	item_ui.item_dynamic_data = item_dynamic_data
	return item_ui

func get_save_data() -> Dictionary:
	var save_data = {}
	var resource_path = "res://items/item_world.tscn" # either pass path or uid
	save_data[SaveManager.INSTANCE_ID_KEY] = resource_path
	if custom_graphics:
		save_data[SaveManager.INSTANCE_ID_KEY] = ItemDB.get_item_data(item_id)[ItemDB.GRAPHICS_WORLD_PATH_STR]
		
	#save_data.instance_tag = resource_path.get_file().replace("."+resource_path.get_extension(), "")
	save_data.item_id = item_id
	save_data.global_position = var_to_str(Vector2i(global_position)) # rounding to ints to save space in save file
	save_data.global_rotation = roundi(global_rotation_degrees)
	save_data.item_dynamic_data = item_dynamic_data.get_save_data()
	return save_data

func load_save_data(save_data: Dictionary):
	add_to_group("instanced")
	add_to_group("serializable")
	if "item_id" in save_data:
		item_id = save_data.item_id
	if "global_position" in save_data:
		global_position = str_to_var(save_data.global_position)
	if "global_rotation" in save_data:
		global_rotation_degrees = save_data.global_rotation
	if "item_dynamic_data" in save_data:
		var new_item_dynamic_data = ItemDynamicData.create_new_item_dynamic_data(item_id, true)
		new_item_dynamic_data.load_save_data(save_data.item_dynamic_data)
		item_dynamic_data = new_item_dynamic_data
	initialize_item()
