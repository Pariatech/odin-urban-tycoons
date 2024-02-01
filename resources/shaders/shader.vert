#version 450

layout(binding = 2) uniform UniformBufferObject {
    mat4 proj;
    mat4 view;
} ubo;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec3 light;
layout(location = 2) in vec4 texcoord;
layout(location = 3) in float depth_map;

layout(location = 0) out vec3 frag_light;
layout(location = 1) out vec4 frag_texcoord;
layout(location = 2) out float frag_depth_map;
layout(location = 3) out mat4 frag_projection;

void main() {
    frag_projection = ubo.proj;
    gl_Position = frag_projection * ubo.view * vec4(pos, 1.0);
    frag_light = light;
    frag_texcoord = texcoord;
    frag_depth_map = depth_map;
}
