shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 card_color : source_color = vec4(0.035, 0.045, 0.09, 1.0);
uniform vec4 frame_color : source_color = vec4(0.22, 0.78, 1.0, 1.0);
uniform vec4 rare_color : source_color = vec4(0.96, 0.18, 0.68, 1.0);
uniform float foil_strength : hint_range(0.0, 2.0) = 0.9;
uniform float scan_speed : hint_range(-3.0, 3.0) = 0.42;
uniform float corner_radius : hint_range(0.0, 0.15) = 0.055;

float rounded_box(vec2 p, vec2 half_size, float radius) {
	vec2 q = abs(p) - half_size + radius;
	return length(max(q, vec2(0.0))) + min(max(q.x, q.y), 0.0) - radius;
}

vec3 spectral(float t) {
	return 0.56 + 0.44 * cos(CZN_TAU * (vec3(0.02, 0.35, 0.68) + t));
}

void fragment() {
	vec2 uv = UV;
	vec2 p = uv - 0.5;
	float distance_to_card = rounded_box(p, vec2(0.42, 0.46), corner_radius);
	float card_mask = 1.0 - smoothstep(-0.002, 0.006, distance_to_card);
	float inner_mask = 1.0 - smoothstep(-0.012, 0.004, distance_to_card + 0.018);
	float frame = max(card_mask - inner_mask, 0.0);

	vec4 art = texture(TEXTURE, (uv - 0.5) * 1.15 + 0.5);
	float diagonal = uv.x * 0.85 + uv.y * 0.55 + TIME * scan_speed;
	float foil_noise = czn_fbm(uv * vec2(8.0, 13.0) + vec2(TIME * 0.12, 0.0));
	vec3 rainbow = spectral(diagonal + foil_noise * 0.23);
	float foil_band = pow(max(sin(diagonal * 11.0 + foil_noise * 5.0), 0.0), 3.0);

	vec3 background = card_color.rgb * (0.7 + czn_noise(uv * 18.0) * 0.3);
	vec3 color = mix(background, art.rgb, art.a * 0.72);
	color += rainbow * foil_band * foil_strength * (0.28 + art.a * 0.45);
	color += frame_color.rgb * frame * 1.5;
	float corner_glow = pow(max(1.0 - abs(sin((uv.x - uv.y + TIME * 0.14) * CZN_PI)), 0.0), 12.0);
	color += rare_color.rgb * frame * corner_glow * 2.0;

	float micro_grid = step(0.965, sin(uv.x * 420.0) * sin(uv.y * 420.0) * 0.5 + 0.5);
	color += frame_color.rgb * micro_grid * inner_mask * 0.06;
	COLOR = vec4(czn_tonemap(color * 1.28), card_mask) * COLOR;
}
