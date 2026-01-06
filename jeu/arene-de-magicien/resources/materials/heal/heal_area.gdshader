shader_type spatial;

render_mode unshaded;

uniform float radius = 0.5;
uniform sampler2D color_gradient;
uniform sampler2D wave_gradient;
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
	
	float radial_intensity = texture(intensity_gradient, vec2(radius_ratio)).r;
	
	float animated_radius_ratio = fract(radius_ratio - TIME * speed);
	float wave_intensity = texture(wave_gradient, vec2(animated_radius_ratio)).r;
	
	wave_intensity = max(wave_intensity * radial_intensity, 0.05 * radial_intensity);
	
	vec3 color = texture(color_gradient, vec2(wave_intensity)).rgb;
	
	ALBEDO = color;
	ALPHA = wave_intensity;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
