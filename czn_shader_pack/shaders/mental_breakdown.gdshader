shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float intensity : hint_range(0.0, 1.0) = 0.78;
uniform float chromatic_split : hint_range(0.0, 0.03) = 0.008;
uniform float tear_strength : hint_range(0.0, 0.15) = 0.045;
uniform float grain_amount : hint_range(0.0, 0.5) = 0.16;
uniform vec4 panic_color : source_color = vec4(0.92, 0.025, 0.10, 1.0);

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	vec2 local_uv = UV;
	float tick = floor(TIME * 13.0);
	float row = floor(local_uv.y * 46.0);
	float row_noise = czn_hash21(vec2(row, tick));
	float tear_gate = step(0.79 + (1.0 - intensity) * 0.18, row_noise);
	float tear = (czn_hash21(vec2(row + 19.0, tick)) * 2.0 - 1.0) * tear_strength * tear_gate;
	screen_uv.x += tear;

	float pulse = 0.65 + 0.35 * sin(TIME * 3.2 + czn_fbm(local_uv * 3.0) * 4.0);
	float split = chromatic_split * intensity * (0.4 + tear_gate * 2.2 + pulse * 0.3);
	vec3 color;
	color.r = texture(screen_texture, screen_uv + vec2(split, 0.0)).r;
	color.g = texture(screen_texture, screen_uv).g;
	color.b = texture(screen_texture, screen_uv - vec2(split, 0.0)).b;

	float grain = czn_hash21(FRAGCOORD.xy + vec2(tick * 7.0, tick * 3.0)) - 0.5;
	float scanline = sin(FRAGCOORD.y * 1.45 + TIME * 18.0) * 0.5 + 0.5;
	color += grain * grain_amount * intensity;
	color *= 1.0 - scanline * 0.12 * intensity;

	vec2 p = (local_uv - 0.5) * vec2(1.35, 1.0);
	float vignette = smoothstep(0.28, 0.82, length(p));
	float dirty = czn_fbm(p * 5.0 + vec2(TIME * 0.08, 0.0));
	float red_mask = vignette * (0.45 + dirty * 0.7) * intensity;
	color = mix(color, color * vec3(0.32, 0.08, 0.10) + panic_color.rgb * pulse * 0.24, red_mask);

	float blink = step(0.988, czn_hash11(tick));
	color = mix(color, vec3(0.85, 0.04, 0.06) - color * 0.18, blink * intensity * 0.75);
	COLOR = vec4(color, 1.0);
}
