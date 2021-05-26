class_name LizafosSpearMove
extends EntityStateBase

export (float, 0.1, 3) var anim_speed = 1.0

export (NodePath) var player_detection_node = "../../player_detection"
onready var player_detection := get_node(player_detection_node) as TargetDetection

var backwards: bool = false
var direction

# Maximum possible linear velocity
export (int, 1, 15, 1) var move_speed = 4
# Maximum change in linear velocity
export (int, 1, 20, 1) var acceleration = 1

export (Vector2) var spear_offset = Vector2(0, -14)
export (int, 0, 60, 1) var spear_rotation_radius = 26

var target_dir := Vector2.ZERO
var velocity := Vector2.ZERO

export (int, 0, 360, 1) var move_count = 240
var frame_count = 0

func enter(params):
	.enter(params)
	
	velocity = Vector2.ZERO
	target_dir = Vector2.ZERO
	
	if player_detection.targets.size() > 0:
		var target = Utils.find_nearest_target(_fsm.root.global_position, player_detection.targets)
		target_dir = (target.global_position - _fsm.root.global_position).normalized()
		direction = Utils.get_direction_name(target_dir)
		
		Utils.play_animation(_anim_player, "spear_move", anim_speed, direction)
	else:
		_fsm.transition_to("idle", null)

func exit():
	frame_count = 0
	.exit()
	
func update(delta):
	velocity = velocity.move_toward(target_dir * move_speed, delta * acceleration)
	var collision = _fsm.root.move_and_collide(velocity)
	
	if collision != null:
		# prints(collision.position, collision.normal, collision.collider)
		_fsm.transition_to("hurt", {"collision": collision})
		# _fsm.transition_to("hurt", null)
	else:
		frame_count += 1
		if frame_count > move_count:
			_fsm.transition_to("idle", {"prev_dir": direction})
		
func on_hurt(from: Stats):
	_fsm.transition_to("hurt", {"from": from})
