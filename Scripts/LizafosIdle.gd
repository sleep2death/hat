extends EntityStateBase
class_name LizafosIdle

export (float, 0.1, 3) var anim_speed = 1.0
var direction

export (NodePath) var player_detection_node = "../../player_detection"
onready var player_detection := get_node(player_detection_node) as TargetDetection

func enter(params):
	.enter(params)
	
	if params && params.has("prev_dir"):
		direction = params.prev_dir
	if not direction:
		direction = _fsm.root.default_facing
		
	Utils.play_animation(_anim_player, "idle", anim_speed, direction)
	assert(player_detection.connect("targets_changed", self, "on_targets_changed") == OK)

func exit():
	player_detection.disconnect("targets_changed", self, "on_targets_changed")
	.exit()

func on_hurt(from: Stats):
	_fsm.transition_to("hurt", {"from": from})

func on_targets_changed(targets):
	if targets.size() > 0:
		var target = Utils.find_nearest_target(_fsm.root.global_position, targets)
		var dir = (target.global_position - _fsm.root.global_position).normalized()
		_fsm.transition_to("spear_grab", {"prev_dir": Utils.get_direction_name(dir)})
