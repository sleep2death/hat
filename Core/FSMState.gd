class_name FSMState
extends Node

var fsm setget set_fsm

func set_fsm(value):
	fsm = value

func update(_delta):
	pass

func exit():
	pass

func enter(_msg):
	pass

func on_global_event(_name, _args):
	pass
