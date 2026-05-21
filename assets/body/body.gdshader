shader_type spatial;

render_mode blend_mix, unshaded;

uniform vec3 color: source_color;
uniform float outline_thickness: hint_range(0.0, 1.0, 0.01) = 0.05;

void fragment() {
    ALBEDO = color;
}
