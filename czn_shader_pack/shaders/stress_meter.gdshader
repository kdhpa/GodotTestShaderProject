shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform float stress : hint_range(0.0, 1.0) = 0.82;
uniform float auto_breathe : hint_range(0.0, 1.0) = 1.0;
uniform vec4 calm_color : source_color = vec4(0.12, 0.74, 1.0, 1.0);
uniform vec4 danger_color : source_color = vec4(1.0, 0.035, 0.16, 1.0);
uniform vec4 empty_color : source_color = vec4(0.025, 0.035, 0.065, 1.0);
uniform float segments : hint_range(1.0, 30.0) = 12.0;

void fragment() {
	vec2 uv = UV;
	float breathing = stress + sin(TIME * 1.7) * 0.045 * auto_breathe * smoothstep(0.65, 1.0, stress);
	float fill = step(uv.x, clamp(breathing, 0.0, 1.0));
	float segment_line = step(0.12, fract(uv.x * segments));
	float edge = smoothstep(0.0, 0.09, uv.y) * (1.0 - smoothstep(0.91, 1.0, uv.y));
	float danger = smoothstep(0.58, 0.94, breathing);
	float pulse = 0.65 + 0.35 * sin(TIME * (2.0 + danger * 5.0));
	vec3 filled_color = mix(calm_color.rgb, danger_color.rgb, danger);
	vec3 color = mix(empty_color.rgb, filled_color * (0.82 + danger * pulse * 0.62), fill * segment_line);

	float wave = 1.0 - smoothstep(0.02, 0.07, abs(uv.y - 0.5 - sin(uv.x * 34.0 - TIME * 7.0) * 0.16));
	wave *= fill * danger;
	color += danger_color.rgb * wave * 0.85;
	float current_edge = 1.0 - smoothstep(0.0, 0.025, abs(uv.x - breathing));
	color += mix(calm_color.rgb, vec3(1.0), danger) * current_edge * (0.7 + pulse);

	float border = 1.0 - step(0.035, min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y)));
	color += mix(calm_color.rgb, danger_color.rgb, danger) * border * 0.7;
	COLOR = vec4(czn_tonemap(color * 1.25), edge);
}
