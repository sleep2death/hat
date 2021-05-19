class_name FSMState
extends Node

var fsm setget set_fsm

func set_fsm(value):
	fsm = value

func update(_delta):
	pass

func exit():
	fsm.disconnect("on_global_event", self, "on_global_event")

func enter(_msg):
	fsm.connect("on_global_event", self, "on_global_event")

func on_global_event(_name, _args):
	pass
