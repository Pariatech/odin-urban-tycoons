#version 450

uniform sampler2D texture_sampler;

layout(location = 0) in vec2 texcoord;

layout(location = 0) out vec4 color;

void main() {
    float gray = texture(texture_sampler, texcoord).r;
    // if (gray < 0.01) {
    //     discard;
    // }
    color = vec4(gray);
}
