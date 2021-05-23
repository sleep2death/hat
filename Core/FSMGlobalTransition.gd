extends Node
class_name FSMGlobalTransition

export (NodePath) var fsm_node
onready var fsm = get_node(fsm_node) as FSM

func on_global_event(name, _args):
	fsm.on_global_event(name, _args)
