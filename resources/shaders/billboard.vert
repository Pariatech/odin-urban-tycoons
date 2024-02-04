#version 450

layout(binding = 2) uniform UniformBufferObject {
    mat4 proj;
    mat4 view;
    mat4 rotation;
    uint camera_rotation;
} ubo;

layout(location = 0) in vec3 pos;
layout(location = 1) in vec2 texcoord;

layout(location = 2) in vec3 world_pos;
layout(location = 3) in vec3 light;
layout(location = 4) in float texture;
layout(location = 5) in float depth_map;
layout(location = 6) in float rotation;

layout(location = 0) out vec3 frag_light;
layout(location = 1) out vec2 frag_texcoord;
layout(location = 2) out float frag_texture_index;
layout(location = 3) out float frag_depth_map;

void main() {
    vec4 rotated_pos = ubo.rotation * vec4(pos, 1.0);
    vec4 translated_pos = rotated_pos + vec4(world_pos, 0.0);
    gl_Position = ubo.proj * ubo.view * translated_pos;

    frag_light = light;

    float final_rotation = (int(texture) % 2 * 2 + int(rotation + ubo.camera_rotation)) % 4;
    frag_texcoord = texcoord;
    if ((uint(final_rotation) % 2) == 1) {
        frag_texcoord.x = 1 - frag_texcoord.x;
    }

    frag_texture_index = floor(texture / 2) * 2;
    frag_texture_index += floor(final_rotation / 2);

    frag_depth_map = floor(depth_map / 2) * 2;
    frag_depth_map += floor(final_rotation / 2);
}
