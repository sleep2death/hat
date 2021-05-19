extends KinematicBody2D

export (NodePath) var fsm_node
onready var fsm = get_node(fsm_node) as FSM

func on_hurt(from):
	fsm.on_global_event("on_hurt", from)
