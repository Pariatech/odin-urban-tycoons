#version 410

layout (std140) uniform UniformBufferObject {
    mat4 mvp;
    vec3 light;
} ubo;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 texcoord;

layout(location = 0) out vec2  frag_texcoord;

void main() {
    gl_Position = ubo.mvp * vec4(pos, 1.0);

    frag_texcoord = texcoord;
}
