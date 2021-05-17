shader_type canvas_item;
render_mode blend_mix;

uniform vec4 region;
uniform  vec2 offset;
uniform vec4 modulate : hint_color;

void vertex() {
	// VERTEX.y = VERTEX.y * (1.0 + newOffset.y);
}
void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	vec2 offset_uv = vec2(UV.x, UV.y);
	
	vec2 skew_uv = vec2( UV.x + (-UV.y * 0.1 ) ,
	UV.y);
	
	vec4 shadow = vec4(modulate.rgb, texture(TEXTURE, skew_uv).a * modulate.a);
	COLOR = shadow;
	// COLOR = mix(shadow, col, col.a);
}
