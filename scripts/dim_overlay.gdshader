shader_type canvas_item;

uniform float amt : hint_range(0.0, 1.0) = 0.5;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float visibility : hint_range(0.0, 1.0) = 0.0;  // 0 = hidden, 1 = shown
uniform vec2 rect_size = vec2(1920.0, 1080.0); 

void fragment() {
    vec2 p = (UV - 0.5) * rect_size;
    float radius_px = amt * 0.5 * min(rect_size.x, rect_size.y);

    if (length(p) > radius_px) {
        COLOR = vec4(0.0);
    } else {
        COLOR = vec4(color.rgb, color.a * visibility);
    }
}