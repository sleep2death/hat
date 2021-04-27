extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

const ACCELERATION = 500;
const MAX_SPEED = 100;
const FRICTION = 500;

var vel = Vector2.ZERO
var input = Vector2.ZERO;

onready var ap = $AnimationPlayer as AnimationPlayer
onready var at = $AnimationTree as AnimationTree
onready var astate = at.get("parameters/playback")

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()


	if input != Vector2.ZERO:
		at.set("parameters/Idle/blend_position", input)
		at.set("parameters/Run/blend_position", input)
		astate.travel("Run")

		vel = vel.move_toward(input * MAX_SPEED, ACCELERATION * delta)
	else:
		astate.travel("Idle")

		vel = vel.move_toward(Vector2.ZERO, FRICTION * delta)

	# remember the velocity, so the body won't damp
	vel = move_and_slide(vel)
