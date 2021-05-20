class_name PeahatFly
extends FSMState

export (NodePath) var animation_player
onready var anim_player = get_node(animation_player) as AsePlayer

export (float, 0.1, 3) var anim_speed = 1.0
export (int, 10, 200, 1) var knockback_speed = 150
export (int, 100, 600, 1) var deceleration = 300

var knockback: Vector2 = Vector2.ZERO
var linear_drag := 0.1

# player's physics body
var kinematic_body: KinematicBody2D
var hurt_box: HurtBox
var player_detection: TargetDetection


# Maximum possible linear velocity
export (int, 100, 450, 1) var speed_max = 300
# Maximum change in linear velocity
export (int, 100, 450, 1) var acceleration_max = 250

var velocity := Vector2.ZERO
export (int, 0, 120, 1) var ground_count = 90

# Holds the linear and angular components calculated by our steering behaviors.
var acceleration := GSAITargetAcceleration.new()
var target := GSAISteeringAgent.new()

# GSAISteeringAgent holds our agent's position, orientation, maximum speed and acceleration.
onready var agent := GSAISteeringAgent.new()
onready var seek_blend := GSAIBlend.new(agent)

func set_fsm(new_value: FSM):
	knockback = Vector2.ZERO
	
	if fsm != new_value:
		fsm = new_value
		kinematic_body = fsm.root
		hurt_box = fsm.root.get_node("hurt_box") as HurtBox
		player_detection = fsm.root.get_node("player_detection") as TargetDetection

func enter(_params):
	anim_player.play("fly", -1, anim_speed)
	
	anim_player.shadow.offset.y = 15
	anim_player.shadow.offset.x = 15

	agent.linear_speed_max = speed_max
	agent.linear_acceleration_max = acceleration_max
	
	assert(hurt_box.connect("on_hurt", self, "on_hurt") == OK)
	# assert(player_detection.connect("targets_changed", self, "on_targets_changed") == OK)
	
	var seek := GSAISeek.new(agent, target)

	# var proximity := GSAIRadiusProximity.new(agent, [target], 100)
	# var avoid := GSAIAvoidCollisions.new(agent, proximity)

	seek_blend.add(seek, 1)	
	# seek_blend.add(avoid, 2)	

func exit():
	hurt_box.disconnect("on_hurt", self, "on_hurt")
	# player_detection.disconnect("targets_changed", self, "on_targets_changed")

func update(delta):
	update_agent()

	if knockback.length_squared() > 0:
		knockback = knockback.move_toward(Vector2.ZERO, delta * deceleration)
		knockback = kinematic_body.move_and_slide(knockback)
		return

	var nearest := Utils.find_nearest_target(kinematic_body.global_position, player_detection.targets)

	if nearest != null:
		target.position.x = nearest.global_position.x
		target.position.y = nearest.global_position.y

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
		velocity = kinematic_body.move_and_slide(velocity)
	else:	
		ground_count += 1
		fsm.transition_to("jump", true)

	
func on_hurt(stats: Stats):
	var dir: Vector2 = hurt_box.global_position - stats.hitbox.global_position
	knockback = dir.normalized() * knockback_speed

func update_agent():
	agent.position.x = kinematic_body.global_position.x
	agent.position.y = kinematic_body.global_position.y

	agent.linear_velocity.x = velocity.x
	agent.linear_velocity.y = velocity.y
