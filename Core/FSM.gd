class_name FSM
extends Node

export (bool) var active = true

export (NodePath) var root_node = NodePath("..")
onready var root = get_node(root_node)

export (NodePath) var initial_state

signal on_state_changed(current)

var current_state: FSMState
var prev_state: FSMState

func _ready():
	transition_to(initial_state, null)

func transition_to(path: NodePath, params):
	assert(has_node(path), "next state PATH invalid: " + path)
	var next = get_node(path)
	assert(next as FSMState, "next state TYPE invalid: " + path)
	
	if current_state != null:
		current_state.exit()
		prev_state = current_state
		
	current_state = next
	
	current_state.fsm = self
	current_state.enter(params)
	
	emit_signal("on_state_changed", current_state.name)

func on_global_event(name, args):
	current_state.on_global_event(name, args)
	
func _physics_process(delta):
	current_state.update(delta)
