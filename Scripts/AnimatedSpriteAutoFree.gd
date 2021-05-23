extends AnimatedSprite
class_name AnimatedSpriteAutoFree

func _ready():
	assert(connect("animation_finished", self, "on_animation_finished") == OK)
	
func on_animation_finished():
	disconnect("animation_finished", self, "on_animation_finished")
	queue_free()
