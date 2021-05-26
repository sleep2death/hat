class_name PeahatFly
extends EntityStateBase

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

var linear_drag := 0.1

export (NodePath) var player_detection_node = "../../player_detection"
onready var player_detection := get_node(player_detection_node) as TargetDetection

export (NodePath) var animated_top_node = "../../display/top"
onready var animated_top := get_node(animated_top_node) as AnimatedSprite

# Maximum possible linear velocity
export (int, 100, 450, 1) var speed_max = 35
# Maximum change in linear velocity
export (int, 100, 450, 1) var acceleration_max = 35

var velocity := Vector2.ZERO
export (int, 0, 120, 1) var ground_count = 120
var idle_count := 0

var target_player: KinematicBody2D

func enter(_params):
	.enter(_params)
	
	_anim_player.play("fly", -1, anim_speed)
	
	_hit_box.position.y = -16
	_hurt_box.position.y = -16
	
	_anim_player.shadow.offset.y = 15
	_anim_player.shadow.offset.x = 15
	
	idle_count = 0
	
	animated_top.playing = true
	animated_top.visible = true

func exit():
	animated_top.playing = false
	animated_top.visible = false
	.exit()

func update(delta):
	target_player = Utils.find_nearest_target(_fsm.root.global_position, player_detection.targets)
	
	_fsm.root.start()
	if target_player != null:
		_fsm.root.seek(target_player)
	
	_fsm.root.avoid_collision()
	_fsm.root.group_separation(get_tree().get_nodes_in_group("enemies"))
	var dir = _fsm.root.finalize()
	
	velocity = velocity.move_toward(dir * speed_max, delta * acceleration_max)
	velocity = _fsm.root.move_and_slide(velocity)

	
func on_hurt(from: Stats):
	_fsm.transition_to("hurt", from)
