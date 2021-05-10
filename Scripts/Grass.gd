extends Node2D

const GrassEffect = preload("res://Scenes/World/GrassEffect.tscn") 
	
func createGrassEffect():
		var ge = GrassEffect.instance();
		ge.position = global_position

		var world = get_tree().current_scene
		world.add_child(ge)


func onHitBoxEntered(_area: Area2D):
		createGrassEffect()
		queue_free()
