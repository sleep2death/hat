extends EntityStateBase
class_name LizafosHurt

var hit_burst := preload("res://Scenes/HitBurst.tscn")
var dust_poof_particles := preload("res://Scenes/World/DustPoofParticles.tscn")
var enemy_death := preload("res://Scenes/EnemyDeath.tscn")

export (int, 0, 600) var knock_back_speed = 150
export (int, 0, 600) var friction = 300

var knock_back: Vector2 = Vector2.ZERO

export (int, 0, 100, 1) var freeze_count = 30
var frame_count := 0

export (NodePath) var dust_particles_node = "../../dust_poof_particles"
onready var dust_particles = get_node(dust_particles_node)

var is_dizzle: bool = false
var direction

var dying: bool = false

func enter(params):
	.enter(params)
	
	var dir := Vector2.ZERO
	if params.has("from"):
		is_dizzle = false
		var from = params.from
		if _stats.take_damage(from) == 0:
			dying = true
		else:
			dying = false
			
		dir = (_fsm.root.global_position - from.owner.global_position).normalized()
	elif params.has("collision"):
		is_dizzle = true
		dir = params.collision.normal
	
	knock_back = knock_back_speed * dir
	
	direction = Utils.get_reversed_direction_name(dir)
	Utils.play_animation(_anim_player, "hurt", 1.0, direction, true)
	
	var hb := hit_burst.instance() as AnimatedSpriteAutoFree
	hb.playing = true
	hb.global_position = _hurt_box.global_position
	
	get_tree().current_scene.call_deferred("add_child", hb)
	dust_particles.emitting = true

func exit():
	.exit()
	frame_count = 0

func on_dying():
	var ed := enemy_death.instance() as AnimatedSpriteAutoFree
	ed.playing = true 
	ed.global_position = _fsm.root.global_position
	
	fsm.root.call_deferred("queue_free")
	get_tree().current_scene.call_deferred("add_child", ed)

func update(delta):
	knock_back = knock_back.move_toward(Vector2.ZERO, delta * friction)
	knock_back = _fsm.root.move_and_slide(knock_back)
	
	if knock_back.length_squared() <= 0.01:
		if is_dizzle:
			frame_count += 1
			if frame_count > freeze_count:
				_fsm.transition_to("idle", {"prev_dir": direction})
		else:
			if dying:
				return on_dying()
			_fsm.transition_to("idle", {"prev_dir": direction})

func on_hurt(from: Stats):
	if not dying:
		_fsm.transition_to("hurt", {"from": from})
