class_name HitBox
extends Area2D

export (NodePath) var stats_node
onready var stats = get_node(stats_node) as PlayerStats

enum {
	HIT_TYPE_PHY_ATTACK
	HIT_TYPE_LIFT
}

var type = HIT_TYPE_PHY_ATTACK
