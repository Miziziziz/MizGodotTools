class_name Inventory extends Control

## Generic inventory system, set up whatever inventory containers you want under Containers node
# make sure to define container_to_pickup_to in inspector
# in main player script just check "is_open" to see if in inventory
# set 'can_open_inventory' to false if player is dead or in dialog or whatever

@onready var item_dragging_base: Control = $ItemDraggingBase

@onready var containers_base: Control = $Containers
var containers : Array[InventoryContainer]
@onready var inventory_drop_items_area: InventoryDropItemsArea = $Containers/InventoryDropItemsArea

var can_open_inventory = true
var is_open = false
var item_currently_dragging : ItemUI

@onready var open_sound: AudioStreamPlayer = $Sfx/OpenSound
@onready var close_sound: AudioStreamPlayer = $Sfx/CloseSound
@onready var item_sound_player: AudioStreamPlayer = $Sfx/ItemSound

@onready var hover_info: Label = $HoverInfo
var hover_info_offset_from_cursor = Vector2.RIGHT * 10

@export var container_to_pickup_to : InventoryContainer # must be defined in inspector

func _ready() -> void:
	hide()
	inventory_drop_items_area.item_inserted.connect(item_dropped_on_ground)
	for c in containers_base.get_children():
		if c is InventoryContainer:
			containers.append(c)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory()
	
	hover_info.hide()
	if !is_open:
		return
	
	var grab_input = Input.is_action_just_pressed("interact_inventory")
	var drag_input = Input.is_action_pressed("interact_inventory")
	var place_input = Input.is_action_just_released("interact_inventory")
	var auto_interact_input = Input.is_action_just_pressed("auto_interact_inventory")
	
	var cursor_pos = get_cursor_pos()
	if drag_input and item_currently_dragging:
		drag_item(cursor_pos)
	elif grab_input:
		grab_item(cursor_pos)
	elif place_input:
		place_item()
	elif auto_interact_input:
		auto_interact(cursor_pos)
	else:
		peek_item(cursor_pos)

func get_cursor_pos():
	return containers_base.get_global_mouse_position() # TODO add controller support

func toggle_inventory():
	if is_open:
		close()
	else:
		open()

func open():
	if !can_open_inventory:
		return
	show()
	is_open = true
	open_sound.play()
	inventory_drop_items_area.hide()

func close():
	hide()
	is_open = false
	close_sound.play()
	inventory_drop_items_area.hide()

func grab_item(cursor_pos: Vector2):
	var container = get_container_under_cursor(cursor_pos)
	if container:
		item_currently_dragging = container.grab_item(cursor_pos)
		if item_currently_dragging:
			item_currently_dragging.reparent(item_dragging_base)
			play_item_sound(item_currently_dragging.item_id, ItemDB.GRAB_INV_SOUND_PATH_STR)
			inventory_drop_items_area.show()
			item_currently_dragging.set_item_center_pos(cursor_pos)

func peek_item(cursor_pos: Vector2):
	var container = get_container_under_cursor(cursor_pos)
	var item_peeking : ItemUI
	if container:
		item_peeking = container.peek_item(cursor_pos)
	if item_peeking:
		hover_info.show()
		hover_info.text = item_peeking.get_hover_info_text()
		hover_info.size = hover_info.get_minimum_size()
		hover_info.global_position = cursor_pos + hover_info_offset_from_cursor

func place_item():
	if item_currently_dragging == null:
		return
	
	var successful_insert = false
	var container = get_container_under_cursor(item_currently_dragging.get_item_center_pos())
	if container:
		successful_insert = container.insert_item(item_currently_dragging)
	
	if !successful_insert or container != inventory_drop_items_area: # dont play place in inventory sound if was dropped
		play_item_sound(item_currently_dragging.item_id, ItemDB.DROP_INV_SOUND_PATH_STR)
	
	if !successful_insert:
		item_currently_dragging.return_to_last_container()
	
	item_currently_dragging = null
	inventory_drop_items_area.hide()

func item_dropped_on_ground(item: ItemUI):
	play_item_sound(item.item_id, ItemDB.DROP_WORLD_SOUND_PATH_STR)

func drag_item(cursor_pos: Vector2):
	if item_currently_dragging:
		item_currently_dragging.set_item_center_pos(cursor_pos)

func auto_interact(_cursor_pos: Vector2):
	pass # TODO implement whatever behaviour you want, like consume potion, auto equip armor

func pickup_world_item(item_world: ItemWorld):
	var item_ui_instance : ItemUI = item_world.get_item_ui_instance()
	add_child(item_ui_instance) # calls _ready initializing the item
	if container_to_pickup_to.insert_item_at_first_available_spot(item_ui_instance):
		play_item_sound(item_world.item_id, ItemDB.GRAB_WORLD_SOUND_PATH_STR)
		item_world.pickup_item()
	else:
		item_ui_instance.queue_free()
		pass #TODO play inventory full sound

func get_container_under_cursor(cursor_pos: Vector2) -> InventoryContainer:
	for container in containers:
		if container.is_hovering(cursor_pos):
			return container
	return null

func play_item_sound(item_id: String, item_sound_tag: String):
	item_sound_player.stream = ItemDB.get_sound_for_item(item_id, item_sound_tag)
	item_sound_player.play()


func get_save_data():
	if item_currently_dragging: # force place item to it's saved
		place_item()
	var container_data = []
	for container in containers:
		if container is InventoryDropItemsArea:
			continue
		container_data.append(container.get_save_data())
	return {
		"containers_data" : container_data
	}

func load_save_data(data: Dictionary):
	if "containers_data" in data:
		var i = 0
		for container in containers:
			if container is InventoryDropItemsArea:
				continue
			container.load_save_data(data.containers_data[i])
			i += 1
