#version 450

layout(location = 0) in vec2 pos;
layout(location = 1) in vec2 start;
layout(location = 2) in vec2 end;
layout(location = 3) in vec4 color;
layout(location = 4) in vec3 texcoord;

layout(location = 0) out vec2  frag_start;
layout(location = 1) out vec2  frag_end;
layout(location = 2) out vec4  frag_color;
layout(location = 3) out vec3 frag_texcoord;

void main() {
    gl_Position = vec4(pos, -1.0, 1.0);
    frag_start = start;
    frag_end = end;
    frag_color = color;
    frag_texcoord = texcoord;
    // frag_texcoord.y *= -1;
}
