// Shared procedural helpers for the CZN-inspired shader pack.
// All functions are prefixed to avoid collisions when this file is included.

const float CZN_PI = 3.14159265359;
const float CZN_TAU = 6.28318530718;

float czn_hash11(float p) {
	p = fract(p * 0.1031);
	p *= p + 33.33;
	p *= p + p;
	return fract(p);
}

float czn_hash21(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

vec2 czn_hash22(vec2 p) {
	float n = czn_hash21(p);
	return fract(vec2(n, n * 34.567) * vec2(13.545, 57.583));
}

float czn_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(czn_hash21(i), czn_hash21(i + vec2(1.0, 0.0)), u.x),
		mix(czn_hash21(i + vec2(0.0, 1.0)), czn_hash21(i + vec2(1.0, 1.0)), u.x),
		u.y
	);
}

float czn_fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	mat2 rotation = mat2(vec2(0.80, 0.60), vec2(-0.60, 0.80));
	for (int i = 0; i < 5; i++) {
		value += amplitude * czn_noise(p);
		p = rotation * p * 2.03 + vec2(17.1, 9.2);
		amplitude *= 0.5;
	}
	return value;
}

float czn_voronoi(vec2 p) {
	vec2 cell = floor(p);
	vec2 local = fract(p);
	float distance_to_cell = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x), float(y));
			vec2 point = czn_hash22(cell + neighbor);
			vec2 delta = neighbor + point - local;
			distance_to_cell = min(distance_to_cell, dot(delta, delta));
		}
	}
	return sqrt(distance_to_cell);
}

float czn_sd_segment(vec2 p, vec2 a, vec2 b) {
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
	return length(pa - ba * h);
}

float czn_hex_lines(vec2 p) {
	vec2 q = vec2(p.x * 1.1547005, p.y + p.x * 0.5773503);
	vec2 cell = fract(q) - 0.5;
	vec2 edge = abs(cell);
	return max(edge.x * 0.8660254 + edge.y * 0.5, edge.y);
}

vec3 czn_tonemap(vec3 color) {
	return color / (1.0 + color);
}
