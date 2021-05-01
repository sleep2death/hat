extends Node2D
# Called when the node enters the scene tree for the first time.
func _process(delta):
	if Input.is_action_just_pressed("ui_attack"):
		var GrassEffect = preload("res://Effects/GrassEffect.tscn") 
		var ge = GrassEffect.instance();
		ge.position = global_position
		var world = get_tree().current_scene
		world.add_child(ge)
		queue_free()

