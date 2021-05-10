class_name AnimatedSpriteWithDropshadow
extends Sprite

func _ready():
	connect("frame_changed", self, "on_frame_changed")

func on_frame_changed():
	material.set_shader_param("coord_v", self.frame_coords.y)
	material.set_shader_param("scale_x", self.scale.x)
