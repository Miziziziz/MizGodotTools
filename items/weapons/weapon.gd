class_name Weapon extends Node

## Weapon base class, any weapons should be an inherited scene from Weapon.tscn
## this implementation does not count as an Item (ItemWorld or ItemUI) and is
## intented to be attached directly to the player

@onready var attack_emitter : AttackEmitter = $AttackEmitter
@export var damage = 1

signal attacked

func _ready():
	attack_emitter.damage = damage

func set_weapon_held_by(held_by: Node2D):
	attack_emitter.source_of_attack = held_by

func set_bodies_to_exclude(bte: Array):
	attack_emitter.set_bodies_to_exclude(bte)

func attack():
	attack_emitter.do_attack()
	attacked.emit()
