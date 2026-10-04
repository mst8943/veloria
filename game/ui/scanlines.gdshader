shader_type canvas_item;
// Televizyon: tarama çizgileri, hafif titreşim ve kenar kararması.
uniform float lines = 360.0;
uniform float strength = 0.18;

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float s = sin(UV.y * lines * 3.14159) * 0.5 + 0.5;
	float flick = 0.97 + 0.03 * sin(TIME * 50.0);
	float v = smoothstep(0.85, 0.35, distance(UV, vec2(0.5)));
	c.rgb *= (1.0 - strength * s) * flick * mix(0.75, 1.0, v);
	COLOR = c * COLOR;
}
