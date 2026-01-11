shader_type spatial;

render_mode unshaded, shadows_disabled, ambient_light_disabled, cull_disabled;

uniform sampler2D shape;
uniform sampler2D gradient;
uniform vec3 color : source_color;
uniform vec2 speed = vec2(0);
uniform float angle = 0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float c_a = cos(angle);
	float s_a = sin(angle);
	vec2 uv = vec2(UV.x * c_a - UV.y * s_a, UV.x * s_a + UV.y * c_a);
	
	
	vec2 uv_moved = uv + TIME * speed;
	
	float attenuation = texture(gradient, vec2(uv.y, 0)).r;
	
	ALBEDO = color;
	ALPHA = clamp(texture(shape, uv_moved).r - attenuation, 0.0, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
