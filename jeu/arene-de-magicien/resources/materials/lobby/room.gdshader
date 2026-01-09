shader_type spatial;

render_mode unshaded;

uniform vec3 sphere_center;
uniform float sphere_radius = 0.5;

uniform sampler2D _albedo;
uniform sampler2D _normal;
uniform sampler2D _orm;
uniform vec2 scale = vec2(1);

varying vec3 vertex_model;

void vertex() {
	vertex_model = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	bool layer_1 = length(vertex_model - sphere_center) <= sphere_radius;
	//layer_1 = layer_1 && dot(NORMAL, vec3(0,1,0)) >= 0.8;

	if(!layer_1){
		discard;
	} else {
		vec2 uv = UV * scale;
		ALBEDO = texture(_albedo, uv).rgb;
		NORMAL = texture(_normal, uv).rgb;
		METALLIC = texture(_orm, uv).b;
	}
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
