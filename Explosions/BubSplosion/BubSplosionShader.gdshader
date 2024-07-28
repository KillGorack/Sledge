shader_type spatial;

uniform sampler2D texture_sheet;
uniform vec2 frame_size;
uniform int columns;
uniform int rows;
uniform int frame;

void fragment() {
    int column = frame % columns;
    int row = frame / columns;
    vec2 offset = vec2(float(column), float(row)) * frame_size;
    vec2 frame_uv = UV * frame_size + offset;
    vec4 color = texture(texture_sheet, frame_uv);
    float intensity = (color.r + color.g + color.b) / 3.0;
    vec3 gradient_color = mix(mix(vec3(1.0, 0.5, 0.0), vec3(1.0, 0.0, 0.0), intensity), vec3(1.0, 1.0, 1.0), intensity);
    ALBEDO = gradient_color;
    ALPHA = color.a;
    EMISSION = gradient_color * (intensity * 0.4);
}
