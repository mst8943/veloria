shader_type canvas_item;
// Vinyet + film greni + hafif mum titremesi. Tam ekran bir ColorRect üzerinde çalışır.
uniform float vignette : hint_range(0.0, 1.0) = 0.6;
uniform float grain : hint_range(0.0, 0.2) = 0.05;
uniform float flicker : hint_range(0.0, 0.2) = 0.03;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	float d = distance(UV, vec2(0.5, 0.5));
	float v = smoothstep(0.38, 0.98, d) * vignette;
	float t = floor(TIME * 24.0);
	float g = (rand(UV * vec2(1280.0, 720.0) + t) - 0.5) * grain * 2.0;
	float fl = (sin(TIME * 7.3) * 0.5 + sin(TIME * 13.1 + 1.7) * 0.5) * flicker;
	vec3 warm = vec3(1.0, 0.72, 0.38) * max(fl, 0.0);
	float ga = abs(g);
	vec3 gc = vec3(step(0.0, g));
	float a = clamp(v + ga + max(fl, 0.0) * 0.5, 0.0, 1.0);
	vec3 col = (vec3(0.0) * v + gc * ga + warm * 0.5) / max(v + ga + max(fl, 0.0) * 0.5, 0.0001);
	COLOR = vec4(col, a);
}
