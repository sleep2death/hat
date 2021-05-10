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

# player's animation sprite
var sprite: Sprite

var velocity = Vector2.ZERO
var direction = "down"
var last_nonzero_input = Vector2.ZERO

func set_fsm(new_value: FSM):
	if fsm != new_value:
		fsm = new_value

		kinematic_body = fsm.root
		anim_player = fsm.root.get_node("AsepritePlayer") as AnimationPlayer
		sprite = fsm.root.get_node("Sprite") as Sprite

func enter(params):
	if params && params.has("prev_vel"):
		velocity = params.prev_vel
	else:
		velocity = Vector2.ZERO

func update(delta):
	var input = Utils.get_input()
	
	# ATTACK	
	if Input.is_action_just_pressed("ui_attack"):
		return fsm.transition_to("Attack", {"prev_input": last_nonzero_input, "prev_vel": velocity})

	# ROLL	
	if Input.is_action_just_pressed("ui_roll"):
		return fsm.transition_to("Roll", {"prev_input": last_nonzero_input, "prev_vel": velocity})
	
	play_animation(input)	

	velocity = velocity.move_toward(input * run_speed, delta * acceleration)
	velocity = kinematic_body.move_and_slide(velocity)

func play_animation(input):
	var anim = ""	
	# IDLE
	if input.length_squared() == 0:
		anim = "idle_" + direction
	else:
		last_nonzero_input = input
		direction = Utils.get_direction_name(input)
		anim = "walk_" + direction	
		# flip sprite if input is LEFT
		if input.x < 0:
			sprite.scale.x = -1.0
		else:
			sprite.scale.x = 1.0	

	if anim_player.current_animation != anim:
		anim_player.play(anim, -1, anim_speed)
