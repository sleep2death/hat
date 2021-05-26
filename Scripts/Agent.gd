extends KinematicBody2D
class_name Agent

export (String, "front", "right", "back", "left") var default_facing = "front"

export (int, 4, 32, 1) var num_rays = 16

# context array
var ray_directions = []
var interests = []
var dangers = []

# velocity control
var chosen_dir = Vector2.ZERO
var velocity = Vector2.ZERO

func _ready():
	var body = get_node("./display/body") as Sprite
	
	# add reflection
	water_reflection_ins = water_reflection.instance() as WaterReflection
	water_reflection_ins.target_node = body.get_path()
	reflection_layer.add_child(water_reflection_ins)
	
	water_circle_ins = water_circle.instance() as AnimatedSprite
	reflection_layer.add_child(water_circle_ins)
	
	# initialize arrays
	ray_directions.resize(num_rays)
	interests.resize(num_rays)
	dangers.resize(num_rays)
	
	for i in num_rays:
		interests[i] = 0
		dangers[i] = 0
		
		var rad = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(rad)

func start():
	for i in num_rays:
		interests[i] = 0
		dangers[i] = 0

func seek(target: KinematicBody2D, weight: float = 1.0):
	for i in num_rays:
		var dir = (target.global_position - global_position).normalized()
		interests[i] += max(0, ray_directions[i].dot(dir) * weight)

func avoid_collision(look_ahead: float = 50.0, weight: float = 1.0):
	var space_state = get_world_2d().direct_space_state
	
	for i in num_rays:
		var result = space_state.intersect_ray(position,
				position + ray_directions[i].rotated(rotation) * look_ahead,
				[self], collision_mask)
		if not result:
			continue
		var dist = position.distance_to(result.position)
		dangers[i] += ((look_ahead - dist) / look_ahead) * weight

func group_separation(group: Array, radius: float = 30.0, weight: float = 1.0):
	var radius_squared = radius * radius 
	
	for body in group:
		if body == self:
			continue
		var dist_squared = global_position.distance_squared_to(body.global_position)
		if dist_squared < radius_squared:
			for i in num_rays:
				var dir = (body.global_position - global_position).normalized()
				dangers[i] += max(0, ray_directions[i].dot(dir) * weight)

func finalize() -> Vector2:
	# Eliminate interest in slots with danger
	for i in num_rays:
		if dangers[i] > 0.0:
			interests[i] = max(0, interests[i] - dangers[i])
	# Choose direction based on remaining interest

	chosen_dir = Vector2.ZERO
	for i in num_rays:
		chosen_dir += ray_directions[i] * interests[i]

	chosen_dir = chosen_dir.normalized()
	return chosen_dir

var water_reflection = preload("res://Scenes/WaterReflection.tscn")
var water_reflection_ins: WaterReflection

var water_circle = preload("res://Scenes/WaterCircle.tscn")
var water_circle_ins: AnimatedSprite


export (NodePath) var reflection_node = "../../../WaterReflection"
onready var reflection_layer := get_node(reflection_node) as Node2D

export (NodePath) var water_node = "../../../Water"
onready var water := get_node(water_node) as TileMap

func _physics_process(_delta):
	water_circle_ins.global_position = global_position
	
	if is_on_water():
		water_reflection_ins.visible = true
		# draw reflection
		water_reflection_ins.do_update()
	else:
		water_reflection_ins.visible = false
		
func is_on_water() -> bool:
	var pos := water.to_local(global_position)
	var cell := water.world_to_map(pos)
	
	return water.get_cellv(cell) >= 0
	
func _exit_tree():
	reflection_layer.remove_child(water_reflection_ins)
	reflection_layer.remove_child(water_circle_ins)
	
