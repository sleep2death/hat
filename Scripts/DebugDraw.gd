extends Node2D
class_name DebugDraw

export (NodePath) var agent_node = ".."
onready var agent := get_node(agent_node) as Agent

export (int, 10, 100, 1) var radius = 35
export (Color) var interests_color = 0x0dc752

export (bool) var active  = false

func _draw():
	if active:
		for i in agent.num_rays:
			if not agent.interests[i]:
				continue	
			var l = agent.ray_directions[i] * agent.interests[i] * radius	
			draw_line(Vector2.ZERO, l, interests_color, 1.0, true)
	
func _physics_process(_delta):
	if active:
		update()
