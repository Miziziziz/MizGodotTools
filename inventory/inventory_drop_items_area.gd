class_name InventoryDropItemsArea extends InventoryContainer

## 'container' that actually just drops items into the game world

@export var item_world_drop_point : Node2D 

var rand_offset_amnt = 10.0

func insert_item(item: ItemUI, force_insert = false) -> bool:
	if !force_insert and !get_global_rect().has_point(item.global_position):
		return false
	
	item.queue_free()
	var item_world : ItemWorld = item.get_item_world_instance()
	var rand_offset = Vector2(randf_range(-rand_offset_amnt, rand_offset_amnt), randf_range(-rand_offset_amnt, rand_offset_amnt))
	item_world.global_position = item_world_drop_point.global_position + rand_offset # if error, check if you set 'item_world_drop_point' in the inspector
	item_world.global_rotation = randf_range(0.0, TAU)
	get_tree().get_root().add_child(item_world)
	item_inserted.emit(item)
	return true
