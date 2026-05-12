shader_type spatial;
render_mode blend_mix, depth_draw_opaque, unshaded;

uniform vec4 gridColor: source_color;
uniform vec4 checkerColor: source_color;
uniform float unitSize = 1.0;
uniform int subdivisions: hint_range(1, 10) = 5;
uniform float majorLineThickness = 2.0;
uniform float minorLineThickness = 1.0;
uniform float minorLineAlpha: hint_range(0.0, 1.0) = .3;

uniform bool useFade = true;
uniform float fadeStart = 0.0;
uniform float fadeEnd = 10.0;

instance uniform vec3 centerOffset = vec3(0.0, -1.0, 0.0);


float grid(vec2 pos, float unit, float thickness) {
	vec2 xDiv = dFdx(pos);
	vec2 yDiv = dFdy(pos);

	vec2 threshold = (abs(xDiv) + abs(yDiv)) * thickness * 0.5 / unit;
	vec2 posWrapped = pos / unit;

	vec2 line =
		step(fract(-posWrapped), threshold) +
		step(fract( posWrapped), threshold);

	return max(line.x, line.y);
}


void fragment() {

	// ray from camera to fragment in world space
	// VIEW is the normalized vector from fragment position to camera in view space
	// INV_VIEW_MATRIX gives us a view space to world space transform
	vec3 rayWorld = normalize(mat3(INV_VIEW_MATRIX) * VIEW);

	// Masks everything below y
	float ty = -(CAMERA_POSITION_WORLD.y - centerOffset.y) / (rayWorld.y);

	// Calculate fragment position in world space
	vec3 posWorld;
	posWorld.y = -centerOffset.y;
	posWorld.xz = CAMERA_POSITION_WORLD.xz + ty * rayWorld.xz;

	// Calculate planar distance from camera to fragment (used for fading)
	float distPlanar = distance(posWorld.xz, centerOffset.xz);

	ALBEDO = posWorld;
}
