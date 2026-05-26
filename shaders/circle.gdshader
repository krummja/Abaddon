shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx, unshaded;

uniform float radius : hint_range(0.0, 0.5, 0.01) = 0.4;
uniform float line_width : hint_range(0.001, 0.01, 0.0001) = 0.001;
uniform vec4 line_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec2 center = vec2(0.5, 0.5);
    vec2 uv = UV - center;

    float dist = length(uv);

    float angle = atan(uv.y, uv.x);
    angle = (angle + PI) / (2.0 * PI);

    float edge = abs(dist - radius);

    if (edge < line_width) {
        ALBEDO = line_color.rgb;
        ALPHA = line_color.a;
    } else {
        discard;
    }
}
