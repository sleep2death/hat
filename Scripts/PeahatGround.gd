class_name PeahatGround
extends EntityStateBase

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

var knockback: Vector2 = Vector2.ZERO

export (NodePath) var player_detection_node = "../../player_detection"
onready var player_detection := get_node(player_detection_node) as TargetDetection

func enter(_params):
	.enter(_params)
	
	_anim_player.play("ground", -1, anim_speed)
	_anim_player.shadow.offset = Vector2.ZERO
	
	_hit_box.position.y = 0
	_hurt_box.position.y = 0
	
	assert(player_detection.connect("targets_changed", self, "on_targets_changed") == OK)

func exit():
	player_detection.disconnect("targets_changed", self, "on_targets_changed")
	.exit()
	
func update(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta * deceleration)
	knockback = _fsm.root.move_and_slide(knockback)

func on_hurt(from: Stats):
	_fsm.transition_to("hurt", from)

func on_targets_changed(targets):
	if targets.size() > 0:
		_fsm.transition_to("jump", null)
