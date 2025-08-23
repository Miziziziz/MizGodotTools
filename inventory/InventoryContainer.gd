class_name GridInventoryContainer extends InventoryContainer

## Basic grid inventory, like minecraft, WoW etc. (not Diablo style)
## WIP

# TODO debug view of grid

@export var num_of_columns = 5
@export var num_of_rows = 10

@onready var grid_container: GridContainer = $GridContainer
const SLOT_INVENTORY_CONTAINER = preload("res://inventory/slot_inventory_container.tscn")
var slots : Array[SlotInventoryContainer]

func _ready():
	super()
	grid_container.columns = num_of_columns
	for _y in num_of_rows:
		for _x in num_of_columns:
			var slot_container : SlotInventoryContainer = SLOT_INVENTORY_CONTAINER.instantiate()
			grid_container.add_child(slot_container) 
			slots.append(slot_container)

func insert_item(item: ItemUI, force_insert = false) -> bool:
	for slot_c in slots:
		if slot_c.insert_item(item, force_insert):
			return true
	return false

func grab_item(cursor_pos: Vector2) -> ItemUI:
	for slot_c in slots:
		var item = slot_c.grab_item(cursor_pos)
		if item:
			return item
	return null  

func peek_item(cursor_pos: Vector2) -> ItemUI:
	for slot_c in slots:
		var item = slot_c.peek_item(cursor_pos)
		if item:
			return item
	return null

func get_item_under_pos(cursor_pos: Vector2) -> ItemUI:
	for item in get_all_items():
		if item.get_global_rect().has_point(cursor_pos):
			return item
	return null

func get_all_items() -> Array[ItemUI]:
	var items : Array[ItemUI]
	for slot_c in slots:
		var items_in_slot = slot_c.get_all_items()
		if !items_in_slot.is_empty():
			items.append(items_in_slot[0])
	return items

func get_save_data():
	return {} # TODO

func load_save_data(_container_data):
	clear() # TODO
