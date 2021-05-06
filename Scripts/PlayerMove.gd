class_name PlayerMove
extends FSMState

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var run_speed = 80
export (int, 100, 600, 1) var acceleration = 300

var fsm: FSM setget set_fsm

# player's physics body
var kinematic_body: KinematicBody2D

# player's animation player
var anim_player: AnimationPlayer

var velocity = Vector2.ZERO
var direction = "down"

func set_fsm(new_value: FSM):
	if fsm != new_value:
		fsm = new_value

		kinematic_body = fsm.root
		anim_player = fsm.root.get_node("AsepritePlayer") as AnimationPlayer

func update(delta):
	var input = Utils.get_input()

	# ATTACK	
	if Input.is_action_just_pressed("ui_attack"):
		return fsm.transition_to("Attack", {"prev_dir": direction, "prev_vel": velocity})

	# ROLL	
	if Input.is_action_just_pressed("ui_roll"):
		return fsm.transition_to("Roll", {"prev_dir": direction, "prev_vel": velocity})

	var anim = ""	
	# IDLE
	if input.length_squared() == 0:
		anim = "Idle_" + direction
	else:
		direction = Utils.get_direction_name(input)
		anim = "Run_" + direction

	if anim_player.current_animation != anim:
		anim_player.play(anim, -1, anim_speed)

	velocity = velocity.move_toward(input * run_speed, delta * acceleration)
	velocity = kinematic_body.move_and_slide(velocity)
