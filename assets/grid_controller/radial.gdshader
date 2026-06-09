shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 gridColor: source_color;
uniform float unitSize: hint_range(0.05, 10.0, 0.05) = 1.0;
uniform float lineThickness: hint_range(1.0, 5.0, 0.1) = 1.0;
uniform float fadeStart: hint_range(0.01, 30.0, 0.01) = 10.0;
uniform float fadeEnd: hint_range(0.01, 30.0, 0.01) = 20.0;

instance uniform vec3 centerOffset = vec3(0.0, 0.0, 0.0);

float grid(vec2 pos, float unit, float thickness) {
    vec2 xDiv = dFdx(pos);
    vec2 yDiv = dFdy(pos);
	vec2 threshold = (abs(xDiv) + abs(yDiv)) * thickness * 0.5 / unit;

	vec2 posWrapped = pos / unit;
    vec2 line = step(fract(-posWrapped), threshold);
    line += step(fract(posWrapped), threshold);

	return max(line.x, line.y);
}

float rows(vec2 pos, float unit) {
    vec2 posWrapped = pos / unit;
    vec2 line = vec2(
        posWrapped.x - floor(posWrapped.x),
        posWrapped.y - ceil(posWrapped.y)
    );

    return max(line.x, line.y);
}

float columns(vec2 pos, float unit) {
    vec2 posWrapped = pos / unit;
    vec2 line = vec2(
        posWrapped.x - ceil(posWrapped.x),
        posWrapped.y - floor(posWrapped.y)
    );

    return max(line.x, line.y);
}

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
	// Ray from camera to fragment in world space
    // VIEW is the normalized vector from fragment position to camera in view space
    // INV_VIEW_MATRIX gives us a view space to world space transform
	vec3 rayWorld = normalize(mat3(INV_VIEW_MATRIX) * VIEW);

    // Calculates the y-axis projection for the fragment
    // This is used to mask the positive y axis so that the grid only appears
    // below the horizon.
	float ty = -(CAMERA_POSITION_WORLD.y - centerOffset.y) / (rayWorld.y);

	// Calculate fragment position in world space
	vec3 posWorld;
	posWorld.y = centerOffset.y;
	posWorld.xz = CAMERA_POSITION_WORLD.xz + ty * rayWorld.xz;

    // Calculate planar distance from camera to fragment (for fading)
    float distPlanar = distance(posWorld.xz, centerOffset.xz);

    // Calculate the fade distance
    float fadeFactor = 1.0 - clamp((distPlanar - fadeStart) / (fadeEnd - fadeStart), 0.0, 1.0);

    // Calculate grid lines
    // float line = grid(posWorld.xz, unitSize, lineThickness);
    // float line = columns(posWorld.xz, unitSize);
    float line = distanceField(posWorld.xz, unitSize, lineThickness);

    // Normalize
    line = clamp(line, 0.0, 1.0);

    // Write ground plane depth into depth buffer.
    vec4 pp = (PROJECTION_MATRIX * (VIEW_MATRIX * vec4(posWorld, 1.0)));
    DEPTH = pp.z / pp.w;

    // Calculate Alpha
    float alphaGrid = line * gridColor.a;
    ALPHA = clamp(alphaGrid, 0.0, 1.0);
    ALPHA *= fadeFactor;

    // Eliminate grid above the horizon
    ALPHA *= step(ty, 0.0);

    // Write Albedo
    ALBEDO = (gridColor.rgb * alphaGrid);
}
