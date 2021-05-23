class_name Utils
extends Object

const half_pi = PI * 0.5
# animation names
const DIRECTIONS = ["back", "right", "front", "left"]

static func get_input() -> Vector2:
	return Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()

# smooth 8-axis snapping
# SEE: https://forum.unity.com/threads/8-way-direction-joystick-only.438758/
static func get_direction_name(input) -> String:
	var rad = input.angle()
	var deg = -7.5 * sin(rad * 4) + rad2deg(rad) 
	return DIRECTIONS[int(round(deg / 90)) + 1]

static func get_reversed_direction_name(input: Vector2) -> String:
	var res = get_direction_name(input)
	match res:
		"right": res = "left"
		"left": res = "right"
		"front": res = "back"
		"back": res = "front"
	
	return res

	
static func get_side_direction(name: String) -> String:
	if name == "left" || name == "right":
		return "side"
	return name
		
static func get_direction_rad(name) -> float:
	var dir = DIRECTIONS.find(name)
	assert(dir > -1, "wrong direction name " + name)
	return dir * half_pi

static func find_nearest_target(global_pos: Vector2, targets: Array) -> PhysicsBody2D:
	if targets.size() == 0:
		return null
	elif targets.size() == 1:
		return targets[0]
	
	var nearest_dist = INF
	var nearest: PhysicsBody2D = null
	for p in targets:
		var dist = global_pos.distance_squared_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
		else:
			continue
	
	return nearest
