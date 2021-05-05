extends Node2D
	
func createGrassEffect():
		var GrassEffect = preload("res://Scenes/GrassEffect.tscn") 
		var ge = GrassEffect.instance();
		ge.position = global_position

		var world = get_tree().current_scene
		world.add_child(ge)


func onHitBoxEntered(_area: Area2D):
		createGrassEffect()
		queue_free()
