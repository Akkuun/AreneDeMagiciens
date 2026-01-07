shader_type spatial;


uniform sampler2D ground_texture_1;
uniform sampler2D ground_texture_2;
uniform vec2 ground_scale = vec2(1.0);

uniform sampler2D cliff_texture;
uniform vec2 cliff_texture_scale = vec2(1);
uniform float transition_sharpness = 1.0;
uniform sampler2D cliff_transition_noise;
uniform float noise_strength = 0.1;

varying vec3 world_vertex;

void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

vec4 triplanar_sample(sampler2D tex, vec3 normal, vec2 scale){
	vec2 uv_x = world_vertex.zy * scale;
	vec2 uv_y = world_vertex.xz * scale;
	vec2 uv_z = world_vertex.xy * scale;
	
	vec3 abs_normal = abs(normal);
	// Normalized ?
	vec3 weights = abs_normal / (abs_normal.x + abs_normal.y + abs_normal.z);
	
	vec4 color_x = texture(tex, uv_x) * weights.x;
	vec4 color_y = texture(tex, uv_y) * weights.y;
	vec4 color_z = texture(tex, uv_z) * weights.z;
	return (color_x + color_y + color_z) / 3.0;
}

void fragment() {
	vec3 world_normal = normalize((INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	float noise_ratio = texture(cliff_transition_noise, UV).r;
	float cliff_ratio = 1.0 - max(dot(vec3(0,1,0), world_normal), 0.0);
	cliff_ratio = pow(cliff_ratio, transition_sharpness);
	cliff_ratio = clamp(cliff_ratio - noise_ratio * noise_strength, 0.0, 1.0);

	vec3 cliff_color = triplanar_sample(cliff_texture, world_normal, cliff_texture_scale).rgb;
	vec3 ground_color = triplanar_sample(ground_texture_1, world_normal, ground_scale).rgb;


	ALBEDO = mix(ground_color, cliff_color, cliff_ratio);
}
