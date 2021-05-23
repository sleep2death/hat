extends Area2D
class_name TargetDetection

export (int, 0, 120, 1) var frequency = 30
var frame_count = 0

var targets = []
signal targets_changed

func _physics_process(_delta):
	frame_count += 1
	
	if frame_count >= frequency:
		targets = []
		var bodies := get_overlapping_bodies()
		for b in bodies:
			var stats := b.get_node("stats") as Stats
			if stats.hp > 0:
				targets.append(b)
		
		emit_signal("targets_changed", targets)
		frame_count = 0
