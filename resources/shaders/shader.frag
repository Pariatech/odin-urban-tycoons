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

    // float depth_scale = 0.00115446357;
    float depth = gl_FragCoord.z;
    float clip_depth = 2.0 * depth - 1.0;
    float linear_depth = 0.0;
    // float ndc = depth * 2.0 - 1.0;
    // float linear_depth = (2.0 * near * far) / (far + near - ndc * (far - near));
    // float linear_depth = near * far / (far - depth * (far - near));

    // linear_depth = (gl_FragCoord * inverse(ubo.proj)).z;
    // linear_depth = depth_to_linear(depth);
    linear_depth = depth_to_linear(depth);
    // color = vec4(vec3(linear_depth), 1.0);

    float depth_from_map = texture(depth_map_texture_sampler, vec3(texcoord.rg, depth_map)).r;
    // color = vec4(texcoord.rg, 0.0, 1.0);
    // color = vec4(vec3(depth_from_map), 1.0);
    // linear_depth += depth_to_linear(2.0 * depth_from_map - 1.0);
    linear_depth += depth_from_map;
    // color = vec4(vec3(linear_depth), 1.0);
    // depth = -near * far / (linear_depth * (far - near)) - far / (far - near);

    // linear_depth = (inverse(projection) * vec4(0, 0, gl_FragCoord.z, gl_FragCoord.w)).z;
    // depth = (projection * vec4(0, 0, linear_depth, 1)).z;

    // vec4 pos = inverse(projection) * gl_FragCoord; 
    // float depth_scale = 1;
    // float depth_offset = depth_from_map * depth_scale;
    // pos.z += depth_offset;
    // pos = projection * pos;
    // pos /= gl_FragCoord.w;
    
    // gl_FragDepth = linear_depth * gl_FragCoord.w;
    gl_FragDepth = linear_to_depth(linear_depth);
    // gl_FragDepth = gl_FragCoord.z;
}
