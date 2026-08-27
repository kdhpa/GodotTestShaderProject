shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 upper_color : source_color = vec4(0.035, 0.045, 0.090, 1.0);
uniform vec4 lower_color : source_color = vec4(0.008, 0.010, 0.025, 1.0);
uniform vec4 chaos_color : source_color = vec4(0.32, 0.03, 0.32, 1.0);
uniform vec4 signal_color : source_color = vec4(0.05, 0.56, 0.78, 1.0);
uniform float fog_amount : hint_range(0.0, 2.0) = 0.8;
uniform float grid_amount : hint_range(0.0, 1.0) = 0.16;
uniform float speed : hint_range(0.0, 2.0) = 0.22;

void fragment() {
	vec2 uv = UV;
	vec2 p = (uv - 0.5) * vec2(1.7, 1.0);
	float time = TIME * speed;

	vec3 color = mix(lower_color.rgb, upper_color.rgb, smoothstep(0.0, 1.0, 1.0 - uv.y));
	float fog_a = czn_fbm(p * 3.2 + vec2(time, -time * 0.4));
	float fog_b = czn_fbm(p * 5.4 - vec2(time * 0.6, time * 0.2));
	float fog = smoothstep(0.38, 0.85, fog_a * 0.75 + fog_b * 0.4);
	color += chaos_color.rgb * fog * fog_amount;

	vec2 grid_uv = uv * vec2(28.0, 16.0);
	vec2 grid_cell = abs(fract(grid_uv) - 0.5);
	float grid = 1.0 - smoothstep(0.47, 0.5, max(grid_cell.x, grid_cell.y));
	grid *= 0.25 + 0.75 * smoothstep(0.2, 0.9, uv.y);
	color += signal_color.rgb * grid * grid_amount;

	float stars = step(0.992, czn_hash21(floor(uv * vec2(260.0, 150.0))));
	stars *= 0.45 + 0.55 * sin(TIME * 2.0 + czn_hash21(floor(uv * 100.0)) * 6.0);
	color += vec3(0.45, 0.72, 1.0) * stars;

	float vignette = 1.0 - smoothstep(0.35, 0.9, length(p));
	color *= 0.42 + 0.58 * vignette;
	COLOR = vec4(czn_tonemap(color * 1.35), 1.0);
}
