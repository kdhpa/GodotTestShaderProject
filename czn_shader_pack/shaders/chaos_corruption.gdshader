shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 void_color : source_color = vec4(0.008, 0.003, 0.018, 1.0);
uniform vec4 body_color : source_color = vec4(0.20, 0.015, 0.24, 1.0);
uniform vec4 vein_color : source_color = vec4(0.95, 0.08, 0.48, 1.0);
uniform vec4 hot_color : source_color = vec4(0.25, 0.72, 1.0, 1.0);
uniform float corruption : hint_range(0.0, 1.0) = 0.72;
uniform float vein_density : hint_range(2.0, 16.0) = 8.0;
uniform float speed : hint_range(0.0, 3.0) = 0.65;

void fragment() {
	vec2 uv = UV;
	vec2 p = (uv - 0.5) * vec2(1.45, 1.0);
	float time = TIME * speed;

	float warp_a = czn_fbm(p * 2.7 + vec2(time * 0.16, -time * 0.11));
	float warp_b = czn_fbm(p * 5.3 + vec2(-time * 0.10, time * 0.18) + warp_a * 2.2);
	vec2 warped = p + vec2(warp_a - 0.5, warp_b - 0.5) * 0.32;

	float mass_noise = czn_fbm(warped * 3.4 - vec2(time * 0.12, 0.0));
	float mass = smoothstep(0.74 - corruption * 0.58, 0.88 - corruption * 0.36, mass_noise);
	float cells = czn_voronoi(warped * vein_density + vec2(time * 0.15, 0.0));
	float veins = 1.0 - smoothstep(0.055, 0.18, cells);
	veins *= smoothstep(0.2, 0.72, mass_noise);

	float tendril = sin((warped.x + czn_fbm(warped * 4.0) * 0.65) * 18.0 - time * 2.0);
	tendril = pow(max(tendril, 0.0), 9.0) * smoothstep(0.2, 0.75, mass_noise);

	vec3 color = mix(void_color.rgb, body_color.rgb, mass);
	color += vein_color.rgb * veins * (1.3 + 0.4 * sin(TIME * 3.5));
	color += hot_color.rgb * tendril * 0.55;
	color += vec3(0.65, 0.08, 0.52) * pow(mass_noise, 5.0) * 0.5;

	float edge = 1.0 - smoothstep(0.5, 0.82, length(p));
	color *= 0.35 + 0.65 * edge;
	COLOR = vec4(czn_tonemap(color * 1.5), 1.0);
}
