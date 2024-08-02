#version 410

layout (std140) uniform UniformBufferObject {
    mat4 proj;
    mat4 view;
} ubo;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 texcoord;

layout(location = 2) in vec3 world_pos;
layout(location = 3) in vec3 light;
layout(location = 4) in float texture;
layout(location = 5) in float depth_map;
layout(location = 6) in float mirror;

layout(location = 0) out vec3 frag_light;
layout(location = 1) out vec2 frag_texcoord;
layout(location = 2) out float frag_texture_index;
layout(location = 3) out float frag_depth_map;

void main() {
    vec4 translated_pos = vec4(pos, 1.0) + vec4(world_pos, 0.0);
    gl_Position = ubo.proj * ubo.view * translated_pos;

    frag_light = light;

    frag_texcoord = vec2(texcoord.x * mirror, texcoord.y);
    frag_texture_index = texture;
    frag_depth_map = depth_map;
}
