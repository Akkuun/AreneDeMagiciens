shader_type spatial;

render_mode cull_disabled, unshaded, depth_draw_never;

uniform float fill_rate : hint_range(0, 1) = 0.5f;
uniform vec4 bot_color : source_color;
uniform vec4 top_color : source_color;

varying float frag_height;

void vertex() {
	// Called for every vertex the material is visible on.
	frag_height = VERTEX.y + 0.5f;
}

void fragment() {
	vec4 color = FRONT_FACING ? bot_color : top_color;
	color = bot_color;
	if(frag_height > fill_rate){
		discard;
	}
	ALPHA = frag_height > fill_rate ? 0.f : color.a;
	ALBEDO = color.rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
