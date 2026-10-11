#version 320 es
precision highp float;

in vec2 v_texcoord;
out vec4 fragColor;
uniform sampler2D tex;
uniform float effect_time;
uniform vec2 surface_size;

// Orbit focus: a neutral glass sheen sweeps diagonally across the window while
// the rim lights up and the content settles from a tiny lift. No colour split,
// no distortion; finishes inside window-shader-events' 0.45 s focus window.
void main() {
    float p = clamp(effect_time / 0.42, 0.0, 1.0);
    float ease = 1.0 - pow(1.0 - p, 3.0);
    float fade = 1.0 - ease;

    float lift = 0.006 * fade;
    vec2 uv = (v_texcoord - 0.5) * (1.0 - lift) + 0.5;
    vec4 colour = texture(tex, uv);

    float diagonal = (v_texcoord.x + v_texcoord.y) * 0.5;
    float centre = mix(-0.2, 1.2, ease);
    float sheen = exp(-pow((diagonal - centre) / 0.09, 2.0));

    vec2 px = v_texcoord * surface_size;
    float edge = min(min(px.x, surface_size.x - px.x), min(px.y, surface_size.y - px.y));
    float rim = exp(-edge / 5.0);

    float glow = (sheen * 0.07 + rim * 0.12) * fade;
    colour.rgb += vec3(glow) * colour.a;
    // WezTerm draws a translucent background; lift alpha slightly so the sheen reads.
    colour.a = min(1.0, colour.a + glow * 0.05);
    fragColor = colour;
}
