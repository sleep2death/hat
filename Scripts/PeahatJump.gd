class_name PeahatJump
extends EntityStateBase

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

var knockback: Vector2 = Vector2.ZERO

var backwards: bool = false

func enter(params):
	.enter(params)
	print("jump_", self)
	if params && params == true:
		backwards = true
		_anim_player.play("jump", -1, -1.0 * anim_speed, true)
	else:
		backwards = false
		_anim_player.play("jump", -1, anim_speed)
		
	_anim_player.get_animation("jump").loop = false
	
	_anim_player.shadow.offset.y = 3
	_anim_player.shadow.offset.x = 4
	
	assert(_anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")

func exit():
	.exit()
	_anim_player.disconnect("animation_finished", self, "on_anim_finished")

func update(delta):
	knockback = knockback.move_toward(Vector2.ZERO, delta * deceleration)
	knockback = _fsm.root.move_and_slide(knockback)

func on_anim_finished(_player):
	if backwards == true:
		fsm.transition_to("ground", null)
	else:
		fsm.transition_to("fly", null)
	
func on_hurt(from: Stats):
	_fsm.transition_to("hurt", from)

func on_targets_changed(targets):
	if targets.size() > 0:
		print("player entered")
