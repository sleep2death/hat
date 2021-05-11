class_name HitBox
extends Area2D

enum {
	HIT_TYPE_PHY_ATTACK
	HIT_TYPE_LIFT
}

var type = HIT_TYPE_PHY_ATTACK
# Don't export this, it will be set by player's stats
# at each attack
var damage = 1
