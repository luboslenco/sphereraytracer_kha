#ifdef GL_ES
precision highp float;
#endif

attribute vec2 pos;

varying vec2 fragCoord;
const vec2 madd = vec2(0.5, 0.5);

void kore() {
	fragCoord = pos.xy * madd + madd;
	gl_Position = vec4(pos.xy, 0.0, 1.0);
}
