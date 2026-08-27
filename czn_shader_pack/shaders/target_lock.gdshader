shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 lock_color : source_color = vec4(1.0, 0.12, 0.25, 1.0);
uniform vec4 accent_color : source_color = vec4(0.16, 0.78, 1.0, 1.0);
uniform float lock_progress : hint_range(0.0, 1.0) = 0.82;
uniform float rotate_speed : hint_range(-4.0, 4.0) = 0.9;
uniform float scale_pulse : hint_range(0.0, 0.3) = 0.06;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.2;
	float pulse = 1.0 + sin(TIME * 3.2) * scale_pulse;
	p *= pulse;
	float radius = length(p);
	float angle = atan(p.y, p.x);
	float ring_a = 1.0 - smoothstep(0.018, 0.055, abs(radius - 0.47));
	float ring_b = 1.0 - smoothstep(0.012, 0.04, abs(radius - 0.68));
	float sweep_angle = fract(angle / CZN_TAU + TIME * rotate_speed * 0.08 + 0.5);
	float sweep = step(sweep_angle, lock_progress) * ring_b;
	float brackets = pow(max(cos(angle * 4.0), 0.0), 36.0);
	brackets *= 1.0 - smoothstep(0.09, 0.16, abs(radius - 0.58));

	float horizontal = (1.0 - smoothstep(0.012, 0.035, abs(p.y))) * (1.0 - smoothstep(0.08, 0.42, abs(p.x)));
	float vertical = (1.0 - smoothstep(0.012, 0.035, abs(p.x))) * (1.0 - smoothstep(0.08, 0.34, abs(p.y)));
	float center_dot = exp(-radius * 24.0);
	float confirmed = smoothstep(0.96, 1.0, lock_progress) * (0.65 + 0.35 * sin(TIME * 8.0));

	vec3 color = lock_color.rgb * (ring_a * 0.55 + brackets * 1.4 + horizontal + vertical + center_dot * 1.6);
	color += accent_color.rgb * sweep * 1.15;
	color += vec3(1.0) * confirmed * center_dot * 2.0;
	float alpha = clamp(ring_a + sweep + brackets + horizontal + vertical + center_dot, 0.0, 1.0);
	COLOR = vec4(czn_tonemap(color * 1.45), alpha);
}
