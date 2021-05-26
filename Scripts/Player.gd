extends KinematicBody2D

var reflection = preload("res://Scenes/WaterReflection.tscn")
var water_reflection_ins: WaterReflection

var water_circle = preload("res://Scenes/WaterCircle.tscn")
var water_circle_ins: AnimatedSprite

var water_splash = preload("res://Scenes/WaterSplash.tscn")
var water_splash_ins: AnimatedSprite

export (NodePath) var reflection_node = "../../WaterReflection"
onready var reflection_layer := get_node(reflection_node) as Node2D

export (NodePath) var water_node = "../../Water"
onready var water := get_node(water_node) as TileMap

func _ready():
	var body = get_node("./display/body") as Sprite
	
	# add reflection
	water_reflection_ins = reflection.instance() as WaterReflection
	water_reflection_ins.target_node = body.get_path()
	reflection_layer.add_child(water_reflection_ins)
	
	water_circle_ins = water_circle.instance() as AnimatedSprite
	reflection_layer.add_child(water_circle_ins)
	
	water_splash_ins = water_splash.instance() as AnimatedSprite
	reflection_layer.add_child(water_splash_ins)
	
func _physics_process(_delta):
	water_circle_ins.global_position = global_position
	water_splash_ins.global_position = global_position
	
	if is_on_water():
		# draw reflection
		water_reflection_ins.do_update()
		water_reflection_ins.visible = true
	else:
		water_reflection_ins.visible = false
		
func is_on_water() -> bool:
	var pos := water.to_local(global_position)
	var cell := water.world_to_map(pos)
	
	return water.get_cellv(cell) >= 0
	
func _exit_tree():
	reflection_layer.remove_child(water_reflection_ins)
	reflection_layer.remove_child(water_circle_ins)
	reflection_layer.remove_child(water_splash_ins)
