class_name InventoryContainer extends Control

## Generic inventory container class
## Can be used as a superclass for any kind of inventory container: Grid, Loose, Slots, whatever
 

@onready var items_base : Control = $Items
var list_of_contained_items : Array[ItemUI]

signal item_inserted(item: ItemUI)
signal item_successfully_inserted
signal item_removed(item: ItemUI)
signal item_hover(item: ItemUI)
signal cleared

func _ready() -> void:
	pass

var active = true
func set_active(a: bool):
	active = a
	visible = a
	if !a:
		clear()

func is_active() -> bool:
	return active

# called once when inventory is opened
func just_opened(_obj_opening=null):
	pass

# called once when inventory is closed
func just_closed():
	pass

func insert_item(item: ItemUI, _force_insert = false) -> bool:
	if !is_active():
		return false
	item.complete_insert(self)
	if item.get_parent() == null:
		items_base.add_child(item)
	else:
		item.reparent(items_base)
	list_of_contained_items.append(item)
	item_inserted.emit(item)
	item_successfully_inserted.emit()
	return true

func insert_item_at_first_available_spot(item: ItemUI) -> bool:
	return insert_item(item, true)

func fill_identical_stackables(new_item: ItemUI): # returns true if new_item will be deleted
	if !new_item.stackable:
		return false
	
	var returning_item = new_item.last_container_inside_of == self
	if returning_item:
		return false
	
	for item : ItemUI in list_of_contained_items:
		if item.item_id == new_item.item_id:
			var item_filling = item
			var item_emptying = new_item
			var space = item_filling.max_stack - item_filling.amount_in_stack
			var amnt_in_new_item = item_emptying.amount_in_stack
			if amnt_in_new_item <= space:
				remove_item(item_emptying)
				item_emptying.queue_free()
				item_filling.amount_in_stack += amnt_in_new_item
				item_inserted.emit(item_filling)
				item_successfully_inserted.emit()
				return true
			else:
				item_filling.amount_in_stack += space
				item_emptying.amount_in_stack -= space
	return false

func grab_item(cursor_pos: Vector2) -> ItemUI:
	if !is_active():
		return null
	var item : ItemUI = get_item_under_pos(cursor_pos)
	if item:
		remove_item(item)
		item.grab(cursor_pos)
	return item

func remove_item(item: ItemUI):
	if item in list_of_contained_items:
		list_of_contained_items.erase(item)
		item_removed.emit(item)

func peek_item(cursor_pos: Vector2) -> ItemUI:
	if !is_active():
		return null
	var item : ItemUI = get_item_under_pos(cursor_pos)
	if item:
		item_hover.emit(item)
	return item

func has_space_for_item(_item : ItemUI):
	return true

func is_hovering(cursor_pos: Vector2) -> bool:
	if !is_active():
		return false
	return get_global_rect().has_point(cursor_pos)

func get_item_under_pos(cursor_pos: Vector2) -> ItemUI:
	if !is_active():
		return null
	var items_inverted = items_base.get_children()
	items_inverted.reverse()
	for item : ItemUI in items_inverted:
		if item.get_global_rect().has_point(cursor_pos):
			return item
	return null

func get_all_items() -> Array:
	return list_of_contained_items

func get_save_data():
	return {}

func load_save_data(_container_data):
	clear()

func clear():
	if items_base == null:
		return
	list_of_contained_items = []
	for item in items_base.get_children():
		if not is_instance_valid(item):
			continue
		item.queue_free()
	cleared.emit()
