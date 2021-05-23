extends Area2D
class_name HurtBox

signal on_hurt(from)
# this func may be called by player's hitbox directly
func on_hurt(from: Stats):
	emit_signal("on_hurt", from)
	# fsm.on_global_event("on_hurt", from)

func has_area_entered() -> bool:
	return get_overlapping_areas().size() > 0

func _ready():
	assert(connect("area_entered", self, "on_area_entered") == OK)

func _exit_tree():
	disconnect("area_entered", self, "on_area_entered")

func on_area_entered(area: HitBox):
	on_hurt(area.stats)
