class_name RollState
extends State

export (int, 10, 200, 1) var roll_speed = 80
export (int, 100, 600, 1) var acceleration = 350

var previous_direction = ""
var previous_dir = Vector2.UP

func enter(_msg):
	previous_direction = _msg
	previous_dir = Vector2.UP.rotated(.get_direction_rad(previous_direction))

func get_velocity(velocity, delta) -> Vector2:
	return velocity.move_toward(previous_dir * roll_speed, delta * acceleration)

func get_animation() -> String:
	return "Roll"

func update_animation(ap: AnimationPlayer):
	var name =  "Roll_" + previous_direction
	if ap.current_animation != name:
		ap.play(name, -1, animation_speed)
		ap.get_animation(name).loop = false

# Animation finished
func animation_finished(_anim_name):
	make_transition("IdleState", previous_direction)
