class_name LooseContainer extends InventoryContainer

# carries items loosely, non grid container

@export var random_offset_max = 60.0 # used for insert_item_at_first_available_spot

func insert_item(item: ItemUI, force_insert = false) -> bool:
	if !force_insert and not get_global_rect().has_point(item.get_item_center_pos()):
		return false
	if fill_identical_stackables(item): # stackable was inserted and fully drained and deleted
		return true
	
	var item_pos = item.global_position
	
	var item_top_left_local_pos = item_pos - global_position
	var item_bot_right_local_pos = item_top_left_local_pos + item.size
	var offset = Vector2()
	if item_top_left_local_pos.x < 0:
		offset.x = -item_top_left_local_pos.x
	if item_top_left_local_pos.y < 0:
		offset.y = -item_top_left_local_pos.y
	if item_bot_right_local_pos.x > size.x:
		offset.x = size.x - item_bot_right_local_pos.x
	if item_bot_right_local_pos.y > size.y:
		offset.y = size.y - item_bot_right_local_pos.y
	item.global_position = item_pos + offset
	
	super(item, force_insert)
	return true

func insert_item_at_first_available_spot(item: ItemUI) -> bool:
	actually_set_item_to_center_pos.call_deferred(item) # have to defer since takes a frame for size to update on ItemUI
	return insert_item(item, true)

func actually_set_item_to_center_pos(item: ItemUI):
	await get_tree().process_frame
	if !is_instance_valid(item):
		return
	var rand_offset = Vector2(randf_range(-random_offset_max, random_offset_max), randf_range(-random_offset_max, random_offset_max))
	item.set_item_center_pos(global_position + size / 2 + rand_offset)

func create_item_from_id_and_insert(item_id: String):
	var item = ItemDB.create_item_for_ui(item_id)
	items_base.add_child(item)
	item.global_position = global_position + size / 2.0 - item.size / 2.0
	insert_item(item, true)
	return item

func get_save_data():
	var bag_data = []
	for item : ItemUI in items_base.get_children():
		bag_data.append(item.get_save_data(true))
	return bag_data

func load_save_data(bag_data):
	clear()
	for item_data in bag_data:
		var item : ItemUI = ItemUI.create_item_ui_from_save_data(item_data)
		if item:
			items_base.add_child(item)
			insert_item(item, true)
