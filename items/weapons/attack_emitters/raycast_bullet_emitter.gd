extends AttackEmitter

## do a raycast check and deal damage
## spawns bullet tracer and a hit effect if hits a wall

@onready var ray_cast_2d : RayCast2D = $RayCast2D

const BULLET_HIT_EFFECT = preload("res://effects/bullet_hit_effect/bullet_hit_effect.tscn")
const BULLET_TRACER = preload("res://effects/bullet_tracer/bullet_tracer.tscn")

func set_bodies_to_exclude(bte: Array):
	super(bte)
	for body in bte:
		ray_cast_2d.add_exception(body)

func do_attack():
	super()
	ray_cast_2d.enabled = true
	ray_cast_2d.force_raycast_update()
	var end_pos = ray_cast_2d.to_global(ray_cast_2d.target_position)
	if ray_cast_2d.is_colliding():
		end_pos = ray_cast_2d.get_collision_point()
		var hit_coll = ray_cast_2d.get_collider()
		if hit_coll is HitBox:
			var dmg_data = DamageData.new()
			dmg_data.damage_amount = damage
			dmg_data.damage_position = ray_cast_2d.get_collision_point()
			dmg_data.damage_direction = ray_cast_2d.global_transform.x
			dmg_data.hit_normal = ray_cast_2d.get_collision_normal()
			dmg_data.source_of_damage = source_of_attack
			hit_coll.hurt(dmg_data)
		else:
			var hit_effect = BULLET_HIT_EFFECT.instantiate()
			hit_effect.global_position = ray_cast_2d.get_collision_point()
			get_tree().get_root().add_child(hit_effect)
	ray_cast_2d.enabled = false
	
	var bullet_tracer = BULLET_TRACER.instantiate()
	get_tree().get_root().add_child(bullet_tracer)
	bullet_tracer.display_line(global_position, end_pos)
