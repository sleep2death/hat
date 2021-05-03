extends KinematicBody2D

onready var hurtBox: Area2D = $HurtBox

func _ready():
	if hurtBox.connect("area_entered", self, "onHurt") != OK:
		print_debug("CAN NOT FIND hurtbox")
		pass

func onHurt(area: Area2D):
	print("hurt...")
