shader_type spatial;

render_mode unshaded;

uniform float radius = 0.5;
uniform sampler2D color_gradient;
uniform sampler2D intensity_gradient;
uniform float speed = 1.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float current_radius = length(UV - vec2(0.5));
	if (current_radius > radius){
		ALPHA = 0.0;
		discard;
	}
	
	float radius_ratio = current_radius / radius;
	radius_ratio = fract(radius_ratio - TIME * speed);
	float intensity = texture(intensity_gradient, vec2(radius_ratio)).r;
	intensity = max(intensity, 0.02);
	
	vec3 color = texture(color_gradient, vec2(intensity)).rgb;
	
	ALBEDO = color;
	ALPHA = intensity;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
