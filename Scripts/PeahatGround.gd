class_name PeahatGround
extends FSMState

export (NodePath) var animation_player
onready var anim_player = get_node(animation_player) as AsePlayer

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

var knockback: Vector2 = Vector2.ZERO

# player's physics body
var kinematic_body: KinematicBody2D
var hurt_box: HurtBox
var player_detection: TargetDetection

func set_fsm(new_value: FSM):
	knockback = Vector2.ZERO
	
	if fsm != new_value:
		fsm = new_value
		kinematic_body = fsm.root
		hurt_box = fsm.root.get_node("hurt_box") as HurtBox
		player_detection = fsm.root.get_node("player_detection") as TargetDetection

func enter(_params):
	anim_player.play("ground", -1, anim_speed)
	anim_player.shadow.offset = Vector2.ZERO
	
	assert(hurt_box.connect("on_hurt", self, "on_hurt") == OK)
	assert(player_detection.connect("targets_changed", self, "on_targets_changed") == OK)


func exit():
	hurt_box.disconnect("on_hurt", self, "on_hurt")
	player_detection.disconnect("targets_changed", self, "on_targets_changed")
	
func update(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta * deceleration)
	knockback = kinematic_body.move_and_slide(knockback)

func on_hurt(stats: Stats):
	var dir: Vector2 = hurt_box.global_position - stats.hitbox.global_position
	knockback = dir.normalized() * knockback_speed

func on_targets_changed(targets):
	if targets.size() > 0:
		fsm.transition_to("jump", null)
