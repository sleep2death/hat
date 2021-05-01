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
const KEYFRAME_DURATION = 0.1

var vel = Vector2.ZERO
var input = Vector2.ZERO;

onready var sprite = $Sprite as Sprite
onready var ap = $AnimationPlayer as AnimationPlayer
onready var at = $AnimationTree as AnimationTree
onready var astate = at.get("parameters/playback") as AnimationNodeStateMachinePlayback

func _ready():
	createAnimations()
	(at.tree_root as AnimationNodeStateMachine).set_start_node("Idle")
	# createAnimationBlends()
	# at.active = true
	# print(at.get("parameters/playback") == null)
	# ap.set_current_animation("Idle_right")
	# ap.play("Idle_back_right")

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

	# remember the velocity, so the physics body won't damp
	vel = move_and_slide(vel)
	print(sprite.frame)

func createAnimations():
	# read sprite sheet json
	var json = readJSON("res://AnimRes/Hero.json")
	var root = at.tree_root as AnimationNodeStateMachine
	if json != null:
		var tags = json.meta.frameTags
		for tag in tags:
			var tag_name = tag.name.split("_")
			var state = tag_name[0]
			var dir = tag_name[1]
			
			# add animation blender to the statemachine
			if root.get_node(state) == null:
				var n = AnimationNodeBlendSpace2D.new()
				root.add_node(state, n)
			
			var blender = root.get_node(state) as AnimationNodeBlendSpace2D
			print(blender)
			
			# add animation to player
			var anim = Animation.new()
			anim.length = (tag.to - tag.from + 1) * KEYFRAME_DURATION
			anim.add_track(0)
			anim.track_set_path(0, "Sprite:frame")
			anim.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
			anim.loop = true
			
			for t in range(tag.from, tag.to):
				anim.track_insert_key(0, KEYFRAME_DURATION * (t - tag.from), t)
			ap.add_animation(tag.name, anim)
			
			# add blend point to blender
			var ana = AnimationNodeAnimation.new()
			ana.animation = tag.name
			print(dir)
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
