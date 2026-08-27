shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec2 light_position = vec2(0.72, 0.20);
uniform vec4 light_color : source_color = vec4(0.42, 0.78, 1.0, 1.0);
uniform vec4 rim_color : source_color = vec4(0.86, 0.16, 0.72, 1.0);
uniform vec4 shadow_color : source_color = vec4(0.025, 0.008, 0.07, 0.78);
uniform float ambient : hint_range(0.0, 1.0) = 0.34;
uniform float light_power : hint_range(0.0, 4.0) = 1.55;
uniform float normal_strength : hint_range(0.0, 8.0) = 3.0;
uniform float rim_width : hint_range(0.0, 8.0) = 2.0;
uniform vec2 shadow_offset = vec2(5.0, 7.0);

void fragment() {
	vec2 uv = UV;
	vec2 px = TEXTURE_PIXEL_SIZE;
	vec4 base = texture(TEXTURE, uv);

	float alpha_left = texture(TEXTURE, uv - vec2(px.x, 0.0)).a;
	float alpha_right = texture(TEXTURE, uv + vec2(px.x, 0.0)).a;
	float alpha_up = texture(TEXTURE, uv - vec2(0.0, px.y)).a;
	float alpha_down = texture(TEXTURE, uv + vec2(0.0, px.y)).a;
	vec2 gradient = vec2(alpha_right - alpha_left, alpha_down - alpha_up);
	vec3 normal = normalize(vec3(-gradient * normal_strength, 1.0));
	vec3 light_direction = normalize(vec3(light_position - uv, 0.28));
	float diffuse = max(dot(normal, light_direction), 0.0);
	float distance_falloff = 1.0 / (1.0 + length(light_position - uv) * 1.8);

	vec2 rim_px = px * rim_width;
	float expanded = max(max(
		texture(TEXTURE, uv + vec2(rim_px.x, 0.0)).a,
		texture(TEXTURE, uv - vec2(rim_px.x, 0.0)).a), max(
		texture(TEXTURE, uv + vec2(0.0, rim_px.y)).a,
		texture(TEXTURE, uv - vec2(0.0, rim_px.y)).a));
	float rim = max(expanded - base.a, 0.0);
	float rim_facing = smoothstep(-0.4, 0.7, dot(normalize(vec3(gradient, 0.001)), -light_direction));

	vec2 shadow_uv = uv - shadow_offset * px;
	float shadow_alpha = texture(TEXTURE, shadow_uv).a * (1.0 - base.a);
	vec3 lit = base.rgb * (ambient + diffuse * distance_falloff * light_power);
	lit += light_color.rgb * diffuse * distance_falloff * 0.34;
	vec3 color = mix(shadow_color.rgb, lit, base.a);
	color += rim_color.rgb * rim * (0.35 + rim_facing * 0.9);
	float alpha = max(max(base.a, rim), shadow_alpha * shadow_color.a);
	COLOR = vec4(color, alpha) * COLOR;
}
