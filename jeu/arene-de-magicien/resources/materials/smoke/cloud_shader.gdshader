shader_type spatial;

uniform sampler2D alpha_shape;


varying float alpha;
void vertex() {
	alpha = 1.0 - INSTANCE_CUSTOM.y;
	// Called for every vertex the material is visible on.
}

void fragment() {
	float current_alpha = texture(alpha_shape, UV).r;
	if(current_alpha > alpha){
		discard;
	}
	ALPHA = current_alpha * alpha;
}