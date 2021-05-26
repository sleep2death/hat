class_name LizafosSpearGrab
extends EntityStateBase

export (float, 0.1, 3) var anim_speed = 1.0

var backwards: bool = false
var direction

func enter(params):
	.enter(params)
	
	var speed = anim_speed
	if params && params.has("backwards"):
		backwards = params.backwards
	
	if backwards:
		speed = anim_speed * -1.0
	else:
		backwards = false
	
	if params && params.has("prev_dir"):
		direction = params.prev_dir
	if not direction:
		direction = _fsm.root.default_facing
			
	assert(_anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")
	Utils.play_animation(_anim_player, "spear_move", speed, direction, true)

func exit():
	.exit()
	_anim_player.disconnect("animation_finished", self, "on_anim_finished")

func on_anim_finished(_player):
	if backwards == true:
		fsm.transition_to("idle", {"prev_dir": direction})
	else:
		fsm.transition_to("spear_move", {"prev_dir": direction})
	
func on_hurt(from: Stats):
	_fsm.transition_to("hurt", {"from": from})
