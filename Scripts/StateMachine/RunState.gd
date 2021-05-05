class_name RunState
extends State

export (int, 10, 200, 1) var run_speed = 80
export (int, 100, 600, 1) var acceleration = 300

var input = Vector2.ZERO
var direction = "down"

func get_velocity(velocity, delta) -> Vector2:
	input = Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()

	return velocity.move_toward(input * run_speed, delta * acceleration)

func update_animation(ap: AnimationPlayer):
	if input == Vector2.ZERO:
		return

	direction = .get_direction_name(input)	
	var name =  "Run_" + direction
	if ap.current_animation != name:
		ap.play(name, -1, animation_speed)
		ap.get_animation(name).loop = true

func post_update():
	if input == Vector2.ZERO:
		return make_transition("IdleState", direction)

	if Input.is_action_just_pressed("ui_attack"	):
		return make_transition("AttackState", direction)

	if Input.is_action_just_pressed("ui_roll"	):
		return make_transition("RollState", direction)
