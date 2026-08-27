shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform vec4 shadow_color : source_color = vec4(0.008, 0.0, 0.016, 1.0);
uniform vec4 wound_color : source_color = vec4(0.76, 0.015, 0.055, 1.0);
uniform float horror : hint_range(0.0, 1.0) = 0.82;
uniform float scratch_density : hint_range(4.0, 40.0) = 18.0;

void fragment() {
	vec2 uv = UV;
	vec2 p = (uv - 0.5) * vec2(1.55, 1.0);
	float time = TIME;
	float twitch = (czn_hash11(floor(time * 9.0)) - 0.5) * 0.018 * horror;
	vec3 source = texture(screen_texture, SCREEN_UV + vec2(twitch, 0.0)).rgb;

	float crawling = czn_fbm(p * 4.2 + vec2(time * 0.13, -time * 0.08));
	float darkness = smoothstep(0.18, 0.92, length(p) + crawling * 0.35);
	vec3 color = mix(source, shadow_color.rgb, darkness * horror * 0.88);

	vec2 scratch_uv = p * vec2(scratch_density, scratch_density * 0.32);
	float column = floor(scratch_uv.x);
	float scratch_offset = czn_hash11(column) * 8.0;
	float scratch = abs(fract(scratch_uv.y + scratch_offset + sin(column) * time * 0.06) - 0.5);
	scratch = 1.0 - smoothstep(0.015, 0.055, scratch);
	scratch *= step(0.62, czn_hash11(column + floor(time * 2.0)));
	scratch *= smoothstep(0.15, 0.86, 1.0 - length(p));
	color += wound_color.rgb * scratch * horror * 0.8;

	float blot = czn_fbm(p * 11.0 + crawling * 2.0);
	blot = smoothstep(0.67, 0.88, blot) * horror;
	color = mix(color, wound_color.rgb * 0.22, blot * 0.55);

	float shutter = step(0.965, czn_hash11(floor(time * 17.0)));
	color *= 1.0 - shutter * 0.7;
	COLOR = vec4(color, 1.0);
}
