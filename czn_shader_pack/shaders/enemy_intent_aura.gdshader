shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform int intent_mode : hint_range(0, 2) = 0; // 0 attack, 1 defend, 2 debuff
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float rotation_speed : hint_range(-4.0, 4.0) = 0.7;

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	p.x *= 1.2;
	float radius = length(p);
	float angle = atan(p.y, p.x);
	vec3 base_color = vec3(1.0, 0.08, 0.12);
	if (intent_mode == 1) {
		base_color = vec3(0.10, 0.68, 1.0);
	} else if (intent_mode == 2) {
		base_color = vec3(0.74, 0.12, 1.0);
	}

	float ring = 1.0 - smoothstep(0.018, 0.052, abs(radius - 0.53));
	float ticks = pow(max(cos(angle * 8.0 + TIME * rotation_speed), 0.0), 18.0) * ring;
	float orbit = 1.0 - smoothstep(0.02, 0.055, abs(radius - 0.72));
	orbit *= step(0.25, fract(angle / CZN_TAU * 6.0 + TIME * rotation_speed * 0.16));

	float icon = 0.0;
	if (intent_mode == 0) {
		float blade_a = czn_sd_segment(p, vec2(-0.26, 0.26), vec2(0.26, -0.26));
		float blade_b = czn_sd_segment(p, vec2(-0.20, -0.21), vec2(0.20, 0.21));
		icon = 1.0 - smoothstep(0.045, 0.085, min(blade_a, blade_b));
	} else if (intent_mode == 1) {
		float shield = max(abs(p.x) * 0.86 + p.y * 0.22, abs(p.y + 0.04));
		icon = (1.0 - smoothstep(0.29, 0.35, shield)) * step(-0.36, p.y);
		icon *= 1.0 - smoothstep(0.24, 0.35, radius);
	} else {
		float eye = abs(length(p * vec2(0.75, 1.5)) - 0.25);
		icon = 1.0 - smoothstep(0.035, 0.075, eye);
		icon += 1.0 - smoothstep(0.05, 0.09, radius);
	}

	float smoke = czn_fbm(p * 5.0 + vec2(TIME * 0.18, -TIME * 0.24));
	smoke = smoothstep(0.58, 0.88, smoke) * (1.0 - smoothstep(0.25, 0.85, radius));
	vec3 color = base_color * (ring * 0.65 + ticks * 1.8 + orbit * 0.55 + smoke * 0.28);
	color += mix(base_color, vec3(1.0), 0.72) * icon * 1.7;
	float alpha = clamp((ring + ticks + orbit * 0.7 + icon + smoke * 0.35) * intensity, 0.0, 1.0);
	COLOR = vec4(czn_tonemap(color * 1.5 * intensity), alpha);
}
