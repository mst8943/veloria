shader_type canvas_item;
// Gazete baskısı: gri ton, hafif sepya, yüksek kontrast ve mürekkep greni.
uniform float contrast = 1.25;
uniform float grain = 0.06;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float g = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	g = clamp((g - 0.5) * contrast + 0.5, 0.0, 1.0);
	g += (rand(UV * 900.0) - 0.5) * grain;
	vec3 sepia = mix(vec3(g), vec3(g * 1.04, g * 0.97, g * 0.86), 0.55);
	COLOR = vec4(sepia, c.a) * COLOR;
}
