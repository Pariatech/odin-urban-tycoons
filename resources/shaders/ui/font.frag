#version 410

uniform sampler2D texture_sampler;

layout(location = 0) in vec2 frag_texcoord;
layout(location = 1) in vec4 frag_color;
layout(location = 2) in vec2 frag_clip_start;
layout(location = 3) in vec2 frag_clip_end;

layout(location = 0) out vec4 color;

layout(origin_upper_left) in vec4 gl_FragCoord;

void main() {
    if (gl_FragCoord.x < frag_clip_start.x || 
        gl_FragCoord.x >= frag_clip_end.x ||
        gl_FragCoord.y < frag_clip_start.y ||
        gl_FragCoord.y >= frag_clip_end.y) {
        discard;
    }

    float gray = texture(texture_sampler, frag_texcoord).r;
    color = frag_color * vec4(gray);
}
