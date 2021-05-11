extends Area2D

signal on_hit
signal on_lift

func _ready():
	connect("area_entered", self, "on_area_entered")
	
func on_area_entered(hb: HitBox):
	match hb.type:
		HitBox.HIT_TYPE_PHY_ATTACK:
			emit_signal("on_hit", hb.damage)
		HitBox.HIT_TYPE_LIFT:
			emit_signal("on_lift")
			pass

func _exit_tree():
	disconnect("area_entered", self, "on_area_entered")
