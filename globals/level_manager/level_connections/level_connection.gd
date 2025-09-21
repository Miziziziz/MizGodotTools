class_name LevelConnector extends Area2D

## loads another level when the player enters this

@export var level_to_load = "" # the name of a level in LEVEL_LIST on the LevelManager (not the full path)
@export var connection_name = "" # this should match with a LevelConnector on the connecting level_to_load

@onready var transform_on_level_enter_ref: Marker2D = $TransformOnLevelEnterRef

signal entered_here

func _ready():
	body_entered.connect(on_body_enter)

func on_body_enter(body: PhysicsBody2D):
	if body.is_in_group("player"):
		load_connected_level()

func load_connected_level():
	LevelManager.load_level.call_deferred(level_to_load, connection_name)

func load_connected_level_instant():
	LevelManager.load_level.call_deferred(level_to_load, connection_name, true)

func get_player_transform_on_entrance():
	return transform_on_level_enter_ref.global_transform

func player_entered_here():
	entered_here.emit()
