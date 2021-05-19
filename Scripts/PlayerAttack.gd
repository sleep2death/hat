class_name PlayerAttack
extends FSMState

export (NodePath) var animation_player
onready var anim_player = get_node(animation_player) as AsePlayer

export (NodePath) var display_node
onready var display = get_node(display_node) as Node2D

export (NodePath) var hitbox_node
onready var hitbox = get_node(hitbox_node) as Area2D
onready var hitshape: CollisionShape2D

export (NodePath) var stats_node
onready var stats = get_node(stats_node) as Stats

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 100, 600, 1) var deceleration = 300

# player's physics body
var kinematic_body: KinematicBody2D

const half_pi = PI * 0.5

# physics frame - 60fps unsually, NOT Animation frame
export (int, 0, 60) var hit_start_frame = 0
export (int, 0, 60) var hit_end_frame = 10
var frame_count = 0

var velocity = Vector2.ZERO
var direction = ""

func set_fsm(new_value: FSM):
	if fsm != new_value:
		fsm = new_value

		kinematic_body = fsm.root
		physics = kinematic_body.get_world_2d().direct_space_state
		hitshape = hitbox.get_node("shape") as CollisionShape2D
		
		query.set_shape(hitshape.shape)
		query.collision_layer = hitbox.collision_mask
		query.collide_with_areas = true
	
func enter(params):
	if params && params.has("prev_vel"):
		velocity = params.prev_vel
	else:
		velocity = Vector2.ZERO

	# require pre direction name
	assert(params && params.has("prev_dir"), "prev_dir required")
	direction = params.prev_dir
	
	hitbox.rotation = Utils.get_direction_rad(direction)
	
	assert(anim_player.connect("animation_finished", self, "on_anim_finished") == OK, "aseprite player can NOT connect: finished")
	play_animation()

func update(_delta):
	if frame_count >= hit_start_frame && frame_count < hit_end_frame:
		hit_collision_query()
	else:
		prev_collisions.clear()
		
	velocity = velocity.move_toward(Vector2.ZERO, _delta * deceleration)
	velocity = kinematic_body.move_and_slide(velocity)
	
	frame_count += 1

func exit():
	anim_player.disconnect("animation_finished", self, "on_anim_finished")
	frame_count = 0

func on_anim_finished(_name):
	fsm.transition_to("move", {"prev_dir": direction, "prev_vel":velocity})


func play_animation():
	var anim = ""	
	anim = Utils.get_side_direction(direction) + "_attack_dagger"	

	# flip sprite if input is LEFT
	if direction == "left" && display.scale.x == 1.0:
		display.scale.x = -1.0
		anim_player.on_flipped(true)
	elif direction != "left" && display.scale.x == -1.0:
		display.scale.x = 1.0
		anim_player.on_flipped(false)

	if anim_player.current_animation != anim:
		anim_player.get_animation(anim).loop = false	
		anim_player.play(anim, -1, anim_speed)

var physics: Physics2DDirectSpaceState
var query = Physics2DShapeQueryParameters.new()
var bush_particle = preload("res://Scenes/World/BushParticles.tscn")

var prev_collisions: Array = []

func hit_collision_query():
	query.transform = hitshape.global_transform
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
					print("hit stump")
		elif col.collider is HurtBox:
			var hb = col.collider as HurtBox
			if prev_collisions.find(col.collider_id) < 0:
				hb.on_hurt(stats)
				prev_collisions.append(col.collider_id)
		else:
			prints("unkown collider:", col.collider)

func hit_bush(map, map_pos, global_pos):
	var p = bush_particle.instance()
	p.position = global_pos + Vector2(16, 16)
	p.position += Vector2(16, 16)
	var world = get_tree().current_scene
	world.add_child(p)
	
	map.set_cellv(map_pos, -1)
	
