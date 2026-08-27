shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 ring_color : source_color = vec4(0.30, 0.82, 1.0, 1.0);
uniform vec4 flash_color : source_color = vec4(1.0, 0.35, 0.68, 1.0);
uniform float cycle_speed : hint_range(0.05, 3.0) = 0.48;
uniform float ring_width : hint_range(0.002, 0.15) = 0.028;
uniform float distortion : hint_range(0.0, 1.0) = 0.42;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.25;
	float phase = fract(TIME * cycle_speed);
	float radius = phase * 1.12;
	float angle = atan(p.y, p.x);
	float noisy_radius = length(p) + (czn_noise(vec2(angle * 7.0, TIME * 3.0)) - 0.5) * 0.08 * distortion;
	float ring = 1.0 - smoothstep(ring_width, ring_width * 3.0, abs(noisy_radius - radius));
	ring *= 1.0 - smoothstep(0.72, 1.0, phase);

	float spokes = pow(max(cos(angle * 12.0 + TIME * 1.7), 0.0), 24.0);
	spokes *= exp(-length(p) * 3.2) * (1.0 - smoothstep(0.0, 0.28, phase));
	float flash = exp(-length(p) * (5.0 + phase * 18.0));
	flash *= 1.0 - smoothstep(0.0, 0.24, phase);
	float debris = step(0.968, czn_hash21(floor((p / max(phase, 0.08)) * 20.0)));
	debris *= smoothstep(0.07, 0.32, phase) * (1.0 - smoothstep(0.5, 0.9, phase));
	debris *= exp(-abs(length(p) - radius * 0.8) * 8.0);

	vec3 color = ring_color.rgb * ring * 1.6;
	color += flash_color.rgb * spokes * 1.3;
	color += mix(flash_color.rgb, vec3(1.0), 0.65) * flash * 2.8;
	color += ring_color.rgb * debris * 1.8;
	float alpha = clamp(ring + spokes + flash + debris, 0.0, 1.0);
	COLOR = vec4(czn_tonemap(color * 1.6), alpha);
}
