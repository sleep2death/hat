class_name PlayerAttack
extends FSMState

export (NodePath) var animation_player
onready var anim_player = get_node(animation_player) as AsePlayer

export (NodePath) var display_node
onready var display = get_node(display_node) as Node2D

export (NodePath) var hitbox_node
onready var hitbox = get_node(hitbox_node) as Area2D
onready var hitshape: CollisionShape2D

export (NodePath) var stats_node
onready var stats = get_node(stats_node) as PlayerStats

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 100, 600, 1) var deceleration = 300

var fsm: FSM setget set_fsm

# player's physics body
var kinematic_body: KinematicBody2D

const half_pi = PI * 0.5

# physics frame - 60fps unsually, NOT Animation frame
export (int, 0, 60) var hit_start_frame = 0
export (int, 0, 60) var hit_end_frame = 10
var frame_count = 0

var velocity = Vector2.ZERO
var direction = ""

func set_fsm(new_value: FSM):
	if fsm != new_value:
		fsm = new_value

		kinematic_body = fsm.root
		hitshape = hitbox.get_node("CollisionShape2D") as CollisionShape2D

func enter(params):
	if params && params.has("prev_vel"):
		velocity = params.prev_vel
	else:
		velocity = Vector2.ZERO

	# require pre direction name
	assert(params && params.has("prev_dir"), "prev_dir required")
	direction = params.prev_dir
	
	hitbox.rotation = Utils.get_direction_rad(direction)
	
	assert(anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")
	play_animation()

func update(_delta):
	if frame_count >= hit_start_frame && frame_count < hit_end_frame:
		hitshape.disabled = false
	else:
		hitshape.disabled = true

	velocity = velocity.move_toward(Vector2.ZERO, _delta * deceleration)
	velocity = kinematic_body.move_and_slide(velocity)

	frame_count += 1

func exit():
	anim_player.disconnect("animation_finished", self, "on_anim_finished")
	frame_count = 0

func on_anim_finished(_name):
	fsm.transition_to("move", {"prev_dir": direction, "prev_vel":velocity})


func play_animation():
	var anim = ""	
	anim = Utils.get_side_direction(direction) + "_attack_dagger"	

	# flip sprite if input is LEFT
	if direction == "left" && display.scale.x == 1.0:
		display.scale.x = -1.0
		anim_player.on_flipped(true)
	elif direction != "left" && display.scale.x == -1.0:
		display.scale.x = 1.0
		anim_player.on_flipped(false)

	if anim_player.current_animation != anim:
		anim_player.get_animation(anim).loop = false	
		anim_player.play(anim, -1, anim_speed)
	
