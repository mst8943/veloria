shader_type canvas_item;
// Masa nesnesi ışığı: nesneyi sahnenin lambasıyla aydınlatır, böylece stüdyo ışığında
// çekilmiş görseller masanın ışığına uyar. Lambaya yakın kısım aydınlık ve sıcak,
// uzak kısım sahnenin karanlığına karışır.

uniform vec2 light_uv = vec2(0.75, 0.34);        // lambanın ekrandaki yeri (0..1)
uniform vec3 warm = vec3(1.0, 0.87, 0.68);       // lamba rengi
uniform float ambient = 0.6;                     // lambadan en uzak noktadaki ışık
uniform float reach = 0.95;                      // lamba ışığının erimi (ekran yüksekliği cinsinden)
uniform float desat = 0.2;                       // sahne paletine yaklaştırmak için doygunluk kısma
uniform float lift = 0.0;                        // üzerine gelinince parlama
uniform vec2 light_dir = vec2(0.7, -0.7);        // nesne içinde ışığın geldiği yön (UV)

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float l = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	c.rgb = mix(c.rgb, vec3(l), desat);
	// Kontrastı hafif düşür: parlak stüdyo beyazları sahneye uymaz.
	c.rgb = mix(vec3(0.5), c.rgb, 0.92);
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 d = (SCREEN_UV - light_uv) * vec2(aspect, 1.0);
	float t = clamp(1.0 - length(d) / reach, 0.0, 1.0);
	float lamp = ambient + (1.0 - ambient) * t * t;
	float side = 0.84 + 0.3 * clamp(dot(UV - 0.5, normalize(light_dir)) + 0.5, 0.0, 1.0);
	c.rgb *= warm * lamp * side * (1.0 + lift);
	COLOR = c * COLOR;
}
