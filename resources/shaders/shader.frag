#version 450

uniform sampler2DArray texture_sampler;

layout(location = 0) in vec3 light;
layout(location = 1) in vec4 texcoord;

layout(location = 0) out vec4 color;

void main() {
    vec4 tex = texture(texture_sampler, texcoord.rgb);
    vec4 mask_tex = texture(texture_sampler, texcoord.rga);
    if (tex.a * mask_tex.a < 0.01) {
        discard;
    }
    color = vec4(light * tex.rgb * mask_tex.rgb, tex.a * mask_tex.a);
    // color = vec4(1.0);
}
