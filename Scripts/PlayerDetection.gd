extends Area2D
class_name TargetDetection

var targets = []
signal targets_changed

func _ready():
	assert(connect("body_entered", self, "on_body_entered") == OK, "can not connect: body_entered")
	assert(connect("body_exited", self, "on_body_exited") == OK, "can not connect: body_exited")

func on_body_entered(body):
	targets.append(body)
	emit_signal("targets_changed", targets)

func on_body_exited(body):
	targets.erase(body)
	emit_signal("targets_changed", targets)
