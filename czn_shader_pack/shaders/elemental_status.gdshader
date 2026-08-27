shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform int effect_mode : hint_range(0, 2) = 0; // 0 burn, 1 poison, 2 bleed
uniform float intensity : hint_range(0.0, 2.0) = 1.0;
uniform float speed : hint_range(0.0, 4.0) = 1.0;

void fragment() {
	vec2 uv = UV;
	vec2 p = (uv - 0.5) * 2.0;
	float time = TIME * speed;
	vec3 low_color = vec3(0.42, 0.015, 0.008);
	vec3 high_color = vec3(1.0, 0.62, 0.06);
	float shape = 0.0;
	float detail = 0.0;

	if (effect_mode == 0) {
		float flame_noise = czn_fbm(vec2(p.x * 3.7, p.y * 2.1 - time * 1.4));
		float taper = 0.58 - (p.y + 1.0) * 0.22;
		shape = 1.0 - smoothstep(taper - 0.08, taper + 0.10, abs(p.x + (flame_noise - 0.5) * 0.38));
		shape *= 1.0 - smoothstep(-0.72, 0.92, p.y);
		detail = pow(max(sin((p.x + flame_noise) * 17.0 - time * 3.0), 0.0), 5.0) * shape;
	} else if (effect_mode == 1) {
		low_color = vec3(0.08, 0.18, 0.015);
		high_color = vec3(0.58, 1.0, 0.12);
		float cloud = czn_fbm(p * 4.0 + vec2(time * 0.22, -time * 0.34));
		shape = 1.0 - smoothstep(0.42, 0.72, length(p * vec2(0.85, 1.15)) - cloud * 0.32);
		detail = step(0.88, czn_hash21(floor((p + vec2(0.0, time * 0.15)) * 24.0))) * shape;
	} else {
		low_color = vec3(0.20, 0.0, 0.015);
		high_color = vec3(1.0, 0.04, 0.12);
		float drip_noise = czn_noise(vec2(floor((p.x + 1.0) * 12.0), 2.0));
		float drip = abs(fract((p.y + 1.0) * (2.0 + drip_noise * 3.0) - time * (0.35 + drip_noise)) - 0.5);
		shape = (1.0 - smoothstep(0.05, 0.16, abs(p.x + (drip_noise - 0.5) * 0.75))) * (1.0 - smoothstep(0.06, 0.22, drip));
		float slash = 1.0 - smoothstep(0.025, 0.075, abs(p.y + p.x * 0.75 - sin(p.x * 8.0 + time) * 0.06));
		detail = slash * (1.0 - smoothstep(0.2, 1.0, length(p)));
	}

	vec3 color = mix(low_color, high_color, detail) * (shape + detail * 1.2) * intensity;
	float alpha = clamp((shape + detail) * intensity, 0.0, 0.92);
	COLOR = vec4(czn_tonemap(color * 1.7), alpha);
}
