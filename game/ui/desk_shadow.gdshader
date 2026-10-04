shader_type canvas_item;
// Masa nesnesinin gölgesi: nesnenin kendi silüetinden bulanık, yarı saydam bir leke.
// Düğüm, nesnenin çizim alanından her kenarda `pad` oranında büyüktür; bulanıklık taşabilsin.

uniform float pad = 0.15;
uniform float blur = 0.03;      // UV cinsinden yayılma
uniform float opacity = 0.6;

void fragment() {
	vec2 uv = (UV - vec2(pad)) / (1.0 - 2.0 * pad);
	float s = 0.0;
	float w = 0.0;
	for (int x = -3; x <= 3; x++) {
		for (int y = -3; y <= 3; y++) {
			vec2 o = vec2(float(x), float(y)) / 3.0;
			float k = exp(-dot(o, o) * 2.0);
			vec2 p = uv + o * blur;
			float inside = step(0.0, p.x) * step(0.0, p.y) * step(p.x, 1.0) * step(p.y, 1.0);
			s += texture(TEXTURE, clamp(p, vec2(0.0), vec2(1.0))).a * inside * k;
			w += k;
		}
	}
	COLOR = vec4(0.02, 0.012, 0.008, s / w * opacity * COLOR.a);
}
