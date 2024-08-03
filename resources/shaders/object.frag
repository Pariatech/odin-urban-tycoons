#version 410

uniform sampler2DArray texture_sampler;
uniform sampler2DArray depth_map_texture_sampler;
uniform sampler2DArray mask_texture_sampler;

layout(location = 0) in vec3  frag_light;
layout(location = 1) in vec2  frag_texcoord;
layout(location = 2) in float frag_texture_index;
layout(location = 3) in float frag_depth_map;
layout(location = 4) in float frag_mask;

layout(location = 0) out vec4 color;

void main() {
    vec4 tex = texture(texture_sampler, vec3(frag_texcoord, frag_texture_index));
    if (tex.xyz == vec3(1)) {
        tex = texture(mask_texture_sampler, vec3(frag_texcoord, frag_mask));
    }
    if (tex.a < 0.01) {
        discard;
    }
    color = vec4(frag_light * tex.rgb, tex.a);
    // color = vec4(1);

    float depth = gl_FragCoord.z;
    float depth_from_map = texture(depth_map_texture_sampler, vec3(frag_texcoord, frag_depth_map)).r;
    // color = vec4(vec3(depth_from_map), 1);
    depth += depth_from_map;
    gl_FragDepth = depth;
}
