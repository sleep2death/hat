class_name AttackState
extends State

var previous_direction: String = "down"

export (NodePath) var hit_box
onready var hit_area = get_node(hit_box) as Area2D
onready var hit_shape = hit_area.get_node("CollisionShape2D") as CollisionShape2D

export (float, 0, 0.8, 0.01) var hit_start_time = 0.0
export (float, 0, 0.8, 0.01) var hit_end_time = 0.1
var hit_time: float = 0.0

func enter(_msg):
	assert(has_node(hit_box), "Hit box NOT existed")
	assert(hit_start_time < hit_end_time, "hit_start_time should less thant hit_end_time")

	previous_direction = _msg
	hit_area.rotation = get_direction_rad(previous_direction)

	hit_time = 0.0
	hit_shape.disabled = true	

func get_velocity(_velocity, delta) -> Vector2:
	if hit_time >= hit_start_time && hit_time <= hit_end_time:
		hit_shape.disabled = false
	else:
		hit_shape.disabled = true	

	hit_time += delta
	return Vector2.ZERO

func update_animation(ap: AnimationPlayer):
	var name =  "Attack1_" + previous_direction

	if ap.current_animation != name:
		ap.play(name, -1, animation_speed)
		ap.get_animation(name).loop = false

# Animation finished
func animation_finished(_anim_name):
	make_transition("IdleState", previous_direction)
