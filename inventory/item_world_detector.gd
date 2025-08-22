extends Area2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D

func get_nearest_item() -> ItemWorld:
	ray_cast_2d.enabled = true
	var nearest_item : ItemWorld
	var last_dist = -1
	for item in get_overlapping_areas():
		if item is ItemWorld:
			ray_cast_2d.target_position = ray_cast_2d.to_local(item.global_position)
			ray_cast_2d.force_raycast_update()
			if !ray_cast_2d.is_colliding(): # make sure item is not behind wall
				var dist = global_position.distance_squared_to(item.global_position)
				if last_dist < 0.0 or dist < last_dist:
					last_dist = dist
					nearest_item = item
	ray_cast_2d.enabled = false
	return nearest_item
