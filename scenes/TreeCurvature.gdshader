shader_type spatial;
render_mode world_vertex_coords;

uniform vec4 color1 : source_color = vec4(1.0);
uniform vec4 color2 : source_color = vec4(1.0);

void vertex() {
float center = 0.8; //projection offset
	float width = 0.1; //projection widt
	float fall = 5.0; //projection strength

	float x = ((VERTEX.z-CAMERA_POSITION_WORLD.z+center)*width);
	if(abs(x)>1.0){
		VERTEX.y -= 1000.0;
	} else {
		VERTEX.y += fall*(sqrt(1.0-x*x)-1.0);
	}
}

void fragment() {
    //ALBEDO = mat1.albedo_color;
	if (COLOR.x == 1.0) {
		ALBEDO = color1.xyz;
	} else {
		ALBEDO = color2.xyz;
	}


}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
