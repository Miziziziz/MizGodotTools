class_name AttackEmitter extends Node2D

## Base class used for emitting attacks from weapons

signal attacked

var damage : int :
	set(v):
		damage = v
		for child in get_children():
			if child is AttackEmitter:
				child.damage = v

var source_of_attack : Node2D:
	set(s):
		source_of_attack = s
		for child in get_children():
			if child is AttackEmitter:
				child.source_of_attack = s


func set_bodies_to_exclude(bte: Array):
	for child in get_children():
		if child is AttackEmitter:
			child.set_bodies_to_exclude(bte)

func do_attack():
	for child in get_children():
		if child is AttackEmitter:
			child.do_attack()
	attacked.emit()
