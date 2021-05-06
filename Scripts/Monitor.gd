extends CanvasLayer

var count = 0
func _physics_process(_delta):
	if count == 60:
		$FPS.text = "FPS: " + str(Performance.get_monitor(Performance.TIME_FPS))
		$MEM.text = "MEM: " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC) * 100 / 1024 / 1024)/100) + "MB"
		count = 0
	count += 1
