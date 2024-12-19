shader_type spatial;
render_mode world_vertex_coords;

uniform sampler2D tex;
uniform float roughness;

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
	vec4 color = texture(tex, UV);
	ALBEDO = color.xyz;
	ROUGHNESS = roughness;
	ALPHA = color.w;// * INSTANCE_CUSTOM.y;
}

