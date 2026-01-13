shader_type canvas_item;

uniform float amplitude = 0.05;
uniform float frequency = 10.0;
uniform float speed = 3;
uniform float anchor_direction = 1;

uniform float use_anchor = 1;
uniform float is_y_direction = 0;

void fragment() {
    vec2 uv = UV;

	if ( is_y_direction > 0.0 )
	{
		float anchor_x = uv.y * anchor_direction;
		if (use_anchor > 0.0)
		{
			anchor_x = 1.0;
		}
		float wave_x = sin(uv.y * frequency + TIME * speed) * amplitude * 0.7 ;
		uv.x += wave_x * anchor_x;
	}
	else
	{
		float anchor_y = uv.y * anchor_direction;
		if (use_anchor > 0.0)
		{
			anchor_y = 1.0;
		}
		float wave_y = sin(uv.x * frequency + TIME * speed) * amplitude * 0.7 ;
		uv.y += wave_y * anchor_y;
	}
	uv = clamp(uv, vec2(0.0), vec2(1.0));
	COLOR = texture(TEXTURE, uv);
}