class_name Utils
extends Object

# animation names
const DIRECTIONS = ["upleft", "up", "upright", "right", "downright", "down", "downleft", "left"]

static func get_input() -> Vector2:
	return Vector2(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")).normalized()

# smooth 8-axis snapping
# SEE: https://forum.unity.com/threads/8-way-direction-joystick-only.438758/
static func get_direction_name(input) -> String:
	var rad = input.angle()
	var deg = -7.5 * sin(rad * 8) + rad2deg(rad) 
	return DIRECTIONS[int(round(deg / 45)) + 3]

static func get_direction_rad(name) -> float:
	var dir = DIRECTIONS.find(name)
	assert(dir > -1, "wrong direction name " + name)
	return dir * PI * 0.25 + (PI * 1.75)