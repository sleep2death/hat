extends FSMState
class_name EntityStateBase

export (NodePath) var fsm_node = ".."
onready var _fsm := get_node(fsm_node) as FSM

export (NodePath) var ase_node = "../../ase"
onready var _anim_player := get_node(ase_node) as AsePlayer

export (NodePath) var hit_box_node = "../../hit_box"
export (NodePath) var hurt_box_node = "../../hurt_box"
export (NodePath) var stats_node = "../../stats"

onready var _hit_box := get_node(hit_box_node) as HitBox
onready var _hurt_box := get_node(hurt_box_node) as HurtBox
onready var _stats := get_node(stats_node) as Stats

func enter(_params):
	assert(_hurt_box.connect("on_hurt", self, "on_hurt") == OK)

func exit():
	_hurt_box.disconnect("on_hurt", self, "on_hurt")

func on_hurt(_from: Stats):
	pass
