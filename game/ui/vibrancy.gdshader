shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;
uniform float saturation = 1.30;
uniform float contrast = 1.0;
uniform float brightness = 1.03;

void fragment() {
	vec4 source = texture(screen_texture, SCREEN_UV);
	float luma = dot(source.rgb, vec3(0.2126, 0.7152, 0.0722));
	vec3 color = mix(vec3(luma), source.rgb, saturation);
	color = (color - vec3(0.5)) * contrast + vec3(0.5);
	COLOR = vec4(clamp(color * brightness, vec3(0.0), vec3(1.0)), source.a);
}
