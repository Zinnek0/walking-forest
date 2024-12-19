shader_type spatial;
uniform sampler2D face;
uniform sampler2D body;
uniform int faceCount;
uniform int faceUsers;
uniform int faceIndex;
uniform int faceUserIndex;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 bodyColor = texture(body, UV);
	vec4 faceColor = texture(
		face, 
		vec2(
		//(UV2.x / float(faceCount)) + float(float(faceIndex) / float(faceCount)),
		(UV2.x + (float(faceIndex))) / float(faceCount), 
		//(UV2.y / float(faceUsers)) + float(float(faceUserIndex) / float(faceUsers)) 
		(UV2.y + (float(faceUserIndex))) / float(faceUsers)
		));
	ALBEDO = mix(bodyColor.rgb, faceColor.rgb, faceColor.a);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
