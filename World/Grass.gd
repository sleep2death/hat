extends Node2D
func _ready():
	print($HitBox)
	pass
	
func createGrassEffect():
		var GrassEffect = preload("res://Effects/GrassEffect.tscn") 
		var ge = GrassEffect.instance();
		ge.position = global_position

		var world = get_tree().current_scene
		world.add_child(ge)


func onHitBoxEntered(area: Area2D):
	if area.name == "SwordBox":
		print("sword!")
		createGrassEffect()
		queue_free()
