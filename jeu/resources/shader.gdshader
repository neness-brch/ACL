
shader_type canvas_item;
render_mode blend_mix;

uniform sampler2D water_noise : repeat_enable, filter_nearest;
uniform sampler2D water_noise2 : repeat_enable, filter_nearest;

uniform float noise_scale = 100.0;

uniform float wave_speed = 0.35;

uniform float intensity : hint_range(0.0, 1.0) = 0.35;

uniform vec4 highlight_color : source_color =
    vec4(0.55, 0.85, 1.0, 1.0);

varying vec2 world_position;

void vertex() {
    world_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {

    vec2 uv = world_position / noise_scale;

    vec2 movement1 = uv + vec2(
        TIME * wave_speed,
        TIME * wave_speed * 0.25
    );

    vec2 movement2 = uv * 1.7 + vec2(
        -TIME * wave_speed * 0.3,
        TIME * wave_speed * 0.7
    );

    float noise1 = texture(water_noise, movement1).r;
    float noise2 = texture(water_noise2, movement2).r;

    float combined_noise = mix(noise1, noise2, 0.5);

    float highlights = smoothstep(
        0.58,
        0.78,
        combined_noise
    );

    float wave = sin(
        world_position.y * 0.08
        + combined_noise * 4.0
        - TIME * wave_speed * 8.0
    );

    wave = smoothstep(0.0, 0.8, wave);

    float final_effect = highlights * wave * intensity;

    vec4 tile = texture(TEXTURE, UV) * COLOR;

    COLOR = vec4(
        highlight_color.rgb,
        final_effect * tile.a * highlight_color.a
    );
}
