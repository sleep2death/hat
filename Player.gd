extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

const ACCELERATION = 300;
const MAX_SPEED = 60;
const FRICTION = 500;
const KEYFRAME_DURATION = 0.1

var vel = Vector2.ZERO
var input = Vector2.ZERO;

onready var sprite = $Sprite as Sprite
onready var ap = $AnimationPlayer as AnimationPlayer
onready var at = $AnimationTree as AnimationTree
onready var astate = at.get("parameters/playback") as AnimationNodeStateMachinePlayback

func _ready():
	createAnimations()
	
	# set default animation state
	(at.tree_root as AnimationNodeStateMachine).set_start_node("Idle")

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state  = MOVE

func _physics_process(delta):
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()

	match state:
		MOVE:
			move(delta)
		ROLL:
			pass
		ATTACK:
			attack(delta)


func move(delta):
	if input != Vector2.ZERO:
		# set all blend_position here:
		at.set("parameters/Idle/blend_position", input)
		at.set("parameters/Run/blend_position", input)
		at.set("parameters/Attack1/blend_position", input)
		at.set("parameters/Attack2/blend_position", input)
		astate.travel("Run")
		vel = vel.move_toward(input * MAX_SPEED, ACCELERATION * delta)
	else:
		astate.travel("Idle")
		vel = vel.move_toward(Vector2.ZERO, FRICTION * delta)

	# remember the velocity, so the physics body won't damp
	vel = move_and_slide(vel)

	if Input.is_action_just_pressed("ui_attack"):
		state = ATTACK

func attack(delta):
	astate.travel("Attack1")

func animFinished(blender: String):
	if blender == "Attack1" || blender == "Attack2":
		state = MOVE

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
				if t == tag.to:
					anim.track_insert_key(1, time, {"method" : "animFinished" , "args" : [blend]})

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
