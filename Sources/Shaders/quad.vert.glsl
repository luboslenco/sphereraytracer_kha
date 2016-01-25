#version 450

#ifdef GL_ES
precision highp float;
#endif

in vec2 pos;

out vec2 fragCoord;

const vec2 madd = vec2(0.5, 0.5);

void main() {
	fragCoord = pos.xy * madd + madd;
	gl_Position = vec4(pos.xy, 0.0, 1.0);
}
