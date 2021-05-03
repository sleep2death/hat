extends Node2D

onready var aSprite :AnimatedSprite = $AnimatedSprite

func _ready():
	aSprite.play("animate")
	pass # Replace with function body.

func onAnimFinished():
	queue_free()
