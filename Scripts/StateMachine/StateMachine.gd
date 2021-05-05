class_name StateMachine
extends KinematicBody2D
# Hierarchical State machine for the player.
# Initializes states and delegates engine callbacks
# (_physics_process, _unhandled_input) to the state.

var State = preload("./State.gd")

signal player_state_changed(previous, new)

export var start_state = NodePath()
var state: State

# animation player
export(NodePath) var animation_player
onready var ap := get_node(animation_player) as AsepritePlayer

# player's velocity
var velocity: Vector2 = Vector2.ZERO

func _ready():
	add_to_group("state_machine")

	assert(start_state != null, "init state should Not be null")

	assert(ap != null, "aseprite player NOT found")
	assert(ap.connect("animation_started", self, "animation_started") == OK, "aseprite player can NOT connect: started")
	assert(ap.connect("animation_finished", self, "animation_finished") == OK, "aseprite player can NOT connect: finished")
	assert(ap.connect("animation_changed", self, "animation_finished") == OK, "aseprite player can NOT connect: finished")

	transition_to(start_state, "down")

func transition_to(target_state_path, msg):
	assert(has_node(target_state_path), "target state does NOT exist: " + target_state_path)

	var target_state = get_node(target_state_path)
	assert(target_state is State, "target state is not type of State")

	if state != null:
		state.exit()

	state = target_state
	state.enter(msg)

	# connect "transition_to" signal only ONCE
	assert(state.connect("transition_to", self, "transition_to", [], CONNECT_ONESHOT) == OK, "connect failed")

	emit_signal("player_state_changed", state.name)
	prints("state changed to:", state.name)

func _physics_process(delta):
	# update velocity	
	velocity = move_and_slide(state.get_velocity(velocity, delta))	

	# update animation
	state.update_animation(ap)
	
	# post update
	state.post_update()	

# Animation started handling
func animation_started(anim_name):
	# print("animation started: ", anim_name)
	state.animation_started(anim_name)

# Animation finished handling
func animation_finished(anim_name):
	# print("animation finished: ", anim_name)
	state.animation_finished(anim_name)
