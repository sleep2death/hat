class_name Stats
extends Node

export (NodePath) var hit_box_node
onready var hitbox = get_node(hit_box_node) as Area2D

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
