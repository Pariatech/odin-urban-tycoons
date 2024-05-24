#version 450

uniform sampler2D texture_sampler;

layout(location = 0) in vec2 texcoord;
layout(location = 1) in vec4 color;

layout(location = 0) out vec4 frag_color;

void main() {
    float gray = texture(texture_sampler, texcoord).r;
    frag_color = color * vec4(gray);
}
