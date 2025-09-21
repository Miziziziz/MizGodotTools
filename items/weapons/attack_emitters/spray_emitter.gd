extends AttackEmitter

## add random variance to an attack

@export var max_random_angle = 3.0

func do_attack():
	rotation_degrees = randf_range(-max_random_angle, max_random_angle)
	super()
