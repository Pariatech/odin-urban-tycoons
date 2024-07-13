#version 410

uniform sampler2D texture_sampler;

layout(location = 0) in vec2 texcoord;
layout(location = 1) in vec4 color;
layout(location = 2) in vec2 clip_start;
layout(location = 3) in vec2 clip_end;

layout(location = 0) out vec4 frag_color;

layout(origin_upper_left) in vec4 gl_FragCoord;

void main() {
    if (gl_FragCoord.x < clip_start.x || 
        gl_FragCoord.x >= clip_end.x ||
        gl_FragCoord.y < clip_start.y ||
        gl_FragCoord.y >= clip_end.y) {
        discard;
    }

    float gray = texture(texture_sampler, texcoord).r;
    frag_color = color * vec4(gray);
}
