shader_type spatial;
render_mode world_vertex_coords;

uniform vec4 color1 : source_color = vec4(1.0);
uniform vec4 color2 : source_color = vec4(1.0);

uniform float height_scale = 0.035; //Lower number lower scale, higher number higher scale
uniform float height_scale_dirt = 0.071;
uniform float normal_height = 6.0; //Lower number 0.01 High Detail, Higher Number 1.0 Lower Detail
uniform float normal_height_dirt = 10.0;
uniform float noise_scale = 8.0;
uniform float noise_scale_dirt = 1.0;

uniform float camp_radius = 0.001;


//Noise generation following the godot vertex shader tutorial
float hash(vec2 p) {
	return fract(sin(dot(p * 17.17, vec2(14.91, 67.31))) * 4791.9511);
}

float noise(vec2 x) {
	vec2 p = floor(x);
	vec2 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	vec2 a = vec2(1.0, 0.0);
	return mix(mix(hash(p + a.yy), hash(p + a.xy), f.x),
	mix(hash(p + a.yx), hash(p + a.xx), f.x), f.y);
}

float fbm(vec2 x) {
	float height = 0.0;
	float amplitude = 0.5;
	float frequency = 3.0;
	for (int i = 0; i < 6; i++){
		height += noise(x * frequency) * amplitude;
		amplitude *= 0.5;
		frequency *= 2.0;
		}
		return height;
}

vec3 camp_circle(vec2 x) {
	// Calculate distance from center
	float dist_from_center = length(x);
	float smooth_radius = smoothstep(camp_radius, camp_radius * 1.25, dist_from_center);

	// Generate noise
	float noise = fbm(x * noise_scale);
	float noise_dirt = fbm(x * noise_scale_dirt);
	float height = mix(noise_dirt, noise, smooth_radius);

	return vec3(noise, 1.0 - smooth_radius, height);
}

vec3 rgb_to_hsv(vec3 c) {
    float max_val = max(c.r, max(c.g, c.b));
    float min_val = min(c.r, min(c.g, c.b));
    float delta = max_val - min_val;

    float h = 0.0;
    if (delta > 0.0) {
        if (max_val == c.r) {
            h = mod((c.g - c.b) / delta, 6.0);
        } else if (max_val == c.g) {
            h = (c.b - c.r) / delta + 2.0;
        } else {
            h = (c.r - c.g) / delta + 4.0;
        }
        h /= 6.0;
    }

    float s = (max_val == 0.0) ? 0.0 : delta / max_val;
    float v = max_val;

    return vec3(h, s, v);
}

vec3 hsv_to_rgb(vec3 c) {
    float h = c.r * 6.0;
    float s = c.g;
    float v = c.b;

    float i = floor(h);
    float f = h - i;
    float p = v * (1.0 - s);
    float q = v * (1.0 - f * s);
    float t = v * (1.0 - (1.0 - f) * s);

    if (i == 0.0) return vec3(v, t, p);
    if (i == 1.0) return vec3(q, v, p);
    if (i == 2.0) return vec3(p, v, t);
    if (i == 3.0) return vec3(p, q, v);
    if (i == 4.0) return vec3(t, p, v);
    return vec3(v, p, q);
}

//Remappping my height value so it looks better
float remap(float value, float in_min, float in_max, float out_min, float out_max) {
    return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min);
}

//Remapping math for vec 3 with the same min maxes
vec3 remap3(vec3 value, float in_min, float in_max, float out_min, float out_max){
	float x = remap(value.x, in_min, in_max, out_min, out_max);
	float y = remap(value.y, in_min, in_max, out_min, out_max);
	float z = remap(value.z, in_min, in_max, out_min, out_max);

	return vec3(x, y, z);
}

void vertex() {
	vec2 world_coords = VERTEX.xz;
	COLOR.xyz = camp_circle(world_coords);

	float height = COLOR.z * height_scale;
	float height_dirt = COLOR.z * height_scale_dirt;

	VERTEX.y += mix(height, height_dirt, COLOR.y);

	//Normal Calculation normal_height_dirt
	vec2 e = vec2(normal_height, 0.0);
	vec3 normal_grass = normalize(vec3(fbm(VERTEX.xz - e) - fbm(VERTEX.xz + e), 2.0 * e.x, fbm(VERTEX.xz - e.yx) - fbm(VERTEX.xz + e.yx)));
	e = vec2(normal_height_dirt, 0.0);
	vec3 normal_dirt = normalize(vec3(fbm(VERTEX.xz - e) - fbm(VERTEX.xz + e), 2.0 * e.x, fbm(VERTEX.xz - e.yx) - fbm(VERTEX.xz + e.yx)));
	vec3 normal = mix(normal_dirt, normal_grass, COLOR.y);
	NORMAL = normal;

	// World Curvature
	float center = 0.8; //projection offset
	float width = 0.1; //projection width
	float fall = 5.0; //projection strength

	float x = ((VERTEX.z-CAMERA_POSITION_WORLD.z+center)*width);
	if(abs(x)>1.0){
		VERTEX.y -= 1000.0;
	} else {
		VERTEX.y += fall*(sqrt(1.0-x*x)-1.0);
	}
}

void fragment() {
	// Called for every pixel the material is visible on.

	vec3 grass = color1.xyz;
	vec3 dirt = color2.xyz;

    // Convert RGB to HSV
	vec3 grass_hsv = rgb_to_hsv(grass);
	vec3 dirt_hsv = rgb_to_hsv(dirt);
	// Remap Noise levels for Saturation & Value for Grass
	float value = remap(COLOR.z, 0.0, 1.0, 0.95, 0.75);
	value = mix(value, grass_hsv.z, 0.5);
	//float saturation = remap(COLOR.z, 0.0, 1.0, 0.6, 0.8);
	float saturation = grass_hsv.y;
	grass_hsv = vec3(grass_hsv.r, saturation, value);
	// Remap Noise levels for Saturation & Value for Dirt
	value = remap(COLOR.z, 0.0, 1.0, 1.0, 0.9);
	saturation = remap(COLOR.z, 0.0, 1.0, 0.75, 1.0);
	dirt_hsv = vec3(dirt_hsv.r, dirt_hsv.g, value);

	// Deprecated RGB mixing works better than HSV mixing
	//vec3 mixed_hsv = mix(grass_hsv, dirt_hsv, COLOR.y);

	// Mix RGBs
	grass = hsv_to_rgb(grass_hsv);
	dirt = hsv_to_rgb(dirt_hsv);
	vec3 mixed_rgb = mix(grass, dirt, COLOR.y);

	ALBEDO = mixed_rgb;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}