extends EntityStateBase
class_name PeahatHurt

var hit_burst := preload("res://Scenes/HitBurst.tscn")
var enemy_death := preload("res://Scenes/EnemyDeath.tscn")

export (int, 0, 600) var knock_back_speed = 150
export (int, 0, 600) var friction = 200

var knock_back: Vector2 = Vector2.ZERO

export (int, 0, 100, 1) var freeze_count = 10
var frame_count := 0

export (NodePath) var animated_top_node = "../../display/top"
onready var animated_top := get_node(animated_top_node) as AnimatedSprite

var dying := false

func enter(from: Stats):
	.enter(from)
	if _stats.take_damage(from) == 0:
		dying = true
		
	# _hurt_box.monitorable = false
	var dir: Vector2 = (_fsm.root.global_position - from.owner.global_position).normalized()
	knock_back = knock_back_speed * dir
	
	var hb := hit_burst.instance() as AnimatedSpriteAutoFree
	hb.playing = true
	hb.global_position = _hurt_box.global_position
	
	get_tree().current_scene.call_deferred("add_child", hb)
	
	animated_top.playing = true
	animated_top.visible = true

func exit():
	animated_top.playing = false
	animated_top.visible = false
	frame_count = 0
	.exit()

func on_dying():
	var ed := enemy_death.instance() as AnimatedSpriteAutoFree
	ed.playing = true 
	ed.global_position = _fsm.root.global_position
	
	fsm.root.call_deferred("queue_free")
	get_tree().current_scene.call_deferred("add_child", ed)

func update(delta):
	knock_back = knock_back.move_toward(Vector2.ZERO, delta * friction)
	knock_back = _fsm.root.move_and_slide(knock_back)
	
	frame_count += 1
	if knock_back.length_squared() <= 0.01:
		if dying:
			return on_dying()
		_fsm.transition_to(_fsm.prev_state.name, null)
