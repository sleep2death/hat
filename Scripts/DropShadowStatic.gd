extends Node2D
class_name DropShadowStatic

export (NodePath) var target_node
onready var target = get_node(target_node)

export (Vector2) var offset = Vector2(0, 0)

export (float, 0.0, 1.0, 0.1) var scale_y = 0.9
export (float, -1.0, 1.0, 0.1) var skew_x = 0.5
export (float, 0.0, 1.0, 0.1) var alpha = 0.3

func _draw():
	var tr = Transform2D(Vector2(1, 0), Vector2(skew_x, scale_y), offset)
	var size = target.texture.get_size()
	tr.origin -= size * 0.5
	tr.origin.x -= size.x * skew_x
	tr.origin.y += size.y * (1 - scale_y)
	self.transform = tr
	draw_texture(target.texture, Vector2.ZERO, Color(0, 0, 0, alpha))
