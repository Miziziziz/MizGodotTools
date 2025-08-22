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

@export var custom_graphics = false
@onready var collision_shape_2d = $CollisionShape2D

@onready var item_graphics: Sprite2D = $ItemGraphics
@onready var item_outline: Sprite2D = $ItemOutline

var stackable = false
var max_stack = 1
@export var amount_in_stack = 1:
	set(value):
		amount_in_stack = value
		update_stackable_graphics()

var stack_display_textures = []

func _ready():
	if item_id == "":
		return
	initialize_item()

func initialize_item():
	if is_in_group("instanced"):
		add_to_group("serializable")
	
	var item_data = ItemDB.get_item_data(item_id)
	if ItemDB.ITEM_MAX_STACK_STR in item_data:
		stackable = true
		max_stack = item_data[ItemDB.ITEM_MAX_STACK_STR]
	
	if custom_graphics:
		return
	
	var texture_path = item_data[ItemDB.GRAPHICS_WORLD_PATH_STR]
	if texture_path is Array:
		stack_display_textures = texture_path
		texture_path = stack_display_textures[0]
	var texture = load(texture_path)
	if Engine.is_editor_hint() and item_id != "":
		$ItemGraphics.texture = texture
		name = item_id.capitalize()
		update_stackable_graphics()
		return
	
	item_graphics.texture = texture
	item_outline.texture = texture
	
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = texture.get_size()
	collision_shape_2d.shape = rect_shape
	update_stackable_graphics()

func update_stackable_graphics():
	if stack_display_textures.is_empty():
		return
	var ind = clamp(amount_in_stack - 1, 0, stack_display_textures.size()-1)
	var texture = load(stack_display_textures[ind])
	$ItemGraphics.texture = texture
	$ItemOutline.texture = texture # reference directly so it works in editor

func pickup_item():
	if !is_in_group("instanced"):
		SaveManager.add_deleted_node_path(get_path())
	queue_free()

func get_item_ui_instance() -> ItemUI:
	var item_ui : ItemUI = ItemDB.create_item_for_ui(item_id)
	item_ui.amount_in_stack = amount_in_stack
	return item_ui

func get_save_data() -> Dictionary:
	var save_data = {}
	save_data[SaveManager.INSTANCE_TYPE_STR] = "item_world"
	save_data.item_id = item_id
	save_data.global_position = var_to_str(global_position)
	save_data.global_rotation = global_rotation
	return save_data

func load_save_data(save_data: Dictionary):
	add_to_group("instanced")
	add_to_group("serializable")
	if "item_id" in save_data:
		item_id = save_data.item_id
	if "global_position" in save_data:
		global_position = str_to_var(save_data.global_position)
	if "global_rotation" in save_data:
		global_rotation = save_data.global_rotation
	initialize_item()
