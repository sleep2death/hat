class_name PlayerMove
extends EntityStateBase

export (float, 0.1, 3) var idle_anim_speed = 0.6
export (float, 0.1, 3) var move_anim_speed = 1.0
export (int, 10, 200, 1) var run_speed = 80
export (int, 100, 600, 1) var acceleration = 300

var velocity = Vector2.ZERO
var direction = "front"
var last_nonzero_input = Vector2.ZERO

func enter(params):
	.enter(params)

	_fsm.root.z_index = 0
	_anim_player.shadow.offset = Vector2.ZERO
	
	# if the player was already get hurt
	# TODO: a little more time
	var hit_boxes =  _hurt_box.get_overlapping_areas()
	if hit_boxes.size() > 0:
		_fsm.transition_to("hurt", hit_boxes[0].stats)
	
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
		return _fsm.transition_to("attack", {"prev_dir": direction, "prev_vel": velocity})

	play_animation(input)	

	velocity = velocity.move_toward(input * run_speed, delta * acceleration)
	velocity = _fsm.root.move_and_slide(velocity)

func on_hurt(from: Stats):
	_fsm.transition_to("hurt", from)

func play_animation(input):
	var anim = ""	
	var anim_speed = 1.0
	# IDLE
	if input.length_squared() == 0:
		anim = Utils.get_side_direction(direction) + "_idle"
		
		_fsm.root.water_circle_ins.visible = true
		_fsm.root.water_splash_ins.visible = false
		
		anim_speed = idle_anim_speed
	else:
		last_nonzero_input = input
		direction = Utils.get_direction_name(input)
		anim = Utils.get_side_direction(direction)	 + "_move"
		# flip sprite if input is LEFT
		if direction == "left" :
			_anim_player.on_flipped(true)
		else:
			_anim_player.on_flipped(false)
		
		_fsm.root.water_circle_ins.visible = false
		_fsm.root.water_splash_ins.visible = true
		
		anim_speed = move_anim_speed

	if _anim_player.current_animation != anim:
		_anim_player.play(anim, -1, anim_speed)
