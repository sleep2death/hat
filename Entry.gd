extends Node2D

var p = preload("res://Player.tscn")
onready var player = p.instance()

func _ready():
	var y = get_node("YSort")
	y.add_child(player)
	# createPlayer()

func createPlayer():
	var json = readJSON("res://AnimRes/Hero.json")
	if json != null:
		var animPlayer = player.get_node("AnimationPlayer") as AnimationPlayer
		var tags = json.meta.frameTags
		for tag in tags:
			print(tag.from, ' - ', tag.to)
			var anim = Animation.new()
			animPlayer.add_animation(tag.name, anim)
		
		var animStateMachine = player.get_node("AnimationTree").tree_root as AnimationNodeStateMachine	
		var blendNode = AnimationNodeBlendSpace2D.new()
		animStateMachine.add_node("Idle_8", blendNode)
		# var idle = animStateMachine.get_start_node() as AnimationNodeBlendSpace2D

func readJSON(path):
	var f = File.new()
	f.open(path, File.READ)
	var j = f.get_as_text()
	f.close()
	if j.length() > 0:
		var res = JSON.parse(j)
		if res.error == OK:
			return res.result
		else:
			print_debug("can\'t read json file:" + path)
