#version 450

layout(binding = 2) uniform UniformBufferObject {
    mat4 proj;
    mat4 view;
    mat4 rotation;
} ubo;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 texcoord;

layout(location = 2) in vec3 instance_pos;
layout(location = 3) in vec3 light;
layout(location = 4) in float texture;
layout(location = 5) in float depth_map;

layout(location = 0) out vec3 frag_light;
layout(location = 1) out vec3 frag_texcoord;
layout(location = 2) out float frag_texture;
layout(location = 3) out float frag_depth_map;

void main() {
    gl_Position = ubo.proj * ubo.view * ubo.rotation * vec4(pos + instance_pos, 1.0);
    frag_light = light;
    frag_texcoord = vec3(texcoord, texture);
    frag_depth_map = depth_map;
}
