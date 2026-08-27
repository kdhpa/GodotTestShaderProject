shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 barrier_color : source_color = vec4(0.12, 0.68, 1.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.82, 0.96, 1.0, 1.0);
uniform float grid_scale : hint_range(4.0, 30.0) = 13.0;
uniform float barrier_power : hint_range(0.0, 2.0) = 1.0;
uniform float ripple_speed : hint_range(0.0, 6.0) = 1.7;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.18;
	float radial = length(p);
	float sphere = 1.0 - smoothstep(0.72, 0.82, radial);
	float rim = 1.0 - smoothstep(0.012, 0.055, abs(radial - 0.76));

	vec2 grid_p = p * grid_scale;
	float hex_distance = czn_hex_lines(grid_p);
	float hex_lines = smoothstep(0.40, 0.49, hex_distance);
	hex_lines *= sphere;
	float wave = 1.0 - smoothstep(0.025, 0.095, abs(radial - fract(TIME * ripple_speed * 0.24) * 0.78));
	wave *= sphere;

	float hit_angle = -0.65 + sin(TIME * 0.73) * 0.42;
	vec2 hit_position = vec2(cos(hit_angle), sin(hit_angle)) * 0.58;
	float hit = exp(-length(p - hit_position) * 13.0);
	float cracks = pow(max(sin(atan(p.y - hit_position.y, p.x - hit_position.x) * 7.0 + radial * 15.0), 0.0), 18.0);
	cracks *= exp(-length(p - hit_position) * 6.0);

	vec3 color = barrier_color.rgb * (hex_lines * 0.58 + sphere * 0.055 + wave * 0.65);
	color += edge_color.rgb * rim * 1.25;
	color += edge_color.rgb * hit * 2.4;
	color += barrier_color.rgb * cracks * 1.2;
	float alpha = clamp((hex_lines * 0.5 + sphere * 0.10 + rim + wave * 0.5 + hit + cracks) * barrier_power, 0.0, 1.0);
	COLOR = vec4(czn_tonemap(color * barrier_power * 1.5), alpha);
}
