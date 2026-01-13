shader_type canvas_item;

uniform float amplitude = 0.05;
uniform float frequency = 10.0;
uniform float speed = 3;

void fragment() {
    vec2 uv = UV;
    float wave3 = sin(uv.y * frequency + TIME * speed);
    float wave_y = wave3 * amplitude * 0.7;

    float anchor = uv.y;

    uv.y += wave_y * anchor;
	uv = clamp(uv, vec2(0.0), vec2(1.0));
    COLOR = texture(TEXTURE, uv);
}