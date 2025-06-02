shader_type spatial;

uniform sampler2D albedo_texture;
uniform sampler2D normal_texture;
uniform sampler2D height_texture;
uniform sampler2D roughness_texture; // For surface smoothness

uniform vec2 scroll_speed1 = vec2(0.2, 0.0); // First layer speed
uniform vec2 scroll_speed2 = vec2(0.0, 0.2); // Second layer speed

uniform float blend_factor = 0.5; // Controls blending between layers

void fragment() {
    vec2 uv1 = UV + scroll_speed1 * TIME;
    vec2 uv2 = UV + scroll_speed2 * TIME;

    // Sample textures from two scrolling layers
    vec3 albedo_color1 = texture(albedo_texture, uv1).rgb;
    vec3 albedo_color2 = texture(albedo_texture, uv2).rgb;

    vec3 normal_map1 = texture(normal_texture, uv1).rgb * 2.0 - 1.0;
    vec3 normal_map2 = texture(normal_texture, uv2).rgb * 2.0 - 1.0;

    float height_map1 = texture(height_texture, uv1).r;
    float height_map2 = texture(height_texture, uv2).r;

    float roughness1 = texture(roughness_texture, uv1).r;
    float roughness2 = texture(roughness_texture, uv2).r;

    // Blend two texture layers together
    ALBEDO = mix(albedo_color1, albedo_color2, blend_factor);
    NORMAL = mix(normal_map1, normal_map2, blend_factor);
    METALLIC = 1.0;
    ROUGHNESS = mix(roughness1, roughness2, blend_factor) * 0.3;
}
