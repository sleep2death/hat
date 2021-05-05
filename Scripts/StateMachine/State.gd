class_name State
extends Node

signal state_entered(name)
signal state_exited(name)
signal transition_to(path, params)

export (float, 0.1, 3.0, 0.1) var animation_speed = 1.0

# animation names
const DIRECTIONS = ["upleft", "up", "upright", "right", "downright", "down", "downleft", "left"]

func _ready():
	add_to_group("state_machine")

func post_update():
	pass

func get_velocity(_velocity, _delta) -> Vector2:
	return Vector2.ZERO

func update_animation(_ap: AnimationPlayer):
	pass

func enter(_msg):
	emit_signal("state_entered", self.name)

func exit():
	emit_signal("state_exited", self.name)

func make_transition(path, params):
	emit_signal("transition_to", path, params)

func animation_started(_anim_name):
	pass

func animation_finished(_anim_name):
	pass

# smooth 8-axis snapping
# SEE: https://forum.unity.com/threads/8-way-direction-joystick-only.438758/
func get_direction_name(input) -> String:
	var deg = -7.5 * sin(input.angle() * 8) + rad2deg(input.angle()) 
	return DIRECTIONS[int(round(deg / 45)) + 3]

func get_direction_rad(name) -> float:
	var dir = DIRECTIONS.find(name)
	assert(dir > -1, "wrong direction name " + name)
	return dir * PI * 0.25 + (PI * 1.75)
