#version 410

uniform sampler2DArray texture_sampler;
uniform sampler2DArray depth_map_texture_sampler;

layout(location = 0) in vec3  frag_light;
layout(location = 1) in vec2  frag_texcoord;
layout(location = 2) in float frag_texture_index;
layout(location = 3) in float frag_depth_map;

layout(location = 0) out vec4 frag_color;

void main() {
    vec4 tex = texture(texture_sampler, vec3(frag_texcoord, frag_texture_index));
    vec4 color = vec4(frag_light * tex.rgb, tex.a);
    if (color.a < 0.01) {
        discard;
    }
    frag_color = color;

    float depth = gl_FragCoord.z;

    float depth_from_map = texture(depth_map_texture_sampler, vec3(frag_texcoord, frag_depth_map)).r;
    depth += depth_from_map;

    gl_FragDepth = depth;
}
