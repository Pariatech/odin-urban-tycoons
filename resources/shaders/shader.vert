#version 410

uniform UniformBufferObject {
    mat4 proj;
    mat4 view;
} ubo;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 light;
layout(location = 2) in vec4 texcoord;

layout(location = 0) out vec3 frag_light;
layout(location = 1) out vec4 frag_texcoord;

void main() {
    gl_Position = ubo.proj * ubo.view * vec4(pos, 1.0);
    frag_light = light;
    frag_texcoord = texcoord;
}
