extends Node2D
class_name DropShadowAnimated

export (NodePath) var target_node
onready var target = get_node(target_node)

export (Vector2) var offset = Vector2(0, 0)

export (float, 0.0, 1.0, 0.1) var scale_y = 0.9
export (float, -1.0, 1.0, 0.1) var skew_x = 0.5
export (float, 0.0, 1.0, 0.1) var alpha = 0.3
	
func _draw():
	var tr = Transform2D(Vector2(1, 0), Vector2(skew_x, scale_y), offset)
	if target.global_transform.x.x == -1:
		tr.y.x *= -1
		tr.origin.x = -offset.x
			
	self.transform = tr
	draw_texture(target.texture, target.offset, Color(0, 0, 0, alpha))
