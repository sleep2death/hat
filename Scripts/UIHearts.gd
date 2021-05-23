extends HBoxContainer

export (NodePath) var player_node
onready var player := get_node(player_node)
onready var stats := player.get_node("stats") as Stats

var hud_hearts := preload("res://Scenes/HudHearts.tscn")

func _ready():
	assert(stats.connect("health_changed", self, "on_health_changed") == OK)
	update_hearts(stats.max_hp)
	
func on_health_changed(hp):
	update_hearts(hp)
	# label.text = "HP: " + String(hp)

func update_hearts(hp: int):
	for c in get_children():
		c.queue_free()
	
	for _i in range(0, hp * 0.25):
		var hh := hud_hearts.instance() as HudHearts
		call_deferred("add_child", hh)
	
	var m = hp % 4
	if m > 0:
		var h := hud_hearts.instance() as HudHearts
		h.set_heart(m)
		call_deferred("add_child", h)
