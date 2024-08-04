shader_type canvas_item;

uniform sampler2D texture;
uniform float scroll_speed; // Speed of scrolling
uniform vec2 offset; // Optional offset for starting position

void fragment() {
    vec2 uv = UV; // Get the current UV coordinates
    uv.x += offset.x; // Apply the offset
    uv.x += scroll_speed * TIME; // Apply scrolling based on time and speed
    uv = mod(uv, 1.0); // Wrap around the UV coordinates
    COLOR = texture(texture, uv); // Sample the texture at the new UV coordinates
}
