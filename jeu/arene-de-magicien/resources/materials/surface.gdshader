shader_type spatial;

uniform float radius = .5f;
uniform vec4 color : source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	if(length(UV - vec2(0.5)) > radius){
		discard;
	}
	
	ALBEDO = color.rgb;
	ALPHA = color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
