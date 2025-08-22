extends CharacterBody2D


@onready var top_down_character_mover: TopDownCharacterMover = $TopDownCharacterMover
@onready var top_down_input: TopDownInput = $TopDownInput

@onready var inventory: Inventory = %Inventory
@onready var item_world_detector: Area2D = $itemWorldDetector
@onready var item_nearby_info: Label = $UICanvasLayer/ItemNearbyInfo

func _process(_delta: float) -> void:
	item_nearby_info.hide()
	if inventory.is_open:
		top_down_character_mover.move_vec = Vector2.ZERO
		return
	
	top_down_character_mover.move_vec = top_down_input.move_vec
	top_down_character_mover.face_vec = top_down_input.face_vec
	
	var nearest_item : ItemWorld = item_world_detector.get_nearest_item()
	if nearest_item:
		item_nearby_info.show()
		item_nearby_info.text = "Press 'E' to pick up: " + ItemDB.get_item_name(nearest_item.item_id)
		if nearest_item.stackable:
			item_nearby_info.text += "(%s)" % nearest_item.amount_in_stack
		if Input.is_action_just_pressed("interact"):
			inventory.pickup_world_item(nearest_item)


func get_save_data():
	return {
		"position": var_to_str(global_position),
		"rotation": global_rotation,
		"inventory" : inventory.get_save_data()
	}

func load_save_data(data: Dictionary, load_from_save: bool):
	if "position" in data and load_from_save:
		global_position = str_to_var(data.position)
	if "rotation" in data and load_from_save:
		global_rotation = data.rotation
	if "inventory" in data:
		inventory.load_save_data(data.inventory)
	
