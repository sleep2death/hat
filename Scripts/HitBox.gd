class_name HitBox
extends Area2D

export (NodePath) var stats_node
onready var stats = get_node(stats_node) as PlayerStats

enum {
	HIT_TYPE_PHY_ATTACK
	HIT_TYPE_LIFT
}

var type = HIT_TYPE_PHY_ATTACK

func _on_hitbox_body_shape_entered(body_id, body, body_shape, local_shape):
	var physics := get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape($CollisionShape2D.shape)
	query.collide_with_areas = true
	query.transform = $CollisionShape2D.global_transform
	query.collision_layer = 16
	var results = physics.intersect_shape(query)
	# print(results)
	# print(body, body_shape_owner_id)
