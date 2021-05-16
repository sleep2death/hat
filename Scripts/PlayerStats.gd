class_name PlayerStats
extends Node

export (int, 1, 100, 1) var damage = 1

export (int, 1, 20, 1) var max_hp = 4
onready var hp: int = max_hp setget set_hp
var is_dead: bool = false

func set_hp(value):
	if value < 0:
		value = 0
		is_dead = true
	elif value > max_hp:
		value = max_hp
