class_name SlotContainer extends InventoryContainer

## Carries exactly one item

@export var restrict_to_item_type = "" # e.g. "weapon", "armor"

func insert_item(item: ItemUI, force_insert = false) -> bool:
	if !item_is_correct_type(item.item_id):
		return false
	if !force_insert and not get_global_rect().has_point(item.get_item_center_pos()):
		return false
	if fill_identical_stackables(item): # stackable was inserted and fully drained and deleted
		return true
	if !list_of_contained_items.is_empty():
		return false
	
	item.set_custom_size(size)
	item.set_item_center_pos(global_position + size / 2.0)
	super(item, force_insert)
	return true

func has_space_for_item(item: ItemUI):
	if !item_is_correct_type(item.item_id):
		return false
	if !list_of_contained_items.is_empty():
		return false
	return true

func item_is_correct_type(item_id: String):
	return restrict_to_item_type == "" or ItemDB.get_item_type(item_id) == restrict_to_item_type

func get_save_data():
	if list_of_contained_items.is_empty():
		return {}
	return list_of_contained_items[0].get_save_data()

func load_save_data(data: Dictionary):
	clear()
	var item : ItemUI = ItemUI.create_item_ui_from_save_data(data)
	if item:
		items_base.add_child(item)
		insert_item(item, true)
