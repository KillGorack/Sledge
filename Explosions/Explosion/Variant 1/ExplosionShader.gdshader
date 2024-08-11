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
uniform sampler2D emission_map; // Emission map texture

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
    vec3 light_dir = normalize(vec3(1.0, 1.0, 1.0)); // Light direction
    float diff = max(dot(normal, light_dir), 0.0);

    // Specular Highlights
    vec3 view_dir = normalize(-FRAGCOORD.xyz); // View direction
    vec3 reflect_dir = reflect(-light_dir, normal); // Reflection direction
    float spec = pow(max(dot(view_dir, reflect_dir), 0.0), glossiness);
    vec3 specular = vec3(specular_intensity) * spec;

    // Final Color
    vec3 result_color = (color.rgb * diff) + specular;
    float intensity = (color.r + color.g + color.b) / 3.0;
    vec3 gradient_color = mix(mix(vec3(1.0, 0.5, 0.0), vec3(1.0, 0.0, 0.0), intensity), vec3(1.0, 1.0, 1.0), intensity);

    ALBEDO = result_color * gradient_color;
    ALPHA = intensity < 0.1 ? 0.0 : intensity;

    // Emission
    vec3 emission_color = texture(emission_map, frame_uv).rgb;
    EMISSION = emission_color * gradient_color * (intensity * 2.4);
}