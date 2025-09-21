extends CharacterBody2D


@onready var top_down_character_mover: TopDownCharacterMover = $TopDownCharacterMover
@onready var top_down_input: TopDownInput = $TopDownInput
@onready var health_manager = $HealthManager

@onready var pause_menu = $Menus/PauseMenu
@onready var death_menu = $Menus/DeathMenu

func _ready():
	health_manager.died.connect(on_death)

func _process(_delta: float) -> void:
	top_down_character_mover.move_vec = top_down_input.move_vec
	top_down_character_mover.face_vec = top_down_input.face_vec

func on_death():
	pause_menu.can_pause_game = false
	death_menu.display_death_menu()
	set_process(false)
	top_down_character_mover.move_vec = Vector2.ZERO
