shader_type canvas_item;
render_mode unshaded;

uniform vec4 inner_color : source_color = vec4(1.0, 0.92, 0.62, 1.0);
uniform vec4 outer_color : source_color = vec4(1.0, 0.04, 0.18, 1.0);
uniform float glow_width : hint_range(0.0, 12.0) = 4.0;
uniform float pulse : hint_range(0.0, 2.0) = 1.0;

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	vec2 px = TEXTURE_PIXEL_SIZE * glow_width;
	float glow_alpha = 0.0;
	glow_alpha += texture(TEXTURE, UV + vec2(px.x, 0.0)).a;
	glow_alpha += texture(TEXTURE, UV - vec2(px.x, 0.0)).a;
	glow_alpha += texture(TEXTURE, UV + vec2(0.0, px.y)).a;
	glow_alpha += texture(TEXTURE, UV - vec2(0.0, px.y)).a;
	glow_alpha += texture(TEXTURE, UV + px * 0.7).a;
	glow_alpha += texture(TEXTURE, UV - px * 0.7).a;
	glow_alpha = clamp(glow_alpha / 4.5, 0.0, 1.0) * (1.0 - base.a);
	float heartbeat = 0.72 + 0.28 * sin(TIME * 5.5) * sin(TIME * 5.5);
	vec3 color = outer_color.rgb * glow_alpha * heartbeat * pulse;
	color += mix(base.rgb, inner_color.rgb, 0.68) * base.a * (1.0 + heartbeat * 0.35);
	COLOR = vec4(color, max(base.a, glow_alpha * outer_color.a)) * COLOR;
}
