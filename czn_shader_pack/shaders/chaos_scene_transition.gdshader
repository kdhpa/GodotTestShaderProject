shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float progress : hint_range(0.0, 1.0) = 0.45;
uniform float auto_cycle : hint_range(0.0, 1.0) = 1.0;
uniform vec4 void_color : source_color = vec4(0.008, 0.0, 0.018, 1.0);
uniform vec4 edge_color : source_color = vec4(0.88, 0.035, 0.52, 1.0);
uniform float edge_width : hint_range(0.001, 0.25) = 0.075;

void fragment() {
	vec2 uv = UV;
	float loop = abs(fract(TIME * 0.16) * 2.0 - 1.0);
	float current_progress = mix(progress, loop, auto_cycle);
	float noise = czn_fbm(uv * 5.0 + vec2(TIME * 0.08, -TIME * 0.04));
	float tendrils = sin((uv.y + noise * 0.42) * 23.0 + uv.x * 8.0 - TIME * 1.7) * 0.04;
	float field = uv.x + (noise - 0.5) * 0.42 + tendrils;
	float mask = 1.0 - smoothstep(current_progress - 0.03, current_progress + 0.03, field);
	float edge = smoothstep(current_progress - edge_width, current_progress, field) - smoothstep(current_progress, current_progress + edge_width, field);

	vec2 distorted_uv = SCREEN_UV + vec2((noise - 0.5) * edge * 0.04, 0.0);
	vec3 source = texture(screen_texture, distorted_uv).rgb;
	vec3 color = mix(source, void_color.rgb, mask);
	color += edge_color.rgb * edge * 1.8;
	float sparks = step(0.985, czn_hash21(floor(uv * vec2(160.0, 90.0)) + floor(TIME * 12.0)));
	color += edge_color.rgb * sparks * edge * 2.0;
	COLOR = vec4(czn_tonemap(color * 1.2), 1.0);
}
