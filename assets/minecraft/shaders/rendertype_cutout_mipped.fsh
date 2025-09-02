#version 150 core
in vec2 vUV0;
in vec4 vColor;
uniform sampler2D Sampler0;
out vec4 fragColor;

void main() {
    vec4 tex = texture(Sampler0, vUV0);
    // subtle proof it runs: tiny green lift
    vec3 rgb = tex.rgb * vec3(0.95, 1.05, 0.95);
    fragColor = vec4(rgb, tex.a) * vColor;
}
