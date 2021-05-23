class_name PeahatFly
extends EntityStateBase

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

var linear_drag := 0.1

export (NodePath) var player_detection_node = "../../player_detection"
onready var player_detection := get_node(player_detection_node) as TargetDetection

# Maximum possible linear velocity
export (int, 100, 450, 1) var speed_max = 300
# Maximum change in linear velocity
export (int, 100, 450, 1) var acceleration_max = 250

var velocity := Vector2.ZERO
export (int, 0, 120, 1) var ground_count = 120
var idle_count := 0

# Holds the linear and angular components calculated by our steering behaviors.
var acceleration := GSAITargetAcceleration.new()
var target := GSAISteeringAgent.new()

# GSAISteeringAgent holds our agent's position, orientation, maximum speed and acceleration.
onready var agent := GSAISteeringAgent.new()
onready var seek_blend := GSAIBlend.new(agent)

func enter(_params):
	.enter(_params)
	
	_anim_player.play("fly", -1, anim_speed)
	
	_hit_box.position.y = -16
	_hurt_box.position.y = -16
	
	_anim_player.shadow.offset.y = 15
	_anim_player.shadow.offset.x = 15
	
	idle_count = 0

	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = acceleration_max
	
	agent.bounding_radius = 10
	
	var seek := GSAISeek.new(agent, target)

	# ar proximity := GSAIRadiusProximity.new(agent, get_tree().get_nodes_in_group("Enemies"), 100)
	# var avoid := GSAIAvoidCollisions.new(agent, proximity)

	seek_blend.add(seek, 1)	
	# seek_blend.add(avoid, 1)	

func update(delta):
	update_agent()

	var nearest := Utils.find_nearest_target(_fsm.root.global_position, player_detection.targets)
	
	if nearest != null:
		target.position.x = nearest.global_position.x
		target.position.y = nearest.global_position.y
	else:
		var rand := rand_range(-PI, PI)
		var op := Vector2(cos(rand), sin(rand)) * 60
			
		target.position.x = op.x
		target.position.y = op.y
		
		idle_count += 1	
		if idle_count >= ground_count:
			return _fsm.transition_to("jump", true)
		
	seek_blend.calculate_steering(acceleration)
	# We add the discovered acceleration to our linear velocity. The toolkit does not limit
	# velocity, just acceleration, so we clamp the result ourselves here.
	velocity = (velocity + Vector2(acceleration.linear.x, acceleration.linear.y) * delta).clamped(
		agent.linear_speed_max
	)

	# This applies drag on the agent's motion, helping it to slow down naturally.
	velocity = velocity.linear_interpolate(Vector2.ZERO, linear_drag)

	# And since we're using a KinematicBody2D, we use Godot's excellent move_and_slide to actually
	# apply the final movement, and record any change in velocity the physics engine discovered.
	velocity = _fsm.root.move_and_slide(velocity)

	
func on_hurt(from: Stats):
	_fsm.transition_to("hurt", from)

func update_agent():
	agent.position.x = _fsm.root.global_position.x
	agent.position.y = _fsm.root.global_position.y

	agent.linear_velocity.x = velocity.x
	agent.linear_velocity.y = velocity.y
