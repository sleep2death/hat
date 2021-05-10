class_name AsepritePlayer
extends AnimationPlayer

export (float, 0.01, 0.5, 0.01) var keyframe_duration = 0.1
export (String, FILE, "*.json") var json_path

func _ready():
	create_animations(json_path)
	self.current_animation = "idle_down"

func create_animations(path: String):
	# read sprite sheet json
	var json = read_json(path)
	if json != null:
		var tags = json.meta.frameTags
		for tag in tags:
			# add animation to player
			var anim = Animation.new()
			anim.length = (tag.to - tag.from + 1) * keyframe_duration
			 
			# add frame track
			anim.add_track(Animation.TYPE_VALUE, 0)
			anim.track_set_path(0, "Sprite:frame")

			# add method callback track
			anim.add_track(Animation.TYPE_METHOD, 1)
			anim.track_set_path(1, ".:Functions")

			# DO NOT FORGET TO: + 1 frame
			for t in range(tag.from, tag.to + 1):
				var time = keyframe_duration * (t - tag.from)
				anim.track_insert_key(0, time, t)

			# DO NOT DELETE THIS LINE
			anim.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
			anim.loop = true
			
			# add animation to the player
			assert(add_animation(tag.name, anim) == OK, "add animation FAILED: " + tag.name)

func read_json(path):
	var f = File.new()
	f.open(path, File.READ)
	var j = f.get_as_text()
	f.close()
	if j.length() > 0:
		var res = JSON.parse(j)
		if res.error == OK:
			return res.result
		else:
			push_error("can\'t read json file:" + path)

