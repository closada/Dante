shader_type canvas_item;

uniform float pulse_speed = 2.0;
uniform float glow_intensity = 0.4;
uniform vec4 glow_color : source_color = vec4(0.8, 0.9, 1.0, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    float pulse = (sin(TIME * pulse_speed) + 1.0) * 0.5;
    vec3 glow = tex.rgb + glow_color.rgb * glow_intensity * pulse;
    COLOR = vec4(glow, tex.a);
}
