class_name PlayerMove
extends FSMState

export (NodePath) var animation_player
onready var anim_player = get_node(animation_player) as AsePlayer

export (NodePath) var display_node
onready var display = get_node(display_node) as Node2D

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var run_speed = 80
export (int, 100, 600, 1) var acceleration = 300

var fsm: FSM setget set_fsm
# player's physics body
var kinematic_body: KinematicBody2D


var velocity = Vector2.ZERO
var direction = "front"
var last_nonzero_input = Vector2.ZERO

func set_fsm(new_value: FSM):
	if fsm != new_value:
		fsm = new_value

		kinematic_body = fsm.root

func enter(params):
	if params && params.has("prev_vel"):
		velocity = params.prev_vel
	else:
		velocity = Vector2.ZERO
	
	if params && params.has("prev_dir"):
		direction = params.prev_dir

func update(delta):
	var input = Utils.get_input()
	
	# ATTACK	
	if Input.is_action_just_pressed("ui_attack"):
		return fsm.transition_to("attack", {"prev_dir": direction, "prev_vel": velocity})

	play_animation(input)	

	velocity = velocity.move_toward(input * run_speed, delta * acceleration)
	velocity = kinematic_body.move_and_slide(velocity)

func play_animation(input):
	var anim = ""	
	# IDLE
	if input.length_squared() == 0:
		anim = Utils.get_side_direction(direction) + "_idle"
	else:
		last_nonzero_input = input
		direction = Utils.get_direction_name(input)
		anim = Utils.get_side_direction(direction)	 + "_move"
		# flip sprite if input is LEFT
		if direction =="left" && display.scale.x == 1.0:
			display.scale.x = -1.0
			anim_player.on_flipped(true)
		elif direction != "left" && display.scale.x == -1.0:
			display.scale.x = 1.0
			anim_player.on_flipped(false)

	if anim_player.current_animation != anim:
		anim_player.play(anim, -1, anim_speed)
