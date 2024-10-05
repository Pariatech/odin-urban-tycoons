#version 410

uniform sampler2DArray texture_sampler;

layout (std140) uniform UniformBufferObject {
    mat4 mvp;
    vec3 light;
} ubo;

layout(location = 0) in vec3  frag_texcoord;
layout(location = 1) in vec3  frag_color;

layout(location = 0) out vec4 color;

void main() {
    vec4 tex = texture(texture_sampler, frag_texcoord);
    if (tex.a < 0.01) {
        discard;
    }
    color = tex * vec4(ubo.light, 1) * vec4(frag_color, 1);
}
