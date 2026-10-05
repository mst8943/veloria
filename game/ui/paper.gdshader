shader_type canvas_item;
// Gazete kâğıdı: lif dokusu, kenarlarda sararma, ortadan yatay katlanma izi.
uniform vec4 base : source_color = vec4(0.913, 0.878, 0.788, 1.0);
uniform float fiber = 0.05;       // lif dokusunun gücü (ucuz kâğıtta daha çok)
uniform float age = 0.25;         // kenar sararması ve lekeler
uniform float fold_y = 0.5;       // katlanma yeri (0: yok)
uniform vec2 px_size = vec2(1120.0, 800.0);  // kâğıdın boyutu: doku ölçeği sabit kalsın

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
		mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 p = UV * px_size;
	// Lifler yatayda uzun: kâğıt hamuru akış yönünde.
	float n = noise(p * 0.8) * 0.45 + noise(p * 0.22) * 0.3 + noise(vec2(p.x * 0.04, p.y * 1.3)) * 0.25;
	vec3 col = base.rgb * (1.0 - fiber + fiber * 1.6 * n) + (hash(p) - 0.5) * 0.02;
	// Kenarlar ve rastgele lekeler sararır.
	vec2 d = min(UV, 1.0 - UV) * px_size;
	float edge = 1.0 - smoothstep(0.0, 80.0, min(d.x, d.y));
	float blotch = smoothstep(0.45, 0.9, noise(p * 0.01));
	col = mix(col, col * vec3(0.86, 0.78, 0.6), age * clamp(edge * 0.9 + blotch * 0.4, 0.0, 1.0));
	// Katlanma: ince koyu kırık çizgi, hemen üstünde açık sırt, iki yana yumuşak gölge.
	if (fold_y > 0.0) {
		float y = (UV.y - fold_y) * px_size.y;
		col *= 1.0 - 0.09 * exp(-y * y / 5.0);
		col += 0.04 * exp(-(y + 3.0) * (y + 3.0) / 5.0);
		col *= 1.0 - 0.035 * exp(-y * y / 1600.0);
	}
	COLOR = vec4(col, COLOR.a);
}
