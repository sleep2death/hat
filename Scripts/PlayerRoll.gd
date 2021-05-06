class_name PlayerRoll
extends FSMState

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var roll_speed = 80
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

func enter(params):
	if params && params.has("prev_vel"):
		velocity = params.prev_vel
	else:
		velocity = Vector2.ZERO	

	assert(params && params.has("prev_dir"), "prev_dir required")
	direction = params.prev_dir

	assert(anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")

	var anim = "Roll_" + direction
	anim_player.get_animation(anim).loop = false
	anim_player.play(anim, -1, anim_speed)

func update(delta):
	velocity = velocity.move_toward(Vector2.UP.rotated(Utils.get_direction_rad(direction)) * roll_speed, delta * acceleration)
	velocity = kinematic_body.move_and_slide(velocity)

func exit():
	anim_player.disconnect("animation_finished", self, "on_anim_finished")

func on_anim_finished(_name):
	# IDLE
	fsm.transition_to("Move", {"prev_dir": direction, "prev_vel": velocity})
