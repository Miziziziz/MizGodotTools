extends AttackEmitter

## Do multiple attacks in an arc

@export var arc = 30.0
@export var shots_to_fire = 5

func do_attack():
	if shots_to_fire == 1:
		rotation_degrees = 0
		super()
		return
	
	for i in shots_to_fire:
		var angle = -arc/2.0 + i * arc / (shots_to_fire-1)
		rotation_degrees = angle
		super()
	
