shader_type canvas_item;
render_mode unshaded;

#include "res://czn_shader_pack/shaders/czn_common.gdshaderinc"

uniform vec2 focus = vec2(0.5, 0.5);
uniform vec4 line_color : source_color = vec4(0.68, 0.88, 1.0, 1.0);
uniform float density : hint_range(8.0, 160.0) = 72.0;
uniform float strength : hint_range(0.0, 2.0) = 1.0;
uniform float inner_radius : hint_range(0.0, 0.8) = 0.18;
uniform float speed : hint_range(0.0, 8.0) = 2.2;

void fragment() {
	vec2 p = UV - focus;
	p.x *= 1.45;
	float radius = length(p);
	float angle = atan(p.y, p.x);
	float ray_id = floor((angle / CZN_TAU + 0.5) * density);
	float random_value = czn_hash11(ray_id);
	float angular_line = pow(max(sin(angle * density + random_value * 6.0), 0.0), 14.0);
	float travel = fract(radius * (5.0 + random_value * 9.0) - TIME * speed * (0.5 + random_value));
	float dash = smoothstep(0.12, 0.36, travel) * (1.0 - smoothstep(0.65, 0.95, travel));
	float radial_mask = smoothstep(inner_radius, inner_radius + 0.28, radius);
	float edge_mask = smoothstep(0.3, 1.0, radius);
	float line = angular_line * dash * radial_mask * edge_mask * step(0.24, random_value);
	float alpha = clamp(line * strength, 0.0, 1.0);
	COLOR = vec4(line_color.rgb * line * (1.0 + radius), alpha);
}
