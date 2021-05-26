class_name Stats
extends Node

export (int, 1, 100, 1) var damage = 1

export (int, 1, 20, 1) var max_hp = 12
onready var hp: int = max_hp setget set_hp

signal dying()
signal health_changed(hp)

func _ready():
	emit_signal("health_changed", hp)

func set_hp(value):
	value = clamp(value, 0, max_hp)
	if value != hp:
		hp = value
		emit_signal("health_changed", hp)
		
	if hp == 0:
		emit_signal("dying")

func take_damage(from: Stats) -> int:
	self.hp -= from.damage
	return hp
