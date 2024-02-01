#version 450

uniform sampler2DArray texture_sampler;
uniform sampler2DArray depth_map_texture_sampler;

layout(binding = 2) uniform UniformBufferObject {
    mat4 proj;
    mat4 view;
} ubo;

layout(location = 0) in vec3 light;
layout(location = 1) in vec4 texcoord;
layout(location = 2) in float depth_map;
layout(location = 3) out mat4 projection;

layout(location = 0) out vec4 color;

float near = 0.1;
float far = 100.0;
float depth_to_linear(float depth) {
    // return mix(near, far, depth);
    // return (2.0 * near * far) / (far + near - depth * (far - near));
    return near * far / (far - depth * (far + near));
}

float linear_to_depth(float linear_depth) {
    return (linear_depth - near) / (far - near);
}

void main() {
    vec4 tex = texture(texture_sampler, texcoord.rgb);
    vec4 mask_tex = texture(texture_sampler, texcoord.rga);
    if (tex.a * mask_tex.a < 0.01) {
        discard;
    }
    color = vec4(light * tex.rgb * mask_tex.rgb, tex.a * mask_tex.a);

    float depth = gl_FragCoord.z;
    float depth_from_map = texture(depth_map_texture_sampler, vec3(texcoord.rg, depth_map)).r;
    depth += depth_from_map;
    gl_FragDepth = depth;
}
