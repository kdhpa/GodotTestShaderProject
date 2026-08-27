shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec4 outline_color : source_color = vec4(0.12, 0.82, 1.0, 1.0);
uniform vec4 hit_color : source_color = vec4(1.0, 0.94, 0.80, 1.0);
uniform vec4 afterimage_color : source_color = vec4(0.93, 0.04, 0.48, 0.65);
uniform float outline_width : hint_range(0.0, 8.0) = 2.0;
uniform float hit_amount : hint_range(0.0, 1.0) = 0.65;
uniform float auto_pulse : hint_range(0.0, 1.0) = 1.0;
uniform float afterimage_distance : hint_range(0.0, 24.0) = 8.0;

void fragment() {
	vec2 uv = UV;
	vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
	vec4 base = texture(TEXTURE, uv);
	float around = 0.0;
	around = max(around, texture(TEXTURE, uv + vec2(px.x, 0.0)).a);
	around = max(around, texture(TEXTURE, uv - vec2(px.x, 0.0)).a);
	around = max(around, texture(TEXTURE, uv + vec2(0.0, px.y)).a);
	around = max(around, texture(TEXTURE, uv - vec2(0.0, px.y)).a);
	around = max(around, texture(TEXTURE, uv + px).a);
	around = max(around, texture(TEXTURE, uv - px).a);
	float outline = max(around - base.a, 0.0);

	float offset = afterimage_distance * TEXTURE_PIXEL_SIZE.x;
	float ghost_a = texture(TEXTURE, uv + vec2(offset, 0.0)).a * (1.0 - base.a - outline);
	float ghost_b = texture(TEXTURE, uv - vec2(offset * 0.65, 0.0)).a * (1.0 - base.a - outline);
	float ghost = max(ghost_a, ghost_b * 0.55);

	float pulse = mix(1.0, pow(max(sin(TIME * 4.4), 0.0), 5.0), auto_pulse);
	float flash = hit_amount * pulse;
	vec3 base_luma = vec3(dot(base.rgb, vec3(0.299, 0.587, 0.114)));
	vec3 hit = mix(base.rgb, hit_color.rgb + base_luma * 0.3, flash);
	vec3 color = hit * base.a;
	color += outline_color.rgb * outline * (0.7 + pulse * 0.6);
	color += afterimage_color.rgb * ghost * afterimage_color.a;
	float alpha = max(max(base.a, outline), ghost * afterimage_color.a);
	COLOR = vec4(color, alpha) * COLOR;
}
