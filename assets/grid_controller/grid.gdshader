shader_type spatial;
render_mode blend_mix, unshaded;

uniform int gridType: hint_enum("Grid", "Radial", "Mixed") = 0;
uniform vec4 gridColor: source_color;
uniform vec4 checkerColor: source_color;
uniform int subdivisions: hint_range(1, 10) = 5;
uniform float majorLineThickness = 2.0;
uniform float minorLineThickness = 1.0;
uniform float minorLineAlpha: hint_range(0.0, 1.0) = .3;

uniform bool useFade = true;

instance uniform float fadeStart = 0.0;
instance uniform float fadeEnd = 10.0;
instance uniform float unitSize = 1.0;
instance uniform vec3 centerOffset = vec3(0.0, 0.0, 0.0);

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

// calculate checkerboard mask
float checker(vec2 pos, float unit){
	float square1 = step(.5, fract(pos.x / unit *.5));
	float square2 = step(.5, fract(pos.y / unit *.5));
	return max(square1, square2) - square1 * square2;
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

	// calculate planar distance from camera to fragment (used for fading)
	float distPlanar = distance(
        posWorld.xz,
        centerOffset.xz
    );

	// major grid lines
	float gridLine = grid(
        posWorld.xz,
        unitSize,
        majorLineThickness
    );

	// minor grid lines
	gridLine += grid(
        posWorld.xz,
        unitSize / float(subdivisions),
        minorLineThickness
    ) * minorLineAlpha;

	// radial grid lines
	float radialLine = distanceField(
		posWorld.xz,
		unitSize,
		majorLineThickness
	);

	radialLine += distanceField(
		posWorld.xz,
		unitSize / float(subdivisions),
		minorLineAlpha
	) * minorLineAlpha;

	// Output line
	float line = 0.0;

	switch (gridType) {
		case 0:
			line = gridLine;
			break;
		case 1:
			line = radialLine;
			break;
		case 2:
			line = gridLine + radialLine;
			break;
		default:
			line = gridLine;
			break;
	}

	line = clamp(line, 0.0, 1.0);

	// checkerboard
	float chec = checker(posWorld.xz, unitSize);

	// distance fade factor
	float fadeFactor = 1.0 - clamp(
        (distPlanar - fadeStart) / (fadeEnd - fadeStart),
        0.0, 1.0
    );

	// write ground plane depth into z buffer
	vec4 pp = (PROJECTION_MATRIX * (VIEW_MATRIX * vec4(posWorld, 1.0)));
	DEPTH = pp.z / pp.w;

	// final alpha
	float alphaGrid = line * gridColor.a;
	float alphaChec = chec * checkerColor.a;

    ALPHA = clamp(alphaGrid, 0.0, 1.0);

    if (useFade) {
	    ALPHA *= fadeFactor;
    }

	// eliminate grid above the horizon
	ALPHA *= step(ty, 0.0);

	// final color (premultiplied alpha blend)
	ALBEDO =
        (checkerColor.rgb * alphaChec) *
        (1.0 - alphaGrid) +
        (gridColor.rgb * alphaGrid);
}
