shader_type canvas_item;

uniform vec2 shadow_skew = vec2(0.5, 0.0); // X and Y skew factors
uniform float shadow_scale_y = 0.5;        // Compresses or stretches the shadow height
uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.4);

void vertex() {
    // Only skew the top parts of the sprite based on the UV height
    // (UV.y = 0.0 is the top, UV.y = 1.0 is the bottom anchor point)
    float mask = 1.0 - UV.y;
    
    // Distort the position
    VERTEX.x += shadow_skew.x * mask * VERTEX.y;
    VERTEX.y += shadow_skew.y * mask * VERTEX.y;
    
    // Scale the height
    VERTEX.y *= shadow_scale_y;
}

void fragment() {
    // Grab the alpha channel from the original sprite texture
    vec4 sprite_texture = texture(TEXTURE, UV);
    
    // Overwrite the color completely with the shadow color, matching original alpha
    COLOR = vec4(shadow_color.rgb, sprite_texture.a * shadow_color.a);
}