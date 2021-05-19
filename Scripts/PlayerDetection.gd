extends Area2D
class_name PlayerDetection

var player = null

func _ready():
	connect("body_entered", self, "on_body_entered")
	connect("body_exited", self, "on_body_exited")
	
func on_body_entered(body):
	player = body

func on_body_exited(body):
	player = body
