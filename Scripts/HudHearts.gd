extends TextureRect
class_name HudHearts

func set_heart(count: int):
	var t := texture as AtlasTexture
	t.region.position.x = 18 *  (4 - count)
