#version 450

uniform sampler2DArray texture_sampler;
uniform sampler2DArray depth_map_texture_sampler;

layout(location = 0) in vec3 light;
layout(location = 1) in vec3 texcoord;
layout(location = 2) in float depth_map;

layout(location = 0) out vec4 color;

void main() {
    vec4 tex = texture(texture_sampler, texcoord);
    if (tex.a < 0.01) {
        discard;
    }
    color = vec4(light * tex.rgb, tex.a);
    // color = vec4(1);

    float depth = gl_FragCoord.z;
    float depth_from_map = texture(depth_map_texture_sampler, vec3(texcoord.rg, depth_map)).r;
    // color = vec4(vec3(depth_from_map), 1);
    depth += depth_from_map;
    gl_FragDepth = depth;
}
