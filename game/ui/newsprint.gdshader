shader_type canvas_item;
// Gazete baskısı: 45 derece yarım ton nokta tramı, kâğıt renginde zemin, mürekkep rengi nokta.
// Saf tram fotoğrafı okunmaz yapar; okunurluk için sürekli tonla karıştırılır (tone_mix).
uniform float cell = 4.0;         // nokta aralığı (ekran pikseli)
uniform float contrast = 1.3;
uniform float lift = 0.16;        // gece sahneleri baskıda kararmasın
uniform float tone_mix = 0.45;
uniform vec4 ink : source_color = vec4(0.086, 0.07, 0.05, 1.0);
uniform vec4 paper : source_color = vec4(0.913, 0.878, 0.788, 1.0);

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	g = clamp((g - 0.5) * contrast + 0.5 + lift, 0.0, 1.0);
	float dark = 1.0 - g;
	vec2 p = FRAGCOORD.xy / cell;
	vec2 r = vec2(p.x + p.y, p.y - p.x) * 0.7071;
	float d = length(fract(r) - 0.5);
	float radius = sqrt(dark) * 0.7;
	float dotv = 1.0 - smoothstep(radius - 0.1, radius + 0.1, d);
	vec3 halftone = mix(paper.rgb, ink.rgb, dotv);
	vec3 tone = mix(paper.rgb, ink.rgb, dark);
	// Godot 4'te COLOR zaten doku rengini içerir; yalnızca saydamlığı (solma) al.
	COLOR = vec4(mix(halftone, tone, tone_mix), COLOR.a);
}
