shader_type canvas_item;
// Altın parıltı: yazının üzerinden periyodik olarak geçen ışık bandı.
uniform float speed = 0.12;
uniform float width = 0.06;
uniform vec4 glow : source_color = vec4(1.0, 0.95, 0.75, 1.0);
uniform float screen_w = 1600.0;

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	float x = FRAGCOORD.x / screen_w;
	float p = fract(TIME * speed) * 1.8 - 0.4;   // band ekranın solundan sağına geçer, sonra bekler
	float band = 1.0 - smoothstep(0.0, width, abs(x - p));
	c.rgb = mix(c.rgb, glow.rgb, band * 0.75 * c.a);
	COLOR = c;
}
