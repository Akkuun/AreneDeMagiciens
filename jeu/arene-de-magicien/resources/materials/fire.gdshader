shader_type spatial;

uniform sampler2D noise;
uniform sampler2D gradient;
uniform float speed = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float xvalue = texture(noise, UV + vec2(0, TIME * speed)).r;
	vec4 value = texture(gradient, vec2(xvalue, 0));
	ALBEDO = value.rgb;
	ALPHA = value.a;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
