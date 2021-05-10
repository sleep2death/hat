shader_type canvas_item;
render_mode blend_mix;

uniform float skew_x = 0.03;
uniform float modify_y = 0.3;

uniform int h_frames = 32;
uniform int v_frames = 2;

uniform int coord_h = 0;
uniform int coord_v = 0;

uniform float foot_offset = 0.375; // 12 / 32
uniform float scale_x = 1.0;

uniform vec4 modulate : hint_color;

void vertex() {
	// VERTEX.y = VERTEX.y * (1.0 + newOffset.y);
}
void fragment() {
	vec2 ps = SCREEN_PIXEL_SIZE;
	vec4 col = texture(TEXTURE, UV);
	
	float offset_x = skew_x * ps.x;
	float offset_y = 1.0 / float(v_frames) * float(coord_v);
	
	vec2 skew_uv = vec2( UV.x + scale_x * (-skew_x * (UV.y - offset_y) + skew_x * foot_offset),
		(UV.y - offset_y) * (1.0 + modify_y) - foot_offset * modify_y);
	
	vec4 shadow = vec4(modulate.rgb, texture(TEXTURE, skew_uv).a * modulate.a);
	COLOR = mix(shadow, col, col.a);
//	float alphaCut = 1.0;
//	if (newUV.x < 0.0 || 
//		newUV.x > 1.0) {
//		alphaCut = 0.0;
//	}
//
//	vec4 c = vec4(col.rgb, col.a * alphaCut);
//v	ec2 skew = vec2(-newOffset * newUV.y  + newOffset, (newUV.y - 1.0) * y_modify * ps.y);
//	vec4 shadow = vec4(modulate.rgb, texture(TEXTURE, newUV + skew).a * modulate.a);
//
//	alphaCut = 1.0;
//	if (newUV.x < -skew.x || 
//		newUV.x > 1.0 - skew.x ||
//		newUV.y < - skew.y
//		) {
//		alphaCut = 0.0;
//	}
//	vec4 s = vec4(shadow.rgb, shadow.a * alphaCut);
//
//	// COLOR = s;
//	COLOR = mix(s, c, c.a);
}
