shader_type canvas_item;
render_mode blend_mix;

uniform float skew_x = 24.0;
uniform float offset_y = 0.3;
uniform float foot_offset = 0.94;
uniform vec4 modulate : hint_color;

void vertex() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float newOffset = skew_x * ps.x;
	
	VERTEX.x = VERTEX.x * (1.0 + newOffset) - 0.5 * skew_x;
	// VERTEX.y = VERTEX.y;
	// VERTEX.y = VERTEX.y * (1.0 + newOffset.y);
}
void fragment() {
	vec2 ps = TEXTURE_PIXEL_SIZE;
	float newOffset = skew_x * ps.x;
	
	vec2 newUV;
	newUV.x = UV.x * (1.0 + newOffset) - newOffset;
	newUV.y = UV.y;
	
	vec4 col = texture(TEXTURE, newUV);
	
	float alphaCut = 1.0;
	if (newUV.x < 0.0 || 
		newUV.x > 1.0) {
		alphaCut = 0.0;
	}
	
	vec4 c = vec4(col.rgb, col.a * alphaCut);
	
	vec2 skew_uv = vec2( newUV.x + 1.0 * (-newOffset * newUV.y + newOffset * foot_offset),
	newUV.y * (1.0 + offset_y) - foot_offset * offset_y);
	
	vec4 shadow = vec4(modulate.rgb, texture(TEXTURE, skew_uv).a * modulate.a);
	
	alphaCut = 1.0;
	if (skew_uv.x < 0.0 || 
		skew_uv.x > 1.0 ||
		skew_uv.y < 0.0
		) {
		alphaCut = 0.0;
	}
	vec4 s = vec4(shadow.rgb, shadow.a * alphaCut);
	
	// COLOR = s;
	COLOR = mix(s, c, c.a);
}
