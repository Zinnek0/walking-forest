shader_type spatial;
render_mode cull_disabled;
uniform sampler2D animated_texture;
uniform float emission_intensity = 1.0;

float compare(float a, float b, float epsilon) {
	return abs(a - b) <= epsilon ? 1.0 : 0.0;
}

void fragment() {
	vec4 color = texture(animated_texture, UV);

	ALBEDO = color.xyz;
	
	//Recreating my blender material nodes to fix the garbage alpha output
	float luminance = dot(color.xyz, vec3(0.2126, 0.7152, 0.0722));
	color.w = compare(luminance, color.w, 0.39);
	
	
	EMISSION = mix(color.rgb * emission_intensity, vec3(0.0), color.w);
	//ALBEDO = vec3(mix(1.0, 0.0, color.w));
	
	//Adds smoke alpha but looks bad
	//luminance *= 2.2;
	//color.w = (1.0 - color.w) + luminance;
	color.w = (1.0 - color.w);
	ALPHA = color.w;
}

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