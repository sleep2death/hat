extends Area2D
class_name HurtBox

signal on_hurt(from)

func on_hurt(from: Stats):
	emit_signal("on_hurt", from)
