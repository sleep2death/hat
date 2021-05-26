extends Node2D
class_name WaterReflection

export (NodePath) var target_node
onready var target = get_node(target_node)

export (NodePath) var water_node = "../../Water"
onready var water = get_node(water_node) as TileMap
	
func _draw():
	var tr = Transform2D(Vector2(target.global_transform.x.x, 0), Vector2(0, -1), target.global_position)
	self.transform = tr
	draw_texture(target.texture, target.offset)

func _ready():
	do_update()

func do_update():
	var t = target.texture as AtlasTexture
	material.set_shader_param("os", t.region.position.y)
	material.set_shader_param("oe", t.region.position.y + t.region.size.y)
	update()
