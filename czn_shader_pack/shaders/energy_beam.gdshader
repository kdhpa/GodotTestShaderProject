shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 core_color : source_color = vec4(1.0, 0.98, 0.88, 1.0);
uniform vec4 beam_color : source_color = vec4(0.18, 0.82, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.78, 0.08, 0.96, 1.0);
uniform float beam_width : hint_range(0.01, 0.5) = 0.14;
uniform float turbulence : hint_range(0.0, 1.0) = 0.52;
uniform float pulse_speed : hint_range(0.0, 8.0) = 2.4;

void fragment() {
	vec2 p = UV - 0.5;
	float time = TIME * pulse_speed;
	float wave_a = czn_noise(vec2(UV.x * 11.0 - time, time * 0.17)) - 0.5;
	float wave_b = czn_noise(vec2(UV.x * 27.0 + time * 1.7, time * 0.28)) - 0.5;
	float center_offset = (wave_a * 0.55 + wave_b * 0.2) * beam_width * turbulence;
	float distance_to_beam = abs(p.y - center_offset);
	float ragged_width = beam_width * (0.72 + czn_noise(vec2(UV.x * 16.0, time * 0.23)) * 0.5);
	float beam = 1.0 - smoothstep(ragged_width * 0.5, ragged_width * 1.35, distance_to_beam);
	float core = 1.0 - smoothstep(0.0, ragged_width * 0.24, distance_to_beam);
	float edge = (1.0 - smoothstep(ragged_width, ragged_width * 2.1, distance_to_beam)) - beam;

	float packet = pow(max(sin(UV.x * 42.0 - time * 7.0), 0.0), 10.0);
	packet *= beam;
	float origin_flare = exp(-length((UV - vec2(0.08, 0.5)) * vec2(2.4, 6.0)) * 3.3);
	float horizontal_fade = smoothstep(0.0, 0.08, UV.x) * (1.0 - smoothstep(0.86, 1.0, UV.x));

	vec3 color = beam_color.rgb * beam * 1.45;
	color += core_color.rgb * core * 3.0;
	color += edge_color.rgb * edge * 0.9;
	color += core_color.rgb * packet * 1.3;
	color += mix(edge_color.rgb, core_color.rgb, 0.65) * origin_flare * 1.8;
	float alpha = clamp((beam + core + edge * 0.55 + origin_flare) * horizontal_fade, 0.0, 1.0);
	COLOR = vec4(czn_tonemap(color * 1.45), alpha);
}
