extends Node2D

func _ready():
	$AnimatedSprite.play()

func on_animation_finished():
	queue_free()
