#version 410

uniform sampler2D texture_sampler;

layout(location = 0) in vec2  frag_texcoord;

layout(location = 0) out vec4 color;

void main() {
    vec4 tex = texture(texture_sampler, frag_texcoord);
    if (tex.a < 0.01) {
        discard;
    }
    color = tex;
}
