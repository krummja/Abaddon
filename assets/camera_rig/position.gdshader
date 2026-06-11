shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float unitSize: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float lineThickness: hint_range(0.1, 10.0, 0.1) = 1.0;
uniform float fadeStart = 0.0;
uniform float fadeEnd = 10.0;

instance uniform vec3 centerOffset;

float distanceField(vec2 pos, float unit, float thickness) {
	vec2 xDiv = dFdx(pos);
    vec2 yDiv = dFdy(pos);
	vec2 threshold = (abs(xDiv) + abs(yDiv)) * thickness * 0.5 / unit;

    float d = 0.0;
    d = length(abs(pos / unit));
    vec2 line = step(fract(-d), threshold);
    line += step(fract(d), threshold);
    return max(line.x, line.y);
}

void fragment() {
	// ray from camera to fragment in world space
    // VIEW is the normalized vector from fragment position to camera in view space
    // INV_VIEW_MATRIX gives us a view space to world space transform
	vec3 rayWorld = normalize(mat3(INV_VIEW_MATRIX) * VIEW);
	float ty = -(CAMERA_POSITION_WORLD.y - centerOffset.y) / (rayWorld.y);

	// calculate fragment position in world space
	vec3 posWorld;

	posWorld.x = CAMERA_POSITION_WORLD.x + ty * rayWorld.x;
	posWorld.y = centerOffset.y;
	posWorld.z = CAMERA_POSITION_WORLD.z + ty * rayWorld.z;

	float distPlanar = distance(
        posWorld.xz,
        centerOffset.xz
    );

	float fadeFactor = 1.0 - clamp(
        (distPlanar - fadeStart) / (fadeEnd - fadeStart),
        0.0, 1.0
    );

	vec4 pp = (PROJECTION_MATRIX * (VIEW_MATRIX * vec4(posWorld, 1.0)));
	DEPTH = pp.z / pp.w;

	float line = distanceField(
		posWorld.xz,
		unitSize,
		lineThickness
	);

	float alphaCirc = line * color.a;

	ALPHA = clamp(alphaCirc, 0.0, 1.0);
	ALPHA *= fadeFactor;
	ALPHA *= step(ty, 0.0);

	ALBEDO = (1.0 - alphaCirc) + (color.rgb * alphaCirc);
}
