shader_type spatial;



uniform sampler2D ground_texture_1;
uniform sampler2D ground_texture_2;
uniform vec2 ground_scale = vec2(1.0);

uniform sampler2D cliff_texture;
uniform vec2 cliff_texture_scale = vec2(1);

uniform sampler2D cliff_transition_noise;
uniform float noise_strength = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;

	float noise_ratio = texture(cliff_transition_noise, UV).r;
	float cliff_ratio = 1.0 - dot(vec3(0,1,0), world_normal);
	cliff_ratio = clamp(cliff_ratio - noise_ratio * noise_strength, 0.0, 1.0);

	vec3 cliff_color = texture(cliff_texture, UV * cliff_texture_scale).rgb;
	vec3 ground_color = texture(ground_texture_1, UV * ground_scale).rgb;


	ALBEDO = mix(ground_color, cliff_color, cliff_ratio);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
