extends KinematicBody2D

export (int, 10, 100, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

onready var stats = $Stats

var knockback_velocity := Vector2.ZERO
var velocity := Vector2.ZERO

func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO, delta * deceleration)
	velocity = move_and_slide(velocity)

func on_hurt(hit_area: Area2D):
	var dir =  ($HurtBox.global_position - hit_area.global_position).normalized()
	velocity = dir * knockback_speed

	if hit_area.has("damage"):
		stats.hp -= hit_area.damage
		if stats.hp == 0:
			queue_free()
