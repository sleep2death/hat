extends EntityStateBase
class_name PlayerDying

# British Engish: Grey; American English: Gray
onready var filter := get_tree().current_scene.get_node("./CanvasLayer/BackBufferCopy").get_node("GreyFilter") as ColorRect

func enter(_params):
	_fsm.root.z_index = 2
	
	var anim := _anim_player.get_animation("death")
	anim.loop = false

	_anim_player.shadow.offset = Vector2(-4, 2)
	
	_anim_player.play("death")
	assert(_anim_player.connect("animation_finished", self, "on_animation_finished") == OK)

var frame_count = 0

func update(_delta):
	if frame_count < 100:
		filter.material.set_shader_param("offset", 0.01 * frame_count)
		frame_count += 1

func on_animation_finished(_name):
	# filter.material.set_shader_param("offset", 1.0)
	print("dead: ", _name)
	
