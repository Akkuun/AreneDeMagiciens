shader_type spatial;

render_mode world_vertex_coords, unshaded;

uniform float fill_rate : hint_range(0, 1) = 0.5f;
uniform float wobble_x : hint_range(-0.5, 0.5) = 0.f;
uniform float wobble_y : hint_range(-0.5, 0.5) = 0.f;
uniform vec4 bot_color : source_color;
uniform vec4 top_color : source_color;
uniform bool use_top_color = false;

uniform sampler2D refraction_noise;
uniform sampler2D screen_texture : hint_screen_texture;

varying float frag_height;

void vertex() {
	// Called for every vertex the material is visible on.
	mat4 motion_rotation_x = mat4(
		vec4(1, 0, 0, 0),
		vec4(0, cos(wobble_x * PI), -sin(wobble_x * PI), 0),
		vec4(0, sin(wobble_x * PI), cos(wobble_x * PI), 0),
		vec4(0, 0, 0, 1));
	mat4 motion_rotation_y = mat4(
		vec4(cos(wobble_y * PI), 0, -sin(wobble_y * PI), 0),
		vec4(0,                  1,                   0, 0),
		vec4(sin(wobble_y * PI), 0,  cos(wobble_y * PI), 0),
		vec4(0,                  0,                   0, 1));
	vec4 new_pos = motion_rotation_x * motion_rotation_y * vec4(VERTEX, 1);
	frag_height = (new_pos.y - NODE_POSITION_WORLD.y) + 0.5f;
}

void fragment() {
	vec4 color = FRONT_FACING ? bot_color : top_color;
	color = use_top_color ? top_color : bot_color;

	if(frag_height > fill_rate){
		discard;
	}
	ALPHA = frag_height > fill_rate ? 0.f : color.a;

	float agitation = sqrt(wobble_x * wobble_x + wobble_y * wobble_y);
	float idx_refraction = texture(refraction_noise, SCREEN_UV + vec2(TIME * 0.05, cos(TIME) * (agitation + 0.05))).r;

	float x_offset = dFdx(idx_refraction);
	float y_offset = dFdy(idx_refraction);

	vec3 blend_a = texture(screen_texture, SCREEN_UV + vec2(x_offset, y_offset) * 1.f).rgb;
	vec3 blend_b = color.rgb;
	//ALBEDO = vec3(1) - (vec3(1) - blend_a) * (vec3(1) - blend_b);
	ALBEDO = color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
