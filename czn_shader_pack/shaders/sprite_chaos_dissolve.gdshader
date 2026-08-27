shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform float dissolve : hint_range(0.0, 1.0) = 0.38;
uniform float auto_cycle : hint_range(0.0, 1.0) = 1.0;
uniform float edge_width : hint_range(0.001, 0.25) = 0.095;
uniform vec4 edge_color : source_color = vec4(1.0, 0.08, 0.45, 1.0);
uniform vec4 hot_color : source_color = vec4(0.25, 0.72, 1.0, 1.0);
uniform float noise_scale : hint_range(1.0, 30.0) = 8.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	float animated = 0.5 + 0.5 * sin(TIME * 0.85);
	float threshold = mix(dissolve, animated, auto_cycle);
	vec2 warped_uv = UV + vec2(
		czn_noise(UV * 5.0 + TIME * 0.14),
		czn_noise(UV * 4.0 - TIME * 0.11)
	) * 0.055;
	float noise_value = czn_fbm(warped_uv * noise_scale + vec2(0.0, -TIME * 0.18));
	float visible_mask = smoothstep(threshold - 0.025, threshold + 0.025, noise_value);
	float edge_mask = smoothstep(threshold - edge_width, threshold, noise_value) - visible_mask;
	float sparks = step(0.972, czn_hash21(floor(UV * vec2(90.0, 60.0)) + floor(TIME * 8.0)));
	sparks *= edge_mask;

	vec3 color = base.rgb * visible_mask;
	color += edge_color.rgb * edge_mask * 1.4;
	color += hot_color.rgb * edge_mask * edge_mask * 1.2;
	color += hot_color.rgb * sparks * 2.0;
	float alpha = base.a * max(visible_mask, edge_mask);
	COLOR = vec4(czn_tonemap(color * 1.3), alpha) * COLOR;
}
