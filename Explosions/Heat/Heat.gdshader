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

    ALBEDO = color.rgb;
    ALPHA = color.a;

    // Calculate inverse alpha
    float inverse_alpha = 1.0 - color.a;

    // Adjust emission based on inverse alpha
    EMISSION = color.rgb * inverse_alpha * 5.0;
}
