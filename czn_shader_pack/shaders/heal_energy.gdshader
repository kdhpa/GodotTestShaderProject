shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 energy_color : source_color = vec4(0.18, 1.0, 0.64, 1.0);
uniform vec4 rune_color : source_color = vec4(0.56, 0.92, 1.0, 1.0);
uniform float particle_density : hint_range(10.0, 120.0) = 54.0;
uniform float rise_speed : hint_range(0.0, 3.0) = 0.72;
uniform float glow : hint_range(0.0, 3.0) = 1.2;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.25;
	float radial = length(p);
	float time = TIME * rise_speed;

	vec2 particle_grid = vec2(p.x * 8.0, (p.y + time) * particle_density * 0.1);
	vec2 particle_cell = floor(particle_grid);
	vec2 particle_local = fract(particle_grid) - 0.5;
	vec2 random_offset = czn_hash22(particle_cell) - 0.5;
	float particle = exp(-length(particle_local - random_offset * vec2(0.7, 0.35)) * 13.0);
	particle *= 1.0 - smoothstep(0.1, 0.9, abs(p.x));

	float ring_radius = 0.48 + sin(TIME * 1.8) * 0.035;
	float rune_ring = 1.0 - smoothstep(0.012, 0.038, abs(radial - ring_radius));
	float angle = atan(p.y, p.x);
	float rune_ticks = pow(max(cos(angle * 12.0 + TIME * 0.35), 0.0), 16.0) * rune_ring;
	float inner_wave = 1.0 - smoothstep(0.025, 0.08, abs(radial - fract(TIME * 0.42) * ring_radius));
	inner_wave *= 1.0 - smoothstep(ring_radius, ring_radius + 0.05, radial);

	vec2 cross_p = abs(p * 2.7);
	float cross_shape = min(max(cross_p.x - 0.11, cross_p.y - 0.38), max(cross_p.x - 0.38, cross_p.y - 0.11));
	float cross = 1.0 - smoothstep(-0.02, 0.025, cross_shape);
	cross *= 0.45 + 0.55 * sin(TIME * 2.6) * sin(TIME * 2.6);

	vec3 color = energy_color.rgb * particle * 1.35;
	color += rune_color.rgb * (rune_ring * 0.5 + rune_ticks * 1.4);
	color += energy_color.rgb * inner_wave * 0.75;
	color += mix(energy_color.rgb, vec3(1.0), 0.65) * cross * 1.4;
	float alpha = clamp((particle + rune_ring + rune_ticks + inner_wave + cross) * glow, 0.0, 1.0);
	COLOR = vec4(czn_tonemap(color * glow), alpha);
}
