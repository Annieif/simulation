shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_alpha_prepass, blend_mix;

uniform float global_scale: hint_range(0.0, 10.0) = 1.0;

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vec3 cam_right = normalize(cross(vec3(0.0, 1.0, 0.0), CAMERA_DIRECTION));
	vec3 cam_up = normalize(cross(CAMERA_DIRECTION, cam_right));
	
	float size = CUSTOM0.x * global_scale;
	vec3 offset = cam_right * UV.x * size + cam_up * UV.y * size;
	
	vec3 final_pos = world_pos + offset;
	VERTEX = (MODEL_MATRIX.affine_inverse() * vec4(final_pos, 1.0)).xyz;
}

void fragment() {
	float dist = length(UV) / 1.414;
	if (dist > 1.0) discard;
	
	ALBEDO = COLOR.rgb;
	ALPHA = COLOR.a * (1.0 - smoothstep(0.0, 1.0, dist));
}