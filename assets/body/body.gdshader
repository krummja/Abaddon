shader_type spatial;

render_mode blend_mix, unshaded;

uniform vec3 color: source_color;
uniform sampler2D surface: source_color;

void fragment() {
    vec3 tex_color = texture(surface, UV).rgb;
    vec3 albedo = color.rgb * tex_color;
    ALBEDO = albedo;
}
