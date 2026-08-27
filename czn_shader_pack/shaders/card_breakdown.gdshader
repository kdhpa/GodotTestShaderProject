shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform float breakdown : hint_range(0.0, 1.0) = 0.64;
uniform float auto_pulse : hint_range(0.0, 1.0) = 1.0;
uniform vec4 crack_color : source_color = vec4(1.0, 0.025, 0.15, 1.0);
uniform vec4 void_color : source_color = vec4(0.03, 0.0, 0.045, 1.0);
uniform float crack_scale : hint_range(3.0, 24.0) = 11.0;

void fragment() {
	vec2 uv = UV;
	vec4 base = texture(TEXTURE, uv);
	float amount = clamp(breakdown + sin(TIME * 1.4) * 0.07 * auto_pulse, 0.0, 1.0);
	vec2 warp = vec2(czn_noise(uv * 7.0 + TIME * 0.2), czn_noise(uv * 6.0 - TIME * 0.17)) - 0.5;
	float corruption_noise = czn_fbm(uv * 5.0 + warp * 0.7);
	float corruption = smoothstep(0.78 - amount * 0.56, 0.92 - amount * 0.35, corruption_noise);

	float cells = czn_voronoi(uv * crack_scale + warp * 1.7);
	float cracks = 1.0 - smoothstep(0.025, 0.085, cells);
	cracks *= smoothstep(0.12, 0.62, corruption_noise + amount * 0.18);
	float offset = cracks * 0.012 * amount;
	vec3 split_color;
	split_color.r = texture(TEXTURE, uv + vec2(offset, 0.0)).r;
	split_color.g = base.g;
	split_color.b = texture(TEXTURE, uv - vec2(offset, 0.0)).b;

	vec3 color = mix(split_color, void_color.rgb, corruption * 0.85);
	color += crack_color.rgb * cracks * (1.1 + sin(TIME * 4.0) * 0.35);
	float static_noise = czn_hash21(FRAGCOORD.xy + floor(TIME * 14.0));
	color += crack_color.rgb * step(0.985, static_noise) * corruption;
	float alpha = base.a * (1.0 - corruption * 0.18);
	COLOR = vec4(czn_tonemap(color * 1.25), alpha) * COLOR;
}
