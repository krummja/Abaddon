shader_type spatial;
render_mode blend_mix, unshaded;

uniform vec4 albedo : source_color;
uniform float point_size : hint_range(0.1, 128.0, 0.1);

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;

void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;
	vec3 col = VERTEX;
	ALBEDO = col / 2.0;
}
