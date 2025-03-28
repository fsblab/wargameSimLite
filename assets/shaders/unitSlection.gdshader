shader_type spatial;

varying vec3 pos;
uniform float size;

void vertex() {
    pos = VERTEX;
}

void fragment() {
	ALBEDO = vec3(1., 0., 0.);
	RIM = .5;
	ALPHA = .5;
	if (pos.x > -.4 * size && pos.x < .4 * size && pos.z > -.4 * size && pos.z < .4 * size) {
		ALPHA = .0;
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
