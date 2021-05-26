extends EntityStateBase
class_name PlayerHurt

const hit_burst := preload("res://scenes/HitBurst.tscn")

export (float, 0.1, 3) var anim_speed = 1.0

export (int, 0, 600) var knock_back_speed = 150
export (int, 0, 600) var friction = 200

var knock_back: Vector2 = Vector2.ZERO

export (int, 0, 100, 1) var freeze_count = 40 # half second
var frame_count := 0

var direction = ""

func enter(from: Stats):
	if _stats.take_damage(from) == 0:
		_fsm.transition_to("dying", null)
		return
	# _hurt_box.monitorable = false
	var dir: Vector2 = (_fsm.root.global_position - from.owner.global_position).normalized()
	knock_back = knock_back_speed * dir
	play_animation(dir)
	
	var hb := hit_burst.instance() as AnimatedSpriteAutoFree
	hb.playing = true
	hb.global_position = _hurt_box.global_position
	
	get_tree().current_scene.call_deferred("add_child", hb)
	
func exit():
	frame_count = 0
	# _hurt_box.set_deferred("monitorable", true)

func update(delta):
	knock_back = knock_back.move_toward(Vector2.ZERO, delta * friction)
	knock_back = _fsm.root.move_and_slide(knock_back)
	
	frame_count += 1
	if frame_count > freeze_count:
		_fsm.transition_to("move", {"prev_dir": direction, "prev_vel": knock_back})

func play_animation(dir: Vector2):
	var anim = ""	
	direction = Utils.get_reversed_direction_name(dir)
	anim = Utils.get_side_direction(direction) + "_hurt"	
	
	# flip sprite if input is LEFT
	if direction == "left":
		_anim_player.on_flipped(true)
	else:
		_anim_player.on_flipped(false)

	if _anim_player.current_animation != anim:
		_anim_player.get_animation(anim).loop = false	
		_anim_player.play(anim, -1, anim_speed)

