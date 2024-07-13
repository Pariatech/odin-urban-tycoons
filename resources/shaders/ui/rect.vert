#version 410

layout(location = 0) in vec2 pos;
layout(location = 1) in vec2 start;
layout(location = 2) in vec2 end;
layout(location = 3) in vec4 color;
layout(location = 4) in float left_border_width;
layout(location = 5) in float right_border_width;
layout(location = 6) in float top_border_width;
layout(location = 7) in float bottom_border_width;

layout(location = 0) out vec2  frag_start;
layout(location = 1) out vec2  frag_end;
layout(location = 2) out vec4  frag_color;
layout(location = 3) out float frag_left_border_width;
layout(location = 4) out float frag_right_border_width;
layout(location = 5) out float frag_top_border_width;
layout(location = 6) out float frag_bottom_border_width;

void main() {
    gl_Position = vec4(pos, -1.0, 1.0);
    frag_start = start;
    frag_end = end;
    frag_color = color;
    frag_left_border_width = left_border_width;
    frag_right_border_width = right_border_width;
    frag_top_border_width = top_border_width;
    frag_bottom_border_width = bottom_border_width;
}
