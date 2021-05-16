shader_type canvas_item;
render_mode blend_mix;

uniform vec4 region;
uniform  vec2 offset;

void vertex() {
	// VERTEX.y = VERTEX.y * (1.0 + newOffset.y);
}
void fragment() {
	COLOR = texture(TEXTURE, UV * 0.9);
	// COLOR = mix(shadow, col, col.a);
}
