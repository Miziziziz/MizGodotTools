extends CanvasLayer

@onready var base = $Base
@onready var hurt = $Base/Hurt
@onready var heal = $Base/Heal
@onready var animation_player = $AnimationPlayer

func play_heal_effect():
	heal.show()
	hurt.hide()
	animation_player.play("flash")

func play_hurt_effect():
	hurt.show()
	heal.hide()
	animation_player.play("flash")
