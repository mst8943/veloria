shader_type canvas_item;
// Tüplü televizyon camı: altında çizilmiş her şeyi (görüntü ve kanal grafikleri) ekran dokusundan
// okuyup eğrilik, tarama çizgisi, fosfor maskesi, kenar kararması ve parazitle yeniden çizer.
// Ekranın en üst çocuğu olmalı.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float curve = 0.045;      // fıçı eğriliği
uniform float corner = 0.08;      // köşe yuvarlaklığı
uniform float lines = 270.0;      // tarama çizgisi sayısı

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// Yerel UV değişimini ekran UV değişimine çeviren ölçek (dikdörtgen eksene hizalı, sabit).
	vec2 k = vec2(dFdx(SCREEN_UV.x) / dFdx(UV.x), dFdy(SCREEN_UV.y) / dFdy(UV.y));
	vec2 c = UV * 2.0 - 1.0;
	c += c * (c.yx * c.yx) * curve;
	vec2 luv = c * 0.5 + 0.5;
	vec2 q = abs(c) - (1.0 - corner);
	float sd = length(max(q, 0.0)) - corner;
	float inside = 1.0 - smoothstep(-0.006, 0.006, sd);
	vec2 base = SCREEN_UV + (luv - UV) * k;
	vec2 ca = vec2(0.0011, 0.0) * k;
	vec3 col;
	col.r = texture(screen_tex, base + ca).r;
	col.g = texture(screen_tex, base).g;
	col.b = texture(screen_tex, base - ca).b;
	// Tarama çizgileri ve RGB fosfor maskesi
	col *= (0.84 + 0.16 * sin(luv.y * lines * 6.2832)) * 1.2;
	float px = mod(floor(FRAGCOORD.x), 3.0);
	vec3 m = vec3(0.9);
	if (px < 0.5) { m.r = 1.0; } else if (px < 1.5) { m.g = 1.0; } else { m.b = 1.0; }
	col *= m;
	// Kenar kararması, yavaş kayan parlaklık bandı, parazit, titreşim
	float vig = luv.x * luv.y * (1.0 - luv.x) * (1.0 - luv.y);
	col *= clamp(pow(vig * 16.0, 0.22), 0.0, 1.0);
	float roll = fract(TIME * 0.07) * 1.3 - 0.15;
	col *= 1.0 + 0.05 * exp(-pow((luv.y - roll) * 9.0, 2.0));
	col += (hash(luv * 700.0 + fract(TIME) * 13.0) - 0.5) * 0.035;
	col *= 0.985 + 0.015 * sin(TIME * 47.0);
	// Camda pencere yansıması (sol üst)
	col += vec3(0.06) * smoothstep(0.55, 0.0, length((luv - vec2(0.2, 0.1)) * vec2(1.0, 1.6)));
	COLOR = vec4(mix(vec3(0.012, 0.012, 0.014), col, inside), 1.0);
}
