shader_type spatial;
render_mode unshaded, cull_disabled;

uniform float point_size: hint_range(1.0, 50.0) = 15.0;
uniform float brightness: hint_range(0.5, 3.0) = 2.0;

void vertex() {
	POINT_SIZE = point_size;
}

void fragment() {
	ALBEDO = COLOR.rgb * brightness;
	ALPHA = clamp(COLOR.a, 0.1, 1.0);
}