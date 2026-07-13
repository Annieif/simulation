shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_alpha_prepass;

uniform float point_size: hint_range(0.5, 20.0) = 3.0;

void vertex() {
	POINT_SIZE = point_size;
}

void fragment() {
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a;
}