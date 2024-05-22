#version 450

layout(location = 0) in vec2 pos;
layout(location = 1) in vec2 texcoord;

layout(location = 0) out vec2 frag_texcoord;

void main() {
    gl_Position = vec4(pos, -1.0, 1.0);
    frag_texcoord = texcoord;
}
