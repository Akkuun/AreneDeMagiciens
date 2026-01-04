shader_type spatial;

render_mode unshaded, shadows_disabled, ambient_light_disabled, cull_disabled;

uniform sampler2D shape;
uniform sampler2D gradient;
uniform vec3 color : source_color;
uniform vec2 speed = vec2(0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 uv = UV;
	uv += TIME * speed;
	
	float attenuation = texture(gradient, vec2(UV.y, 0)).r;
	
	ALBEDO = color;
	ALPHA = clamp(texture(shape, uv).r - attenuation, 0.0, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
