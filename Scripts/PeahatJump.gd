class_name PeahatJump
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

var backwards: bool = false

func set_fsm(new_value: FSM):
	knockback = Vector2.ZERO
	
	if fsm != new_value:
		fsm = new_value
		kinematic_body = fsm.root
		hurt_box = fsm.root.get_node("hurt_box") as HurtBox

func enter(params):
	if params && params == true:
		backwards = true
		anim_player.play("jump", -1, -1.0 * anim_speed, true)
	else:
		backwards = false
		anim_player.play("jump", -1, anim_speed)
		
	anim_player.get_animation("jump").loop = false
	
	anim_player.shadow.offset.y = 3
	anim_player.shadow.offset.x = 4
	
	assert(hurt_box.connect("on_hurt", self, "on_hurt") == OK)
	assert(anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")

func exit():
	hurt_box.disconnect("on_hurt", self, "on_hurt")
	anim_player.disconnect("animation_finished", self, "on_anim_finished")

func update(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta * deceleration)
	knockback = kinematic_body.move_and_slide(knockback)

func on_anim_finished(_player):
	if backwards == true:
		fsm.transition_to("ground", null)
	else:
		fsm.transition_to("fly", null)
	
func on_hurt(stats: Stats):
	var dir: Vector2 = hurt_box.global_position - stats.hitbox.global_position
	knockback = dir.normalized() * knockback_speed

func on_targets_changed(targets):
	if targets.size() > 0:
		print("player entered")
