class_name BatStats
extends Node

signal dying(stats)

export (int, 1, 100, 1) var max_hp = 1
onready var hp = max_hp setget set_hp

func set_hp(new_value):
	hp = new_value
	if hp <= 0:
		hp = 0
		emit_signal("dying", self)
