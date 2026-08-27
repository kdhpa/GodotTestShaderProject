shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 core_color : source_color = vec4(0.93, 0.98, 1.0, 1.0);
uniform vec4 energy_color : source_color = vec4(0.18, 0.72, 1.0, 1.0);
uniform vec4 trail_color : source_color = vec4(0.92, 0.05, 0.55, 1.0);
uniform float radius : hint_range(0.1, 1.2) = 0.62;
uniform float thickness : hint_range(0.005, 0.3) = 0.055;
uniform float arc_length : hint_range(0.1, 3.14) = 1.72;
uniform float speed : hint_range(-5.0, 5.0) = 1.25;

float angle_delta(float a, float b) {
	return atan(sin(a - b), cos(a - b));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.32;
	float distance_from_center = length(p);
	float angle = atan(p.y, p.x);
	float sweep = TIME * speed - 0.7;
	float angle_mask = 1.0 - smoothstep(arc_length, arc_length + 0.16, abs(angle_delta(angle, sweep)));
	float turbulence = (czn_noise(vec2(angle * 5.0, TIME * 2.0)) - 0.5) * 0.055;
	float arc_distance = abs(distance_from_center - radius - turbulence);
	float body = (1.0 - smoothstep(thickness, thickness * 2.8, arc_distance)) * angle_mask;
	float core = (1.0 - smoothstep(thickness * 0.18, thickness * 0.72, arc_distance)) * angle_mask;

	float trail_angle = abs(angle_delta(angle, sweep - 0.24));
	float trail = (1.0 - smoothstep(thickness * 1.8, thickness * 5.0, abs(distance_from_center - radius * 0.92)));
	trail *= 1.0 - smoothstep(arc_length * 0.55, arc_length, trail_angle);
	trail *= 0.35 + 0.65 * czn_noise(vec2(angle * 13.0, distance_from_center * 8.0 - TIME * 4.0));

	vec2 tip = vec2(cos(sweep), sin(sweep)) * radius;
	float tip_glow = exp(-length(p - tip) * 11.0);
	float sparks = step(0.955, czn_hash21(floor((p - tip) * 38.0) + floor(TIME * 15.0)));
	sparks *= exp(-length(p - tip) * 4.0);

	vec3 color = energy_color.rgb * body * 1.4;
	color += core_color.rgb * core * 2.6;
	color += trail_color.rgb * trail * 0.9;
	color += mix(energy_color.rgb, core_color.rgb, 0.6) * tip_glow * 1.8;
	color += core_color.rgb * sparks * 1.7;
	float alpha = clamp(body + core + trail * 0.65 + tip_glow + sparks, 0.0, 1.0);
	COLOR = vec4(czn_tonemap(color * 1.6), alpha);
}
