shader_type spatial;

uniform sampler2D texture_sheet;
uniform vec2 frame_size;
uniform int columns;
uniform int rows;
uniform int frame;
uniform sampler2D normal_map : hint_normal;
uniform float specular_intensity = 0.5;
uniform float glossiness = 0.5;
uniform float detail_mix = 0.5;
uniform sampler2D emission_map;

void fragment() {
    int column = frame % columns;
    int row = frame / columns;
    vec2 offset = vec2(float(column), float(row)) * frame_size;
    vec2 frame_uv = UV * frame_size + offset;
    vec4 color = texture(texture_sheet, frame_uv);

    // Normal Mapping
    vec3 normal = texture(normal_map, frame_uv).rgb;
    normal = normalize((normal * 2.0) - 1.0);

    // Basic Lighting
    vec3 light_dir = normalize(vec3(1.0, 1.0, 1.0));
    float diff = max(dot(normal, light_dir), 0.0);

    // Specular Highlights
    vec3 view_dir = normalize(-FRAGCOORD.xyz);
    vec3 reflect_dir = reflect(-light_dir, normal);
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), glossiness);
    vec3 specular = vec3(specular_intensity) * spec;

    // Final Color
    vec3 result_color = (color.rgb * diff) + specular;
    ALBEDO = result_color;
    ALPHA = color.a;

    // Emission
    vec3 emission_color = texture(emission_map, frame_uv).rgb;
    EMISSION = emission_color * (color.rgb * diff);
}
