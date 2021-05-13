extends AnimationPlayer
class_name Aseprite

export (String, FILE, "*.json") var json

func _ready():
	var res = read_json(json)

	if res == null:
		push_error("json file invalid: " + json)
		return
	
	var tags = res.meta.frameTags
	for tag in tags:
		# create animation
		var anim = Animation.new()

		var l = 0
		for layer in res.meta.layers:
			# create region track
			anim.add_track(Animation.TYPE_VALUE, l)
			anim.track_set_path(l, layer.name + ":texture:region")
			anim.value_track_set_update_mode(l, Animation.UPDATE_DISCRETE)

			# create margin track
			anim.add_track(Animation.TYPE_VALUE, l + 1)
			anim.track_set_path(l + 1, layer.name + ":texture:margin")
			anim.value_track_set_update_mode(l + 1, Animation.UPDATE_DISCRETE)

			var duration = 0

			for i in range(tag.from, tag.to + 1):
				var f = res.frames[layer.name + "_" + String(i)]
				if layer.name == "weapon" && f.frame.w > 1:
					print(layer.name + "_" + String(i) + "_" + layer.name)

				anim.track_insert_key(l, duration, Rect2(f.frame.x, f.frame.y, f.frame.w, f.frame.h))
				anim.track_insert_key(l + 1, duration, Rect2(f.spriteSourceSize.x, f.spriteSourceSize.y, f.sourceSize.w, f.sourceSize.h))
				duration += f.duration / 1000
				# prints(f.frame, f.sourceSize)

			l += 2
			anim.length = duration	

		# add animation to the player
		anim.loop = true
		assert(add_animation(tag.name, anim) == OK, "add animation FAILED: " + tag.name)

	play("back_attack_dagger")	

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
