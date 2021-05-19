class_name PeahatGround
extends FSMState

export (NodePath) var animation_player
onready var anim_player = get_node(animation_player) as AsePlayer

export (NodePath) var display_node
onready var display = get_node(display_node) as Node2D

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

var knockback: Vector2 = Vector2.ZERO

# player's physics body
var kinematic_body: KinematicBody2D
var foot_collision: CollisionShape2D

func set_fsm(new_value: FSM):
	knockback = Vector2.ZERO
	
	if fsm != new_value:
		fsm = new_value
		kinematic_body = fsm.root
		foot_collision = fsm.root.get_node("foot_collision") as CollisionShape2D

func enter(params):
	anim_player.play("ground", -1, anim_speed)
	.enter(params)

func update(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta * deceleration)
	knockback = kinematic_body.move_and_slide(knockback)

func on_global_event(name, args):
	print(foot_collision)
	var dir: Vector2 = foot_collision.global_position - args.hitbox.global_position
	knockback = dir.normalized() * knockback_speed
