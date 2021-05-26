shader_type canvas_item;

uniform float os = 0.0;
uniform float oe = 0.0;

uniform float alpha_scale = 1.0;
uniform float alpha_offset = 0.50;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float a = alpha_scale * (UV.y - os * TEXTURE_PIXEL_SIZE.y) /  ((oe - os) * TEXTURE_PIXEL_SIZE.y);
	c.a = a * a * c.a;
	COLOR = c;
}