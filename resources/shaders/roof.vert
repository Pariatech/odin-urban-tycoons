#version 410

layout (std140) uniform UniformBufferObject {
    mat4 mvp;
    vec3 light;
} ubo;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 texcoord;
layout(location = 2) in vec3 color;

layout(location = 0) out vec3  frag_texcoord;
layout(location = 1) out vec3  frag_color;

void main() {
    gl_Position = ubo.mvp * vec4(pos, 1.0);

    frag_texcoord = texcoord;
    frag_color = color;
}
