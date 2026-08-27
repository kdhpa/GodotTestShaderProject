shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 signal_color : source_color = vec4(0.16, 0.78, 1.0, 1.0);
uniform vec4 error_color : source_color = vec4(1.0, 0.06, 0.42, 1.0);
uniform float glitch_amount : hint_range(0.0, 1.0) = 0.62;
uniform float rgb_split : hint_range(0.0, 0.04) = 0.009;
uniform float block_count : hint_range(4.0, 100.0) = 38.0;
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.22;

void fragment() {
	float tick = floor(TIME * 12.0);
	float row = floor(UV.y * block_count);
	float block_random = czn_hash21(vec2(row, tick));
	float active = step(0.84 - glitch_amount * 0.25, block_random);
	float direction = czn_hash21(vec2(row + 11.0, tick)) * 2.0 - 1.0;
	vec2 shifted_uv = UV + vec2(direction * active * glitch_amount * 0.07, 0.0);
	float split = rgb_split * (0.35 + active * 2.4);

	vec4 center = texture(TEXTURE, shifted_uv);
	vec3 color;
	color.r = texture(TEXTURE, shifted_uv + vec2(split, 0.0)).r;
	color.g = center.g;
	color.b = texture(TEXTURE, shifted_uv - vec2(split, 0.0)).b;
	float luminance = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, signal_color.rgb * luminance * 1.35, 0.28);
	color = mix(color, error_color.rgb * (0.45 + luminance), active * 0.38);

	float scanline = sin(FRAGCOORD.y * 2.3 + TIME * 11.0) * 0.5 + 0.5;
	color *= 1.0 - scanline * scanline_strength;
	float dropout = step(0.982, czn_hash21(vec2(floor(UV.y * 180.0), tick)));
	float alpha = center.a * (1.0 - dropout * glitch_amount);
	color += signal_color.rgb * dropout * center.a * 0.8;
	COLOR = vec4(color, alpha) * COLOR;
}
