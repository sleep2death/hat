extends AnimationPlayer
class_name AsePlayer

export (String, FILE, "*.json") var json
export (bool) var draw_shadow = true

export (NodePath) var shadow_node
onready var shadow: DropShadowAnimated = get_node(shadow_node)

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
			
			# create callback track
			anim.add_track(Animation.TYPE_METHOD, l + 2)
			anim.track_set_path(l + 2, get_node(root_node).get_path_to(self))
			# anim.value_track_set_update_mode(l + 2, Animation.UPDATE_TRIGGER)

			var duration = 0
			for i in range(tag.from, tag.to + 1):
				var f = res.frames[layer.name + "_" + String(i)]

				anim.track_insert_key(l, duration, Rect2(f.frame.x, f.frame.y, f.frame.w, f.frame.h))
				anim.track_insert_key(l + 1, duration, Rect2(f.spriteSourceSize.x, f.spriteSourceSize.y, f.sourceSize.w, f.sourceSize.h))
				anim.track_insert_key(l + 2, duration, {"method": "on_frame_changed", "args": []})
				duration += f.duration / 1000
				# prints(f.frame, f.sourceSize)

			l += 3
			anim.length = duration	

		# add animation to the player
		anim.loop = true
		assert(add_animation(tag.name, anim) == OK, "add animation FAILED: " + tag.name)
		
	# play("front_idle")

func on_flipped(_is_flipped: bool):
	if draw_shadow:
		shadow.update()
	
func on_frame_changed():
	if draw_shadow:
		shadow.update()
	# emit_signal("on_frame_changed")
	
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
