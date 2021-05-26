extends Position2D
class_name CameraController

export (NodePath) var player_node = "../Player"
onready var player = get_node(player_node) as Player

export (int, 100, 600, 1) var acceleration = 150;

func _physics_process(delta):
	var target_pos = global_position.move_toward(player.global_position, acceleration * delta)
	global_position = Vector2(int(target_pos.x), int(target_pos.y))
