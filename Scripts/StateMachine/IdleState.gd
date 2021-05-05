class_name IdleState
extends State

export (int, 100, 600, 1) var deceleration = 350

var input: Vector2 = Vector2.ZERO

var previous_direction: String = "down"

func enter(_msg):
	previous_direction = _msg

func get_velocity(velocity, delta) -> Vector2:
	input = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()

	return velocity.move_toward(Vector2.ZERO, delta * deceleration)


func update_animation(ap: AnimationPlayer):
	var name =  "Idle_" + previous_direction
	if ap.current_animation != name:
		ap.play(name, -1, animation_speed)
		ap.get_animation(name).loop = true

func post_update():
	if input != Vector2.ZERO:
		return make_transition("RunState", previous_direction)

	if Input.is_action_just_pressed("ui_attack"	):
		return make_transition("AttackState", previous_direction)

	if Input.is_action_just_pressed("ui_roll"	):
		return make_transition("RollState", previous_direction)
