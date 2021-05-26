class_name PlayerAttack
extends EntityStateBase

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 100, 600, 1) var deceleration = 300

const half_pi = PI * 0.5

# physics frame - 60fps unsually, NOT Animation frame
export (int, 0, 60) var hit_start_frame = 0
export (int, 0, 60) var hit_end_frame = 10
var frame_count = 0

var velocity = Vector2.ZERO
var direction = ""

var hit_shape: CollisionShape2D

func _ready():
	._ready()
	
	physics = get_tree().get_current_scene().get_world_2d().direct_space_state
	hit_shape = _hit_box.get_node("shape") as CollisionShape2D
	
	query.set_shape(hit_shape.shape)
	query.collision_layer = _hit_box.collision_mask
	query.collide_with_areas = true
	
func enter(params):
	.enter(params)
	if params && params.has("prev_vel"):
		velocity = params.prev_vel
	else:
		velocity = Vector2.ZERO

	# require pre direction name
	assert(params && params.has("prev_dir"), "prev_dir required")
	direction = params.prev_dir
	
	_hit_box.rotation = Utils.get_direction_rad(direction)
	
	assert(_anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")
	play_animation()

func update(_delta):
	if frame_count >= hit_start_frame && frame_count < hit_end_frame:
		hit_collision_query()
	else:
		prev_collisions.clear()
		
	velocity = velocity.move_toward(Vector2.ZERO, _delta * deceleration)
	velocity = _fsm.root.move_and_slide(velocity)
	
	frame_count += 1

func exit():
	.exit()
	_anim_player.disconnect("animation_finished", self, "on_anim_finished")
	frame_count = 0

func on_hurt(from: Stats):
	_fsm.transition_to("hurt", from)

func on_anim_finished(_name):
	fsm.transition_to("move", {"prev_dir": direction, "prev_vel":velocity})

func play_animation():
	var anim = ""	
	anim = Utils.get_side_direction(direction) + "_attack_dagger"	

	# flip sprite if input is LEFT
	if direction == "left":
		_anim_player.on_flipped(true)
	else:
		_anim_player.on_flipped(false)

	if _anim_player.current_animation != anim:
		_anim_player.get_animation(anim).loop = false	
		_anim_player.play(anim, -1, anim_speed)

var physics: Physics2DDirectSpaceState
var query = Physics2DShapeQueryParameters.new()
var bush_particle = preload("res://Scenes/World/BushParticles.tscn")

var prev_collisions: Array = []

func hit_collision_query():
	query.transform = hit_shape.global_transform
	var res = physics.intersect_shape(query)	
	
	for col in res:
		if col.collider is TileMap:
			var tm = col.collider as TileMap
			var local_position = tm.map_to_world(col.metadata)
			var global_position = tm.to_global(local_position)
			
			match tm.tile_set.tile_get_name(tm.get_cellv(col.metadata)):
				"global_bush":
					hit_bush(tm, col.metadata, global_position)
				"grasslands_tree_stump":
					pass
				
		elif col.collider is HurtBox:
			var hb = col.collider as HurtBox
			if hb.owner != fsm.root && prev_collisions.find(col.collider_id) < 0:
				hb.on_hurt(_stats)
				prev_collisions.append(col.collider_id)
		else:
			pass
			# prints("unkown collider:", col.collider)

func hit_bush(map, map_pos, global_pos):
	var p = bush_particle.instance()
	p.position = global_pos + Vector2(16, 16)
	var world = get_tree().current_scene
	world.add_child(p)
	
	map.set_cellv(map_pos, -1)
	
