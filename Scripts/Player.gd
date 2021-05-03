extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

export var ACCELERATION = 300;
export var MAX_SPEED = 80;
export var FRICTION = 500;
const KEYFRAME_DURATION = 0.075

var vel = Vector2.ZERO
var input = Vector2.ZERO;
var lastNoneZeroInput = Vector2.ZERO
var currentDirection: float = 0
var currentBlender: String = ""

onready var sprite = $Sprite as Sprite
onready var ap = $AnimationPlayer as AnimationPlayer
onready var at = $AnimationTree as AnimationTree
onready var astate = at.get("parameters/playback") as AnimationNodeStateMachinePlayback

onready var swordBox = $SwordBox as Area2D
onready var swordShape = $SwordBox/CollisionShape2D as CollisionShape2D

var inputArr = []
var maxInputBuffer: int = 3

func _ready():
	createAnimations()
	inputArr.resize(maxInputBuffer)
	# set default animation state
	(at.tree_root as AnimationNodeStateMachine).set_start_node("Idle")

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state  = MOVE

func _physics_process(delta):
	match state:
		MOVE:
			move(delta)
		ROLL:
			roll(delta)
		ATTACK:
			attack(delta)

# move state
func move(delta):
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()
	
	if input != Vector2.ZERO:
		# remember last none-zero input 
		lastNoneZeroInput = input

		# set all blend_position here:
		at.set("parameters/Idle/blend_position", input)
		at.set("parameters/Run/blend_position", input)
		at.set("parameters/Attack1/blend_position", input)
		at.set("parameters/Attack2/blend_position", input)
		at.set("parameters/Roll/blend_position", input)
		astate.travel("Run")
		vel = vel.move_toward(input * MAX_SPEED, ACCELERATION * delta)
	else:
		astate.travel("Idle")
		vel = vel.move_toward(Vector2.ZERO, FRICTION * delta)

	# remember the velocity, so the physics body won't damp
	if Input.is_action_just_pressed("ui_attack"):
		doAttack()
		inputArr.append("attack")
		return
	
	if Input.is_action_just_pressed("ui_roll"):
		doRoll()
		inputArr.append("roll")
		return
	
	vel = move_and_slide(vel)


func doAttack():
		state = ATTACK
		# make velocity to 0
		vel = Vector2.ZERO
		# calulate sword box rotation
		swordBox.rotation = lastNoneZeroInput.angle() + (PI * 0.5)
		astate.travel("Attack1")

func attack(_delta):
		pass

func doRoll():
	state = ROLL
	# input = lastNoneZeroInput
	astate.travel("Roll")

func roll(delta):
	vel = vel.move_toward(lastNoneZeroInput * MAX_SPEED, ACCELERATION * delta)
	vel = move_and_slide(vel)
	
func animStarted(blender: String, _direction: String):
	if blender == "Attack1" || blender == "Attack2":
		# make the sword collision disabled
		swordShape.disabled = false
	# print(blender, ":", direction)

func animFinished(blender: String, _direction: String):
	if blender == "Attack1" || blender == "Attack2" || blender == "Roll":
		# swordShape.disabled = true
		state = MOVE
	# make the sword collision available
		swordShape.disabled = true
	
func createAnimations():
	# read sprite sheet json
	var json = readJSON("res://AnimRes/Hero.json")
	var root = at.tree_root as AnimationNodeStateMachine
	if json != null:
		var tags = json.meta.frameTags
		for tag in tags:
			var tag_name = tag.name.split("_")
			var blend = tag_name[0]
			var dir = tag_name[1]
			
			# add animation blender to the statemachine
			if !root.has_node(blend):
				var n = AnimationNodeBlendSpace2D.new()
				root.add_node(blend, n)
			
			var blender = root.get_node(blend) as AnimationNodeBlendSpace2D
			
			# add animation to player
			var anim = Animation.new()
			anim.length = (tag.to - tag.from + 1) * KEYFRAME_DURATION
			 
			# add frame track
			anim.add_track(Animation.TYPE_VALUE, 0)
			anim.track_set_path(0, "Sprite:frame")

			# add "finish" callback track
			anim.add_track(Animation.TYPE_METHOD, 1)
			anim.track_set_path(1, ".:Functions")

			# DO NOT DELETE THIS, use this specific update mode
			anim.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
			anim.loop = true
			
			# DO NOT FORGET TO: + 1 frame
			for t in range(tag.from, tag.to + 1):
				var time = KEYFRAME_DURATION * (t - tag.from)
				anim.track_insert_key(0, time, t)
				if t == tag.from:
					anim.track_insert_key(1, time, {"method" : "animStarted" , "args" : [blend, dir]})
				if t == tag.to:
					anim.track_insert_key(1, time, {"method" : "animFinished" , "args" : [blend, dir]})

			# add animation to the player
			ap.add_animation(tag.name, anim)
			
			# add blend point to blender
			var ana = AnimationNodeAnimation.new()
			ana.animation = tag.name
			match dir:
				"up":
					blender.add_blend_point(ana, Vector2.UP)
				"upright":
					blender.add_blend_point(ana, Vector2(0.7, -0.7))
				"right":
					blender.add_blend_point(ana, Vector2.RIGHT)
				"downright":
					blender.add_blend_point(ana, Vector2(0.7, 0.7))
				"down":
					blender.add_blend_point(ana, Vector2.DOWN)
				"downleft":
					blender.add_blend_point(ana, Vector2(-0.7, 0.7))
				"left":
					blender.add_blend_point(ana, Vector2.LEFT)
				"upleft":
					blender.add_blend_point(ana, Vector2(-0.7, -0.7))
				_:
					print("unrecgonized animation direction: ", dir)


func readJSON(path):
	var f = File.new()
	f.open(path, File.READ)
	var j = f.get_as_text()
	f.close()
	if j.length() > 0:
		var res = JSON.parse(j)
		if res.error == OK:
			return res.result
		else:
			print_debug("can\'t read json file:" + path)
