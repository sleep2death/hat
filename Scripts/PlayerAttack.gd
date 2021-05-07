class_name PlayerAttack
extends FSMState

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 100, 600, 1) var deceleration = 300

var fsm: FSM setget set_fsm

# player's physics body
var kinematic_body: KinematicBody2D

# player's animation player
var anim_player: AnimationPlayer

# player's sprite
var sprite: Sprite

# player's hitbox
var hit_area: HitBox
var hit_shape: CollisionShape2D

# player's stats
var stats: PlayerStats

const half_pi = PI * 0.5

# physics frame - 60fps unsually, NOT Animation frame
export (int, 0, 60) var hit_start_frame = 0
export (int, 0, 60) var hit_end_frame = 10
var frame_count = 0

var velocity = Vector2.ZERO
var prev_input = Vector2.ZERO

func set_fsm(new_value: FSM):
	if fsm != new_value:
		fsm = new_value

		kinematic_body = fsm.root
		anim_player = fsm.root.get_node("AsepritePlayer") as AnimationPlayer
		sprite = fsm.root.get_node("Sprite") as Sprite

		hit_area = fsm.root.get_node("HitBox") as HitBox
		hit_shape = hit_area.get_node("CollisionShape2D") as CollisionShape2D

		stats = fsm.root.get_node("Stats") as PlayerStats

func enter(params):
	if params && params.has("prev_vel"):
		velocity = params.prev_vel
	else:
		velocity = Vector2.ZERO	

	# require pre direction name
	assert(params && params.has("prev_input"), "prev_input required")
	prev_input = params.prev_input
	
	hit_area.damage = stats.damage
	hit_area.rotation = prev_input.angle() + half_pi
	
	assert(anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")
	play_animation(prev_input)

func update(_delta):
	if frame_count >= hit_start_frame && frame_count < hit_end_frame:
		hit_shape.disabled = false
	else:
		hit_shape.disabled = true

	velocity = velocity.move_toward(Vector2.ZERO, _delta * deceleration)
	velocity = kinematic_body.move_and_slide(velocity)

	frame_count += 1

func exit():
	anim_player.disconnect("animation_finished", self, "on_anim_finished")
	frame_count = 0

func on_anim_finished(_name):
	fsm.transition_to("Move", {"prev_input": prev_input, "prev_vel":velocity})


func play_animation(input):
	var anim = ""	

	var direction = Utils.get_direction_name(input)
	anim = "dagger_" + direction	
	# flip sprite if input is LEFT
	if input.x < 0:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1	

	if anim_player.current_animation != anim:
		anim_player.get_animation(anim).loop = false	
		anim_player.play(anim, -1, anim_speed)
